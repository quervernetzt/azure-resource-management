<#
    .SYNOPSIS
        Example how to deploy an ARM template on resource group level using Azure PowerShell
    
    .DESCRIPTION
        See also https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-powershell

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


Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId

[string]$templateFilePath = ".\template_file\azurefunction.template.json"
[string]$parameterFilePath = ".\parameter_files\$($Environment)_azurefunction.template.parameters.json"


New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation

New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $templateFilePath `
    -TemplateParameterFile $parameterFilePath