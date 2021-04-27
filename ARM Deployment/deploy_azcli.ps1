<#
    .SYNOPSIS
        Example how to deploy an ARM template on resource group level using Azure CLI
    
    .DESCRIPTION
        See also https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli

    .PARAMETER TenantId
        The tenant id.

    .PARAMETER SubscriptionId
        The subscription id.
    
    .PARAMETER ResourceGroupName
        The resource group name.
        Example: "TestName"
    
    .PARAMETER ResourceGroupLocation
        The location to create the resource group in.
        Example: "westeurope"
    
    .PARAMETER Environment
        The environment prefix.
        Example: "dev"
#>

param (
    [Parameter(Mandatory = $True)]
    [string]
    $TenantId,

    [Parameter(Mandatory = $True)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory = $True)]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $True)]
    [string]
    $ResourceGroupLocation,

    [Parameter(Mandatory = $True)]
    [string]
    $Environment
)


az login -t $TenantId
az account set -s $SubscriptionId

[string]$templateFilePath = ".\template_file\azurefunction.template.json"
[string]$parameterFilePath = ".\parameter_files\$($Environment)_azurefunction.template.parameters.json"

az group create --location $ResourceGroupLocation --name $ResourceGroupName

az deployment group create --resource-group $ResourceGroupName --template-file $templateFilePath --parameters $parameterFilePath