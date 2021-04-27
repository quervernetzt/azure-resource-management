<#
    .SYNOPSIS
        Script to prepare the AppSettings values for the Azure Function going to be deployed.
        The value are being made available as ADO pipeline variables.

    .PARAMETER KeyVaultName
        The name of the KeyVault to retrieve secret information from.
        Example: "TestName"

    .PARAMETER SecretNames
        Comma separated list of secret names stored in KeyVault.
        Example: "TestName"
#>

param (
    [Parameter(Mandatory = $True)]
    [string]
    $KeyVaultName,

    [Parameter(Mandatory = $True)]
    [string]
    $SecretNames
)

$isLocalTesting = $false
if ($isLocalTesting) {
    [string]$tenantId = "xxx"
    [string]$subscriptionId = "xxx"
    [string]$keyVaultName = "iotcentralkv"
    [string]$secretNames = "TestSecret1,TestSecret2"

    az login -t $tenantId
    az account set -s $subscriptionId
}

$secretNamesArray = $SecretNames.Split(",")

Write-Host "Generating necessary AppSettings values..."

Write-Host "Azure KeyVault Secret References for KeyVault '$KeyVaultName'..."
Write-Host "----------------------------------------------------------"

foreach($secretName in $secretNamesArray) {
    Write-Host "Processing secret '$secretName'..."
    [object]$secretJSON = az keyvault secret show --vault-name $KeyVaultName --name $secretName
    [string]$secretId = ($secretJSON | ConvertFrom-Json).id
    [string]$secretIdWithoutVersion = $secretId.Substring(0, $secretId.LastIndexOf("/"))
    [string]$secretReference = "@Microsoft.KeyVault(SecretUri=$secretIdWithoutVersion)"
    Write-Host "##vso[task.setvariable variable=$secretName;]$secretReference"
    Write-Host "----------------------------------------------------------"
}

Write-Host "Done..."