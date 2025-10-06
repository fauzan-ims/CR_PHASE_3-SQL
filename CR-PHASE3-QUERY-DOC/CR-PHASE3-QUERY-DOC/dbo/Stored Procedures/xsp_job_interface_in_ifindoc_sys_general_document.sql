create PROCEDURE dbo.xsp_job_interface_in_ifindoc_sys_general_document
as

	declare @msg						nvarchar(max)
			,@row_to_process			int
			,@last_id_from_job			bigint
			,@id_interface				bigint
			,@code						nvarchar(50) 
			,@name						nvarchar(250) 
			,@status					nvarchar(10) 
			,@email						nvarchar(200)
			,@last_id					bigint	= 0
			,@code_sys_job				nvarchar(50)
			,@number_rows				int		= 0 
			,@is_active					nvarchar(1)
			,@mod_date					datetime		= getdate()
			,@mod_by					nvarchar(15)	= 'job'
			,@mod_ip_address			nvarchar(15)	= '127.0.0.1' 
			,@from_id					bigint			= 0
			,@current_mod_date			datetime; 

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifindoc_sys_general_document' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_sys_general_document cursor for

		select 		id
					,code
					,document_name
		from		dbo.doc_interface_sys_general_document
		where		job_status in ('HOLD','FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_sys_general_document
			
	fetch next from curr_sys_general_document 
	into	@id_interface
			,@code
			,@name
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			if exists (select 1 from dbo.sys_general_document where code = @code)
			begin
				update	dbo.sys_general_document
				set		code				= @code
						,document_name		= @name
				where	code				= @code 
			end
			else
			begin
				insert into dbo.sys_general_document
				(
					code
					,document_name
					,is_temp
					,is_physical
					,is_allow_out
					,is_collateral
					,is_active
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select code
					  ,document_name
					  ,'1'
					  ,'1'
					  ,'1'
					  ,'1'
					  ,'1'
					  ,@mod_date			
					  ,@mod_by			
					  ,@mod_ip_address	
					  ,@mod_date			
					  ,@mod_by			
					  ,@mod_ip_address	
				from   dbo.doc_interface_sys_general_document
				where  id = @id_interface
			end
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			update	dbo.doc_interface_sys_general_document  --cek poin
			set		job_status = 'POST'
			where	id = @id_interface	

			commit transaction
		end try
		begin catch

			rollback transaction 
			set @msg = error_message();
			set @current_mod_date = getdate();

			update	dbo.doc_interface_sys_general_document  --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface --cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= 'job'
													 ,@p_from_id			= @from_id  --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date--cek poin
													 ,@p_cre_by				= N'job'
													 ,@p_cre_ip_address		= N'127.0.0.1'
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= N'job'
													 ,@p_mod_ip_address		= N'127.0.0.1'  ;

		end catch   
	
		fetch next from curr_sys_general_document
		into	@id_interface
				,@code
				,@name

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_sys_general_document') >= -1
		begin
			if cursor_status('global', 'curr_sys_general_document') > -1
			begin
				close curr_sys_general_document ;
			end ;

			deallocate curr_sys_general_document ;
		end ;
	end ;

	if (@last_id > 0)--cek poin
		begin
			set @current_mod_date = getdate();
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													, @p_status				= 'Success'
													, @p_start_date			= @mod_date
													, @p_end_date			= @current_mod_date --cek poin
													, @p_log_description	= ''
													, @p_run_by				= 'job'
													, @p_from_id			= @from_id --cek poin
													, @p_to_id				= @last_id --cek poin
													, @p_number_of_rows		= @number_rows --cek poin
													, @p_cre_date			= @current_mod_date --cek poin
													, @p_cre_by				= 'job'
													, @p_cre_ip_address		= '127.0.0.1'
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= 'job'
													, @p_mod_ip_address		= '127.0.0.1'
					    
		end
	end
