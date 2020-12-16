param(
[switch] $OD)

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

if([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544") -ne $true){Write-Host "`nYou need use an elevated PowerShell window for this to work properly`n" -ForegroundColor White -BackgroundColor Red}
                else {
Write-host "`nRemoving pre-provisioned apps for all new profiles" -NoNewline
Get-AppxProvisionedPackage -online | Where-Object {$_.displayname -like "*xbox*" -or $_.DisplayName -like "*camera*" -or $_.DisplayName -like "*zune*" -or $_.DisplayName -like "*yourphone*" -or $_.DisplayName -like "*skype*" -or $_.DisplayName -like "*bingweather*" -or $_.DisplayName -like "*windowsmaps*" -or $_.DisplayName -like "*windowsfeedback*" -or $_.DisplayName -like "*solitaire*" -or $_.DisplayName -like "*gethelp*" -or $_.DisplayName -like "*3dviewer*" -or $_.DisplayName -like "*mixedreality*" -or $_.DisplayName -like "*onenote*" -or $_.DisplayName -like "*communicationsapps*" -or $_.DisplayName -like "*soundrecorder*" -or $_.DisplayName -like "*getstarted*" -or $_.DisplayName -like "*spotify*"} | Remove-AppxProvisionedPackage -online | Out-Null
Write-host "       (Done)" -ForegroundColor Green
Write-host "Removing app packages for current profile" -NoNewline
Get-AppxPackage | Where-Object {$_.name -like "*xbox*" -or $_.name -like "*camera*" -or $_.name -like "*zune*" -or $_.name -like "*yourphone*" -or $_.name -like "*skype*" -or $_.name -like "*bingweather*" -or $_.name -like "*windowsmaps*" -or $_.name -like "*windowsfeedback*" -or $_.name -like "*solitaire*" -or $_.Name -like "*gethelp*" -or $_.Name -like "*3dviewer*" -or $_.Name -like "*mixedreality*" -or $_.Name -like "*onenote*" -or $_.Name -like "*communicationsapps*" -or $_.Name -like "*soundrecorder*" -or $_.Name -like "*getstarted*" -or $_.Name -like "*spotify*"} | Remove-AppxPackage | Out-Null
Write-host "                (Done)" -ForegroundColor Green
Write-host "Removing app packages for all other local profiles" -NoNewline
Get-AppxPackage | Where-Object {$_.name -like "*xbox*" -or $_.name -like "*camera*" -or $_.name -like "*zune*" -or $_.name -like "*yourphone*" -or $_.name -like "*skype*" -or $_.name -like "*bingweather*" -or $_.name -like "*windowsmaps*" -or $_.name -like "*windowsfeedback*" -or $_.name -like "*solitaire*" -or $_.Name -like "*gethelp*" -or $_.Name -like "*3dviewer*" -or $_.Name -like "*mixedreality*" -or $_.Name -like "*onenote*" -or $_.Name -like "*communicationsapps*" -or $_.Name -like "*soundrecorder*" -or $_.Name -like "*getstarted*" -or $_.Name -like "*spotify*"} | Remove-AppxPackage -AllUsers | Out-Null
Write-host "       (Done)`n`n" -ForegroundColor Green

Write-host "Creating new registry key to disable start menu ads" -NoNewline
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -name "CloudContent" -force | Out-Null
Write-host "      (Done)" -ForegroundColor Green
Write-host "Adding the necessary values to the new key" -NoNewline
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value "1" -PropertyType DWORD -force | Out-Null
Write-host "               (Done)" -ForegroundColor Green

if($OD){
Write-host "`n`nUninstalling OneDrive" -NoNewline
& cmd.exe /c %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
Write-host "                                    (Done)" -ForegroundColor Green
}

Write-host "`n`nMicrosoft Bloat Removal Complete!" -ForegroundColor Green
Read-host "`n`nClick any button to exit..."
}
