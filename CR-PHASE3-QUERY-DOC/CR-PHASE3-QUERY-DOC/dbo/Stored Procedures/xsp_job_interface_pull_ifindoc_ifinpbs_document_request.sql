CREATE PROCEDURE dbo.xsp_job_interface_pull_ifindoc_ifinpbs_document_request
as

	declare @row_to_process			int
			,@msg				    nvarchar(max)
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@last_id				bigint	= 0 
			,@number_rows			int		= 0 
			,@current_mod_date	    datetime
			,@is_active				nvarchar(1)
			,@from_id		        bigint			= 0
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1' ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifindoc_ifinpbs_document_request' -- sesuai dengan nama sp ini
	
	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_document_request cursor for

			select 		id
			from		ifinpbs.dbo.pbs_interface_document_request
			where		id > @last_id_from_job
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_document_request
			
		fetch next from curr_document_request 
		into @id_interface
		
		while @@fetch_status = 0
			begin
				begin try
					begin transaction

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					insert into dbo.doc_interface_document_request
					(
						code
						,request_branch_code
						,request_branch_name
						,request_type
						,request_location
						,request_from
						,request_to
						,request_by
						,request_status
						,request_date
						,remarks
						,document_code
						,process_date
						,process_reff_no
						,process_reff_name
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	code
							,request_branch_code
							,request_branch_name
							,request_type
							,request_location
							,request_from
							,request_to
							,request_by
							,request_status
							,request_date
							,remarks
							,document_code
							,process_date
							,process_reff_no
							,process_reff_name
							,@mod_date
							,@mod_by
							,@mod_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address 
					from	ifinpbs.dbo.pbs_interface_document_request
					where	id = @id_interface

					set @number_rows =+ 1
					set @last_id = @id_interface

					commit transaction
				end try
				begin catch

					rollback transaction 
					
					set @msg = error_message();

					update dbo.doc_interface_document_request
					set		job_status		= 'FAILED'
							,failed_remark	= @msg
					where	id				= @id_interface

					/*insert into dbo.sys_job_tasklist_log*/
					set @current_mod_date = getdate();
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
																,@p_status				= 'Error'
																,@p_start_date			= @mod_date
																,@p_end_date			= @current_mod_date --cek poin
																,@p_log_description		= @msg
																,@p_run_by				= @mod_by
																,@p_from_id				= @from_id  --cek poin
																,@p_to_id				= @id_interface --cek poin
																,@p_number_of_rows		= @number_rows --cek poin
																,@p_cre_date			= @current_mod_date--cek poin
																,@p_cre_by				= @mod_by
																,@p_cre_ip_address		= @mod_ip_address
																,@p_mod_date			= @current_mod_date--cek poin
																,@p_mod_by				= @mod_by
																,@p_mod_ip_address		= @mod_ip_address  ;

					--clear cursor when error
					close curr_document_request
					deallocate curr_document_request

					--stop looping
					break ;
				end catch ;   
	
				fetch next from curr_document_request
				into @id_interface

			end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_document_request') >= -1
		begin
			if cursor_status('global', 'curr_document_request') > -1
			begin
				close curr_document_request ;
			end ;

			deallocate curr_document_request ;
		end ;
	end ;

	if (@last_id > 0)
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													, @p_status				= 'Success'
													, @p_start_date			= @mod_date
													, @p_end_date			= @current_mod_date --cek poin
													, @p_log_description	= ''
													, @p_run_by				= @mod_by
													, @p_from_id			= @last_id --cek poin
													, @p_to_id				= @last_id --cek poin
													, @p_number_of_rows		= @number_rows --cek poin
													, @p_cre_date			= @current_mod_date --cek poin
													, @p_cre_by				= @mod_by
													, @p_cre_ip_address		= @mod_ip_address
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= @mod_by
													, @p_mod_ip_address		= @mod_ip_address
					    
		end
	end
