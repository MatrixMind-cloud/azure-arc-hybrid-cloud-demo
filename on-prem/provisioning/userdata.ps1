#
# Disable Windows Update for now
#

# # set the Windows Update service to "disabled"
# sc.exe config wuauserv start=disabled
# # display the status of the service
# sc.exe query wuauserv
# # stop the service, in case it is running
# sc.exe stop wuauserv
# # display the status again, because we're paranoid
# sc.exe query wuauserv
# # double check it's REALLY disabled - Start value should be 0x4
# REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start 


#
# Download and Activate Azure Arc Agent
#

Set-Location c:\tmp

function downloadArc() {
  $ProgressPreference="SilentlyContinue"; Invoke-WebRequest -Uri https://aka.ms/AzureConnectedMachineAgent -OutFile AzureConnectedMachineAgent.msi
}
downloadArc

# Install the package
msiexec /i AzureConnectedMachineAgent.msi /l*v installationlog.txt /qn | Out-String


$VM_ID_STR= & "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" show | Select-String -Pattern "VM\ ID"
$VM_ID= ($VM_ID_STR -split ":")[1]

if ($VM_ID -eq "") {
  # Run connect command
  & "$env:ProgramFiles\AzureConnectedMachineAgent\azcmagent.exe" connect -i $env:arc_appId -p $env:arc_appSec -g $env:arc_resourceGroup -t $env:arc_tenantId -l $env:arc_location -s $env:arc_subscriptionId -n $env:COMPUTERNAME --tags "scope=azure-arc,environment=sandbox,location=on-prem"
}

# function downloadDepAgent() {
#   $ProgressPreference="SilentlyContinue"; Invoke-WebRequest -Uri https://aka.ms/dependencyagentwindows -OutFile InstallDependencyAgent-Windows.exe
# }
# downloadDepAgent

# .\InstallDependencyAgent-Windows.exe /RebootMode manual
# $DependencyAgentRC = $LASTEXITCODE
# if ($DependencyAgentRC -eq 3010) {
#   Write-Output "Reboot required!!!"
# } elseif ($DependencyAgentRC -gt 0) {
#   Write-Output "Error during installation, check logs."
#   exit $DependencyAgentRC
# }
# Write-Output "Dependency Agent installed."
