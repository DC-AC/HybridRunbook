# This is a script that uses an automation credential to login to SQL. I have DBATools installed on the VM so I can therefore call it.

$cred=Get-AutomationPSCredential -Name 'sql'

 Backup-DbaDatabase `
        -SQLInstance 'SSIS01'`
		-FileCount 4  `
		-CompressBackup `
		-AzureBaseURL 'https://databasebackups.blob.core.windows.net/backupcontainer'`
        -SQLCredential $cred


Backup-DbaDatabase `
        -SQLInstance 'SSIS01'`
		-Type 'log'  `
		-CompressBackup `
		-AzureBaseURL 'https://databasebackups.blob.core.windows.net/backupcontainer'`
        -SQLCredential $cred