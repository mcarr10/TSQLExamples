/********************************************************
Script to create job definitions along with schedules
for migrating across instances.

Created by Jared Zagelbaum, jaredzagelbaum.wordpress.com
Created 5/21/2015

Follow me on Twitter: @JaredZagelbaum

Run the script against the instance that you want to copy the jobs and schedules from.

The script will read the job definitions from the msdb system tables and output a script that performs the following when executed against a different instance:

Creates the job categories if they do not already exist
Creates the appropriate schedules if an existing job schedule with the same name does not exist
Creates the job if an existing job with the same name does not exist
Creates the job steps for all jobs matching job names from the originating instance where the step id does not already exist
Attaches schedules to all jobs matching the configuration in the originating instance
Sets the job start step based on the configuration in the originating instance
Sets the job server to (local) for all jobs 

The short take away is that the script is designed to be executed against a target instance that does not have jobs or schedules with the same names as the source instance. 
If there are identical names, make sure that the definitions are identical as well prior to running the script against the target. I'm also assuming that all jobs are local.

Things to note before running:

Create the appropriate SQL Agent operator on the target instance. The script will only set the operator based on the default you provide (set as "DBAdmins" by default). 
If you need different operators for different jobs, then you'll have to extend the script. Here's how to create an operator: https://msdn.microsoft.com/en-us/library/ms175962.aspx

All jobs and schedules will be created with "sa" as owner. If that doesn't work for you, then you'll have to do some modifications to the script. 

*********************************************************/

USE [msdb]
GO

PRINT N'Use [msdb]'

/*******************************************
Create Job Categories
********************************************/

PRINT N'--Create Job Categories'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';

DECLARE @categoryname sysname
Declare categorycursor CURSOR FAST_FORWARD FOR
SELECT name FROM msdb.dbo.syscategories WHERE category_class = 1

OPEN categorycursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);



FETCH NEXT FROM categorycursor
 INTO @categoryname

  WHILE @@FETCH_STATUS = 0
 BEGIN


