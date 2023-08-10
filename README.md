# Slim11Builder
A Customizable Powershell Script to build a trimmed-down Windows 11 image.

## Features:
- Supports Windows 11 / 10 <sup>*A*</sup>
- Supports multiple Windows Edition into a single ISO.
- Customize what to remove thru from config file. (Provisioned Packages, App Packages, Files/Whole Directories)
- Save Console Output into file.

*<sup>A</sup> <sub>(This script is intended for Windows 11 but you can use this for Windows 10. Just update the ```remove_packages.ini```/```remove_packages_provisioned.ini``` files and add any missing bloat package name for Windows 10)</sub>*


## Requirements
- Windows <strong>10/11</strong>
- Windows Powershell *( ≥ <strong>5.1</strong> )*

### Optional
- OSCDImg executable.<sup>*B*</sup>
- SetACL (Not Yet Implemented).<sup>*B*</sup>

*<sup>B</sup> <sub>(Defined in $PATH or at the same root directory of this script)</sub>*

## Remove Bloatware List Configuration Files
- <strong>remove_packages_provisioned.ini</strong>
  - Provisioned App Packages that will be removed
  <br>*(partial app name is recommended)*
- <strong>remove_packages.ini</strong>
  - Normal App Packages that will be removed
  <br>*(partial app name is recommended)*
- <strong>remove_directories.ini</strong>
  - Directories to be removed
  <br>*(Full Directory Path is recommended)*
    - e.g. Program Files\Microsoft Edge
- <strong>remove_files.ini</strong>
  - Files to be removed
  <br>*(Full File Path is recommended)*
    - e.g. Windows\System32\Drivers\etc\hosts.exe


## How to use
Check and download the latest release zip and unzip it into a directory in your local machine.

Run the ```Slim11Builder.ps1``` file and follow the console instructions.

## Warranty
This script is provided as-is without warranty.

## Support
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")


