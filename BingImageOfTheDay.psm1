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
.EXAMPLE
   saves bing image in default directory  %userprofile%\Pictures
   get-BingImageOfTheDay -BingImageSize 1920x1080
.EXAMPLE
   saves bing image in tmp directory
   get-BingImageOfTheDay -BingImageSize 1366x768 -Destination $env:tmp
.EXAMPLE
   saves bing image in a directory, check for images posted 4 days back, screen size, and regional location
   get-BingImageOfTheDay -BingImageSize 1366x768 -Destination c:\pictures -CountryCode de-DE -DaysBack 4
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
        [string]$DaysBack="7"
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
            #$BingXML=[xml](Invoke-WebRequest -uri "$BingCom/HPImageArchive.aspx?format=xml&idx=0&n=$DaysBack&mkt=$CountryCode" -ErrorAction stop)
            $URL = "$BingCom/HPImageArchive.aspx?format=xml&idx=0&n=$DaysBack&mkt=$CountryCode"
            $BingXML = New-Object xml

            $resolveXML = New-Object -TypeName System.Xml.XmlUrlResolver
            $resolveXML.Credentials = [System.Net.CredentialCache]::DefaultCredentials

            $readXML = New-Object -TypeName System.Xml.XmlReaderSettings
            $readXML.XmlResolver = $resolveXML
            $readXML = [System.Xml.XmlReader]::Create($URL, $readXML)

            $BingXML.Load($readXML)

            if($BingXML){
                foreach($BingImage in $BingXML.images.image){
                   $BingBaseURl = $BingImage.urlBase
                   $BingImageName = $BingBaseURl.Split("_")[0]
                   $BingImageName = $BingImageName.split("/")[-1]
                   $BingCopyright = $BingImage.copyright
                   $DownloadImage = "$BingCom/$BingBaseURl`_$BingImageSize`.jpg"
                   $SaveImage = $Destination+"\"+$BingImageName+$BingImageSize+".jpg"
               
                   if(!(test-path $SaveImage)){
                        write-output "Image not found, downloading $BingImageName$BingImageSize.jpg"
                        Invoke-WebRequest -Uri $DownloadImage -OutFile $SaveImage -ErrorAction stop | Out-Null
                        Add-Content -Path $Destination\ImageInformation.txt -Value "$BingImageName$BingImageSize.jpg : $BingCopyright" -Encoding UTF8
                    }            
                }
            }
        }catch{
            write-error $_.exception.message
        }
    }
}