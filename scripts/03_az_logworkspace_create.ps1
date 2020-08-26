# commons include
. "$(Split-Path $PSCommandPath -Resolve)/00_az_commons.ps1"

# Create the workspace if not exists
try {
    Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroup -Name $WorkspaceName -ErrorAction Stop
} catch {
    New-AzOperationalInsightsWorkspace -Location $Location -Name $WorkspaceName -Sku Standard -ResourceGroupName $ResourceGroup
}
# Get workspace details for log-agent
$WorkspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroup -Name $WorkspaceName)
$Workspace = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroup -Name $WorkspaceName)

$WorkspaceDetails = @{
    "WorkspaceName" = $WorkspaceName
    "WorkspaceId" = $Workspace.CustomerId
    "WorkspaceKey" = $WorkspaceKey.PrimarySharedKey
}
Write-Output $WorkspaceDetails
