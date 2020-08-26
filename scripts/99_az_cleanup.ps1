# commons include
. "$(Split-Path $PSCommandPath -Resolve)/00_az_commons.ps1"

Remove-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name $WorkspaceName -ForceDelete -Force -Confirm
Remove-AzResourceGroup -Name $ResourceGroup -Confirm
