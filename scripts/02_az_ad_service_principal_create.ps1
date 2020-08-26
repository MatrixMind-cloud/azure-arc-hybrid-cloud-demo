# commons include
. "$(Split-Path $PSCommandPath -Resolve)/00_az_commons.ps1"

# create new service principal
$ServicePrincipal = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -Role "Azure Connected Machine Onboarding"
# decode credentials secure string
$ServicePrincipalCredentials = New-Object pscredential -ArgumentList "temp", $ServicePrincipal.Secret

$ServicePrincipalDetails = @{
  "subscriptionId" = $Subscription.SubscriptionId
  "tenantId" = $Subscription.TenantId
  "appId" = $ServicePrincipal.ApplicationId
  "appSec" = $ServicePrincipalCredentials.GetNetworkCredential().password
}
Write-Output $ServicePrincipalDetails
