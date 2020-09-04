#
# Change this for your deployments
#
$SubscriptionName = "Visual Studio Enterprise – MPN"
$Location = "westus2"
$ResourceGroup = "sndbox-azure-arc-us2"
# $Location = "westeurope"
# $ResourceGroup = "sndbox-azure-arc-eu"

#$WorkspaceName = "sndbox-azure-arc-law" + (Get-Random -Maximum 99999) # workspace names need to be unique across all Azure subscriptions - Get-Random helps with this for the example code
$WorkspaceName = "sndbox-azure-arc-law"
$ServicePrincipalName = "Sndbox-Arc-for-Servers"


# get the test subscription details
$Subscription = (Get-AzSubscription -SubscriptionName $SubscriptionName)
# set subscription as default
$Subscription | Select-AzSubscription

# Create the resource group if needed
try {
    Get-AzResourceGroup -Name $ResourceGroup -ErrorAction Stop
} catch {
    New-AzResourceGroup -Name $ResourceGroup -Location $Location
}
