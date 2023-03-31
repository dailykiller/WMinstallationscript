#WM Install Script Created 2023 (Alexander Drummond)

$computers = "W-G92PK93"

$wm_install = "\\f0799p1\share\Systems\ACS 2022\Windows_Application\install_acs_64_allusers - Nordstrom Edition.js"
$cred = Get-Credential

#Install Invoke-Pssession module
Write-Host "Checking if necessary modules are installed" -ForegroundColor Yellow
try {$invoke_pssession_module = Get-InstalledModule -Name Invoke-Pssession -ErrorAction Ignore
    if ($null -eq $invoke_pssession_module){
        throw
    }
    else {Write-Host "Module already installed" -ForegroundColor Green}
}

catch {
    Write-Host "Module Not Currently Installed" -ForegroundColor Red
    Write-Host "Installing Module" -ForegroundColor Yellow
    Install-Module -Name Invoke-PSSession -Force -Credential $cred
    
}

#installs corretto removes all versions of java and jinitiator
foreach ($comp in $computers) {
    Write-Host "Testing Connection for $comp" -ForegroundColor Yellow
    $connection = Test-Connection -ComputerName $comp -Count 2 -Quiet
    Write-Host "Connected to $comp" -ForegroundColor Green
    start-sleep -seconds 5
    $y = Invoke-PSSession -ComputerName $comp -Credential $cred
    start-sleep -seconds 5
    if ($connection -eq $true) {
        
        #uninstalls all versions of java/jinitiator
        Write-Host "Uninstalling all versions of Java" -ForegroundColor Yellow
        Invoke-Command -Session $y -ScriptBlock {
            $java_versions = Get-wmiobject -Class win32_product | Where-Object{$_.Name -Match "Java*"}
            foreach ($java in $java_versions) {
                $java.Uninstall()
            }
            Write-Host "Uninstalling jinitiator" -ForegroundColor Yellow
            $jinitiator = Get-wmiobject -Class win32_product | Where-Object{$_.Name -Match "J-Initiator"} -ErrorAction Ignore
            $jinitiator.Uninstall() 
            Write-Host "Uninstalled jinitiator" -ForegroundColor Green
        }
        Write-Host "Uninstalled java" -ForegroundColor Green

        
        #Installs Corretta if not already installed
        $amazon_corretto_install_location = Get-ChildItem "\\$comp\C$\Program Files\" -Name
        $amazon_corretto = "\\F0799p1\Share\Systems\ACS 2022\amazon-corretto-17.0.6.10.1-windows-x64.msi"
        if ($amazon_corretto_install_location -notcontains "Amazon Corretto") {
            Write-Host "Starting installation of Corretto" -ForegroundColor Yellow
            Invoke-Command -Session $y -ScriptBlock {Start-Process $using:amazon_corretto -Wait -PassThru -Verbose}
            Write-Host "Installed Corretto" -ForegroundColor Green
        }
        else {Write-Host "Amazon Corretto already installed" -ForegroundColor Green}


    
    Remove-Pssession -ComputerName $comp
    }
    
    else {
        Write-Host "Could not connect to $comp" -ForegroundColor Red 
    }

}

#installs ACS if Corretto is installed
foreach ($comp in $computers) {
    $connection = Test-Connection -ComputerName $comp -Count 1 -Quiet
    $y = Invoke-PSSession -ComputerName $comp -Credential $cred
    start-sleep -seconds 5
    if ($connection -eq $true) {
        
        
        #Installs WM if not already installed and if Amazon Corretto is installed
        $wm_install_location = Get-ChildItem "\\$comp\C$\Users\Public\IBM\ClientSolutions\Start_Programs\Windows_x86-64" -Name -ErrorAction Ignore
        $amazon_corretto_install_location = Get-ChildItem "\\$comp\C$\Program Files\" -Name

       if ($wm_install_location -notcontains "acslaunch_win-64.exe") {
            if ($amazon_corretto_install_location -contains "Amazon Corretto") {
                Write-Host "Starting installation of WM" -ForegroundColor Yellow
                Invoke-Command -Session $y -ScriptBlock { 
                    Start-Process $using:wm_install -wait -PassThru 
                    Start-Sleep -Seconds 5
                    Write-Host "Installed WM" -ForegroundColor Green
                }   
            }
            else {Write-Host "WM Not Installed Corretto doesn't exist" -ForegroundColor Red}
            
        } 
        else {Write-Host "WM already installed" -ForegroundColor Green}

    Write-Host "$comp setup complete" -ForegroundColor Green
    Remove-Pssession -ComputerName $comp
    }
    
    else {
        Write-Host "Could not connect to $comp" -ForegroundColor Red 
    }

}
Write-Host @" 
----------------------------------------------------------------------------------------------------------------------
SETUP COMPLETE
----------------------------------------------------------------------------------------------------------------------
"@ -ForegroundColor Black -BackgroundColor Green
    
Start-Sleep -Seconds 120
