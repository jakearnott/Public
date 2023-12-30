Function download-PSADT {
    param (
    [Parameter(Mandatory)]
    [string] $outputPath
    )

$url = 'https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/latest'
$request = [System.Net.WebRequest]::Create($url)
$response = $request.GetResponse()
$realTagUrl = $response.ResponseUri.OriginalString
$version = $realTagUrl.split('/')[-1].Trim('v')
$version
$fileName = "PSAppDeployToolkit_v$($version).zip"
$realDownloadUrl = $realTagUrl.Replace('tag', 'download') + '/' + $fileName
$realDownloadUrl

if (!(Test-Path -Path $outputPath))
    {
    Write-Host "Path not present - creating." -ForegroundColor Cyan
    New-Item -Path $outputPath -ItemType Directory -Force
    }
else
    {
    Write-Host "Path present. Downloading content" -ForegroundColor Green
    $existingFiles = Get-ChildItem -Path $outputPath | select FullName
    }

Invoke-WebRequest -Uri $realDownloadUrl -OutFile "$($outputPath)\$($fileName)"

Expand-Archive -Path "$($outputPath)\$($fileName)" -DestinationPath $outputPath

if ($existingFiles)
    {
    Write-Output "Copying existing files to Files folder"
    foreach ($file in $existingFiles)
        {
        Move-Item -Path $file.FullName -Destination "$($outputPath)\Toolkit\Files"
        }
    }
Remove-Item -Path "$($outputPath)\$($fileName)" -Recurse -Force
Move-Item -Path "$($outputPath)\Toolkit\*" -Destination $outputPath
Remove-Item -Path "$($outputPath)\Toolkit" -Recurse -Force

(get-content -Path "$($outputPath)\AppDeployToolkit\AppDeployToolkitConfig.xml").Replace('$envWinDir\Logs\Software','$envProgramData\Microsoft\IntuneManagementExtension\Logs') | Set-Content "$($outputPath)\AppDeployToolkit\AppDeployToolkitConfig.xml" -Encoding UTF8
(get-content -Path "$($outputPath)\AppDeployToolkit\AppDeployToolkitConfig.xml").Replace('$envProgramData\Logs\Software','$envProgramData\Microsoft\IntuneManagementExtension\Logs') | Set-Content "$($outputPath)\AppDeployToolkit\AppDeployToolkitConfig.xml" -Encoding UTF8

}