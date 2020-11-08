# Handbrake Automator

THIS README IS FOR Handbrake-Automator.ps1 NOT Handbrake-Automator-New.ps1

This is a script I created to automate re-encoding tasks before being picked up by sonarr.  
It can also be used without the sonarr integration if the sonarr option is set to 0


The script will automatically find files in the source folder, (optionally) remove .nfo .txt and image files and then move/copy the grabbed files to a new 'In Progress' folder.  
This folder is picked up again by the script and passed one by one in to the handbrake CLI using arguments you set.
You can set it to either remove the source files or keep them intact for future use, and a log allows the script to exclude previosuly completed files. 


Upon completion of all jobs, all empty directories including the 'In Progress' directory are removed to keep things tidy.


It also has the ability to show notifications based on it's progress through whichever files have been picked up.


Sonarr is then told to do an episode scan for each of the new files in the output directory.  
This was set up to work without the use of the drone factory so that when the drone factory is removed from sonarr the script will still work.


The next update will be to add some error handling in the case that handbrakeCLI.exe stops working mid-way through a job.


## Handbrake Argument and Configuration ##


The handbrake arguments and settings can be set at the top, along with any other variables that the script needs to work.  
It also has the option to import a profile from the Handbrake GUI application if you already have a profile you would like to use.


## Variables Available ##  
#### Required Variables

<details>
	<summary>These are required for the script to work</summary>
<p>
	
```$sourcefolder``` - content you want to re-encode  
```$destinationfolder``` - where you want the completed files  
```$destinationlog``` - where you want the file completion log to go  
```$lockdest``` - where the script lock files go (used to determine if it is currently running or encoding)  
```$newfileext``` - your re-encoded file extension  
```$handargs``` - handbrake settings. do not add input and output arguments to this. It is filled in dynamically by the script  
	
</p>
</details>

#### Optional Features

<details>
	<summary>These variables are not required, but must be set to 1 or 0</summary>
<p>
	
Set these to 1 to enable the feature. 0 will disable it  
```$recursive``` - recursively search source folder  
```$remold``` - remove source files after re-encode has completed  
```$clrrcl``` - clear recycle bin after script has finished  
```$sonarr``` - enable sonarr episode scan after script has finished  
```$changeaffinity``` - change the processor affinity for handbrake CLI whilst running  
```$import``` - import handbrake GUI profile. This overrides the $handargs variable  
```$hidden``` - hide the handbrake CLI window when re-encoding files  
```$notifications``` - enable Windows 10 toast notifications for progress of current job

</p>
</details>


<details>
	<summary>These are required if some optional features are enabled</summary>
<p>

For use with `$sonarr`  
   ``$sonarrurl`` - URL for sonarr  
   ``$sonarrapi`` - API for your sonarr installation
	
For use with `$changeaffinity`  
   ``$decimal`` - choose which threads to use for the above

For use with `$import`  
   ``$profile`` - name of the handbrake GUI profile  
	
</p>
</details>
