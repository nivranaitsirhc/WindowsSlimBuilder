# Self-elevate the script if required
# https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

# Start Script Transcript
Start-Transcript -Append $PSScriptRoot\console-$(Get-Date -Format yyyy-mm-dd_hh-mm-ss).log
$Host.UI.RawUI.WindowTitle = "Slim 11 Builder"
# $Host.UI.RawUI.WindowSize.Height = 80
# $Host.UI.RawUI.WindowSize.Width  = 50



# Init Configurations
# -------------------------------------------------------------------------------------

# Debug Parameter (Enable/Disable Debug Printing, Usefull for Printing Installed App Packages)
$DebugPreference = "SilentlyContinue"      # Disable Debug Messages
# $DebugPreference = "Continue"               # Enable Debug Messages

# Windows ISO Output File name
$ISO_Out_FileName = "Windows_Slim11.iso"

# Path to where the final ISO image will be located (default to root of script directory)
$PathToFinal_ISO_IMAGE = "$PSScriptRoot"

# Working Directory
# The path used in building the image. You can change this path to wherever you like. (SSD Drive is recommended)
$dir_root       = "C:\Slim11Builder" 
# Scratch Directory
# Path for the image mount-points. (recommended to be inside the working directory to be include at clean-up)
$dir_scratch    = "$dir_root\scratchdir"
# source directory
# Path for the extracted ISO Windows installer. (recommended to be inside the working directory to be include at clean-up)
$dir_source     = "$dir_root\source"


# Removal Configuration Files
# Configure these files to what you want to remove.

# Remove App Packages List
$Remove_Packages_ConfigFile                   = "$PSScriptRoot\remove_packages.ini"
# Remove Provisioned App Packages List
$Remove_PackagesProvisioned_ConfigFile        = "$PSScriptRoot\remove_packages_provisioned.ini"
# Remove Directory List
$Remove_Directories_ConfigFile                = "$PSScriptRoot\remove_directories.ini"
# Remove File List
$Remove_Files_ConfigFile                      = "$PSScriptRoot\remove_files.ini"


# Constant Variables (Do Not Change these values)
# Install WIM constant used in varying degrees to handle ESD/WIM image format
$image_type     = "wim"

# Flag set to include creation of bootable ISO.
$create_iso     = $true


# Add Script Path to Current Environment
$env:PATH += ";$PSScriptRoot"

# -------------------------------------------------------------------------------------
# End Init


# Function Declarations
# -------------------------------------------------------------------------------------------------------------------------------
#


# https://community.spiceworks.com/topic/664020-maximize-an-open-window-with-powershell-win7
function Set-WindowStyle {
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'SHOW',
    [Parameter()]
    $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
)
    $WindowStates = @{
        FORCEMINIMIZE   = 11; HIDE            = 0
        MAXIMIZE        = 3;  MINIMIZE        = 6
        RESTORE         = 9;  SHOW            = 5
        SHOWDEFAULT     = 10; SHOWMAXIMIZED   = 3
        SHOWMINIMIZED   = 2;  SHOWMINNOACTIVE = 7
        SHOWNA          = 8;  SHOWNOACTIVATE  = 4
        SHOWNORMAL      = 1
    }
    Write-Verbose ("Set Window Style {1} on handle {0}" -f $MainWindowHandle, $($WindowStates[$style]))

    $Win32ShowWindowAsync = Add-Type –memberDefinition @” 
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
“@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
}

# Displays Colored Text
function Write-ColorOutput(){
    Param(
        [string]$FC,
        [string]$BC,
        [Parameter(Mandatory=$true,Position=0,ValueFromRemainingArguments=$true,ValueFromPipeline=$true)]
        [string]$Message
    )
    # save the current color
    # $_FC = $Host.UI.RawUI.ForegroundColor
    if ($BC) {
        Write-Host -ForegroundColor $FC -BackgroundColor $BC $Message
    } else {
        Write-Host -ForegroundColor $FC $Message
    }
    # restore the original color
    # $Host.UI.RawUI.ForegroundColor = $_FC
}

