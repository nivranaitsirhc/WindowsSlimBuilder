# Self-elevate the script if required
# https://blog.expta.com/2017/03/how-to-self-elevate-powershell-script.html
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

# Debug Parameter
#$DebugPreference = "SilentlyContinue"      # Disable Debug Messages
$DebugPreference = "Continue"               # Enable Debug Messages

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
function Copy-File{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$From,
        [Parameter(Mandatory=$true)]
        [string]$To,
        [string]$Activity='Copying file'
    )
    $FromFile = [io.file]::OpenRead($From)
    $ToFile = [io.file]::OpenWrite($To)
    Write-Progress -Activity "Copying file" -status "$From -> $To" -PercentComplete 0
    try {
        [byte[]]$buff = new-object byte[] 4096
        [long]$total = [int]$count = 0
        do {
            $count = $FromFile.Read($buff, 0, $buff.Length)
            $ToFile.Write($buff, 0, $count)
            $total += $count
            if ($total % 1mb -eq 0) {
                Write-Progress -Activity "$Activity" -status "$From -> $To" `
                   -PercentComplete ([long]($total * 100 / $FromFile.Length))
            }
        } while ($count -gt 0)
    }
    finally {
        $FromFile.Dispose()
        $ToFile.Dispose()
        Write-Progress -Activity "Copying file" -Status "Ready" -Completed
    }
}

# https://stackoverflow.com/questions/13883404/custom-robocopy-progress-bar-in-powershell
function Copy-WithProgress {
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
        Write-Progress -Activity $Activity -Status ("Copied {0} of {1} files; Copied {2} of {3} bytes" -f $CopiedFileCount, $TotalFileCount, $BytesCopied, $BytesTotal) -PercentComplete $Percentage
    }
    #endregion Progress loop

    Write-Progress -Activity $Activity -Status 'Done' -Completed

    #region Function output
    [PSCustomObject]@{
        BytesCopied = $BytesCopied;
        FilesCopied = $CopiedFileCount;
    };
    #endregion Function output
}


function Remove-ProvisionedAppPackagesFromFileListList{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to provisioned app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-ProvisionedAppPackages: Config File does not exist"
        Exit-Script
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

function Remove-AppPackagesFromFileListList{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    if ( -not ( Test-Path -Path "$Config_File" ) ) {
        Write-ColorOutput -FC Red "Remove-AppPackages: Config File does not exist"
        Exit-Script
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

function Remove-Directories{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    Write-Output "Remove-Directories: Removing Directory..`n"
    foreach ( $app_dir in [System.IO.File]::ReadLines("$Config_File")) {
        if ( Test-Path -Path "$Working_Directory\$app_dir" -PathType Leaf ) {
            Write-Output "Remove-Directories: Processing `"$app_dir`""
            takeown /f $Working_Directory\$app_dir
            icacls $Working_Directory\$app_dir /grant Administrators:F /T /C /inheritance:r
            Remove-Item -Recurse -Force "$Working_Directory\$app_dir"
        } else {
            Write-ColorOutput -FC Magenta "Remove-Directories: Not found! $app_dir"
        }
    }
    Write-ColorOutput -FC Green "Remove-Directories: Complete!`n"

}

function Remove-Files{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to Working Directory")]
        [String[]]$Working_Directory,
        [Parameter(Mandatory=$true,HelpMessage="Complete path to app list file")]
        [String[]]$Config_File
    )
    Write-Output "Remove-Files: Removing Files..`n"
    foreach ( $app_file in [System.IO.File]::ReadLines("$Config_File")) {
        if ( Test-Path -Path "$Working_Directory\$app_file" -PathType Leaf ) {
            Write-Output "Remove-Files: Processing `"$app_file`""
            takeown /f $Working_Directory\$app_file >$null
            icacls $Working_Directory\$app_file /grant Administrators:F /T /C /inheritance:r
            Remove-Item -Force "$Working_Directory\$app_file"
        } else {
            Write-ColorOutput -FC Magenta "Remove-Files: Not found! $app_file"
        }
    }
    Write-ColorOutput -FC Green "Remove-Files: Complete!`n"
}

function Convert-ESD2WIM{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to install.esd file")]
        [String[]]$Source_File,
        [Parameter(Mandatory=$true,HelpMessage="Complate path to install.wim destination file")]
        [String[]]$Destination_File,
        [Parameter(Mandatory=$true,HelpMessage="Index of target image to extract")]
        [Int[]]$Index
    )
    if ( -not ( Test-Path -Path "$Source_File" ) ) {
        Write-Output "Convert-ESD2WIM: Source File does not exist"
        Exit-Script
    }
    dism /Export-image /SourceImageFile:$Source_File /SourceIndex:$Index /DestinationImageFile:$Destination_File /Compress:max /CheckIntegrity
}

function Set-BypassSystemRequirments{
    Write-Output "Disabling - UnsupportedHardwareNotificationCache SV1 in Default"
    Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f 
    Write-Output "Disabling - UnsupportedHardwareNotificationCache SV2 in Default"
    Reg add "HKLM\zDEFAULT\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f 
    Write-Output "Disabling - UnsupportedHardwareNotificationCache SV1 in USER"
    Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV1" /t REG_DWORD /d "0" /f 
    Write-Output "Disabling - UnsupportedHardwareNotificationCache SV2 in USER"
    Reg add "HKLM\zNTUSER\Control Panel\UnsupportedHardwareNotificationCache" /v "SV2" /t REG_DWORD /d "0" /f 
    Write-Output "Enabling - BypassCPUCheck in System"
    Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /t REG_DWORD /d "1" /f 
    Write-Output "Enabling - BypassRAMCheck in System"
    Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f 
    Write-Output "Enabling - BypassSecureBootCheck in System"
    Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f 
    Write-Output "Enabling - BypassStorageCheck in System"
    Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /t REG_DWORD /d "1" /f 
    Write-Output "Enabling - BypassTPMCheck in System"
    Reg add "HKLM\zSYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f 
    Write-Output "Enabling - AllowUpgradesWithUnsupportedTPMOrCPU in System"
    Reg add "HKLM\zSYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" /f 
}

function Mount-Registry{
    Param(
        # Parameter help description
        [String]$Working_Directory=''
    )
    if ($Working_Directory -ne '') {
        Write-ColorOutput -FC Yellow "Loading Registry..."
        Write-Output "Loading - COMPONENTS"
        Reg load HKLM\zCOMPONENTS   "$Working_Directory\Windows\System32\config\COMPONENTS" 
        Write-Output "Loading - DEFAULT" 
        Reg load HKLM\zDEFAULT      "$Working_Directory\Windows\System32\config\default"    
        Write-Output "Loading - SOFTWARE"
        Reg load HKLM\zSOFTWARE     "$Working_Directory\Windows\System32\config\SOFTWARE"   
        Write-Output "Loading - SYSTEM"
        Reg load HKLM\zSYSTEM       "$Working_Directory\Windows\System32\config\SYSTEM"     
        Write-Output "Loading - USER"
        Reg load HKLM\zNTUSER       "$Working_Directory\Users\Default\ntuser.dat"           
    } else {
        Write-ColorOutput -FC Yellow "Unloading Registry..."
        Write-Output "Unloading - COMPONENTS"
        Reg unload HKLM\zCOMPONENTS
        Write-Output "Unloading - DEFAULT"
        Reg unload HKLM\zDEFAULT
        Write-Output "Unloading - SOFTWARE"
        Reg unload HKLM\zSOFTWARE
        Write-Output "Unloading - SYSTEM"
        Reg unload HKLM\zSYSTEM
        Write-Output "Unloading - USER"
        Reg unload HKLM\zNTUSER
    }
}

function Update-RegistryOnBootWIM{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to the mounted boot.wim")]
        [String[]]$Working_Directory
    )
    Mount-Registry -Working_Directory $Working_Directory
    Write-ColorOutput -FC Yellow "Bypassing system requirements(on the setup image):"
    Set-BypassSystemRequirments
    Mount-Registry
    Write-ColorOutput -FC green  "Tweaking complete!`n"
}

function Update-RegistryOnInstallWIM{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="Complete path to the mounted install.wim")]
        [String[]]$Working_Directory
    )

    Mount-Registry -Working_Directory $Working_Directory
    Write-ColorOutput -FC Yellow "Bypassing system requirements(on the system image):"
    Set-BypassSystemRequirments

    Write-ColorOutput -FC Yellow "Disabling Dynamic Content in Start-Menu:"
    Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\Windows Search" /v  "EnableDynamicContentInWSB" /t REG_DWORD /d "0" /f 

    Write-ColorOutput -FC Yellow "Disabling Teams:"
    Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v "ConfigureChatAutoInstall" /t REG_DWORD /d "0" /f 
    
    Write-ColorOutput -FC Yellow "Disabling Sponsored Apps:"
    Write-Output "Processing OemPreInstalledAppsEnabled.."
    Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f 
    Write-Output "Processing PreInstalledAppsEnabled.."
    Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f  
    Write-Output "Processing SilentInstalledAppsEnabled.."
    Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f  
    Write-Output "Processing DisableWindowsConsumerFeatures.."
    Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d "1" /f  
    Write-Output "Processing ConfigureStartPins.."
    Reg add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Start" /v "ConfigureStartPins" /t REG_SZ /d "{`"pinnedList`": [{}]}" /f  
    
    Write-ColorOutput -FC Yellow "Enabling Local Accounts on OOBE:"
    Write-Output "Processing BypassNRO.."
    Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f  
    Write-Output "Inserting autounattend.xml.."
    Copy-WithProgress -Source "$PSScriptRoot\autounattend.xml" -Destination "$dir_source\Windows\System32\Sysprep\autounattend.xml" -Activity "Inserting autounattend.xml"
    
    Write-ColorOutput -FC Yellow "Disabling Reserved Storage:"
    Write-Output "Processing ShippedWithReserves.."
    Reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f  
    
    Write-ColorOutput -FC Yellow "Disabling Chat icon:"
    Write-Output "Processing ChatIcon.."
    Reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d "3" /f 
    Write-Output "Processing TaskbarMn.."
    Reg add "HKLM\zNTUSER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f 

    # to-do: This should be in tandem with deletion of the directories
    Write-ColorOutput -FC Yellow "Removing Microsoft Edge Remnants:"
    Reg delete "HKLM\zSOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f
    Reg delete "HKLM\zSOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f

    Write-ColorOutput -FC Green "Tweaking complete!`n"

    Mount-Registry
}

function Exit-Script{
    Write-ColorOutput -FC White "`nGracefully Exiting.."
    Stop-Transcript
    Read-Host -Prompt "Please enter to close the terminal"
    exit
}

function Show-Slim11Header{
    Write-Output `n`n
    Write-ColorOutput -FC Green -BC Black "Slim 11 Image Builder"
    Write-Ascii -InputObject 'Slim 11 Builder'
    Write-Output `n
    Write-ColorOutput -FC Black -BC Green "Created by NivraNaitsirhc"
    Write-Output "https://github.com/nivranaitsirhc/Slim11Builder"
    Write-Output "A Powershell rendition of tiny11builder"
    Write-Output `n`n
}

# Start Script
Start-Transcript -Append $PSScriptRoot\console.log
$Host.UI.RawUI.WindowTitle = "Slim11Builder"

# Init Modules
if(-not (Get-Module WriteAscii -ListAvailable)){
    Install-Module WriteAscii -Scope CurrentUser -Force
}

# Reset Console
Clear-Host

# Init Configurations
$image_type   = "wim"
# root working directory
# Warning! Do not remove the keyword Slim11Builder in the root directory path.
$dir_root       = "C:\Slim11Builder" 
# scratch directory
$dir_scratch    = "$dir_root\scratchdir"
# source directory
$dir_source     = "$dir_root\source"

# Welcome
Show-Slim11Header

# Create working directory
mkdir -Path "$dir_root" -Force >$null

if (-not ((Get-ChildItem "$dir_root" -force | Select-Object -First 1 | Measure-Object).Count -eq 0))
{
   Write-ColorOutput -FC Red "Warning $dir_root is not empty. It is advisable to empty this folder to avoid problems."
   Write-ColorOutput -FC Red "If a Windows Image is still mounted here it will take longer to reset."
   $reset_root_dir = Read-Host -Prompt "`nPlease enter `'Nuke`' to reset the working directory or enter anything to skip"
   # Need to Unmount Images Regardless..
   foreach ($path in Get-WindowsImage -Mounted) {if($path -imatch "slim11builder" ){Dismount-WindowsIamge -Path $path -Discard}}
   if ( $reset_root_dir -imatch 'nuke') {
        Write-Output "Clearing Working Directory.."
        takeown /f "$dir_root"
        icacls "$dir_root" /grant Administrators:F /T /C
        Remove-Item -Recurse -Force -Path "$dir_root"
   }
   Clear-Host
   Show-Slim11Header
}

$driveLetter = Read-Host -Prompt "Please enter the `"Drive Letter`" for the mounted Windows 11 Image"
Write-Output `n

Write-ColorOutput -FC Yellow 'Checking Paths:'
if ( -not ( Test-Path -Path $driveLetter":\sources\boot.wim" -PathType Leaf ) ) {
    Write-ColorOutput -FC Red (
        "Can't find Windows OS Installation files in the specified Drive Letter..
        `nPlease enter the correct DVD Drive Letter.."
    )
	Exit-Script
}
Write-ColorOutput -FC Green "Boot Image Found!"

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
Write-ColorOutput -FC Green "Install Image Found!"
Write-Output `n

# Show Warning How ESD is process.
if ($image_type -eq "esd") {
    Write-ColorOutput -FC Magenta "ESD Format detected!"
    Write-ColorOutput -FC Red -BC Black "Warning! Since ESD are read-only. A few steps with a lot of overhead are necessary. These are cpu intensive an my lag your computer on low-end devices."
}

# Copy Windwos image to source directory
Write-Output "Copying Windows image... (This may take a while.)"
# xcopy.exe /E /I /H /R /Y /J $driveLetter":" $dir_source 
Copy-WithProgress -Source $driveLetter":" -Destination "$dir_source" -Activity "Copying Windows Image to $dir_source"
# Start-Sleep -Seconds 3

Write-Output "Getting Image information:"
# Get the Whole WIM Index
# $raw_index_list = dism /Get-WimInfo /wimfile:$dir_source\sources\install.$image_type
$raw_index_list = Get-WindowsImage -ImagePath "$dir_source\sources\install.$image_type"
# Generate the index list
# $index_list = $raw_index_list | Select-String -Pattern 'Index : ' -SimpleMatch
# $index_list = $index_list -split 'Index : ' | Where-Object {$_}
$index_list = $raw_index_list.ForEach('ImageIndex')


Write-Output ($raw_index_list|Format-List|Out-String)
Write-ColorOutput -FC Yellow "Please select the index number of the edition you want to convert or just type `"all`""
Write-ColorOutput -FC Yellow "e.g. 1, 2, 4`ne.g. all"
Write-ColorOutput -FC Red "Note: Invalid inputs are currently not validated. Please avoid erroneous input."
$indices = Read-Host -Prompt "`nPlease enter the image index number"
if ( $indices -eq '' ) {
    Write-ColorOutput -FC Red "No input detected. Exiting.."
    Exit-Script    
}
if ( $indices -imatch 'all' ) { $indices = $index_list;Write-ColorOutput -FC Magenta "You Just Selected `"All`" depending on your device and the number of images, The whole process will take a lot of time." }

# Cleanup selection
$indices = $indices -replace '\n','' -split ',' | Where-Object {$_}
Write-ColorOutput -FC Green "`nSelected Index/Indices : $indices`n"


# Remove install.wim/install.esd & boot.wim readonly flag
Write-Output "Removing Read-Only flags for images.."
Set-ItemProperty -Path "$dir_source\sources\install.$image_type" -Name IsReadOnly -Value $false
Set-ItemProperty -Path "$dir_source\sources\boot.wim" -Name IsReadOnly -Value $false
Write-Output `n

Write-Output `n
Write-ColorOutput -FC White -BC Black "Processing Install Images:"
Write-Output `n
foreach ( $selected_index in $indices ) {
    $verified_index = $index_list | Select-String -Pattern "\b$selected_index\b" -CaseSensitive

    if ( $verified_index ) {
        Write-ColorOutput -FC Black -BC White "Mounting $($raw_index_list.GetValue($verified_index.ToString() - 1).ImageName).."
        mkdir -Path "$dir_scratch\$verified_index" -Force >$null
        if ( $image_type -eq 'esd' ) {
            # Covert to WIM because ESD is Read-Only
            Write-ColorOutput -FC Magenta "Extracting WIM from ESD.."
            # Extract to $dir_root
            if ( Test-Path -Path "$dir_root\$verified_index-install.wim" -PathType Leaf ) { Remove-Item -Path "$dir_root\$verified_index-install.wim" -Force }
            dism /Export-Image /SourceImageFile:$dir_source\sources\install.esd /SourceIndex:$verified_index /DestinationImageFile:$dir_root\$verified_index-install.wim /Compress:max /CheckIntegrity
            if ($LASTEXITCODE -ne 0) {Exit-Script}
            # Mount to dir_scratch
            dism /Mount-Image /ImageFile:$dir_root\$verified_index-install.wim /Index:1 /MountDir:$dir_scratch\$verified_index
            if ($LASTEXITCODE -ne 0) {Exit-Script}
        } else {
            # Mount to dir_scratch
            dism /Mount-Image /ImageFile:$dir_source\sources\install.wim /Index:$verified_index /MountDir:$dir_scratch\$verified_index
            if ($LASTEXITCODE -ne 0 -And $LASTEXITCODE -ne -1052638937) {Write-Output "$LASTEXITCODE";Exit-Script}
        }
        Write-ColorOutput -FC Green "Mounting Complete!`n"

        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Removing Provisioned Packages.."
        Remove-ProvisionedAppPackagesFromFileListList -Working_Directory "$dir_scratch\$verified_index" -Config_File "$PSScriptRoot\remove_packages_provisioned.txt"
        #Start-Sleep -Seconds 1
        
        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Removing Packages.."
        Remove-AppPackagesFromFileListList -Working_Directory "$dir_scratch\$verified_index" -Config_File "$PSScriptRoot\remove_packages.txt"
        #Start-Sleep -Seconds 1

        
        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Removing Applicaiton Directories.."
        Remove-Directories -Working_Directory "$dir_scratch\$verified_index" -Config_File "$PSScriptRoot\remove_appdirectories.txt"
        #Start-Sleep -Seconds 1

        
        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Removing Applicaiton Files.."
        Remove-Files -Working_Directory "$dir_scratch\$verified_index" -Config_File "$PSScriptRoot\remove_appfiles.txt"
        #Start-Sleep -Seconds 1

        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Aplying Registry Configs.."
        Update-RegistryOnInstallWIM -Working_Directory "$dir_scratch\$verified_index"
        #Start-Sleep -Seconds 1

        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Cleaning Image..."
        dism /image:"$dir_scratch\$verified_index" /Cleanup-Image /StartComponentCleanup /ResetBase

        Write-Output `n
        Write-ColorOutput -FC Black -BC White "Unmounting Image & Commiting Changes..."
        dism /unmount-image /mountdir:"$dir_scratch\$verified_index" /commit

        # Write-Output `n
        # Write-ColorOutput -FC Black -BC White "Exporting Image..."
        # if ( $image_type -eq 'esd' ) {
        #     Write-Output "Converting Image WIM back to ESD.."
        #     dism /Export-Image /SourceImageFile:$dir_root\$verified_index-install.wim /SourceIndex:1 /DestinationImageFile:$dir_root\$verified_index-install.esd /compress:recovery
        # } else {
        #     Write-Output "Extracting Image from Source Install.wim to ESD.."
        #     dism /Export-Image /SourceImageFile:$dir_source\sources\install.wim /SourceIndex:$verified_index /DestinationImageFile:$dir_root\$verified_index-install.esd /compress:recovery
        # }

        
        Write-Output `n
        Write-ColorOutput -FC Green "Completed for Index:$verified_index!"
        Write-Output `n
    }
}
Write-ColorOutput -FC Green "Done Patching Install Image`n"


Write-ColorOutput -FC White -BC Black "Consolidating Images into one Image File:"
# Merge All Images to the First Image
$skipIndex = $false
$source_wim = "$dir_root\source\sources\install.wim"
foreach ( $index in $indices ) {
    # If Image is ESD the files are in root_dir with format $index-install.wim
    # If Image is WIM the files are in root_dir\source\sources\install.wim
    # For ESD, convert the 1st index to ESD and export the rest of wim to 1st
    # For WIM, export the 1st index to ESD and export the rest of wim to 1st

    if ( $image_type -eq 'esd' ) {
        $source_wim = "$dir_root\$index-install.wim"
        Write-Output "Merging $source_wim to install.esd.."
        if ( $skipIndex -eq $false ) {
            $skipIndex = $true
            # convert to ESD
            dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:1 /DestinationImageFile:$dir_root\install.esd /compress:recovery /CheckIntegrity    
            continue
        } else {
            # add to ESD
            dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:1 /DestinationImageFile:$dir_root\install.esd /compress:recovery /CheckIntegrity
        }
    } else {
        Write-Output "Merging $source_wim to install.wim"
        dism /Export-Image /SourceImageFile:$source_wim /SourceIndex:$index /DestinationImageFile:$dir_root\install.wim /compress:max /CheckIntegrity
    }
}

Write-Output "Removing Original Source Image.."
Remove-Item "$dir_source\sources\install.$image_type"
Write-Output "Inserting New Source Image.."
Copy-WithProgress -Source "$dir_root\install.$image_type" -Destination "$dir_source\sources\install.$image_type" -Activity "Copying new install.$image_type to souce directory"
Write-Output "Windows image completed. Continuing with boot.wim."

Write-Output `n
Write-ColorOutput -FC White -BC Black "Processing Boot Image:"
Write-Output `n
mkdir -p "$dir_scratch\boot" -Force >$null
dism /mount-image /imagefile:$dir_source\sources\boot.wim /index:2 /mountdir:$dir_scratch\boot

Write-Output `n
Write-ColorOutput -FC Yellow -BC Black "Aplying Registry Configs.."
Update-RegistryOnBootWIM -Working_Directory "$dir_scratch\boot"

Write-Output "Unmounting Boot image..."
dism /unmount-image /mountdir:$dir_scratch\boot /commit

Write-ColorOutput -FC Green "Done Patching Boot Image!"

# Compile ISO
Write-Output `n
Write-ColorOutput -FC Green -BC Black "Slim11 Image is now completed! Finalizing Sources.."
Write-Output `n

Write-Output "Copying unattended xml file for bypassing MS account on OOBE..."
Copy-WithProgress -Source "$PSScriptRoot\autounattend.xml"  -Destination "$dir_sources\autounattend.xml"

Write-Output `n
Write-ColorOutput -FC White -BC Black "Generating ISO file..."
if ( Test-Path -Path "$PSScriptRoot\Windows_Slim11.iso" -PathType Leaf) {Remove-Item -Path "$PSScriptRoot\Windows_Slim11.iso" -Force}
# $boot_data="2#p0,e,b$dir_source\boot\etfsboot.com#pEF,e,b$dir_source\efi\microsoft\boot\efisys.bin $dir_source $PSScriptRoot\Slim11.iso"
# & "$PSScriptRoot\oscdimg.exe" -m -o -u2 -udfver102 -bootdata:$boot_data
& "$PSScriptRoot\oscdimg.exe" -m -o -u2 -udfver102 -bootdata:2`#p0,e,b$dir_source\boot\etfsboot.com`#pEF,e,b$dir_source\efi\microsoft\boot\efisys.bin $dir_source $PSScriptRoot\Windows_Slim11.iso

Write-Output `n
Write-ColorOutput -FC Green -BC Black "Creation completed!"

Write-Output `n
Write-ColorOutput -FC Red "Working directory $dir_root will be purge if you continue."
$CleanUp = Read-Host -Prompt "Please enter `"No`" to skip clean up"

if ($CleanUp -inotmatch "no") {
    Write-Output "Performing Cleanup..."
    Remove-Item -Recurse -Force "$dir_root"
}

Exit-Script