## Credits & Thanks
* [Tiny11 Builder](https://github.com/ntdevlabs/tiny11builder)

## Sample Terminal Output
```
Slim 11 Image Builder
      _  _                _  _     _             _  _      _
 ___ | |(_) _ __ ___     / |/ |   | |__   _   _ (_)| |  __| |  ___  _ __
/ __|| || || '_ ` _ \    | || |   | '_ \ | | | || || | / _` | / _ \| '__|
\__ \| || || | | | | |   | || |   | |_) || |_| || || || (_| ||  __/| |
|___/|_||_||_| |_| |_|   |_||_|   |_.__/  \__,_||_||_| \__,_| \___||_|

Created by NivraNaitsirhc
https://github.com/nivranaitsirhc/Slim11Builder
A Powershell rendition of tiny11builder

Mount your Windows 11/10 Image ISO and enter the "Drive Letter" mount point.

You Entered Drive Letter: "E"

Checking Paths:
- Boot Image Found!
- Install Image Found!

Copying Windows image... (This may take a while.)
Done!

BytesCopied FilesCopied
----------- -----------
 5565239043           2

Getting Image information:


ImageIndex       : 1
ImageName        : Windows 11 Home
ImageDescription : Windows 11 Home
ImageSize        : 16,452,996,820 bytes

ImageIndex       : 2
ImageName        : Windows 11 Home N
ImageDescription : Windows 11 Home N
ImageSize        : 15,784,152,377 bytes

ImageIndex       : 3
ImageName        : Windows 11 Home Single Language
ImageDescription : Windows 11 Home Single Language
ImageSize        : 16,454,994,553 bytes

ImageIndex       : 4
ImageName        : Windows 11 Education
ImageDescription : Windows 11 Education
ImageSize        : 16,735,779,598 bytes

ImageIndex       : 5
ImageName        : Windows 11 Education N
ImageDescription : Windows 11 Education N
ImageSize        : 16,052,156,243 bytes

ImageIndex       : 6
ImageName        : Windows 11 Pro
ImageDescription : Windows 11 Pro
ImageSize        : 16,733,566,482 bytes

ImageIndex       : 7
ImageName        : Windows 11 Pro N
ImageDescription : Windows 11 Pro N
ImageSize        : 16,066,184,230 bytes

ImageIndex       : 8
ImageName        : Windows 11 Pro Education
ImageDescription : Windows 11 Pro Education
ImageSize        : 16,735,729,808 bytes

ImageIndex       : 9
ImageName        : Windows 11 Pro Education N
ImageDescription : Windows 11 Pro Education N
ImageSize        : 16,052,105,553 bytes

ImageIndex       : 10
ImageName        : Windows 11 Pro for Workstations
ImageDescription : Windows 11 Pro for Workstations
ImageSize        : 16,735,754,703 bytes

ImageIndex       : 11
ImageName        : Windows 11 Pro N for Workstations
ImageDescription : Windows 11 Pro N for Workstations
ImageSize        : 16,052,130,898 bytes
Please select the index number of the edition you want to process or just type "all" to select all available editions
e.g. 1, 2, 4...
e.g. all

Note: Invalid inputs are currently not validated. Please avoid erroneous input.

Selected Index/Indices : 1

Removing Read-Only flags for the images..
Done!


Processing Install Images:

Mounting Windows 11 Home..

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Mounting image
[==========================100.0%==========================]
The operation completed successfully.
Mounting Complete!

Removing Provisioned Packages..
Remove-ProvisionedAppPackages: Removing Provisioned Packages..
Remove-ProvisionedAppPackages: Processed! Clipchamp.Clipchamp_2.2.8.0_neutral_~_yxz26nhyzhsrt
Remove-ProvisionedAppPackages: Processed! Microsoft.BingNews_4.2.27001.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.BingWeather_4.53.33420.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.GamingApp_2021.427.138.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.GetHelp_10.2201.421.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.Getstarted_2021.2204.1.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.MicrosoftOfficeHub_18.2204.1141.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.MicrosoftSolitaireCollection_4.12.3171.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.People_2020.901.1724.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.PowerAutomateDesktop_10.0.3735.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.Todos_2.54.42772.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsAlarms_2022.2202.24.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! microsoft.windowscommunicationsapps_16005.14326.20544.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsFeedbackHub_2022.106.2230.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsMaps_2022.2202.6.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsSoundRecorder_2021.2103.28.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.Xbox.TCUI_1.23.28004.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxGamingOverlay_2.622.3232.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxGameOverlay_1.47.2385.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxSpeechToTextOverlay_1.17.29001.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.YourPhone_1.22022.147.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.ZuneMusic_11.2202.46.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.ZuneVideo_2019.22020.10021.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! MicrosoftCorporationII.MicrosoftFamily_0.1.28.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! MicrosoftCorporationII.QuickAssist_2022.414.1758.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.549981C3F5F10_3.2204.14815.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Complete!

Removing Packages..
Remove-AppPackages: Removing App Packages..
Remove-AppPackages: Processed! Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~en-GB~11.0.22621.1
Remove-AppPackages: Processed! Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~~11.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-Kernel-LA57-FoD-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-Handwriting-en-gb-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-OCR-en-gb-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-Speech-en-gb-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-TextToSpeech-en-gb-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-MediaPlayer-Package~31bf3856ad364e35~amd64~en-GB~10.0.22621.1635
Remove-AppPackages: Processed! Microsoft-Windows-MediaPlayer-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-MediaPlayer-Package~31bf3856ad364e35~wow64~en-GB~10.0.22621.1
Remove-AppPackages: Processed! Microsoft-Windows-MediaPlayer-Package~31bf3856ad364e35~wow64~~10.0.22621.1
Remove-AppPackages: Processed! Microsoft-Windows-TabletPCMath-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackages: Processed! Microsoft-Windows-Wallpaper-Content-Extended-FoD-Package~31bf3856ad364e35~amd64~~10.0.22621.1702
Remove-AppPackagesFromFileList: Complete!

Removing Directories from Lists..
Remove-Directories: Removing Directory..
Remove-Directories: Not found! Program Files (x86)\Microsoft\Edge
Remove-Directories: Not found! Program Files (x86)\Microsoft\EdgeUpdate
Remove-Directories: Complete!

Removing Files from Lists..
Remove-File: Removing Files..
Remove-File: Processing "Windows\System32\OneDriveSetup.exe"
processed file: C:\Slim11Builder\scratchdir\1\Windows\System32\OneDriveSetup.exe
Successfully processed 1 files; Failed processing 0 files
Remove-File: Complete!

Applying Registry Configs..
Mounting Registry...
Loading - COMPONENTS
The operation completed successfully.
Loading - DEFAULT
The operation completed successfully.
Loading - SOFTWARE
The operation completed successfully.
Loading - SYSTEM
The operation completed successfully.
Loading - USER
The operation completed successfully.

Bypassing system requirements(on the system image):
Disable - UnsupportedHardwareNotificationCache SV1 in Default
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV2 in Default
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV1 in USER
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV2 in USER
The operation completed successfully.
Enable  - BypassCPUCheck in System
The operation completed successfully.
Enable  - BypassRAMCheck in System
The operation completed successfully.
Enable  - BypassSecureBootCheck in System
The operation completed successfully.
Enable  - BypassStorageCheck in System
The operation completed successfully.
Enable  - BypassTPMCheck in System
The operation completed successfully.
Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System
The operation completed successfully.

Disabling Dynamic Content in Start-Menu:
The operation completed successfully.

Disabling Teams:
ERROR: Access is denied.

Disabling Sponsored Apps:
Disable - OemPreInstalledAppsEnabled..
The operation completed successfully.
Disable - PreInstalledAppsEnabled..
The operation completed successfully.
Disable - SilentInstalledAppsEnabled..
The operation completed successfully.
Enable  - DisableWindowsConsumerFeatures..
The operation completed successfully.
Disable - ConfigureStartPins..
The operation completed successfully.

Enabling Local Accounts on OOBE:
Enable  -  BypassNRO..
The operation completed successfully.
Copying autounattend.xml to Sysprep
Done!

Disabling Reserved Storage:
Disable -  ShippedWithReserves..
The operation completed successfully.

Configuring Chat & TaskbarMn icon:
Disable -  ChatIcon..
The operation completed successfully.
Disable -  TaskbarMn..
The operation completed successfully.

Removing One-Drive Setup..
ERROR: The system was unable to find the specified registry key or value.

Removing Microsoft Edge Remnants:
The operation completed successfully.
The operation completed successfully.

Un-Mounting Registry...
Unloading - COMPONENTS
The operation completed successfully.
Unloading - DEFAULT
The operation completed successfully.
Unloading - SOFTWARE
The operation completed successfully.
Unloading - SYSTEM
The operation completed successfully.
Unloading - USER
The operation completed successfully.

Done Patching Registry!


Cleaning Image...

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Image Version: 10.0.22621.1702

[==========================100.0%==========================]
The operation completed successfully.

Commiting Changes & Un-Mounting...

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Saving image
[==========================100.0%==========================]
Unmounting image
[==========================100.0%==========================]
The operation completed successfully.


Done Processing Windows 11 Home!

Done Patching Install Image

Consolidating Image(s) to Install.wim..

Removing old Install Image @ C:\Slim11Builder\install.wim..
Merging Windows 11 Home to install.wim..

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Exporting image
[==========================100.0%==========================]
The operation completed successfully.
Done Consolidating Install Iamge(s)

Removing Original Source Image..
Copying New Source Image..
Done!

Windows Image completed.


Processing Boot Image:

Mounting Boot Image..

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Mounting image
[==========================100.0%==========================]
The operation completed successfully.

Aplying Registry Configs..
Mounting Registry...
Loading - COMPONENTS
The operation completed successfully.
Loading - DEFAULT
The operation completed successfully.
Loading - SOFTWARE
The operation completed successfully.
Loading - SYSTEM
The operation completed successfully.
Loading - USER
The operation completed successfully.

Bypassing system requirements(on the setup image):
Disable - UnsupportedHardwareNotificationCache SV1 in Default
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV2 in Default
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV1 in USER
The operation completed successfully.
Disable - UnsupportedHardwareNotificationCache SV2 in USER
The operation completed successfully.
Enable  - BypassCPUCheck in System
The operation completed successfully.
Enable  - BypassRAMCheck in System
The operation completed successfully.
Enable  - BypassSecureBootCheck in System
The operation completed successfully.
Enable  - BypassStorageCheck in System
The operation completed successfully.
Enable  - BypassTPMCheck in System
The operation completed successfully.
Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System
The operation completed successfully.

Un-Mounting Registry...
Unloading - COMPONENTS
The operation completed successfully.
Unloading - DEFAULT
The operation completed successfully.
Unloading - SOFTWARE
The operation completed successfully.
Unloading - SYSTEM
The operation completed successfully.
Unloading - USER
The operation completed successfully.

Done Patching Registry!


Commiting Changes & Un-Mounting...

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Saving image
[==========================100.0%==========================]
Unmounting image
[==========================100.0%==========================]
The operation completed successfully.

Done Patching Boot Image


Slim11 Install & Boot Image are now completed! Finalizing other Tasks..

Copying Autounattend XML file to root source dir...
Done!

Generating ISO file...

Warning Image already exist @ D:\Slim11Builder\Windows_Slim11.iso. It will be renamed to Windows_Slim11.iso__2023-19-05_11-19.iso

OSCDIMG 2.56 CD-ROM and DVD-ROM Premastering Utility
Copyright (C) Microsoft, 1993-2012. All rights reserved.
Licensed only for producing Microsoft authorized content.


Scanning source tree (500 files in 43 directories)
Scanning source tree complete (944 files in 86 directories)

Computing directory information complete

Image file is 4967333888 bytes (before optimization)

Writing 944 files in 86 directories to D:\Slim11Builder\Windows_Slim11.iso

100% complete

Storage optimization saved 4 files, 24576 bytes (0% of image)

After optimization, image file is 4969424896 bytes
Space saved because of embedding, sparseness or optimization = 24576

Done.

Creation completed! Done!
```
