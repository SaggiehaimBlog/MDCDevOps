<#
.SYNOPSIS
This script sets up the TF State file storage account.

.PARAMETER -tfBackendResourceGroupName
Name of the Resource Group containing the Storage Account.

.PARAMETER -tfBackendStorageAccountName
Name of the Storage Accounts you wish to store the TF state file in.

.PARAMETER -tfBackendStorageAccountSku
Storage Account SKU.

.PARAMETER -tfBackendContainerName
The name of the cotainer where the TF state file will reside.
#>

param (
    [Parameter(Mandatory = $true)]
    [string] $tfBackendResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string] $tfBackendStorageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string] $tfBackendStorageAccountSku,

    [Parameter(Mandatory = $true)]
    [string] $tfBackendContainerName
)
$subscription = get-azcontext | select -ExpandProperty Subscription;
Write-Output $subscription
# Get Storage account, if it exists.
$storageAccount = Get-AzStorageAccount -Name $tfBackendStorageAccountName -ResourceGroupName $tfBackendResourceGroupName -ErrorAction SilentlyContinue;

# Check if the Storage Account exists. If it doesn't, create one.
if ($null -eq $storageAccount) {
    Write-Output "No Storage Accounts found that match name: '$($tfBackendStorageAccountName)'";

    # Create Storage Account
    $arguments = @{
        AccountName             = $tfBackendStorageAccountName
        ResourceGroupName       = $tfBackendResourceGroupName
        Location                = (Get-AzResourceGroup -Name $tfBackendResourceGroupName).Location
        SkuName                 = $tfBackendStorageAccountSku
        MinimumTlsVersion       = "TLS1_2"
        AllowBlobPublicAccess   = $false
      }
    $storageAccount = New-AzStorageAccount @arguments

    # Create new Storage Account contaniner
    Write-Output "Creating new Storage Account Container: '$($tfBackendContainerName)'";
    New-AzStorageContainer -Name $tfBackendContainerName -Context $storageAccount.Context | Out-Null;
    Write-Output "Storage Account container '$($tfBackendContainerName)' has been created";
}
else {    
    Write-Output "Found Storage Account: '$($tfBackendStorageAccountName)'";

    # Check if Storage Account has TF State container.
    Write-Output "Checking to see if Storage Account container: '$($tfBackendContainerName)' exists";
    $tfStateContainer = Get-AzStorageContainer -Name $tfBackendContainerName -Context $storageAccount.Context -ErrorAction SilentlyContinue;    
    
    # If no Storage Account container found, create one.
    if ($null -eq $tfStateContainer) {    
        Write-Output "No container found that matches name: '$($tfBackendContainerName)'";        
        Write-Output "Creating new Storage Account Container: '$($tfBackendContainerName)'";
        New-AzStorageContainer -Name $tfBackendContainerName -Context $storageAccount.Context | Out-Null;
        Write-Output "Storage Account container '$($tfBackendContainerName)' has been created";
    }
    else {
        Write-Output "Storage Account container found that matches name: '$($tfBackendContainerName)'. No work to be done here.";    
    }
}