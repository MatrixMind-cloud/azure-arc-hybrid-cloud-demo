# globals include
$globalsPath = "$(Split-Path $PSCommandPath -Resolve)/globals.env.ps1"
if ( -not (Test-Path $globalsPath)) {
    Write-Error "Globals env file not found next to this script"
    Exit 1
} else {
    . $globalsPath
}


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
