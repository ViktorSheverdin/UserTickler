#This is the final version of the UserTickler. It will create a Toast Notification asking a user to upgrade the build of the OS

function create_task {
    $taskName = (Get-ScheduledTask | where-Object { $_.TaskName -match "UserTickler" }).TaskName
    if (!$taskName) {        
        Write-Host("Task does not exist")
        Register-ScheduledTask -Xml (Get-Content 'C:\UserTickler\files\UserTickler.xml' | Out-String) -TaskName "UserTickler" -Force
    }
    else {
        Write-Host("Task Exist") 
        Write-Host("$taskName")
    }
}

function popup_message {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$computer_name = $env:COMPUTERNAME
    )
    Invoke-WmiMethod -Class win32_process -ComputerName $computer_name -Name create -ArgumentList "C:\UserTickler\files\pretty_popup.exe"
}

function check_ip_addrres{
    $range_of_ip = Get-Content -Path "C:\UserTickler\files\list_of_ip.txt"
    $networkAdapterConfiguration = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.DefaultIPGateway -ne $null }
    $ipv4 = $networkAdapterConfiguration.IPAddress | Select-Object -first 1
    # Mock ipv4
    #$ipv4 = "10.65.4.126"
    $Prop = @{
        'IPAddress' = $ipv4
        'SubnetMask' = "255.255.255.0"
    }
    $LocalIP = New-Object -TypeName PSobject -Property $Prop
    $range_of_ip |
    ForEach-Object {
        If ((([IPAddress]$_).Address -band ([IPAddress]$LocalIP.SubnetMask).Address) -eq (([IPAddress]$LocalIP.IPAddress).Address -band ([IPAddress]$LocalIP.SubnetMask).Address) ) {
            "$($LocalIP.IPAddress) is in the same subnet as $_"
            return $true
        }
    }
}

function check_build {
    $requiredBuildNumber = 17763
    #This function checks the build of the OS. If it is lower then the curret one, the popup will appear.
    #If the build is up to date, program will remove the task schedualer and the folder with files.
    $currentComputerBuildNumber = (Get-WmiObject -Class win32_operatingsystem -ComputerName $env:COMPUTERNAME | select-object BuildNumber).BuildNumber

    #This is the mock data
    #$currentComputerBuildNumber = 703
    if ($currentComputerBuildNumber -lt $requiredBuildNumber) {
        #####TODO Check if the computer is on the main network
        create_task
        #C:\UserTickler\pretty_popup.exe
        #popup_message
        if(check_ip_addrres){
            Write-Host("Connected to the main network")
            popup_message
        }
        else{
            Write-Host("Connected to the foreign network")
        }
        #new_popup
    }
    if ($currentComputerBuildNumber -ge $requiredBuildNumber) {
        #Remove TaskSchedualer and clean up the UserTickler folder
        clean_up
    }
}

function clean_up {
    delete_taskSchedualer
    delete_folder
}

function delete_taskSchedualer {
    $taskName = (Get-ScheduledTask | where-Object { $_.TaskName -match "UserTickler" }).TaskName
    if ($taskName) { 
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Task $taskName was deleted. \nThe computer is upgraded"
    }
    if (!$taskName) {
        Write-Host "Task was deleted"
    }
    else {
        Write-Host "Unknown Error"
    }
}

function delete_folder {
    Remove-Item -Path "C:\UserTickler" -Force -Recurse
    return "Folder was deleted"
}

function main {
    check_build
}

main