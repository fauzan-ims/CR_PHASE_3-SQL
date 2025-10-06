CREATE PROCEDURE dbo.xsp_validation_procedure_and_view
as
begin
      begin transaction
	-- (+) 27/08/2019 5:44:01 PM Hari -	sp untuk validasi sp valid	
      declare @scripts table
              (
               Name nvarchar(max)
              ,Command nvarchar(max)
              ,[Type] nvarchar(1)
              ,[stat] nvarchar(max)
              )

      declare @name nvarchar(max)
             ,@command nvarchar(max)
             ,@type nvarchar(1)
             ,@stat nvarchar(max)
             ,@err nvarchar(max)                

      insert   into @scripts
               (
                Name
               ,Command
               ,[Type]
               )
      select   P.name
              ,M.definition
              ,'P'
      from     sys.procedures P
               join sys.sql_modules M on P.object_id = M.object_id

      insert   into @scripts
               (
                Name
               ,Command
               ,[Type]
					
               )
      select   V.name
              ,M.definition
              ,'V'
      from     sys.views V
               join sys.sql_modules M on V.object_id = M.object_id

      declare curs cursor
      for
      select   Name
              ,Command
              ,[Type]
      from     @scripts

      open curs

      fetch next from curs
into @name ,@command ,@type


      while @@FETCH_STATUS = 0
            begin
                  begin try
                      
                        if @type = 'P'
                           set @command = replace(@command ,'CREATE PROCEDURE' ,
                                                  'ALTER PROCEDURE')
                        else
                           set @command = replace(@command ,'CREATE VIEW' ,
                                                  'ALTER VIEW')
                        
                        exec sp_executesql
                           @command
                        
                        update   @scripts
                        set      [stat] = 'OK'
                        where    Name = @name

                  end try
                  begin catch
                        set @err = 'FAILED: '
                            + cast(error_number() as nvarchar(max)) + ' '
                            + error_message()
                        update   @scripts
                        set      [stat] = @err
                        where    Name = @name
                  end catch

                  fetch next from curs
				into @name ,@command ,@type
            end

     
      close curs 
      deallocate curs

      select   Name
              ,stat
      from     @scripts where stat <> 'OK'
      rollback transaction
 
end
