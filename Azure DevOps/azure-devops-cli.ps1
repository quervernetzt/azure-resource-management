[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $TenantId,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureDevOpsOrganization
)


az extension add --name azure-devops

az login --tenant $TenantId

az devops project list --organization "https://dev.azure.com/$AzureDevOpsOrganization"