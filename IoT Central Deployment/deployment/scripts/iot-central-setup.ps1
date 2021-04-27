<#
    .SYNOPSIS
        Script to configure an existing IoT Central instance.
        See also https://docs.microsoft.com/en-us/cli/azure/iot/central?view=azure-cli-latest.

    .PARAMETER IoTCentralAppName
        Name of the IoT Central App.
        Example: "TestName"
    
    .PARAMETER IoTCentralUsers
        String defining users and roles.
        Example: "[ { 'email' = 'abc@def.com', 'roles' = [ 'admin', 'builder', 'operator' ] } ]"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]
    $IoTCentralAppName,

    [Parameter(Mandatory = $true)]
    [string]
    $IoTCentralUsers
)


#########################################################################
# Extension check
#########################################################################
[object]$extensionCheck = (az extension list | ConvertFrom-Json) | Where-Object { $_.name -eq "azure-iot" }

if ($extensionCheck) {
    Write-Host "Azure CLI IoT extension is available..."
}
else {
    Write-Host "Azure CLI IoT extension not available, installing..."
    az extension add --name azure-iot
}


#########################################################################
# Login
########################################################################
$isLocalTesting = $false
if ($isLocalTesting) {
    [string]$tenantId = "xxx-xxx-xxx-xxx-xxx"
    [string]$subscriptionId = "xxx-xxx-xxx-xxx-xxx"

    [string]$IoTCentralAppName = "xxx"
    [array]$usersToAdd = @(
        [pscustomobject]@{email = "xxx@xxx.com"; roles = @("admin", "builder", "operator") }
    )

    az login -t $tenantId
    az account set -s $subscriptionId
}


#########################################################################
# Check if app exists
#########################################################################
[pscustomobject]$app = az iot central app show --name $IoTCentralAppName | ConvertFrom-Json

if ($app) {
    Write-Host $app
}
else {
    throw "IoT Central App '$IoTCentralAppName' does not exist..."
}
Write-Host "----------------------------------------------------------"


#########################################################################
# Add users
# Custom roles can not be created currently via CLI / REST API
#########################################################################
[pscustomobject]$usersToAdd = $IoTCentralUsers | ConvertFrom-Json

[pscustomobject]$roleMapping = [pscustomobject]@{
    admin    = "ca310b8d-2f4a-44e0-a36e-957c202cd8d4"
    builder  = "344138e9-8de4-4497-8c54-5237e96d6aaf"
    operator = "ae2c9854-393b-4f97-8c42-479d70ce626e"
}

foreach ($userToAdd in $usersToAdd) {  
    [string]$email = $userToAdd.email
    [array]$roles = $userToAdd.roles

    Write-Host "Working with user '$email'..."

    foreach ($role in $roles) {
        Write-Host "...and role '$role'..."
        [pscustomobject]$userCheck = (az iot central user list --app-id $IoTCentralAppName | ConvertFrom-Json).value | Where-Object { $_.email -eq $email }

        if ($userCheck) {
            Write-Host "User '$email' already exists..."
    
            [string]$roleCheck = $userCheck.roles | Where-Object { $_.role -eq $roleMapping.$role }
            if ($roleCheck) {
                Write-Host "User has already role '$role'..."
                continue
            }
            else {
                Write-Host "User has not role '$role'..."
                [string]$userId = $userCheck.id
            }
        }
        else {
            Write-Host "User '$email' does not exist..."
            [string]$userId = (New-Guid).Guid
        }
    
        az iot central user create `
            --user-id $userId `
            --app-id $IoTCentralAppName `
            --email $email `
            --role $role
    }
    Write-Host "------------------------"
}
Write-Host "----------------------------------------------------------"


Write-Host "Done..."