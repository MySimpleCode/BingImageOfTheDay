# BingImageOfTheDay
downloading bing image of the day
Initial release at 21-8-2015

#Usage
Copy the psm1 file to "C:\Program Files\WindowsPowerShell\Modules\BingImageOfTheDay"
When powershell is used, get-BingImageOfTheDay will be available.
Create a scheduled task to automate the download.
e.g.
Start Program :  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Arguments : -command & {ipmo BingImageOfTheDay;get-BingImageOfTheDay -BingImageSize 1920x1080 -Destination <FolderName>}

For further usage information use get-help get-BingImageOfTheDay.

