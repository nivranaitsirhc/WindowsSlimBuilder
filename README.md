# Slim11Builder
Scripts to build a trimmed-down Windows 11 image.

*I am to lazy to write this* `readme.md` *so just see the logs. You are welcome!*

#### console.log - output
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

Checking Paths:
- Boot Image Found!
- Install Image Found!

Copying Windows image... (This may take a while.)
Done!

BytesCopied FilesCopied
----------- -----------
 5074603507           1

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

Selected Index/Indices : 1 6

Removing Read-Only flags for the images..


Processing Install Images:

Mounting Windows 11 Home..

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

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
Disable - UnsupportedHardwareNotificationCache SV2 in Default
Disable - UnsupportedHardwareNotificationCache SV1 in USER
Disable - UnsupportedHardwareNotificationCache SV2 in USER
Enable  - BypassCPUCheck in System
Enable  - BypassRAMCheck in System
Enable  - BypassSecureBootCheck in System
Enable  - BypassStorageCheck in System
Enable  - BypassTPMCheck in System
Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System

Disabling Dynamic Content in Start-Menu:

Disabling Teams:

Disabling Sponsored Apps:
Disable - OemPreInstalledAppsEnabled..
Disable - PreInstalledAppsEnabled..
Disable - SilentInstalledAppsEnabled..
Enable  - DisableWindowsConsumerFeatures..
Disable - ConfigureStartPins..

Enabling Local Accounts on OOBE:
Enable  -  BypassNRO..
Inserting autounattend.xml to Sysprep
Done!

Disabling Reserved Storage:
Disable -  ShippedWithReserves..

Configuring Chat & TaskbarMn icon:
Disable -  ChatIcon..
Disable -  TaskbarMn..

Removing One-Drive Setup..

Removing Microsoft Edge Remnants:

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
Version: 10.0.22621.1

Image Version: 10.0.22621.1702

[==========================100.0%==========================]
The operation completed successfully.

Commiting Changes & Un-Mounting...

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

Saving image
[==========================100.0%==========================]
Unmounting image
[==========================100.0%==========================]
The operation completed successfully.


Done Processing Windows 11 Home!

Mounting Windows 11 Pro..

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

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
Remove-ProvisionedAppPackages: Not found! MicrosoftCorporationII.MicrosoftFamily
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
processed file: C:\Slim11Builder\scratchdir\6\Windows\System32\OneDriveSetup.exe
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
Disable - UnsupportedHardwareNotificationCache SV2 in Default
Disable - UnsupportedHardwareNotificationCache SV1 in USER
Disable - UnsupportedHardwareNotificationCache SV2 in USER
Enable  - BypassCPUCheck in System
Enable  - BypassRAMCheck in System
Enable  - BypassSecureBootCheck in System
Enable  - BypassStorageCheck in System
Enable  - BypassTPMCheck in System
Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System

Disabling Dynamic Content in Start-Menu:

Disabling Teams:

Disabling Sponsored Apps:
Disable - OemPreInstalledAppsEnabled..
Disable - PreInstalledAppsEnabled..
Disable - SilentInstalledAppsEnabled..
Enable  - DisableWindowsConsumerFeatures..
Disable - ConfigureStartPins..

Enabling Local Accounts on OOBE:
Enable  -  BypassNRO..
Inserting autounattend.xml to Sysprep
Done!

Disabling Reserved Storage:
Disable -  ShippedWithReserves..

Configuring Chat & TaskbarMn icon:
Disable -  ChatIcon..
Disable -  TaskbarMn..

Removing One-Drive Setup..

Removing Microsoft Edge Remnants:

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
Version: 10.0.22621.1

Image Version: 10.0.22621.1702

[==========================100.0%==========================]
The operation completed successfully.

Commiting Changes & Un-Mounting...

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

Saving image
[==========================100.0%==========================]
Unmounting image
[==========================100.0%==========================]
The operation completed successfully.


Done Processing Windows 11 Pro!

Done Patching Install Image

Consolidating Image(s) to Install.wim..

Merging Windows 11 Home to install.wim..

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

Exporting image
[==========================100.0%==========================]
The operation completed successfully.
Merging Windows 11 Pro to install.wim..

Deployment Image Servicing and Management tool
Version: 10.0.22621.1

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
Version: 10.0.22621.1

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
Disable - UnsupportedHardwareNotificationCache SV2 in Default
Disable - UnsupportedHardwareNotificationCache SV1 in USER
Disable - UnsupportedHardwareNotificationCache SV2 in USER
Enable  - BypassCPUCheck in System
Enable  - BypassRAMCheck in System
Enable  - BypassSecureBootCheck in System
Enable  - BypassStorageCheck in System
Enable  - BypassTPMCheck in System
Enable  - AllowUpgradesWithUnsupportedTPMOrCPU in System

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
Version: 10.0.22621.1

Saving image
[==========================100.0%==========================]
Unmounting image
[==========================100.0%==========================]
The operation completed successfully.

Done Patching Boot Image


Slim11 Install & Boot Image is now completed! Finalizing other Tasks..

Copying Autounattend XML file to root source dir...
Done!

Generating ISO file...


OSCDIMG 2.56 CD-ROM and DVD-ROM Premastering Utility
Copyright (C) Microsoft, 1993-2012. All rights reserved.
Licensed only for producing Microsoft authorized content.


Scanning source tree (500 files in 43 directories)
Scanning source tree complete (944 files in 86 directories)

Computing directory information complete

Image file is 5096407040 bytes (before optimization)

Writing 944 files in 86 directories to C:\Users\yolanda\Desktop\Slim11Builder\Windows_Slim11.iso

100% complete

Storage optimization saved 4 files, 24576 bytes (0% of image)

After optimization, image file is 5098481664 bytes
Space saved because of embedding, sparseness or optimization = 24576

Done.

Creation completed! Done!


Gracefully Exiting..
**********************
Windows PowerShell transcript end
End time: 20230719033952
**********************
```
