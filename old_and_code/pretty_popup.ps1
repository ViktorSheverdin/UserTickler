# https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/adaptive-interactive-toasts

function popup_message {
    $app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
    
    $Template = [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText01
    $SoftwarecenterShortcut = "softwarecenter:SoftwareID=ScopeId_17995F15-6948-4994-850E-533712DFD41E/Application_1e02546f-ebf1-4345-bf17-2a924e6bf8cf"
    #$WarningSignImg = "\\$env:computername\c$\UserTickler\warning.png"
    $WarningSignImg = "c:\UserTickler\files\warning.png"
    $houleLogoImg = "c:\UserTickler\files\houlelogo.png"
    #Gets the Template XML so we can manipulate the values
    [xml]$ToastTemplate = ([Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($Template).GetXml())
    
    [xml]$ToastTemplate = @"
    <toast launch="app-defined-string">
        <visual>
        <binding template="ToastGeneric">
            <text>HOULE IT NOTICE</text>
            <image placement="appLogoOverride" hint-crop="circle" src="$houleLogoImg"/>
            <text>There is important windows upgrade available. Please install it ASAP. The installation process may take up to 2 hours.</text>
        </binding>
        </visual>
        <actions>
        <action content="Install now" activationType="protocol" arguments="$SoftwarecenterShortcut" />
        <action activationType="background" content="Remind me later" arguments="later"/>
        </actions>
    </toast>
"@
        
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($ToastTemplate.OuterXml)

$notify = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app)

$notify.Show($ToastXml)
}
popup_message

# C:\Users\viktor.sheverdin\Desktop\Work\CTF\FunProjects\PowerShellScripts\PS2EXE-v0.5.0.0\ps2exe.ps1 -inputFile \\bby-configmgr01\Applications\UserTickler\old_and_code\pretty_popup.ps1 -outputFile \\bby-configmgr01\Applications\UserTickler\files\pretty_popup.exe