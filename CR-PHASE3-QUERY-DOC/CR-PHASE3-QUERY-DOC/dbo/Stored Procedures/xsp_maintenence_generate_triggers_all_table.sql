-- USE IFINDOC
CREATE PROCEDURE dbo.xsp_maintenence_generate_triggers_all_table
	@Schemaname					   Sysname		  = 'dbo'
	,@GenerateScriptOnly		   bit			  = 1
	,@ForceDropAuditTable		   bit			  = 0
	,@IgnoreExistingColumnMismatch bit			  = 0
	,@DontAuditforUsers			   nvarchar(4000) = ''
	,@DontAuditforColumns		   nvarchar(4000) = ''
as
set nocount on ;

/*    
Parameters    
@Schemaname            - SchemaName to which the table belongs to. Default value 'dbo'.    
@Tablename            - TableName for which the procs needs to be generated.    
@GenerateScriptOnly - When passed 1 , this will generate the scripts alone..    
                      When passed 0 , this will create the audit tables and triggers in the current database.    
                      Default value is 1    
@ForceDropAuditTable - When passed 1 , will drop the audit table and recreate  
                       When passed 0 , will generate the alter scripts  
                       Default value is 0  
@IgnoreExistingColumnMismatch - When passed 1 , will not stop with the error on the mismatch of existing column and will create the trigger.  
                                When passed 0 , will stop with the error on the mismatch of existing column.  
                                Default value is 0  
@DontAuditforUsers - Pass the UserName as comma seperated for whom the audit is not required. 
                     Default value is '' which will do audit for all the users. 
 
@DontAuditforColumns - Pass the ColumnNames as comma seperated for which the audit is not required. 
      Default value is '' which will do audit for all the users. 
*/
declare @SQL varchar(max) ;
declare @SQLTrigger varchar(max) ;
declare @ErrMsg varchar(max) ;
declare @AuditTableName SYSNAME ;
declare @QuotedSchemaName SYSNAME ;
declare @QuotedTableName SYSNAME ;
declare @QuotedAuditTableName SYSNAME ;
declare @InsertTriggerName SYSNAME ;
declare @UpdateTriggerName SYSNAME ;
declare @DeleteTriggerName SYSNAME ;
declare @QuotedInsertTriggerName SYSNAME ;
declare @QuotedUpdateTriggerName SYSNAME ;
declare @QuotedDeleteTriggerName SYSNAME ;
declare @DontAuditforUsersTmp nvarchar(4000) 
declare	@Tablename SYSNAME ;

	--get profiler task
	declare curr_generate_triggers_all_table cursor for

		select	name 
		from	sys.tables
		where	((name	like 'SYS_%'
				or name like 'MASTER_%')
				and name <> 'sysdiagrams')
				or (name = 'JOURNAL_GL_LINK');

	open curr_generate_triggers_all_table
			
	fetch next from curr_generate_triggers_all_table 
	into	@Tablename
		
	while @@fetch_status = 0
	begin
		begin

			select	@AuditTableName = 'Z_AUDIT_' + @Tablename ;
			
			select	@QuotedSchemaName = quotename(@Schemaname) ;
			
			select	@QuotedTableName = quotename(@Tablename) ;
			
			select	@QuotedAuditTableName = quotename(@AuditTableName) ;
			
			select	@InsertTriggerName = @Tablename + '_Insert_Audit' ;
			
			select	@UpdateTriggerName = @Tablename + '_Update_Audit' ;
			
			select	@DeleteTriggerName = @Tablename + '_Delete_Audit' ;
			
			select	@QuotedInsertTriggerName = quotename(@InsertTriggerName) ;
			
			select	@QuotedUpdateTriggerName = quotename(@UpdateTriggerName) ;
			
			select	@QuotedDeleteTriggerName = quotename(@DeleteTriggerName) ;
			
			if ltrim(rtrim(@DontAuditforUsers)) <> ''
			begin
				if right(@DontAuditforUsers, 1) = ','
				begin
					select	@DontAuditforUsersTmp = left(@DontAuditforUsers, len(@DontAuditforUsers) - 1) ;
				end ;
				else
				begin
					select	@DontAuditforUsersTmp = @DontAuditforUsers ;
				end ;
			
				select	@DontAuditforUsersTmp = replace(@DontAuditforUsersTmp, ',', ''',''') ;
			end ;
			
			select	@DontAuditforColumns = ',' + upper(@DontAuditforColumns) + ',' ;
			
			if not exists
			(
				select	1
				from	sys.objects
				where	Name		  = @TableName
						and Schema_id = schema_id(@Schemaname)
						and Type	  = 'U'
			)
			begin
				select	@ErrMsg = @QuotedSchemaName + '.' + @QuotedTableName + ' Table Not Found ' ;
			
				raiserror(@ErrMsg, 16, 1) ;
			
				return ;
			end ;
			
			----------------------------------------------------------------------------------------------------------------------    
			-- Audit Create OR Alter table     
			----------------------------------------------------------------------------------------------------------------------    
			declare @ColList varchar(max) ;
			declare @InsertColList varchar(max) ;
			declare @UpdateCheck varchar(max) ;
			
			declare @NewAddedCols table
			(
				ColumnName			  SYSNAME
				,DataType			  SYSNAME
				,CharLength			  int
				,Collation			  SYSNAME	  null
				,ChangeType			  varchar(20) null
				,MainTableColumnName  SYSNAME	  null
				,MainTableDataType	  SYSNAME	  null
				,MainTableCharLength  int		  null
				,MainTableCollation	  SYSNAME	  null
				,AuditTableColumnName SYSNAME	  null
				,AuditTableDataType	  SYSNAME	  null
				,AuditTableCharLength int		  null
				,AuditTableCollation  SYSNAME	  null
			) ;
			
			select	@ColList = '' ;
			
			select	@UpdateCheck = ' ' ;
			
			select	@SQL = '' ;
			
			select	@InsertColList = '' ;
			
			select	@ColList = @ColList + case SC.is_identity
											  when 1 then 'CONVERT(' + ST.name + ',' + quotename(SC.name) + ') as ' + quotename(SC.name)
											  else quotename(SC.name)
										  end + ','
					,@InsertColList = @InsertColList + quotename(SC.name) + ','
					,@UpdateCheck = @UpdateCheck + case
													   when charindex(',' + upper(SC.NAME) + ',', @DontAuditforColumns) = 0 then 'CASE WHEN UPDATE(' + quotename(SC.name) + ') THEN ''' + quotename(SC.name) + '-'' ELSE '''' END + ' + char(10)
													   else ''
												   end
			from	SYS.COLUMNS SC
					join SYS.OBJECTS SO on SC.object_id			 = SO.object_id
					join SYS.schemas SCH on SCH.schema_id		 = SO.schema_id
					join SYS.types ST on ST.user_type_id		 = SC.user_type_id
										 and   ST.system_type_id = SC.system_type_id
			where	SCH.Name		   = @Schemaname
					and SO.name		   = @Tablename
					and upper(ST.name) <> upper('timestamp') ;
			
			select	@ColList = substring(@ColList, 1, len(@ColList) - 1) ;
			
			select	@UpdateCheck = substring(@UpdateCheck, 1, len(@UpdateCheck) - 3) ;
			
			select	@InsertColList = substring(@InsertColList, 1, len(@InsertColList) - 1) ;
			
			select	@InsertColList = @InsertColList + ',AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns' ;
			
			if exists
			(
				select	1
				from	sys.objects
				where	Name		  = @AuditTableName
						and Schema_id = schema_id(@Schemaname)
						and Type	  = 'U'
			)
			   and	@ForceDropAuditTable = 0
			begin
			
				----------------------------------------------------------------------------------------------------------------------    
				-- Get the comparision metadata for Main and Audit Tables  
				----------------------------------------------------------------------------------------------------------------------    
				insert into @NewAddedCols
				(
					ColumnName
					,DataType
					,CharLength
					,Collation
					,ChangeType
					,MainTableColumnName
					,MainTableDataType
					,MainTableCharLength
					,MainTableCollation
					,AuditTableColumnName
					,AuditTableDataType
					,AuditTableCharLength
					,AuditTableCollation
				)
				select	isnull(MainTable.ColumnName, AuditTable.ColumnName)
						,isnull(MainTable.DataType, AuditTable.DataType)
						,isnull(MainTable.CharLength, AuditTable.CharLength)
						,isnull(MainTable.Collation, AuditTable.Collation)
						,case
							 when MainTable.ColumnName is null then 'Deleted'
							 when AuditTable.ColumnName is null then 'Added'
							 else null
						 end
						,MainTable.ColumnName
						,MainTable.DataType
						,MainTable.CharLength
						,MainTable.Collation
						,AuditTable.ColumnName
						,AuditTable.DataType
						,AuditTable.CharLength
						,AuditTable.Collation
				from
						(
							select	SC.Name as ColumnName
									,ST.Name as DataType
									,SC.is_identity as isIdentity
									,SC.Max_length as CharLength
									,SC.Collation_Name as Collation
							from	SYS.COLUMNS SC
									join SYS.OBJECTS SO on SC.object_id			 = SO.object_id
									join SYS.schemas SCH on SCH.schema_id		 = SO.schema_id
									join SYS.types ST on ST.user_type_id		 = SC.user_type_id
														 and   ST.system_type_id = SC.system_type_id
							where	SCH.Name		   = @Schemaname
									and SO.name		   = @Tablename
									and upper(ST.name) <> upper('timestamp')
						) MainTable
						full outer join
						(
							select	SC.Name as ColumnName
									,ST.Name as DataType
									,SC.is_identity as isIdentity
									,SC.Max_length as CharLength
									,SC.Collation_Name as Collation
							from	SYS.COLUMNS SC
									join SYS.OBJECTS SO on SC.object_id			 = SO.object_id
									join SYS.schemas SCH on SCH.schema_id		 = SO.schema_id
									join SYS.types ST on ST.user_type_id		 = SC.user_type_id
														 and   ST.system_type_id = SC.system_type_id
							where	SCH.Name		   = @Schemaname
									and SO.name		   = @AuditTableName
									and upper(ST.name) <> upper('timestamp')
									and SC.Name not in
				(
					'AuditDataState', 'AuditDMLAction', 'AuditUser', 'AuditDateTime', 'UpdateColumns'
				)
						) AuditTable on MainTable.ColumnName = AuditTable.ColumnName ;
			
				----------------------------------------------------------------------------------------------------------------------    
				-- Find data type changes between table  
				----------------------------------------------------------------------------------------------------------------------    
				if exists
				(
					select	*
					from	@NewAddedCols NC
					where	NC.MainTableColumnName			   = NC.AuditTableColumnName
							and (
									NC.MainTableDataType	   <> NC.AuditTableDataType
									or	NC.MainTableCharLength > NC.AuditTableCharLength
									or	NC.MainTableCollation  <> NC.AuditTableCollation
								)
				)
				begin
					select	convert(   varchar(50), case
														when NC.MainTableDataType <> NC.AuditTableDataType then 'DataType Mismatch'
														when NC.MainTableCharLength > NC.AuditTableCharLength then 'Length in maintable is greater than Audit Table'
														when NC.MainTableCollation <> NC.AuditTableCollation then 'Collation Difference'
													end
								   ) as Mismatch
							,NC.MainTableColumnName
							,NC.MainTableDataType
							,NC.MainTableCharLength
							,NC.MainTableCollation
							,NC.AuditTableColumnName
							,NC.AuditTableDataType
							,NC.AuditTableCharLength
							,NC.AuditTableCollation
					from	@NewAddedCols NC
					where	NC.MainTableColumnName			   = NC.AuditTableColumnName
							and (
									NC.MainTableDataType	   <> NC.AuditTableDataType
									or	NC.MainTableCharLength > NC.AuditTableCharLength
									or	NC.MainTableCollation  <> NC.AuditTableCollation
								) ;
			
					raiserror('There are differences in Datatype or Lesser Length or Collation difference between the Main table and Audit Table. Please refer the output', 16, 1) ;
			
					if @IgnoreExistingColumnMismatch = 0
					begin
						return ;
					end ;
				end ;
			
				----------------------------------------------------------------------------------------------------------------------    
				-- Find the new and deleted columns   
				----------------------------------------------------------------------------------------------------------------------    
				if exists
				(
					select	*
					from	@NewAddedCols
					where	ChangeType is not null
				)
				begin
					select	@SQL = @SQL + 'ALTER TABLE ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + case
																												 when NC.ChangeType = 'Added' then ' ADD ' + quotename(NC.ColumnName) + ' ' + NC.DataType + ' ' + case
																																																					  when NC.DataType in
																																																					  (
																																																						  'char', 'varchar', 'nchar', 'nvarchar'
																																																					  )
																																																						   and	NC.CharLength = -1 then '(max) COLLATE ' + NC.Collation + ' NULL '
																																																					  when NC.DataType in
																																																					  (
																																																						  'char', 'varchar'
																																																					  ) then '(' + convert(varchar(5), NC.CharLength) + ') COLLATE ' + NC.Collation + ' NULL '
																																																					  when NC.DataType in
																																																					  (
																																																						  'nchar', 'nvarchar'
																																																					  ) then '(' + convert(varchar(5), NC.CharLength / 2) + ') COLLATE ' + NC.Collation + ' NULL '
																																																					  else ''
																																																				  end
																												 when NC.ChangeType = 'Deleted' then ' DROP COLUMN ' + quotename(NC.ColumnName)
																											 end + char(10)
					from	@NewAddedCols NC
					where	NC.ChangeType is not null ;
				end ;
			end ;
			else
			begin
				select	@SQL = '  IF EXISTS (SELECT 1     
			                                          FROM sys.objects     
			                                         WHERE Name=''' + @AuditTableName + '''    
			                                           AND Schema_id=Schema_id(''' + @Schemaname + ''')    
			                                           AND Type = ''U'')    
			                            DROP TABLE ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + ' 
			   
			                    SELECT ' + @ColList + '    
			                        ,AuditDataState=CONVERT(VARCHAR(10),'''')     
			                        ,AuditDMLAction=CONVERT(VARCHAR(10),'''')      
			                        ,AuditUser =CONVERT(SYSNAME,'''')    
			                        ,AuditDateTime=CONVERT(DATETIME,''01-JAN-1900'')    
			                        ,UpdateColumns = CONVERT(VARCHAR(MAX),'''')   
			                        Into ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + '    
			                    FROM ' + @QuotedSchemaName + '.' + @QuotedTableName + '    
			                    WHERE 1=2 ' ;
			end ;
			
			if @GenerateScriptOnly = 1
			begin
				print replicate('-', 200) ;
				print '--Create \ Alter Script Audit table for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
				print replicate('-', 200) ;
				print @SQL ;
			
				if ltrim(rtrim(@SQL)) <> ''
				begin
					print 'GO' ;
				end ;
				else
				begin
					print '-- No changes in table structure' ;
				end ;
			end ;
			else
			begin
				if rtrim(ltrim(@SQL)) = ''
				begin
					print 'No Table Changes Found' ;
				end ;
				else
				begin
					print 'Creating \ Altered Audit table for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
			
					exec (@SQL) ;
			
					print 'Audit table ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + ' Created \ Altered succesfully' ;
				end ;
			end ;
			
			----------------------------------------------------------------------------------------------------------------------    
			-- Create Insert Trigger    
			----------------------------------------------------------------------------------------------------------------------    
			select	@SQL = '    
			IF EXISTS (SELECT 1     
			             FROM sys.objects     
			            WHERE Name=''' + @Tablename + '_Insert' + '''    
			              AND Schema_id=Schema_id(''' + @Schemaname + ''')    
			              AND Type = ''TR'')    
			DROP TRIGGER ' + @QuotedSchemaName + '.' + @QuotedInsertTriggerName ;
			
			select	@SQLTrigger = '    
			CREATE TRIGGER ' + @QuotedSchemaName + '.' + @QuotedInsertTriggerName + ' 
			ON ' + @QuotedSchemaName + '.' + @QuotedTableName + '    
			FOR INSERT    
			AS    
			' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' IF SUSER_NAME() NOT IN (''' + @DontAuditforUsersTmp + ''')' ;
			
				select	@SQLTrigger = @SQLTrigger + char(10) + ' BEGIN' ;
			end ;
			
			select	@SQLTrigger = @SQLTrigger + char(10) + ' INSERT INTO ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + char(10) + '(' + @InsertColList + ')' + char(10) + 'SELECT ' + @ColList + ',''New'',''Insert'',SUSER_SNAME(),getdate(),''''  FROM INSERTED ' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' END' ;
			end ;
			
			if @GenerateScriptOnly = 1
			begin
				print replicate('-', 200) ;
				print '--Create Script Insert Trigger for ' + @QuotedSchemaName + '.' + @QuotedTablename ;
				print replicate('-', 200) ;
				print @SQL ;
				print 'GO' ;
				print @SQLTrigger ;
				print 'GO' ;
			end ;
			else
			begin
				print 'Creating Insert Trigger ' + @QuotedInsertTriggerName + '  for ' + @QuotedSchemaName + '.' + @QuotedTablename ;
			
				exec (@SQL) ;
			
				exec (@SQLTrigger) ;
			
				print 'Trigger ' + @QuotedSchemaName + '.' + @QuotedInsertTriggerName + ' Created succesfully' ;
			end ;
			
			----------------------------------------------------------------------------------------------------------------------    
			-- Create Delete Trigger    
			----------------------------------------------------------------------------------------------------------------------    
			select	@SQL = '    
			    
			IF EXISTS (SELECT 1     
			             FROM sys.objects     
			            WHERE Name=''' + @Tablename + '_Delete' + '''    
			              AND Schema_id=Schema_id(''' + @Schemaname + ''')    
			              AND Type = ''TR'')    
			DROP TRIGGER ' + @QuotedSchemaName + '.' + +@QuotedDeleteTriggerName + '    
			' ;
			
			select	@SQLTrigger = '    
			CREATE TRIGGER ' + @QuotedSchemaName + '.' + @QuotedDeleteTriggerName + '    
			ON ' + @QuotedSchemaName + '.' + @QuotedTableName + '    
			FOR DELETE    
			AS   ' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' IF SUSER_NAME() NOT IN (''' + @DontAuditforUsersTmp + ''')' ;
			
				select	@SQLTrigger = @SQLTrigger + char(10) + ' BEGIN' ;
			end ;
			
			select	@SQLTrigger = @SQLTrigger + char(10) + '  INSERT INTO ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + char(10) + '(' + @InsertColList + ')' + char(10) + 'SELECT ' + @ColList + ',''Old'',''Delete'',SUSER_SNAME(),getdate(),''''  FROM DELETED' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' END' ;
			end ;
			
			if @GenerateScriptOnly = 1
			begin
				print replicate('-', 200) ;
				print '--Create Script Delete Trigger for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
				print replicate('-', 200) ;
				print @SQL ;
				print 'GO' ;
				print @SQLTrigger ;
				print 'GO' ;
			end ;
			else
			begin
				print 'Creating Delete Trigger ' + @QuotedDeleteTriggerName + '  for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
			
				exec (@SQL) ;
			
				exec (@SQLTrigger) ;
			
				print 'Trigger ' + @QuotedSchemaName + '.' + @QuotedDeleteTriggerName + ' Created succesfully' ;
			end ;
			
			----------------------------------------------------------------------------------------------------------------------    
			-- Create Update Trigger    
			----------------------------------------------------------------------------------------------------------------------    
			select	@SQL = '    
			    
			IF EXISTS (SELECT 1     
			             FROM sys.objects     
			            WHERE Name=''' + @Tablename + '_Update' + '''    
			              AND Schema_id=Schema_id(''' + @Schemaname + ''')    
			              AND Type = ''TR'')    
			DROP TRIGGER ' + @QuotedSchemaName + '.' + @QuotedUpdateTriggerName + '    
			' ;
			
			select	@SQLTrigger = '    
			CREATE TRIGGER ' + @QuotedSchemaName + '.' + @QuotedUpdateTriggerName + '      
			ON ' + @QuotedSchemaName + '.' + @QuotedTableName + '    
			FOR UPDATE    
			AS ' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' IF SUSER_NAME() NOT IN (''' + @DontAuditforUsersTmp + ''')' ;
			
				select	@SQLTrigger = @SQLTrigger + char(10) + ' BEGIN' ;
			end ;
			
			select	@SQLTrigger = @SQLTrigger + char(10) + '   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols = ' + @UpdateCheck + ' 
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '''' 
			   BEGIN 
			          INSERT INTO ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + char(10) + '(' + @InsertColList + ')' + char(10) + 'SELECT ' + @ColList + ',''New'',''Update'',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO ' + @QuotedSchemaName + '.' + @QuotedAuditTableName + char(10) + '(' + @InsertColList + ')' + char(10) + 'SELECT ' + @ColList + ',''Old'',''Update'',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END' ;
			
			if ltrim(rtrim(@DontAuditforUsersTmp)) <> ''
			begin
				select	@SQLTrigger = @SQLTrigger + char(10) + ' END' ;
			end ;
			
			if @GenerateScriptOnly = 1
			begin
				print replicate('-', 200) ;
				print '--Create Script Update Trigger for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
				print replicate('-', 200) ;
				print @SQL ;
				print 'GO' ;
				print @SQLTrigger ;
				print 'GO' ;
			end ;
			else
			begin
				print 'Creating Delete Trigger ' + @QuotedUpdateTriggerName + '  for ' + @QuotedSchemaName + '.' + @QuotedTableName ;
			
				exec (@SQL) ;
			
				exec (@SQLTrigger) ;
			
				print 'Trigger ' + @QuotedSchemaName + '.' + @QuotedUpdateTriggerName + '  Created succesfully' ;
			end ;

		end
	
		fetch next from curr_generate_triggers_all_table
		into	@Tablename

	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_generate_triggers_all_table') >= -1
		begin
			if cursor_status('global', 'curr_generate_triggers_all_table') > -1
			begin
				close curr_generate_triggers_all_table ;
			end ;

			deallocate curr_generate_triggers_all_table ;
		end ;
	end ;

set nocount off ;