# Copy File With Progress (Console is boring)
function Copy-FileWithProgress{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Destination,
        [string]$Activity='Copying file'
    )
    $SourceFile = [io.file]::OpenRead($Source)
    $DestinationFile = [io.file]::OpenWrite($Destination)
    Write-Progress -Activity "Copying file" -status "$Source -> $Destination" -PercentComplete 0
    try {
        [byte[]]$buff = new-object byte[] 4096
        [long]$total = [int]$count = 0
        do {
            $count = $SourceFile.Read($buff, 0, $buff.Length)
            $DestinationFile.Write($buff, 0, $count)
            $total += $count
            if ($total % 1mb -eq 0) {
                Write-Progress -Activity "$Activity" -status "$Source -> $Destination" `
                   -PercentComplete ([long]($total * 100 / $SourceFile.Length))
            }
        } while ($count -gt 0)
    }
    finally {
        $SourceFile.Dispose()
        $DestinationFile.Dispose()
        Write-Progress -Activity "$Activity" -Status "Completed" -Completed
        Write-Output "Done!"
    }
}

# Copy Directories with Progress (Console is boring)
# https://stackoverflow.com/questions/13883404/custom-robocopy-progress-bar-in-powershell
function Copy-DirWithProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Source,
        [Parameter(Mandatory = $true)]
        [string] $Destination,
        [string] $Activity = "Robocopy",
        [int] $Gap = 200,
        [int] $ReportGap = 500
    )
    # Define regular expression that will gather number of bytes copied
    $RegexBytes = '(?<=\s+)\d+(?=\s+)';

    #region Robocopy params
    # MIR = Mirror mode
    # NP  = Don't show progress percentage in log
    # NC  = Don't log file classes (existing, new file, etc.)
    # BYTES = Show file sizes in bytes
    # NJH = Do not display robocopy job header (JH)
    # NJS = Do not display robocopy job summary (JS)
    # TEE = Display log in stdout AND in target log file
    $CommonRobocopyParams = '/MIR /NP /NDL /NC /BYTES /NJH /NJS';
    #endregion Robocopy params

    #region Robocopy Staging
    Write-Verbose -Message 'Analyzing robocopy job ...';
    $StagingLogPath = '{0}\temp\{1} robocopy staging.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');

    $StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams;
    Write-Verbose -Message ('Staging arguments: {0}' -f $StagingArgumentList);
    Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow -RedirectStandardOutput "NUL"
    # Get the total number of files that will be copied
    $StagingContent = Get-Content -Path $StagingLogPath;
    $TotalFileCount = $StagingContent.Count - 1;

    # Get the total number of bytes to be copied
    [RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | ForEach-Object { $BytesTotal = 0; } { $BytesTotal += $_.Value; };
    Write-Verbose -Message ('Total bytes to be copied: {0}' -f $BytesTotal);
    #endregion Robocopy Staging

    #region Start Robocopy
    # Begin the robocopy process
    $RobocopyLogPath = '{0}\temp\{1} robocopy.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');
    $ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams;
    Write-Verbose -Message ('Beginning the robocopy process with arguments: {0}' -f $ArgumentList);
    $Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow -RedirectStandardOutput "NUL"
    Start-Sleep -Milliseconds 100;
    #endregion Start Robocopy

    #region Progress bar loop
    while (!$Robocopy.HasExited) {
        Start-Sleep -Milliseconds $ReportGap;
        $BytesCopied = 0;
        $LogContent = Get-Content -Path $RobocopyLogPath;
        $BytesCopied = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value; } -End { $BytesCopied; };
        $CopiedFileCount = $LogContent.Count - 1;
        Write-Verbose -Message ('Bytes copied: {0}' -f $BytesCopied);
        Write-Verbose -Message ('Files copied: {0}' -f $LogContent.Count);
        $Percentage = 0;
        if ($BytesCopied -gt 0) {
           $Percentage = (($BytesCopied/$BytesTotal)*100)
        }
        Write-Progress -Activity "$Activity" -Status ("Copied {0} of {1} files; Copied {2} of {3} bytes" -f $CopiedFileCount, $TotalFileCount, $BytesCopied, $BytesTotal) -PercentComplete $Percentage
    }
    #endregion Progress loop

    Write-Progress -Activity "$Activity" -Status 'Done' -Completed
    Write-Output "Done!"

    #region Function output
    [PSCustomObject]@{
        BytesCopied = $BytesCopied;
        FilesCopied = $CopiedFileCount;
    };
    #endregion Function output
}

# Remove Provisioned Packages from File List
function Remove-ProvisionedAppPackagesFromFileListList{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to provisioned app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-ProvisionedAppPackages: Config File does not exist. Returning.."
        Return
    }
    Write-ColorOutput -FC Yellow "Remove-ProvisionedAppPackages: Removing Provisioned Packages..`n"
    $appxlist = dism /image:"$Working_Directory" /Get-ProvisionedAppxPackages | Select-String -Pattern 'PackageName : ' -CaseSensitive -SimpleMatch
    $appxlist = $appxlist -split "PackageName : " | Where-Object {$_}
    Write-Debug "Displaying List of Provisioned Packages`n$appxlist`n"
    foreach ( $appx_provisioned in [System.IO.File]::ReadLines("$Config_File")) {
    	$targetappx = $appxlist | Select-String -Pattern $appx_provisioned -SimpleMatch
        if ( -not ( $targetappx) ) {
            Write-ColorOutput -FC Magenta "Remove-ProvisionedAppPackages: Not found! $appx_provisioned"
        } else {
            foreach ( $appx in $targetappx ) {
                dism /image:"$Working_Directory" /Remove-ProvisionedAppxPackage /PackageName:$appx >$null
                Write-ColorOutput -FC Green "Remove-ProvisionedAppPackages: Processed! $appx"
            }
        }
    }
    Write-ColorOutput -FC Green "Remove-ProvisionedAppPackages: Complete!`n"
}

# Remove Packages from File List
function Remove-AppPackagesFromFileListList{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-AppPackages: Config File does not exist. Returning.."
        Return
    }
    Write-ColorOutput -FC Yellow "Remove-AppPackages: Removing App Packages..`n"
    $packagelist = dism /image:"$Working_Directory" /Get-Packages /Format:List | Select-String -Pattern 'Package Identity : ' -CaseSensitive -SimpleMatch
    $packagelist = $packagelist -split "Package Identity : " | Where-Object {$_}
    Write-Debug "Displaying List of Packages`n$packagelist`n"
    foreach ( $apppackage in [System.IO.File]::ReadLines("$Config_File")) {
        $targetpackage = $packagelist | Select-String -Pattern $apppackage -SimpleMatch
        if ( -not ( $targetpackage) ) {
            Write-ColorOutput -FC Magenta "Remove-AppPackages: Not found! $apppackage"
        } else {
            foreach ( $package in $targetpackage ) {
                dism /image:"$Working_Directory" /Remove-Package /PackageName:$package >$null
                Write-ColorOutput -FC Green "Remove-AppPackages: Processed! $package"
            }
        }
    }
    Write-ColorOutput -FC Green "Remove-AppPackagesFromFileList: Complete!`n"
}

# Remove Directory
function Remove-Directories{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-Directories: Config File does not exist. Returning.."
        Return
    }
    Write-Output "Remove-Directories: Removing Directory..`n"
    foreach ( $app_dir in [System.IO.File]::ReadLines("$Config_File")) {
        if ( Test-Path -Path "$Working_Directory\$app_dir" -PathType Leaf ) {
            Write-Output "Remove-Directories: Processing `"$app_dir`""
            takeown /f "$Working_Directory\$app_dir" >$null
            icacls "$Working_Directory\$app_dir\*" /reset /Q /T /C
            Remove-Item -Recurse -Force "$Working_Directory\$app_dir"
        } else {
            Write-ColorOutput -FC Magenta "Remove-Directories: Not found! $app_dir"
        }
    }
    Write-ColorOutput -FC Green "Remove-Directories: Complete!`n"

}

# Remove File
function Remove-File{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-File: Config File does not exist. Returning.."
        Return
    }
    Write-Output "Remove-File: Removing Files..`n"
    foreach ( $app_file in [System.IO.File]::ReadLines("$Config_File")) {
        if ( Test-Path -Path "$Working_Directory\$app_file" -PathType Leaf ) {
            Write-Output "Remove-File: Processing `"$app_file`""
            takeown /f "$Working_Directory\$app_file" >$null
            icacls "$Working_Directory\$app_file" /grant Administrators:F
            Remove-Item -Force "$Working_Directory\$app_file"
        } else {
            Write-ColorOutput -FC Magenta "Remove-File: Not found! $app_file"
        }
    }
    Write-ColorOutput -FC Green "Remove-File: Complete!`n"
}

# General SubFunction to Mount and Remount Registry
function Mount-Registry{
    Param(
        # Parameter help description
        [String]$Working_Directory=''
    )
    if ($Working_Directory -ne '') {
        Write-ColorOutput -FC Yellow "Mounting Registry..."
        Write-ColorOutput -FC Green "Loading - COMPONENTS"
        Reg load HKLM\slim11COMPONENTS   "$Working_Directory\Windows\System32\config\COMPONENTS" 
        Write-ColorOutput -FC Green "Loading - DEFAULT" 
        Reg load HKLM\slim11DEFAULT      "$Working_Directory\Windows\System32\config\default"    
        Write-ColorOutput -FC Green "Loading - SOFTWARE"
        Reg load HKLM\slim11SOFTWARE     "$Working_Directory\Windows\System32\config\SOFTWARE"   
        Write-ColorOutput -FC Green "Loading - SYSTEM"
        Reg load HKLM\slim11SYSTEM       "$Working_Directory\Windows\System32\config\SYSTEM"     
        Write-ColorOutput -FC Green "Loading - USER"
        Reg load HKLM\slim11NTUSER       "$Working_Directory\Users\Default\ntuser.dat"           
    } else {
        Write-ColorOutput -FC Yellow "Un-Mounting Registry..."
        Write-ColorOutput -FC Green "Unloading - COMPONENTS"
        Reg unload HKLM\slim11COMPONENTS
        Write-ColorOutput -FC Green "Unloading - DEFAULT"
        Reg unload HKLM\slim11DEFAULT
        Write-ColorOutput -FC Green "Unloading - SOFTWARE"
        Reg unload HKLM\slim11SOFTWARE
        Write-ColorOutput -FC Green "Unloading - SYSTEM"
        Reg unload HKLM\slim11SYSTEM
        Write-ColorOutput -FC Green "Unloading - USER"
        Reg unload HKLM\slim11NTUSER
    }
    #
    Write-Output `n
}

# General SubFunction to Bypass Windows 11 Requirements; This can be impletemented in OOBE, since were already here why not implement it already.
function Set-BypassSystemRequirments{
    Write-ColorOutput -FC Green "Disable - UnsupportedHardwareNotificationCache SV1 in Default"
    Reg add "HKLM\slim11DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f 
    Write-ColorOutput -FC Green "Disable - UnsupportedHardwareNotificationCache SV2 in Default"
    Reg add "HKLM\slim11DEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Disable - UnsupportedHardwareNotificationCache SV1 in USER"
    Reg add "HKLM\slim11NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Disable - UnsupportedHardwareNotificationCache SV2 in USER"
    Reg add "HKLM\slim11NTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Enable  - BypassCPUCheck in System"
    Reg add "HKLM\slim11SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Enable  - BypassRAMCheck in System"
    Reg add "HKLM\slim11SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Enable  - BypassSecureBootCheck in System"
    Reg add "HKLM\slim11SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f 
    Write-ColorOutput -FC Green "Enable  - BypassStorageCheck in System"
    Reg add "HKLM\slim11SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Enable  - BypassTPMCheck in System"
    Reg add "HKLM\slim11SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System"
    Reg add "HKLM\slim11SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f
    # 
    Write-Output `n
}

# Function on Patching the Registry of Boot WIM
function Update-RegistryOnBootWIM{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to the mounted boot.wim")]
        [String[]]$Working_Directory
    )
    # Mount Registry
    Mount-Registry -Working_Directory $Working_Directory
    # Bypass System Requirements
    Write-ColorOutput -FC Yellow "Bypassing system requirements(on the setup image):"
    Set-BypassSystemRequirments
    # UnMount Registry
    Mount-Registry

    # Completed
    Write-ColorOutput -FC green  "Done Patching Registry!"
    Write-Output `n
}

# Function on Patching the Registry of Install WIM
function Update-RegistryOnInstallWIM{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to the mounted install.wim")]
        [String[]]$Working_Directory
    )
    # Mount Registry
    Mount-Registry -Working_Directory $Working_Directory
    
    # Bypass System Requirements
    Write-ColorOutput -FC Yellow "Bypassing system requirements(on the system image):"
    Set-BypassSystemRequirments

    # Disable Dynamic Content
    Write-ColorOutput -FC Yellow "Disabling Dynamic Content in Start-Menu:"
    Reg add "HKLM\slim11SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v  "EnableDynamicContentInWSB" /t REG_DWORD /d "0" /f
    Write-Output `n

    # Disable Teams (requires elevated permission)
    Write-ColorOutput -FC Yellow "Disabling Teams:"
    Reg add "HKLM\slim11SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f
    Write-Output `n

    # Disable Sponsored Apps
    Write-ColorOutput -FC Yellow "Disabling Sponsored Apps:"
    Write-ColorOutput -FC Green "Disable - OemPreInstalledAppsEnabled.."
    Reg add "HKLM\slim11NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Disable - PreInstalledAppsEnabled.."
    Reg add "HKLM\slim11NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Disable - SilentInstalledAppsEnabled.."
    Reg add "HKLM\slim11NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f
    Write-ColorOutput -FC Green "Enable  - DisableWindowsConsumerFeatures.."
    Reg add "HKLM\slim11SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Disable - ConfigureStartPins.."
    Reg add "HKLM\slim11SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{`"pinnedList`": [{}]}" /f
    Write-Output `n

    Write-ColorOutput -FC Yellow "Enabling Local Accounts on OOBE:"
    Write-ColorOutput -FC Green "Enable  -  BypassNRO.."
    Reg add "HKLM\slim11SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f
    Write-ColorOutput -FC Green "Copying autounattend.xml to Sysprep"
    Copy-FileWithProgress -Source "$PSScriptRoot\autounattend.xml" -Destination "$Working_Directory\Windows\System32\Sysprep\autounattend.xml" -Activity "Copying autounattend.xml to Source\Windows\System32\Sysprep\autounattend.xml"
    Write-Output `n

    Write-ColorOutput -FC Yellow "Disabling Reserved Storage:"
    Write-ColorOutput -FC Green "Disable -  ShippedWithReserves.."
    Reg add "HKLM\slim11SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f 
    Write-Output `n

    Write-ColorOutput -FC Yellow "Configuring Chat & TaskbarMn icon:"
    Write-ColorOutput -FC Green "Disable -  ChatIcon.."
    Reg add "HKLM\slim11SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f
    Write-ColorOutput -FC Green "Disable -  TaskbarMn.."
    Reg add "HKLM\slim11NTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f
    Write-Output `n
    
    Write-ColorOutput -FC Yellow "Removing One-Drive Setup.."
    Reg delete "HKU\mount\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
    Write-Output `n

    # to-do: This should be in tandem with deletion of the directories
    Write-ColorOutput -FC Yellow "Removing Microsoft Edge Remnants:"
    Reg delete "HKLM\slim11SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f
    Reg delete "HKLM\slim11SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f
    Write-Output `n

    # Un-Mount Registry
    Mount-Registry

    Write-ColorOutput -FC Green "Done Patching Registry!"
    Write-Output `n
}

function Update-EnvPath() {
    $Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")  + ";$PSScriptRoot"
}

function Get-OSCDIMG_From_Tiny11GithubRepo(){
    $URI = "https://github.com/ntdevlabs/tiny11builder/raw/main/oscdimg.exe"
    try {
        # Get OSCDIMG
        Write-ColorOutput -FC Yellow "Get OSCDIMG from ntdevlabs Github Repository.."
        Invoke-WebRequest -URI "$URI" -OutFile "$PSScriptRoot\oscdimg.exe"
        
    }
    catch {
        Write-ColorOutput -Red "Failed to download $URI"
        Write-ColorOutput -Red "$PSItem"
        return
    }
    if(Test-Path "$PSScriptRoot\oscdimg.exe" -PathType Leaf) {
        Write-ColorOutput -FC Green "Downloaded!"
        $script:create_iso = $true
    } else {
        Write-ColorOutput -FC Red "Missing downloaded file."
    }
}

function Exit-Script{
    Param(
        [string]$SkipPause=$false
    )
    Write-ColorOutput -FC White "`nGracefully Exiting.."
    Stop-Transcript
    
    if($SkipPause -ne $true) {
        Read-Host -Prompt "Please enter to close the terminal"
    }
    exit
}

function Show-Slim11Header{
    Clear-Host
    Write-Output `n`n
    Write-ColorOutput -FC Green -BC Black "Slim 11 Image Builder"
    Write-Ascii -InputObject 'Slim 11 Builder'
    Write-Output `n
    Write-ColorOutput -FC Black -BC Green "Created by NivraNaitsirhc"
    Write-Output "https://github.com/nivranaitsirhc/Slim11Builder"
    Write-Output "A Powershell rendition of tiny11builder"
    Write-Output `n`n
}

#
# End Function Declarations
# -------------------------------------------------------------------------------------------------------------------------------



# Initialization
# -------------------------------------------------------------------------------------------------------------------------------
#

# Maximed Console Window 
Set-WindowStyle MAXIMIZE

# Show Welcome Header
Show-Slim11Header

# Init Modules
# WriteAscii - Used for Creating the Graphic Console Art
if(-not (Get-Module WriteAscii -ListAvailable)){
    Install-Module WriteAscii -Scope CurrentUser -Force
}


# Check for Third-Party Non-Included Executables
# OSCDIMG 
if (-not(Get-Command "oscdimg.exe" -ErrorAction SilentlyContinue)) {
    # disable creating iso
    $create_iso = $false

    Write-ColorOutput -FC Red -BC Black "Warnning! OSCDimg is not installed!"
    Write-Output `n
    Write-ColorOutput -FC Yellow -BC Black "This script uses OSCDImg to create the bootable iso. Unfortunately it is not shipped with this script. You can download it directly from Microsoft as part of thier Windows ADK or let the script download it from ntdevlabs tiny11builder github repository @ https://github.com/ntdevlabs/tiny11builder."
    Write-Output `n
    Write-ColorOutput -FC White "Please select the options below:"
    Write-ColorOutput -FC White "1. Open Browser to Windows ADK Install Page. (Close the script afterwards.)"
    Write-ColorOutput -FC White "2. Download from ntdevlabs tiny11builder Github Repository. (Script will download the file and continue.)"
    Write-ColorOutput -FC White "3. Do not download. Manually convert it later. (Disble ISO Creation at the last step.)"
    $answer_oscdimg = Read-Host -Prompt "`nPlease Enter Option 1~3"

    Write-Output "You Selected : $answer_oscdimg"

    switch ($answer_oscdimg) {
        1 {
            Write-ColorOutput -FC Green "Opening link... https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
            Start-Process "https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install"
            Exit-Script
        }
        2 {
            Get-OSCDIMG_From_Tiny11GithubRepo
        }
        3 {
            Write-ColorOutput -FC Yellow "Disabled ISO Creation. Clean-Up will also be disabled."
            Write-ColorOutput -FC Yellow "Please output will be at $dir_source."
        }
    }
    pause
    Show-Slim11Header
}


# Create the working directory
mkdir -Path "$dir_root" -Force >$null

# Check working directory for remnants
if (-not ((Get-ChildItem "$dir_root" -force | Select-Object -First 1 | Measure-Object).Count -eq 0))
{
   Write-ColorOutput -FC Red -BC Black "Warning $dir_root is not empty. Empty this folder to avoid problems."
   Write-Output `n
   Write-ColorOutput -FC Yellow -BC Black "You can ignore this warning if you will be using the same ISO. `n`nAny image that is still mounted in the working directory will be un-mounted."
   Write-Output `n
   Write-ColorOutput -FC Yellow "Please enter `"Nuke`" to Reset the working directory or just press `"Enter`" to Continue."
   $reset_root_dir = Read-Host -Prompt "`nPlease enter your selection"
   # Need to Unmount Images Regardless..
   foreach ($item in Get-WindowsImage -Mounted) {if($item.path -imatch "slim11builder" ){$path=$($item.path.ToString());Write-Output "Unmounting $path.."; dism /Unmount-Image /MountDir:"$path" /Discard}}
   if ( $reset_root_dir -imatch 'nuke') {
        Write-Output "Clearing Working Directory.."
        # Take Ownership of $dir_scratch and reset all permissions.
        takeown /F "$dir_scratch" >$null
        icacls "$dir_scratch\*" /Q /C /T /reset >$null
        Remove-Item -Recurse -Force -Path "$dir_root" >$null
   }
   Show-Slim11Header
}
Write-Output "Mount your Windows 11/10 Image ISO and enter the `"Drive Letter`" mount point."
$driveLetter = Read-Host -Prompt "Please enter Drive Letter"
Write-Output `n
Write-Output "You Entered Drive Letter: `"$driveLetter`""
Write-Output `n

# Check Paths for Boot and Install WIM
# Boot Image Check
Write-ColorOutput -FC Yellow 'Checking Paths:'
if ( -not ( Test-Path -Path $driveLetter":\sources\boot.wim" -PathType Leaf ) ) {
    Write-ColorOutput -FC Red (
        "Can't find Windows OS Installation files in the specified Drive Letter..
        `nPlease enter the correct DVD Drive Letter.."
    )
	Exit-Script
}
Write-ColorOutput -FC Green "- Boot Image Found!"
# Install Image Check
if ( -not ( Test-Path -Path $driveLetter":\sources\install.wim" -PathType Leaf ) ) {
    if ( -not ( Test-Path -Path $driveLetter":\sources\install.esd" -PathType Leaf ) ) {
        Write-ColorOutput -FC Red (
            "Missing install wim/esd from installation drive..
            `nPlease enter the correct DVD Drive Letter.."
        )
        Exit-Script
    }
    $image_type = "esd"
}
Write-ColorOutput -FC Green "- Install Image Found!"
Write-Output `n
# End Check Paths

# Show ESD Warning
if ($image_type -eq "esd") {
    Write-ColorOutput -FC Magenta -BC Black "ESD Format detected!"
    Write-ColorOutput -FC Red -BC Black "Warning! Since ESD's are read-only. A few steps with a lot of overhead are necessary.`nThese are CPU/Memory intensive and may lag your computer specially on low-end devices."
    Write-Output `n
}

# Copy Windwos image to source directory
Write-Output "Copying Windows image... (This may take a while.)" 
Copy-DirWithProgress -Source $driveLetter":" -Destination "$dir_source" -Activity "Copying Windows Image to $dir_source"
Write-Output `n


