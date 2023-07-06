-- Declare variables
DECLARE @DatabaseName NVARCHAR(100) = '$(backupFilename)';
DECLARE @DataFilePath NVARCHAR(100) = '/var/opt/mssql/data/' + @DatabaseName  + '.mdf';
DECLARE @LogFilePath NVARCHAR(100) = '/var/opt/mssql/log/' + @DatabaseName  + '.ldf';
DECLARE @SqlStatement NVARCHAR(MAX);

-- Construct the dynamic SQL statement
SET @SqlStatement = N'RESTORE DATABASE ' + QUOTENAME(@DatabaseName) + N'
FROM DISK = ''/var/opt/mssql/backup/' + @DatabaseName + N'.bak'' 
WITH 
   MOVE ''JustEnough'' TO ''' + @DataFilePath + N''',
   MOVE ''JustEnough_log'' TO ''' + @LogFilePath + N''',
   NOUNLOAD, REPLACE;';

-- Execute the dynamic SQL statement
PRINT @SqlStatement
EXEC sp_executesql @SqlStatement;

--RESTORE DATABASE [JE_Empty_20231] FROM DISK = '/var/opt/mssql/backup/JE_Empty_20231.bak' WITH MOVE 'JE_Empty_20231' TO '/var/opt/mssql/data/JE_Empty_20231.mdf', MOVE 'JE_Empty_20231' TO '/var/opt/mssql/log/JE_Empty_20231.ldf', NOUNLOAD, REPLACE