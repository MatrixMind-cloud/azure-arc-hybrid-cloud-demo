# commons include
. "$(Split-Path $PSCommandPath -Resolve)/00_az_commons.ps1"

# check resource provider registration of current subscription,
# necessary for azure arc

$ProviderStatus = Get-AzResourceProvider -ProviderNamespace microsoft.HybridCompute -Location $Location
$ProviderStatus | Select-Object -Property ProviderNamespace, RegistrationState, Locations

$ProviderStatus = Get-AzResourceProvider -ProviderNamespace microsoft.GuestConfiguration -Location $Location
$ProviderStatus | Select-Object -Property ProviderNamespace, RegistrationState, Locations

# this is absolutely required for Azure Arc
Register-AzResourceProvider -ProviderNamespace microsoft.HybridCompute
# this is a nice extra if available in the right region
Register-AzResourceProvider -ProviderNamespace microsoft.GuestConfiguration
