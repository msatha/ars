<#

#$sqlPassword = [System.Web.Security.Membership]::GeneratePassword(15,2)
$vendorMgmtSqlServerName = 'ftnc-vendor-mgmt-sql-01'
$vendorMgmtDatabaseName = 'db01'
$adminUserName = 'adminUser'
$adminUserPassword  = $sqlPassword
$cloneUserName = 'cloneUser'
$cloneUserPassword = $sqlPassword
$sid = '0x01060000000000640000000000000000672C080BE07E224CBEF56EBCD2298332'

#>

Param(
    [Parameter(Mandatory=$true)][string]$vendorMgmtSqlServerName,
    [Parameter(Mandatory=$true)][string]$vendorMgmtDatabaseName,
    [Parameter(Mandatory=$true)][string]$adminUserName,
    [Parameter(Mandatory=$true)][string]$adminUserPassword,
    [Parameter(Mandatory=$true)][string]$cloneUserName,
    [Parameter(Mandatory=$true)][string]$cloneUserPassword,
    [Parameter(Mandatory=$true)][string]$sid
)

Import-Module .\scripts\sql\execute-sqlcmd.psm1 -Verbose -Force
$tableName = "Employees"
$cmd = "
IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME = '$tableName' and xtype = 'U') BEGIN
CREATE TABLE dbo.$tableName
(
    EmployeeID int,
    EmployeeName varchar(255)
)

INSERT INTO dbo.$tableName (EmployeeID, EmployeeName)
VALUES(1001, 'Employee1')
INSERT INTO dbo.$tableName (EmployeeID, EmployeeName)
VALUES(1002, 'Employee2')
INSERT INTO dbo.$tableName (EmployeeID, EmployeeName)
VALUES(1003, 'Employee3')
INSERT INTO dbo.$tableName (EmployeeID, EmployeeName)
VALUES(1004, 'Employee4')
END
"

Execute-SqlCmd -sqlServerName $vendorMgmtSqlServerName -databaseName $vendorMgmtDatabaseName -userName $adminUserName -password $adminUserPassword -command $cmd

Write-Host "table creation completed" -ForegroundColor Green

$cmd = "
IF NOT EXISTS(SELECT sid FROM sysusers WHERE [name] = '$cloneUserName') BEGIN
    CREATE LOGIN $cloneUserName WITH PASSWORD = '$adminUserPassword', SID = $sid;
    CREATE USER [$cloneUserName] FOR LOGIN [$cloneUserName] WITH DEFAULT_SCHEMA=[dbo];
    ALTER ROLE dbmanager ADD MEMBER $cloneUserName;
END
"

Execute-SqlCmd -sqlServerName $vendorMgmtSqlServerName  -databaseName "master" -userName $adminUserName -password $adminUserPassword -command $cmd
Write-Host "login creation completed" -ForegroundColor Green

$cmd = "
IF NOT EXISTS(SELECT * FROM SYS.DATABASE_PRINCIPALS WHERE NAME = '$cloneUserName') BEGIN
CREATE USER [$cloneUserName] FOR LOGIN [$cloneUserName] WITH DEFAULT_SCHEMA=[dbo];
ALTER ROLE db_owner ADD MEMBER $cloneUserName;
END
"
$cmd
Execute-SqlCmd -sqlServerName $vendorMgmtSqlServerName  -databaseName $vendorMgmtDatabaseName -userName $adminUserName -password $adminUserPassword -command $cmd
Write-Host "db_owner creation completed" -ForegroundColor Green