# Windows Slim Builder
A Customizable Powershell Script to build a trimmed-down Windows 11/10 image.

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

Run the ```WinSlimBuilder.ps1``` file and follow the console instructions.

## Warranty
This script is provided as-is without warranty.

## Support
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")


## Credits & Thanks
* [Tiny11 Builder](https://github.com/ntdevlabs/tiny11builder)

## Sample Terminal Output
```
Windows Slim Image Builder
      _  _                _             _  _      _
 ___ | |(_) _ __ ___     | |__   _   _ (_)| |  __| |  ___  _ __
/ __|| || || '_ ` _ \    | '_ \ | | | || || | / _` | / _ \| '__|
\__ \| || || | | | | |   | |_) || |_| || || || (_| ||  __/| |
|___/|_||_||_| |_| |_|   |_.__/  \__,_||_||_| \__,_| \___||_|

Created by NivraNaitsirhc
https://github.com/nivranaitsirhc/WindowsSlimBuilder

Mount your Windows 11/10 Image ISO and enter the mount point "Drive Letter".

You Entered the Drive Letter: "F"

Checking Paths:
- Boot Image Found!
- Install Image Found!

Copying Windows image... (This may take a while.)
Done!

BytesCopied FilesCopied
----------- -----------
 6107762189         905

Getting Image information:


ImageIndex       : 1
ImageName        : Windows 11 Home
ImageDescription : Windows 11 Home
ImageSize        : 15,062,194,917 bytes

ImageIndex       : 2
ImageName        : Windows 11 Home N
ImageDescription : Windows 11 Home N
ImageSize        : 14,288,258,984 bytes

ImageIndex       : 3
ImageName        : Windows 11 Home Single Language
ImageDescription : Windows 11 Home Single Language
ImageSize        : 15,064,973,190 bytes

ImageIndex       : 4
ImageName        : Windows 11 Education
ImageDescription : Windows 11 Education
ImageSize        : 15,402,415,508 bytes

ImageIndex       : 5
ImageName        : Windows 11 Education N
ImageDescription : Windows 11 Education N
ImageSize        : 14,619,090,923 bytes

ImageIndex       : 6
ImageName        : Windows 11 Pro
ImageDescription : Windows 11 Pro
ImageSize        : 15,399,402,687 bytes

ImageIndex       : 7
ImageName        : Windows 11 Pro N
ImageDescription : Windows 11 Pro N
ImageSize        : 14,632,342,431 bytes

ImageIndex       : 8
ImageName        : Windows 11 Pro Education
ImageDescription : Windows 11 Pro Education
ImageSize        : 15,402,353,926 bytes

ImageIndex       : 9
ImageName        : Windows 11 Pro Education N
ImageDescription : Windows 11 Pro Education N
ImageSize        : 14,619,028,441 bytes

ImageIndex       : 10
ImageName        : Windows 11 Pro for Workstations
ImageDescription : Windows 11 Pro for Workstations
ImageSize        : 15,402,384,717 bytes

ImageIndex       : 11
ImageName        : Windows 11 Pro N for Workstations
ImageDescription : Windows 11 Pro N for Workstations
ImageSize        : 14,619,059,682 bytes

Please select the Index Number(s) of the edition(s) you want to process or type "All" to select all the available editions
e.g. 1, 4, 6.. -> (Windows 11 Home, Windows 11 Education, Windows 11 Pro etc..)
e.g. 6         -> (Windows 11 Pro Only)
e.g. all       -> (All available Editions)

Note: For Multiple selections please use a comma ","

Selected Index/Indices : 6

Removing Read-Only flags for the images..
Done!


Processing Install Images:

Mounting Windows 11 Pro..

Deployment Image Servicing and Management tool
Version: 10.0.19041.844

Mounting image
[==========================100.0%==========================]
The operation completed successfully.
Mounting Complete!

Removing Provisioned Packages..
Remove-ProvisionedAppPackages: Removing Provisioned Packages..
Remove-ProvisionedAppPackages: Not found! Clipchamp.Clipchamp
Remove-ProvisionedAppPackages: Not found! Microsoft.BingNews
Remove-ProvisionedAppPackages: Processed! Microsoft.BingWeather_4.25.20211.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Not found! Microsoft.GamingApp
Remove-ProvisionedAppPackages: Processed! Microsoft.GetHelp_10.1706.13331.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.Getstarted_8.2.22942.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.MicrosoftOfficeHub_18.1903.1152.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.MicrosoftSolitaireCollection_4.4.8204.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.People_2019.305.632.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Not found! Microsoft.PowerAutomateDesktop
Remove-ProvisionedAppPackages: Not found! Microsoft.Todos
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsAlarms_2019.807.41.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! microsoft.windowscommunicationsapps_16005.11629.20316.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsFeedbackHub_2019.1111.2029.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsMaps_2019.716.2316.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.WindowsSoundRecorder_2019.716.2313.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.Xbox.TCUI_1.23.28002.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxGamingOverlay_2.34.28001.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxGameOverlay_1.46.11001.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.XboxSpeechToTextOverlay_1.17.29001.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.YourPhone_2019.430.2026.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.ZuneMusic_2019.19071.19011.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Processed! Microsoft.ZuneVideo_2019.19071.19011.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Not found! MicrosoftCorporationII.MicrosoftFamily
Remove-ProvisionedAppPackages: Not found! MicrosoftCorporationII.QuickAssist
Remove-ProvisionedAppPackages: Processed! Microsoft.549981C3F5F10_1.1911.21713.0_neutral_~_8wekyb3d8bbwe
Remove-ProvisionedAppPackages: Complete!

Removing Packages..
Remove-AppPackages: Removing App Packages..
Remove-AppPackages: Processed! Microsoft-Windows-InternetExplorer-Optional-Package~31bf3856ad364e35~amd64~~11.0.19041.1566
Remove-AppPackages: Not found! Microsoft-Windows-Kernel-LA57-FoD-Package
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-Handwriting-en-gb-Package~31bf3856ad364e35~amd64~~10.0.19041.1
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-OCR-en-gb-Package~31bf3856ad364e35~amd64~~10.0.19041.1
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-Speech-en-gb-Package~31bf3856ad364e35~amd64~~10.0.19041.1
Remove-AppPackages: Processed! Microsoft-Windows-LanguageFeatures-TextToSpeech-en-gb-Package~31bf3856ad364e35~amd64~~10.0.19041.1
Remove-AppPackages: Processed! Microsoft-Windows-MediaPlayer-Package~31bf3856ad364e35~amd64~~10.0.19041.2006
Remove-AppPackages: Processed! Microsoft-Windows-TabletPCMath-Package~31bf3856ad364e35~amd64~~10.0.19041.1865
Remove-AppPackages: Not found! Microsoft-Windows-Wallpaper-Content-Extended-FoD-Package
Remove-AppPackagesFromFileList: Complete!

Removing Directories from Lists..
Remove-Directories: Removing Directory..
Remove-Directories: Not found! Program Files (x86)\Microsoft\Edge
Remove-Directories: Not found! Program Files (x86)\Microsoft\EdgeUpdate
Remove-Directories: Complete!

Removing Files from Lists..
Remove-File: Removing Files..
Remove-File: Not found! Windows\System32\OneDriveSetup.exe
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

Bypassing system requirements (Install Image):
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
The operation completed successfully.

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

Image Version: 10.0.19045.2006

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


Done Processing Windows 11 Pro!

Done Patching Install Image

Consolidating Image(s) to Install.wim..


Adding Windows 10 Pro to install.wim..

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

Bypassing system requirements (Boot Image):
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


Windows Slim Install & Boot Image are now complete! Finalizing other Tasks..

Copying Autounattend XML file to root source dir...
Done!

Generating ISO file...


OSCDIMG 2.56 CD-ROM and DVD-ROM Premastering Utility
Copyright (C) Microsoft, 1993-2012. All rights reserved.
Licensed only for producing Microsoft authorized content.


Scanning source tree (500 files in 41 directories)
Scanning source tree complete (905 files in 86 directories)

Computing directory information complete

Image file is 5191270400 bytes (before optimization)

Writing 905 files in 86 directories to D:\SlimBuilder\Windows_Slim.iso

100% complete

Storage optimization saved 25 files, 14182400 bytes (1% of image)

After optimization, image file is 5179152384 bytes
Space saved because of embedding, sparseness or optimization = 14182400

Done.

Creation completed! Done!


Cleanup Working directory? C:\WinSlimBuilder will be purge if you continue.


Gracefully Exiting..
```