# Get Image Information from Source
Write-Output "Getting Image information:"
$raw_index_list = Get-WindowsImage -ImagePath "$dir_source\sources\install.$image_type"
# Generate the index list
$index_list = $raw_index_list.ForEach('ImageIndex')

# Show the Image list at install.wim/esd and Select the desired Editions
Write-Output ($raw_index_list|Format-List|Out-String)
Write-ColorOutput -FC Yellow "Please select the index number of the edition you want to process or just type `"all`" to select all available editions"
Write-ColorOutput -FC Yellow "e.g. 1, 2, 4...`ne.g. all"
Write-Output `n
Write-ColorOutput -FC Red "Note: Invalid inputs are currently not validated. Please avoid erroneous input."
$indices = Read-Host -Prompt "`nPlease enter the image index number"
if ( $indices -eq '' ) {
    Write-ColorOutput -FC Red "No input detected. Exiting.."
    Exit-Script    
}
if ( $indices -imatch 'all' ) { $indices = $index_list;Write-ColorOutput -FC Magenta "You Just Selected `"All`" depending on your device and the number of images, The whole process will take a lot of time." }

# Format the Index/Indices and show formated
$indices = $indices -replace '\n','' -split ',' | Where-Object {$_}
Write-ColorOutput -FC Green "`nSelected Index/Indices : $indices"
Write-Output `n


# Remove install.wim/install.esd & boot.wim readonly flag
Write-Output "Removing Read-Only flags for the images.."
Set-ItemProperty -Path "$dir_source\sources\install.$image_type" -Name IsReadOnly -Value $false
Set-ItemProperty -Path "$dir_source\sources\boot.wim" -Name IsReadOnly -Value $false
Write-Output "Done!"
Write-Output `n

#
# End Initialization
# -------------------------------------------------------------------------------------------------------------------------------


# Main Script
# -------------------------------------------------------------------------------------------------------------------------------
#

Write-Output `n
Write-ColorOutput -FC White -BC Black "Processing Install Images:"
Write-Output `n
# Valid index flag
$valid_selection=$false
# Process Selected Index
foreach ( $selected_index in $indices ) {
    # Verify that the Index is 
    $verified_index = $index_list | Select-String -Pattern "\b$selected_index\b" -CaseSensitive

    if ($verified_index) {
        # set true
        $valid_selection=$true
    } else {
        # skip this index
        continue
    }
    # Get Edition Name
    $current_edition_name = "$($raw_index_list.GetValue($verified_index.ToString() - 1).ImageName)"

    # Mount selected index
    Write-ColorOutput -FC Black -BC White "Mounting $current_edition_name.."

    mkdir -Path "$dir_scratch\$verified_index" -Force >$null
    # When image type is esd need to export first to wim to enable modifications
    if ( $image_type -eq 'esd' ) {
        # Covert to WIM because ESD's are Read-Only
        Write-ColorOutput -FC Magenta "Extracting WIM from ESD.."
        
        # Extract to $dir_root
        if ( Test-Path -Path "$dir_root\$verified_index-install.wim" -PathType Leaf ) { Remove-Item -Path "$dir_root\$verified_index-install.wim" -Force }
        dism /Export-Image /SourceImageFile:$dir_source\sources\install.esd /SourceIndex:$verified_index /DestinationImageFile:$dir_root\$verified_index-install.wim /Compress:max /CheckIntegrity
        if ($LASTEXITCODE -ne 0) {Exit-Script}
        
        # Mount to dir_scratch at index no. from extracted index-install.wim
        dism /Mount-Image /ImageFile:$dir_root\$verified_index-install.wim /Index:1 /MountDir:$dir_scratch\$verified_index
        if ($LASTEXITCODE -ne 0) {Exit-Script}
    } else {
        # Mount to dir_scratch at index no. from souce install.wim
        dism /Mount-Image /ImageFile:$dir_source\sources\install.wim /Index:$verified_index /MountDir:$dir_scratch\$verified_index
        if ($LASTEXITCODE -ne 0 -And $LASTEXITCODE -ne -1052638937) {Write-Output "$LASTEXITCODE";Exit-Script}
    }
    Write-ColorOutput -FC Green "Mounting Complete!"
    Write-Output `n

    # Remove Provisioned Packages
    Write-ColorOutput -FC Black -BC White "Removing Provisioned Packages.."
    Remove-ProvisionedAppPackagesFromFileListList -Working_Directory "$dir_scratch\$verified_index" -Config_File "$Remove_PackagesProvisioned_ConfigFile"
    Write-Output `n
    
    # Remove Packages
    Write-ColorOutput -FC Black -BC White "Removing Packages.."
    Remove-AppPackagesFromFileListList -Working_Directory "$dir_scratch\$verified_index" -Config_File "$Remove_Packages_ConfigFile"
    Write-Output `n

    # Remove Directories
    Write-ColorOutput -FC Black -BC White "Removing Directories from Lists.."
    Remove-Directories -Working_Directory "$dir_scratch\$verified_index" -Config_File "$Remove_Directories_ConfigFile"
    Write-Output `n

    # Remove Files
    Write-ColorOutput -FC Black -BC White "Removing Files from Lists.."
    Remove-File -Working_Directory "$dir_scratch\$verified_index" -Config_File "$Remove_Files_ConfigFile"
    Write-Output `n

    # Apply Registry Configurations
    Write-ColorOutput -FC Black -BC White "Applying Registry Configs.."
    Update-RegistryOnInstallWIM -Working_Directory "$dir_scratch\$verified_index"
    Write-Output `n

    # Image - Cleanup
    Write-ColorOutput -FC Black -BC White "Cleaning Image..."
    dism /image:"$dir_scratch\$verified_index" /Cleanup-Image /StartComponentCleanup /ResetBase
    Write-Output `n

    # Image - Save and Un-mount
    Write-ColorOutput -FC Black -BC White "Commiting Changes & Un-Mounting..."
    dism /unmount-image /mountdir:"$dir_scratch\$verified_index" /commit
    Write-Output `n
    
    Write-Output `n
    Write-ColorOutput -FC Green -BC Black "Done Processing $current_edition_name!"
    Write-Output `n
}

# Check for valid selection
if (-not($valid_selection)){
    # Exit the process because no selected index were valid
    Write-ColorOutput -FC Red "Selected $indices did not match the valid index list."
    Exit-Script
}

Write-ColorOutput -FC Green "Done Patching Install Image"
Write-Output `n


# Consolidate Image(s)
Write-ColorOutput -FC White -BC Black "Consolidating Image(s) to Install.$image_type.."
Write-Output `n

# Delete old install.wim/esd in dir_root
if (Test-Path -Path "$dir_root\install.$image_type" -PathType Leaf) {
    Write-ColorOutput -FC Magenta "Removing old Install Image @ $dir_root\install.$image_type.."
    Remove-Item "$dir_root\install.$image_type"
}

$skipIndex = $false # use to skip the 1st image
$source_wim = "$dir_root\source\sources\install.wim" # default source for wim.
foreach ( $index in $indices ) {
    # Get Edition Name
    $current_edition_name = "$($raw_index_list.GetValue($index.ToString() - 1).ImageName)"
    Write-ColorOutput -FC Yellow "Merging $current_edition_name to install.$image_type.."

    # For WIM, we directly modified the install.wim at source. We just need to extract from install.wim to new install wim.
    # for ESD, we extracted to each individual wim at working directory We need to convert the 1st image to install.esd and add others if any to this new install.esd
    if ( $image_type -eq 'esd' ) {
        # update source wim to current index
        $source_wim = "$dir_root\$index-install.wim"
        if ( $skipIndex -eq $false ) {
            $skipIndex = $true
            # convert to 1st image to install.esd
            dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:1 /DestinationImageFile:$dir_root\install.esd /compress:recovery /CheckIntegrity    
            continue
        } else {
            # add to new install.esd
            dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:1 /DestinationImageFile:$dir_root\install.esd /compress:recovery /CheckIntegrity
        }
    } else {
        # add to new install.wim
        dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:$index /DestinationImageFile:$dir_root\install.wim /compress:max /CheckIntegrity
    }
}
Write-ColorOutput -FC Green "Done Consolidating Install Iamge(s)"
Write-Output `n

# Remove Original Source Image at source directory
Write-Output "Removing Original Source Image.."
Remove-Item "$dir_source\sources\install.$image_type"
# Copy the new Source Image to directory
Write-Output "Copying New Source Image.."
Copy-FileWithProgress -Source "$dir_root\install.$image_type" -Destination "$dir_source\sources\install.$image_type" -Activity "Copying new install.$image_type to souce directory"
Write-Output `n

Write-ColorOutput -FC Green "Windows Image completed."
Write-Output `n


Write-Output `n
Write-ColorOutput -FC White -BC Black "Processing Boot Image:"
Write-Output `n
mkdir -p "$dir_scratch\boot" -Force >$null

# Mount boot image @index 2
Write-ColorOutput -FC Black -BC Yellow "Mounting Boot Image.."
dism /mount-image /imagefile:$dir_source\sources\boot.wim /index:2 /mountdir:$dir_scratch\boot
Write-Output `n

# Apply Registry Configurations
Write-ColorOutput -FC Black -BC Yellow "Aplying Registry Configs.."
Update-RegistryOnBootWIM -Working_Directory "$dir_scratch\boot"
Write-Output `n

Write-ColorOutput -FC Black -BC White "Commiting Changes & Un-Mounting..."
dism /unmount-image /mountdir:$dir_scratch\boot /commit
Write-Output `n

Write-ColorOutput -FC Green "Done Patching Boot Image"
Write-Output `n



Write-Output `n
Write-ColorOutput -FC Green -BC Black "Slim11 Install & Boot Image are now completed! Finalizing other Tasks.."
Write-Output `n

# Copy Autounattend.xml to root of source directory
Write-Output "Copying Autounattend XML file to root source dir..."
Copy-FileWithProgress -Source "$PSScriptRoot\autounattend.xml"  -Destination "$dir_sources\autounattend.xml" -Activity "Copying autounattend.xml to $dir_sources"
Write-Output `n


if ($create_iso -eq $true) {
    # Generate the ISO Image
    Write-ColorOutput -FC White -BC Black "Generating ISO file..."
    Write-Output `n

    $path_to_iso_file    = "$PathToFinal_ISO_IMAGE\$ISO_Out_FileName"
    # Remove Existing Slim11 Image
    if ( Test-Path -Path "$path_to_iso_file" -PathType Leaf) {
        $new_old_iso_name = "Old__${ISO_Out_FileName}__$(Get-Date (Get-Item $path_to_iso_file | Select-Object LastWriteTime).LastWriteTime -f yyyy-mm-dd_hh-mm).iso"
        Write-ColorOutput -FC Red "Warning Image already exist @ $path_to_iso_file. It will be renamed to a suffix of $new_old_iso_name"
        Start-Sleep 5
        Rename-Item -Path "$path_to_iso_file" -NewName "$new_old_iso_name" -Force
    }

    # Generate ISO using OSCDIMG
    $boot_data="2#p0,e,b$dir_source\boot\etfsboot.com`#pEF,e,b$dir_source\efi\microsoft\boot\efisys.bin"
    oscdimg.exe -m -o -u2 -udfver102 -bootdata:"$boot_data" "$dir_source" "$path_to_iso_file"
} else {
    Write-Output "`nSkipped ISO Creation.`n"
}

Write-Output `n
Write-ColorOutput -FC Green -BC Black "Creation completed! Done!"
Write-Output `n

#
# End Main Script
# -------------------------------------------------------------------------------------------------------------------------------


if ($create_iso -eq $true){
    Write-Output `n
    Write-ColorOutput -FC Red "Cleanup Working directory? $dir_root will be purge if you continue."
    Write-Output `n
    $CleanUp = Read-Host -Prompt "Please enter `"No`" to skip clean up"
    if ($CleanUp -inotmatch "no") {
        Write-Output "Performing Cleanup..."
        Remove-Item -Recurse -Force "$dir_root"
    }
    Exit-Script -SkipPause $true
} else {
    Exit-Script
}
