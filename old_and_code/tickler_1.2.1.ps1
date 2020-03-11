function create_task {
    $taskName = (Get-ScheduledTask | where-Object { $_.TaskName -match "UserTickler" }).TaskName
    if (!$taskName) {        
        Write-Host("Task does not exist")
        $action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
            -Argument '-NoProfile -WindowStyle Hidden -command "& {C:\Program Files (x86)\UserTickler\tickler_1.2.1.ps1}"'
        #$argumentList = '-file "C:\Program Files (x86)\UserTickler\tickler_1.2.1.ps1"'
        #$action = New-ScheduledTaskAction -Execute "Start-Process powershell.exe -argumentlist '$argumentList'"
        $timteSpan = New-TimeSpan -Minutes 1
        $timteSpan2 = New-TimeSpan -Days 200
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $timteSpan -RepetitionDuration $timteSpan2
 
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "UserTickler"
    }
    else {
        Write-Host("Task Exist") 
        Write-Host("$taskName")
    }
}


function remote_message {
    Param(
        [Parameter(Mandatory = $false)]
        [string]$computer_name = $env:COMPUTERNAME
    )
    $message = "
    This is a super annoying message.
    Toss a coin to your Witcher...
    And maybe he'll remove this popup."

    Invoke-WmiMethod -Class win32_process -ComputerName $computer_name -Name create -ArgumentList  "msg.exe * $message"
}

#remote_message

function main {
    create_task
    remote_message
}

main