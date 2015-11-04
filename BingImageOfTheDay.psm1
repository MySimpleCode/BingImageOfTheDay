<#
.Synopsis
   Download the image of the day from bing.com
.DESCRIPTION
   Download the image of the day from bing.com
   If destination is not provided, it will save the image in the "Pictures" folder. 
   It is possible to download all images, posted no more then 7 days back (Restriction of the feed provided by Microsoft)
   At the moment you can download the images in the following resolutions 1366x768 and 1920x1080
   A history file is kept, with the description and Copyright information of the image file.
   Use of the images is protected by Copyright, please consult owner if you would like to use the images other then the desktop wallpaper or lockscreen feature.
   26-10-2015 version 1.1
   Added possibility to delete images if older then <n> days.
   if an image is deleted from the $Destionation folder, the description is also deleted from the ImageInfo file. 
.EXAMPLE
   saves bing image in default directory  %userprofile%\Pictures
   get-BingImageOfTheDay -BingImageSize 1920x1080
.EXAMPLE
   saves bing image in tmp directory
   get-BingImageOfTheDay -BingImageSize 1366x768 -Destination $env:tmp
.EXAMPLE
   saves bing image in a directory, check for images posted 4 days back, screen size, and regional location, and delete all images older then 90 days
   get-BingImageOfTheDay -BingImageSize 1366x768 -Destination c:\pictures -CountryCode de-DE -DaysBack 4 -DeleteOlder 90
#>
function get-BingImageOfTheDay 
{
    [CmdletBinding()]
    Param
    (
        [ValidateSet("1920x1080","1366x768")]
        [string]$BingImageSize="1920x1080",
        [string]$Destination,
		[ValidateSet("nl-NL","en-GB","en-US","fr-FR","de-DE")]
		[string]$CountryCode="nl-NL",
        [ValidateSet("1","2","3","4","5","6","7")]
        [string]$DaysBack="7",
        [string]$DeleteOlder,
        [string]$InfoFileName="ImageInformation.txt"
    )
    Begin{
        $BingCom="http://bing.com" 
    }
    Process{
        try{
            if(!($Destination)){
                $Destination = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name "My Pictures")."My Pictures"
            }else{
                if(!(Test-Path $Destination)){New-Item -Path $Destination -ItemType Directory}       
            }         
            $URL = "$BingCom/HPImageArchive.aspx?format=xml&idx=0&n=$DaysBack&mkt=$CountryCode"
            $BingXML = New-Object xml

            $resolveXML = New-Object -TypeName System.Xml.XmlUrlResolver
            $resolveXML.Credentials = [System.Net.CredentialCache]::DefaultCredentials

            $readXML = New-Object -TypeName System.Xml.XmlReaderSettings
            $readXML.XmlResolver = $resolveXML
            $readXML = [System.Xml.XmlReader]::Create($URL, $readXML)

            $BingXML.Load($readXML)

            [bool]$NewImage=$false

            if($BingXML){
                foreach($BingImage in $BingXML.images.image){
                   $BingBaseURl = $BingImage.urlBase
                   $BingImageName = $BingBaseURl.Split("_")[0]
                   $BingImageName = $BingImageName.split("/")[-1]
                   $BingCopyright = $BingImage.copyright
                   $DownloadImage = "$BingCom/$BingBaseURl`_$BingImageSize`.jpg"
                   $SaveImage = $Destination+"\"+$BingImageName+$BingImageSize+".jpg"
               
                   if(!(test-path $SaveImage)){
                        Write-Output "Image not found, downloading $BingImageName$BingImageSize.jpg"
                        Invoke-WebRequest -Uri $DownloadImage -OutFile $SaveImage -ErrorAction stop | Out-Null
                        Add-Content -Path $Destination\$InfoFileName -Value "$BingImageName$BingImageSize.jpg : $BingCopyright" -Encoding UTF8
                        [bool]$NewImage=$true
                    }            
                }
            }
            if ($NewImage){
                $ImageInfo=@()
                $Images = dir $Destination
                if($DeleteOlder){
                    $CurrentDate = Get-Date
                    $DeleteDate = (Get-Date).AddDays(-$DeleteOlder)
                    foreach ($Image in $Images){
                        if($Image.LastWriteTime -gt $DeleteDate){
                            $ImageInfo += Get-Content $Destination\$InfoFileName | Select-String -pattern $Image.Name
                        }else{
                            if (!($image.PSIsContainer)){
                                Remove-Item $Image.FullName -Force |Out-Null
                            }
                        }
                    }
                }else{
                    foreach ($Image in $Images){
                        $ImageInfo += Get-Content $Destination\$InfoFileName | select-string -pattern $Image.Name
                    }
                }
                $ImageInfo | Out-File $Destination\tmp.txt -Width 500 -Encoding utf8
                #remove empty lines from file
                (Get-Content $Destination\tmp.txt) | ? {$_.trim() -ne "" } | Set-Content $Destination\tmp.txt -Encoding UTF8
                Move-Item $Destination\tmp.txt $Destination\$InfoFileName -Force -Confirm:$false
            }
        }catch{
            Write-Error $_.exception.message
        }
    }
}

#get-BingImageOfTheDay -BingImageSize 1920x1080