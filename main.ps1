# Ensures you do not inherit an AzureRMContext in your runbook
Disable-AzureRmContextAutosave –Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzureRmAccount -ServicePrincipal -Tenant $connection.TenantID `
-ApplicationID $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

$rgName='DevProgramsDW'
$vmName='DevDWSQL01'

$AzureContext = Select-AzureRmSubscription -SubscriptionId 1710afb2-df96-4ad3-9d3b-477fcda0c9e1

$vm=((Get-AzureRmVM -ResourceGroupName $rgName -AzureRmContext $AzureContext -Name $vmName -Status).Statuses[1]).Code
 
 if ($vm -ne 'PowerState/running')
 {start-azurermvm -ResourceGroupName $RGName -Name $vmName;
 start-sleep -Seconds 35;
 start-azureRMautomationrunbook -AutomationAccount 'ProgramsAutomation' -Name 'BackupDB' -ResourceGroupName $rgName -AzureRMContext $AzureContext -Runon 'Backups' -Wait;
 stop-azurermvm -Name $VMname -ResourceGroupName $RgName -force}
 else 
 {start-azureRMautomationrunbook -AutomationAccount 'ProgramsAutomation' -Name 'BackupDB'`
  -ResourceGroupName $rgName -AzureRMContext $AzureContext -RunOn 'Backups' -Wait}

$CleanupTime = [DateTime]::UtcNow.AddHours(-168)

$containerName='backupcontainer'
$resourceGroupName = 'DevProgramsDW'
$storageAccountName = 'egpafdatabasebackups'

# Get the access keys for the ARM storage account  
$accountKeys = Get-AzureRMStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName  


# Create a new storage account context using an ARM storage account  
$Context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $accountKeys[0].value 
Get-AzureStorageBlob -Container $ContainerName -Context $context | `
Where-Object { $_.LastModified.UtcDateTime -lt $CleanupTime}|`
Remove-AzureStorageBlob