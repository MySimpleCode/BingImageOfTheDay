# BingImageOfTheDay
downloading bing image of the day
Initial release at 21-8-2015

26-10-2015 version 1.1
Added possibility to delete images if older then <n> days.
if an image is deleted from the $Destionation folder, the description is also deleted from the ImageInfo file. 

#Usage
Copy the psm1 file to "C:\Program Files\WindowsPowerShell\Modules\BingImageOfTheDay"
When powershell is used, get-BingImageOfTheDay will be available.
Create a scheduled task to automate the download.
e.g.
Start Program :  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Arguments : -command & {ipmo BingImageOfTheDay;get-BingImageOfTheDay -BingImageSize 1920x1080 -Destination <FolderName>}

For further usage information use get-help get-BingImageOfTheDay.

