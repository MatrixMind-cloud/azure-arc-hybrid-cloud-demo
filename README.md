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


---


## Azure Subscription preparations

You require sufficient permissions to create a Service Principal,
Resource Group, Log Analytics Workspace, Automation Account and should be able
to manage those resources as well.

> Step 1

Have a functioning Azure login through your local Azure API tooling.
This project used Powershell (on Ubuntu) as example, but you should be able
to replicate the commands with `az` CLI as well.

For Powershell with Azure-Cmdlets use `Connect-AzAccount`


Create a copy of the globals environment template file `scripts/globals.env.ps1.dist` and
save it under `scripts/globals.env.ps1.
Fill in the Subscription name details and other specific overrides.
This file will be included into all further steps automatically.

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


---


## Enrollment

> On-Prem Vagrant simulation

This Vagrant setup uses a little Bash wrapper to inject credentials into the
provisioning scripts, therefor you will need to prepare a credentials file.

Working in subfolder `on-prem`, copy the `credentials.env.dist`
to `credentials.env` and edit its content according to your Azure Subscription
and Service Principal details. Use the details output from **Step 3**.

* Get a list of available machines: `./vagrant.sh status`

* Start the machine you want to try out: `./vagrant.sh up <machine_name>`

* Destroy a machine: `./vagrant.sh destroy <machine_name>`

> On-AWS Cross-Cloud simulation

This part of the project is Terraform based and deploys the following components:

* AWS VPC with 2 subnets (public + private)
* Internet Gateway for the public subnet
* NAT Gateway for the private subnet
* Bastion Instance with public IP in public subnet
* Windows 2019 Base server Instance in private subnet
* Security Groups for each Instance type and cross-Instance access

Working in the subfolder `on-aws`, copy the `settings.auto.tfvars.dist`
to `settings.auto.tfvars` and fill in the details for your deployment.

This Terraform project used local state only for the demo, keep that in mind!

Quick deploy via:
* `terraform init`
* `terraform plan -out tfplan`
* `terraform apply tfplan`


---


## Azure Services Integration

Go to Azure Arc in your Subscription and click your way through "Manage Server".

For each of the listed VMs listed, add the VM Extension
"Log Analytics Agent - Azure Arc" using the details from **Step 4**.

### Azure Automation Account

Go to Automation Account in your Subscription and create a new account,
e.g. `arc-automation`, on the same resource group you used for your Arc VMs.
Leave the settings as suggested, making sure the correct Location is selected.
After its creation, dive into the Automation Account specific view.

> Enabling Change tracking

Select **Change tracking** from the menu.
Here you will connect the account to the Log Analytics Workspace created for
this project, e.g. `sndbox-azure-arc-law`.

Once this is done, click in the Change Tracking view on **Manage Machines** and
select the specific Arc VMs for now, skip the wildcard *Add all VMs* suggestion.

It will take some time for Machine data to appear, moving on.

> Enabling Update management

Select **Update management** from the menu.
Connect this to your Log Analytics Workspace, same as the before.

Once this is done, click in the Update management view on **Manage Machines** and again add your Arc VMs, skipping the wildcard suggestion.

> Enabling Inventory

With Change tracking enabled, the Inventory of installed Software is also visible. It will take some time again until data becomes available.

### Azure Monitoring

> This Integration still seems experimental.

Enable this integration by going to the **Monitor** service in your
Subscription and selecting the un-monitored Arc VMs.
For each Arc VM follow the steps to enable Monitoring, which will start multiple Extension deployments on your Arc VM resources.

> Notes:
>
> As of this writing the Dependency Agent for Windows and Linux fails to deploy,
> due to timeouts, even with the agent being pre-installed through cloud-init scripts.
>
> Also, if the monitoring views show some details about upgrading the solution,
> follow the steps to allow for hybrid machine data integration.

The integration is ready if you can see metrics being displayed in the Performance view
and once the Map view shows your Arc VM and used port connections.


## Azure Subscription cleanup

In order to clean up all resources created by this demo run the script: `scripts/99_az_cleanup.ps1`

It will remove the Log Analytics Workspace, the Resource Group and the Service Principal used for machine enrollment.
