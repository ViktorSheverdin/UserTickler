$version = "1.3.2"

$ticklerName = "\\$env:computername\c$\UserTickler\files\tickler_$version.ps1"
$filesSrc = "\\bby-configmgr01\Applications\UserTickler\files"
$filesDest = "\\$env:computername\c$\UserTickler"
# $WarningSignImgDest = "\\$env:computername\c$\UserTickler\warning.png"
# $scriptLocation = "\\bby-configmgr01\Applications\UserTickler\tickler_$version.ps1"
# $WarningSignImgSrc = "\\bby-configmgr01\Applications\UserTickler\warning.png"
# $popUpSrc = "\\bby-configmgr01\Applications\UserTickler\pretty_popup.exe"
# $popUpDest = "\\$env:computername\c$\UserTickler\pretty_popup.exe"
# $XML_Src = "\\bby-configmgr01\Applications\UserTickler\UserTickler.xml"
# $XML_Dest = "\\$env:computername\c$\UserTickler\UserTickler.xml"
function setup_persmisions{    
    #$ticklerName = "\\$env:computername\c$\UserTickler\tickler_$version.ps1"
    $acl = Get-Acl $ticklerName
    ###Setup a new owner
    $newOwner = New-Object System.Security.Principal.Ntaccount("BUILTIN\Administrators")
    $acl.SetOwner($newOwner)
    $acl | Set-Acl $ticklerName
    #######################
    #$acl.SetGroup($newOwner)

    ###Remove Users group privilages
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "Allow")
    $acl.RemoveAccessRule($AccessRule)
    $acl | Set-Acl $ticklerName
    ########################

    ###Remove the rest of the permisions
    $usersid = New-Object System.Security.Principal.Ntaccount ("BUILTIN\Users")
    $acl.PurgeAccessRules($usersid)
    $acl | Set-Acl $ticklerName
    ########################

    ###Set revursive permisions
    $acl.SetAccessRuleProtection($true, $true)
    $acl | Set-Acl $ticklerName

    ###Display the current permisions for the folder
    Get-Acl C:\UserTickler | Format-List
}
New-Item -Path $ticklerName -ItemType File -Force
Copy-Item -Path $filesSrc -Destination $filesDest -Recurse -Force
# Copy-Item -Path $scriptLocation -Destination $ticklerName
# Copy-Item -Path $WarningSignImgSrc -Destination $WarningSignImgDest
# Copy-Item -Path $popUpSrc -Destination $popUpDest
# Copy-Item -Path $XML_Src -Destination $XML_Dest


setup_persmisions
#####Set up the permisions

powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File $ticklerName