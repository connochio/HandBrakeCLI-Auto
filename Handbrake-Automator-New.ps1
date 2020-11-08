 #region Global Variables

$sourcefolder = ""
$destinationfolder = ""
$newfileext = "mkv" 
$sonarrURL = ""
$sonarrAPI = ""


$filter = @("RARBG.mp4", "*sample*", "*.txt", "*.nfo", "*.EXE")
$excluded = @("*.mp4", "*.mkv", "*.avi", "*.mpeg4", "*.ts", "*.!ut")
$included = @("*.mp4", "*.mkv", "*.avi", "*.mpeg4", "*.ts")


$progressroot = $sourcefolder + "\" + "In Progress"
$code=@' 
[DllImport("kernel32.dll", CharSet = CharSet.Auto,SetLastError = true)]
  public static extern void SetThreadExecutionState(uint esFlags);
'@
$ste = Add-Type -memberDefinition $code -name System -namespace Win32 -passThru 
$ES_SYSTEM_REQUIRED = [uint32]"0x00000001"
$ES_CONTINUOUS = [uint32]"0x80000000"

#endregion

#region Scriptblocks

$clearunwanted = [scriptblock]::Create('
    Get-ChildItem $sourcefolder\* -Recurse -Include $filter | where { ! $_.PSIsContainer } | foreach {Remove-Item -LiteralPath $_.FullName -Force}
    Get-ChildItem $sourcefolder\* -Recurse -Exclude $excluded | where { ! $_.PSIsContainer } | foreach ($_) {Remove-Item -LiteralPath $_.FullName -Force}')

$getqueued = [scriptblock]::Create('
    $queuedfilelist = Get-ChildItem $script:sourcefolder\* -Recurse -Include $included | where { ! $_.PSIsContainer } | Where {$_.FullName -notlike "*\In Progress\*" -and $_.FullName -notlike "*\Delayed\*"}
    $queuedfilelist')

$clearfolders = [scriptblock]::Create('
    do { $empty = Get-ChildItem $script:sourcefolder -Recurse | Where-Object -FilterScript {$_.PSIsContainer -eq $True} | Where-Object -FilterScript {($_.GetFiles().Count -eq 0) -and $_.GetDirectories().Count -eq 0}
    $empty | remove-item }
    until ($empty.count -eq 0)')

$createprogress = [scriptblock]::Create('
    if ((Test-Path $script:progressroot) -eq $false) {New-Item $script:progressroot -type directory}
    ForEach ($file in $script:queuedfilelist){
    start-sleep -s 1
        $f = 0
        do {$f++;
        $progressfolder = $script:progressroot + "\" + $f
        (Test-Path $progressfolder)}
        until ((Test-Path $progressfolder) -eq $false)
        New-Item $progressfolder -type Directory

        Move-Item -literalpath $file -Destination $progressfolder
    }')

$getperc = [scriptblock]::Create('
    $perc = ((Get-Content "C:\scripts\encode\output.txt" -Tail 1).Split(",")).split("(")[1];
    New-BurntToastNotification -Text "$perc complete” -UniqueIdentifier "000124" -Appid "Encoding" -AppLogo "C:\Scripts\BTNotificationIcon.png"
    ')

#endregion

Function Re-encode{

$filelist = Get-ChildItem -LiteralPath $script:progressroot -Filter *.* -Recurse | where { ! $_.PSIsContainer }
$filecount = $filelist.count

if($filecount -eq 0){return}

ForEach ($file in $filelist)
{

    do { $randomtime = Get-Random -Minimum 10 -Maximum 300
    Start-Sleep -m $randomtime } 
    until ($env:HBSEncoding -eq $false)
    $env:HBSEncoding = $true

    $profile = "Default-All-RF20"
    If($file.Name -like '`[*`]*'){
        $profile = "Default-All-RF18"}
        
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $newfile = $destinationfolder + "\" + $file.BaseName + ".$newfileext";
    $oldfilebase = $file.BaseName + $file.Extension;
    
    $proc = Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -WindowStyle Minimized -ArgumentList "--preset-import-gui --preset $profile -i `"$oldfile`" -o `"$newfile`"" -PassThru #-RedirectStandardOutput "C:\scripts\encode\output.txt"
    
    #$proc.ProcessorAffinity=126
    #$proc.PriorityClass="BelowNormal"
    
    do {
        Start-Sleep -s 1
        } 
        until ($proc.HasExited -eq $true)
    
    if ($proc.exitcode -eq 0){    
        Remove-Item -LiteralPath "$oldfile" -force    
        
        $params = @{"name"="downloadedepisodesscan";"path"="$newfile";} | ConvertTo-Json
        Invoke-RestMethod -Uri $script:sonarrURL -Method Post -Body $params -Headers @{"X-Api-Key"="$script:sonarrAPI"}
        }

    else { 
        $returnfile = $sourcefolder + "\" + $file.BaseName + $file.Extension;
        Move-Item -LiteralPath $oldfile -Destination $returnfile -Force
        Remove-Item -LiteralPath $newfile -Force
        }
    
      
    $env:HBSEncoding = $false
    
    Invoke-Command $script:clearunwanted
    $script:queuedfilelist = Invoke-Command $script:getqueued
    if($script:queuedfilelist.count -ne 0){
    Invoke-Command $script:createprogress
    Invoke-Command $script:clearfolders
    }
}

$filelist = Get-ChildItem -LiteralPath $script:progressroot -Filter *.* -Recurse | where { ! $_.PSIsContainer }
if ($filelist.count -ne 0){
Re-encode}
else{
    [Environment]::SetEnvironmentVariable("HBSRunning", $false, "User")
    [Environment]::SetEnvironmentVariable("HBSEncoding", $false, "User")
    [Environment]::SetEnvironmentVariable("HBSRunning", $false, "Machine")
    [Environment]::SetEnvironmentVariable("HBSEncoding", $false, "Machine")
    return}

}

#region Do Things

if ($env:HBSRunning -eq $false) {[Environment]::SetEnvironmentVariable("HBSRunning", $true, "User")} 
else {exit}

Invoke-Command $clearunwanted
$queuedfilelist = Invoke-Command $script:getqueued

if ($queuedfilelist.count -eq "0") {[Environment]::SetEnvironmentVariable("HBSRunning", $false, "User") 
    Exit }

$ste::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED)

Invoke-Command $createprogress
Invoke-Command $clearfolders

Re-encode

$filelist = Get-ChildItem $destinationfolder -Filter *.* -Recurse | where { ! $_.PSIsContainer }
ForEach ($file in $filelist){
    $filepath = $file.fullname
    $params = @{"name"="downloadedepisodesscan";"path"="$filepath";} | ConvertTo-Json
    Invoke-RestMethod -Uri $sonarrURL -Method Post -Body $params -Headers @{"X-Api-Key"="$sonarrAPI"}
    }

Invoke-Command $clearfolders

Clear-RecycleBin -Confirm:$False

$ste::SetThreadExecutionState($ES_CONTINUOUS)

#endregion 
