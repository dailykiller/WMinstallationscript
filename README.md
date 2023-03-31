# WMinstallationscript

This script installs new version of ACS (WM)

## Details

Full effect of this script is the installation of ACS as well as the uninstallation of all java versions and Jinitiator 

Script also installs Amazon Corretto

This script was designed to be ran on remote computers over the network either a list of computers defined in the script or the script can be modified to iterate over a txt file/csv

### Mandatory Modifications

Change $wm_install variable to equal the install path of your sites WM on share drive 799 share drive location is the current default


### Optional Modifications

Change $comptuers variable to equal Get-Content C:\textfile.txt in single line format 
example: 

Computername
Computername
Computername


#### Potential Future Additions

Adding firewall exception rule so first time open will not require allowing access for firewall