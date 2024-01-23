# AKS with a spot node pool

This example shows how to create an AKS cluster with a spot node pool.

The following node pools are created:
* System node pool with 1 node
* User node pool with max 3 nodes (autoscaling).
* Spot node pool with max 10 nodes (autoscaling).
* Ingress node pool with 1 node with autoscaling disabled

## Run Terraform

```bash
terraform init -upgrade
terraform apply
```

## Get credentials

```bash
az aks list -o table
az aks get-credentials --resource-group aks-spotty --name spotty-aks --overwrite-existing
```

## Simulate

To simulate a spot node eviction, run the following commands:

```bash
az vmss list
vmss_name=$(az vmss list --resource-group MC_AKS-SPOTTY_SPOTTY-AKS_EASTUS --query "[].name" -o tsv | grep spot)
# use actual node resource group and vmss name from the previous command
az vmss list-instances \
  --resource-group MC_AKS-SPOTTY_SPOTTY-AKS_EASTUS \
  --name $vmss_name \
  --output json --query "[].instanceId"

# use actual instance id from the previous command

az vmss simulate-eviction \
   --resource-group MC_AKS-SPOTTY_SPOTTY-AKS_EASTUS \
   --name $vmss_name \
   --instance-id 1
```

This operation is logged:

```bash
az monitor activity-log list --offset 10m -g MC_aks-spotty_spotty-aks_eastus -o json | jq ".[] | {eventTimestamp, operationName}"
```

You should get an output like:
```
{
  "eventTimestamp": "2024-01-22T11:04:02.0525374Z",
  "operationName": {
    "localizedValue": "Simulate Eviction of spot Virtual Machine in Virtual Machine Scale Set",
    "value": "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/simulateEviction/action"
  }
}
```

Is possible to ship Activity Log to Log Analytics workspace and query it from there.

You can see the simulation in the `AzureActivity` log analytics table.

```
AzureActivity
| where OperationNameValue == "MICROSOFT.COMPUTE/VIRTUALMACHINESCALESETS/VIRTUALMACHINES/SIMULATEEVICTION/ACTION"
```

An actual eviction ( not simulated ) can be seen in the `AzureActivity` log analytics table with a different `OperationNameValue`.

```
AzureActivity
| where OperationNameValue == "Microsoft.Compute/virtualMachineScaleSets/evictSpotVM/action"
```
