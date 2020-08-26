# Azure Arc Hybrid Cloud - Demo project

Goals:

* enroll Vagrant machines as simulated on-prem resources
* enroll AWS machines as simulated cross-cloud resources

Furthermore:

* integrate through Azure Automation Account:
  - Change Tracking
  - Inventory Tracking
  - Update Management

* integrate through Azure Monitoring:
  - Performance metrics collection

* integrate through Azure Policy:
  - base system compliance checking

## Azure Subscription preparations

You require sufficient permissions to create a Service Principal,
Resource Group, Log Analytics Workspace, Automation Account and should be able
to manage those resources as well.

> Step 1

Have a functioning Azure login through your local Azure API tooling.
This project used Powershell (on Ubuntu) as example, but you should be able
to replicate the commands with `az` CLI as well.

For Powershell with Azure-Cmdlets use `Connect-AzAccount`


Fill in the Subscription name details in `scripts/00_az_commons.ps1`, this file
will be included into all further steps and ensures that the main Resource Group
for this project is present as well that the Subscription you chose is used by
default.

> Step 2

Register your Subscription for the Azure Arc Providers required to manage your
resources.

Execute `scripts/01_az_provider_registration.ps1`

> Step 3

Create a Service Principal with just enough permission to enroll VMs into
Azure Arc.

Execute `scripts/02_az_ad_service_principal_create.ps1`

Keep the output of this script safe and close-by!

> Step 4

Create the Log Analytics Workspace for Azure Arc machines in this demo.

Execute `scripts/03_az_logworkspace_create.ps1`

Keep the output of this script safe and close-by!


## Enrollment

> On-Prem Vagrant simulation

This Vagrant setup uses a little Bash wrapper to inject credentials into the
provisioning scripts, therefor you will need to prepare a credentials file.

Working in subfolder `on-prem`, copy the `credentials.env.dist`
to `credentials.env` and edit it's content according to your Azure Subscription
and Service Principal details. Use the details output from **Step 3**.

* Get a list of available machines: `./vagrant.sh status`

* Start the machine you want to try out: `./vagrant.sh up <machine_name>`

* Destroy a machine: `./vagrant.sh destroy <machine_name>`

## Azure Services Integration

Go to Azure Arc in your Subscription and click your way through "Manage Server".

For each of the listed VMs listed, add the VM Extension
"Log Analytics Agent - Azure Arc" using the details from **Step 4**.
