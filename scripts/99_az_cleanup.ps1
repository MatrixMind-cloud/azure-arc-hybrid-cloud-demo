# commons include
. "$(Split-Path $PSCommandPath -Resolve)/00_az_commons.ps1"

Remove-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name $WorkspaceName -ForceDelete -Force -Confirm
Get-AzResourceGroup -Name $ResourceGroup | Remove-AzResourceGroup -Confirm
Get-AzADApplication -DisplayName $ServicePrincipalName | Remove-AzADApplication -Confirm
Get-AzADServicePrincipal -DisplayName $ServicePrincipalName | Remove-AzADServicePrincipal -Confirm