PRINT N'IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name= ' + char(39) + @categoryname  + char(39) + N' AND category_class=1)';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''' + @categoryname + char(39);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);

FETCH NEXT FROM categorycursor
 INTO @categoryname

END
CLOSE categorycursor;
DEALLOCATE categorycursor;

PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'

GO

/*******************************************
Create Schedules
********************************************/


PRINT N'--Create Schedules'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';

DECLARE @schedule_name sysname
DECLARE @enabled int
DECLARE @freq_type int
DECLARE @freq_interval int
DECLARE @freq_subday_type int
DECLARE @freq_subday_interval int
DECLARE @freq_recurrence_factor int
DECLARE @active_start_date int
DECLARE @active_end_date int
DECLARE @active_start_time int
DECLARE @active_end_time int
DECLARE @owner_login_name sysname = N'sa' --update owner if required

Declare schedulecursor CURSOR FAST_FORWARD FOR

select [name] as schedule_name
,[enabled]
,freq_type
,freq_interval
,freq_subday_type
,freq_subday_interval
,freq_recurrence_factor
,active_start_date
,active_end_date
,active_start_time
,active_end_time
from msdb.dbo.sysschedules

OPEN schedulecursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);



 FETCH NEXT FROM schedulecursor
 INTO @schedule_name
,@enabled
,@freq_type
,@freq_interval
,@freq_subday_type
,@freq_subday_interval
,@freq_recurrence_factor
,@active_start_date
,@active_end_date
,@active_start_time
,@active_end_time


 WHILE @@FETCH_STATUS = 0
 BEGIN

PRINT N'IF NOT EXISTS (SELECT name FROM msdb.dbo.sysschedules WHERE name= ' + char(39) + @schedule_name  + char(39) + ')';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_add_schedule';
PRINT N'@schedule_name = ' + '''' + cast(@schedule_name as nvarchar(max)) + '''' + ',';
PRINT N'@enabled = ' + cast(@enabled as nvarchar(max)) + ',';
PRINT N'@freq_type= ' + cast(@freq_type as nvarchar(max)) + ',';
PRINT N'@freq_interval= ' + cast(@freq_interval as nvarchar(max)) + ',';
PRINT N'@freq_subday_type= ' + cast(@freq_subday_type as nvarchar(max)) + ',';
PRINT N'@freq_subday_interval= ' + cast(@freq_subday_interval as nvarchar(max)) + ',';
PRINT N'@freq_recurrence_factor= ' + cast(@freq_recurrence_factor as nvarchar(max)) + ',';
PRINT N'@active_start_date= ' + cast(@active_start_date as nvarchar(max)) + ',';
PRINT N'@active_end_date= ' + cast(@active_end_date as nvarchar(max)) + ',';
PRINT N'@active_start_time= ' + cast(@active_start_time as nvarchar(max)) + ',';
PRINT N'@active_end_time= ' + cast(@active_end_time as nvarchar(max)) + ',';
PRINT N'@owner_login_name= ' + char(39) + cast(@owner_login_name as nvarchar(max)) + char(39);
PRINT char(13) + char(10);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);



FETCH NEXT FROM schedulecursor
 INTO @schedule_name
,@enabled
,@freq_type
,@freq_interval
,@freq_subday_type
,@freq_subday_interval
,@freq_recurrence_factor
,@active_start_date
,@active_end_date
,@active_start_time
,@active_end_time

END

PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'


CLOSE schedulecursor;
DEALLOCATE schedulecursor;
GO

/*******************************************
Create Jobs
********************************************/

PRINT N'--Create Jobs'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';


DECLARE @job_name sysname
DECLARE @enabled int
DECLARE @notify_level_eventlog int
DECLARE @notify_level_email int
DECLARE @notify_level_netsend int
DECLARE @notify_level_page int
DECLARE @delete_level int
DECLARE @description nvarchar(512)
DECLARE @category_name sysname
DECLARE @notify_email_operator_name sysname =N'DBAdmins'	--set operator name here. Operator needs to already exist on target instance
DECLARE @owner_login_name sysname = N'sa'	--update owner if required


Declare jobcursor CURSOR FAST_FORWARD FOR

SELECT sj.[name] jobname
      ,[enabled]
      ,[notify_level_eventlog]
      ,[notify_level_email]
      ,[notify_level_netsend]
      ,[notify_level_page]
      ,[delete_level]
	  ,[description]
	  ,sc.[name] categoryname
  FROM [dbo].[sysjobs] sj
  INNER JOIN [dbo].[syscategories] sc
  ON sj.category_id = sc.category_id

  OPEN jobcursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);


 FETCH NEXT FROM jobcursor
 INTO @job_name 
 ,@enabled 
 ,@notify_level_eventlog 
 ,@notify_level_email 
 ,@notify_level_netsend 
 ,@notify_level_page 
 ,@delete_level 
 ,@description
 ,@category_name 


 WHILE @@FETCH_STATUS = 0
 BEGIN

PRINT N'IF NOT EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name= ' + char(39) + @job_name  + char(39) + ')';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_add_job';
PRINT N'@job_name = ' + '''' + cast(@job_name as nvarchar(max)) + '''' + ',';
PRINT N'@enabled = ' + cast(@enabled as nvarchar(max)) + ',';
IF @notify_level_eventlog > 0	PRINT N'@notify_level_eventlog= ' + cast(@notify_level_eventlog as nvarchar(max)) + ',';

--Handle email notification unsupported in sp_add_job 
IF @notify_level_email > 0 AND @notify_email_operator_name IS NOT NULL	PRINT N'@notify_level_email= ' + cast(@notify_level_email as nvarchar(max)) + ',';
IF @notify_level_email = 0 AND @notify_email_operator_name IS NOT NULL	PRINT N'@notify_level_email= 1'  + ',';

IF @notify_level_netsend > 0	PRINT N'@notify_level_netsend= ' + cast(@notify_level_netsend as nvarchar(max)) + ',';
IF @notify_level_page > 0		PRINT N'@notify_level_page= ' + cast(@notify_level_page as nvarchar(max)) + ',';
IF @delete_level > 0			PRINT N'@delete_level= ' + cast(@delete_level as nvarchar(max)) + ',';
IF @description IS NOT NULL		PRINT N'@description= '+ char(39) + cast(@description as nvarchar(max))+ char(39) + ',';
IF @notify_email_operator_name IS NOT NULL PRINT N'@notify_email_operator_name= ' + char(39) + cast(@notify_email_operator_name as nvarchar(max)) + char(39) + ',';
PRINT N'@category_name= '+ char(39) + cast(@category_name as nvarchar(max))+ char(39) + ',';
PRINT N'@owner_login_name= ' + char(39) + cast(@owner_login_name as nvarchar(max)) + char(39);
PRINT char(13) + char(10);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);


 FETCH NEXT FROM jobcursor
 INTO @job_name 
 ,@enabled 
 ,@notify_level_eventlog 
 ,@notify_level_email 
 ,@notify_level_netsend 
 ,@notify_level_page 
 ,@delete_level 
 ,@description
 ,@category_name 
	
	END

PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'


CLOSE jobcursor;
DEALLOCATE jobcursor;
GO

/*******************************************
Create Job Steps
********************************************/

PRINT N'--Create Jobs Steps'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';


DECLARE @job_name sysname
DECLARE @step_name sysname
DECLARE @step_id int
DECLARE	@cmdexec_success_code int
DECLARE	@on_success_action tinyint
DECLARE @on_success_step_id int
DECLARE	@on_fail_action tinyint
DECLARE @on_fail_step_id int
DECLARE	@retry_attempts int
DECLARE	@retry_interval int
DECLARE	@subsystem nvarchar(40)
DECLARE	@command nvarchar(3200)
DECLARE	@output_file_name nvarchar(200)
DECLARE @flags int
--DECLARE @server nvarchar(30)
--DECLARE @database_name sysname
--DECLARE @database_user_name sysname

Declare jobstepcursor CURSOR FAST_FORWARD FOR

SELECT sj.[name] jobname
      ,[step_name]
      ,[step_id]
	  ,[cmdexec_success_code]
	  ,[on_success_action]
      ,[on_success_step_id]
	  ,[on_fail_action]
      ,[on_fail_step_id]
	  ,[retry_attempts]
	  ,[retry_interval]
	  ,[subsystem]
	  ,[command]
	  ,[output_file_name]
      ,[flags]
      --,[server]
      --,[database_name]
      --,[database_user_name]
  FROM [dbo].[sysjobsteps] sjs
  INNER JOIN [dbo].[sysjobs] sj
  ON sjs.job_id = sj.job_id
  ORDER BY sjs.job_id, sjs.step_id

    OPEN jobstepcursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);


 FETCH NEXT FROM jobstepcursor
 INTO @job_name, 
@step_name, 
@step_id, 
@cmdexec_success_code, 
@on_success_action, 
@on_success_step_id, 
@on_fail_action, 
@on_fail_step_id, 
@retry_attempts, 
@retry_interval, 
@subsystem, 
@command, 
@output_file_name, 
@flags --, 
--@server, 
--@database_name, 
--@database_user_name 


 WHILE @@FETCH_STATUS = 0
 BEGIN
PRINT N'IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps sjs INNER JOIN msdb.dbo.sysjobs sj ON sjs.job_id = sj.job_id WHERE sj.[name] =' + char(39) + + cast(@job_name as nvarchar(max)) +  + char(39) + ' and step_id = ' +  cast(@step_id as nvarchar(max)) + ')';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_add_jobstep';
PRINT N'@job_name = ' +  char(39) + cast(@job_name as nvarchar(max)) +  char(39) + ',';
PRINT N'@step_name = ' + char(39) + cast(@step_name as nvarchar(max)) + char(39) + ',';
PRINT N'@step_id= ' + cast(@step_id as nvarchar(max)) + ',';
PRINT N'@cmdexec_success_code= ' + cast(@cmdexec_success_code as nvarchar(max)) + ',';
PRINT N'@on_success_action= ' + cast(@on_success_action as nvarchar(max)) + ',';
PRINT N'@on_success_step_id= ' + cast(@on_success_step_id as nvarchar(max)) + ',';
PRINT N'@on_fail_action= ' + cast(@on_fail_action as nvarchar(max)) + ',';
PRINT N'@on_fail_step_id= ' + cast(@on_fail_step_id as nvarchar(max)) + ',';
PRINT N'@retry_attempts= ' + cast(@retry_attempts as nvarchar(max)) + ',';
PRINT N'@retry_interval= '  + cast(@retry_interval as nvarchar(max))+ ',';
PRINT N'@subsystem= ' + char(39) + cast(@subsystem as nvarchar(max)) + char(39)+ ',';
PRINT N'@command= ' + char(39) + replace( cast(@command as nvarchar(max)), char(39), char(39) + char(39)) + char(39)+ ',';
PRINT N'@output_file_name= ' + char(39) + cast(@output_file_name as nvarchar(max)) + char(39)+ ',';
PRINT N'@flags= '  + cast(@flags as nvarchar(max)) --+ ',';
--PRINT N'@server= ' + char(39) + cast(@server as nvarchar(max)) + char(39)+ ',';
--PRINT N'@database_name= ' + char(39) + cast(@database_name as nvarchar(max)) + char(39)+ ',';
--PRINT N'@database_user_name= ' + char(39) + cast(@database_user_name as nvarchar(max)) + char(39);
PRINT char(13) + char(10);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);


FETCH NEXT FROM jobstepcursor
 INTO @job_name, 
@step_name, 
@step_id, 
@cmdexec_success_code, 
@on_success_action, 
@on_success_step_id, 
@on_fail_action, 
@on_fail_step_id, 
@retry_attempts, 
@retry_interval, 
@subsystem, 
@command, 
@output_file_name, 
@flags --, 
--@server, 
--@database_name, 
--@database_user_name 
	
	END

PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'


CLOSE jobstepcursor;
DEALLOCATE jobstepcursor;

  GO
/*******************************************
Attach schedules
********************************************/

PRINT N'--Attach schedules'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';

DECLARE @schedule_name sysname
DECLARE @job_name sysname

Declare scheduleattachcursor CURSOR FAST_FORWARD FOR

select ss.[name] schedule_name
,sj.name job_name 
from msdb.dbo.sysschedules ss
inner join msdb.dbo.sysjobschedules sjs
ON ss.schedule_id = sjs.schedule_id
inner join msdb.dbo.sysjobs sj
ON sjs.job_id = sj.job_id

OPEN scheduleattachcursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);

 FETCH NEXT FROM scheduleattachcursor
 INTO @schedule_name
 ,@job_name

 WHILE @@FETCH_STATUS = 0
 BEGIN

PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_attach_schedule';
PRINT N'@job_name = ' + '''' + cast(@job_name as nvarchar(max)) + '''' + ',';
PRINT N'@schedule_name = ' + '''' + cast(@schedule_name as nvarchar(max)) + '''' ;
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);

FETCH NEXT FROM scheduleattachcursor
 INTO @schedule_name
 ,@job_name

 END

 PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'

CLOSE scheduleattachcursor;
DEALLOCATE scheduleattachcursor;
GO

/*********************************************************
Set Job Server and Start Step
*********************************************************/

PRINT N'--Set Job Server and Start Step'
PRINT char(13) + char(10)

PRINT N'DECLARE @ReturnCode INT';
PRINT N'SELECT @ReturnCode = 0';


DECLARE @job_name sysname
DECLARE @start_step_id int

Declare jobcursor CURSOR FAST_FORWARD FOR

SELECT [name] jobname
      ,start_step_id
  FROM [dbo].[sysjobs] 


  OPEN jobcursor

PRINT N'BEGIN TRANSACTION';
PRINT char(13) + char(10);


 FETCH NEXT FROM jobcursor
 INTO @job_name 
 ,@start_step_id 
 

 WHILE @@FETCH_STATUS = 0
 BEGIN

PRINT N'IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name= ' + char(39) + @job_name  + char(39) + ')';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_update_job';
PRINT N'@job_name = ' + '''' + cast(@job_name as nvarchar(max)) + '''' + ',';
PRINT N'@start_step_id = ' + cast(@start_step_id as nvarchar(max));
PRINT char(13) + char(10);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);

-- Add all jobs to local server (can be easily altered to support remote target servers if required)
PRINT N'IF NOT EXISTS (SELECT name FROM msdb.dbo.sysjobs sj INNER JOIN msdb.dbo.sysjobservers sjs ON sj.job_id = sjs.job_id  WHERE name= ' + char(39) + @job_name  + char(39) + ')';
PRINT N'BEGIN'
PRINT N'EXEC @ReturnCode = sp_add_jobserver';
PRINT N'@job_name = ' + '''' + cast(@job_name as nvarchar(max)) + '''' + ',';
PRINT N' @server_name = N' + char(39) + '(local)' + char(39);
PRINT char(13) + char(10);
PRINT N'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';
PRINT N'END'
PRINT char(13) + char(10);



 FETCH NEXT FROM jobcursor
 INTO @job_name 
 ,@start_step_id 
	
	END

PRINT char(13) + char(10);
PRINT N'COMMIT TRANSACTION'
PRINT N'GOTO EndSave'
PRINT N'QuitWithRollback:'
PRINT N'    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION'
PRINT N'EndSave:'
PRINT N'GO'


CLOSE jobcursor;
DEALLOCATE jobcursor;
GO