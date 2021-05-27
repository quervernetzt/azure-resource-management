[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $TenantId,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureDevOpsOrganization,

    [Parameter(Mandatory=$false)]
    [string]
    $AzureDevOpsPAT = "xxx"
)


# Authentication Option 1: Azure CLI
az login --tenant $TenantId
[string]$accessToken = "Bearer " + (az account get-access-token --resource=499b84ac-1321-427f-aa17-267ca6975798 | ConvertFrom-Json).accessToken

# Authentication Option 2: Personal Access Token
[string]$accessToken = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)"))

# Get projects in the organization
[pscustomobject]$azureDevOpsAuthenicationHeader = @{Authorization = $accessToken }

[string]$uriBase = "https://dev.azure.com/$AzureDevOpsOrganization" 
[string]$uriFull = "$uriBase/_apis/projects?api-version=6.0"

Invoke-RestMethod -Uri $uriFull -Method GET -Headers $azureDevOpsAuthenicationHeader 