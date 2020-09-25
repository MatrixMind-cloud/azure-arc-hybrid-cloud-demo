#!/usr/bin/env bash

set -fu

cd "${HOME}" || exit 1

ARC_BIN="$(command -v azcmagent)"

if [ -z "${ARC_BIN}" ];
then
  # Download the installation package
  wget -q https://aka.ms/azcmagent -O ~/install_linux_azcmagent.sh
  # Install the hybrid agent
  bash ~/install_linux_azcmagent.sh
fi

echo "Extracting possible ARC Machine ID"
VM_ID="$(azcmagent show | grep 'VM ID' | cut -d: -f2 | tr -d '[:space:]')"

if [ -z "${VM_ID}" ];
then
  echo "Found no ARC Machine ID, running fresh enrollment."
  # Run connect command
  azcmagent connect \
    --service-principal-id "${arc_appId}" \
    --service-principal-secret "${arc_appSec}" \
    --resource-group "${arc_resourceGroup}" \
    --tenant-id "${arc_tenantId}" \
    --location "${arc_location}" \
    --subscription-id "${arc_subscriptionId}" \
    --resource-name "$(hostname)" \
    --tags "scope=azure-arc,environment=sandbox,location=on-prem"
else
  echo "Found ARC Machine ID: ${VM_ID}"
fi

# ms agents seem to require python2 for now
if [ -n "$(command -v apt)" ];
then
  # ubuntu 18.04 comes without python2 support
  apt install -yq python-minimal
else
  echo "Skip Ubuntu Python2 patching"
fi

# if [ ! -d "/opt/microsoft/dependency-agent/" ];
# then
#   wget -q https://aka.ms/dependencyagentlinux -O ~/InstallDependencyAgent-Linux64.bin \
#     && echo "71b4e1da5116e61e03317c49c6702b5069f01a0c9a7cb860f6acfaf5c198740e  InstallDependencyAgent-Linux64.bin" | sha256sum --check - \
#     && bash ~/InstallDependencyAgent-Linux64.bin --check \
#     && bash ~/InstallDependencyAgent-Linux64.bin -s
# fi

# if [ ! -d "/opt/microsoft/omsagent/" ];
# then
#   wget -q https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh \
#     && sh onboard_agent.sh -w "${arc_lawId}" -s "${arc_lawKey}"
# fi
