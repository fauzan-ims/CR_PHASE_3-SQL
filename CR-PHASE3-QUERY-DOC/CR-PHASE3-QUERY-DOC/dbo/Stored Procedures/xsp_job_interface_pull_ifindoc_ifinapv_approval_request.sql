/*
exec xsp_job_interface_pull_ifindoc_ifinapv_approval_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifindoc_ifinapv_approval_request
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@last_id		   bigint		= 0
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@id_interface	   bigint
		,@code_interface   nvarchar(50)
		,@request_status   nvarchar(250)
		,@approval_status  nvarchar(250)
		,@approval_code	   nvarchar(50)
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@reff_no		   nvarchar(50)
		,@current_mod_date datetime
		,@from_id		   bigint		= 0 ;

select	@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@code_sys_job = code
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifindoc_ifinapv_approval_request' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	--get cashier received request
	declare curr_approval_request cursor for
	select		fpr.id
				,ppr.code
				,fpr.request_status
				,fpr.approval_status
				,fpr.approval_category_code
				,ppr.reff_no
	from		ifinapv.dbo.apv_interface_approval_request fpr
				inner join dbo.doc_interface_approval_request ppr on (
																		 ppr.code					= fpr.code
																		 and   ppr.reff_module_code = fpr.reff_module_code
																		 and   ppr.reff_no			= fpr.reff_no
																	 )
	where		fpr.request_status					= 'POST'
				and isnull(fpr.approval_status, '') <> ''
				and ppr.request_status				= 'HOLD'
	order by	fpr.id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_approval_request ;

	fetch next from curr_approval_request
	into @id_interface
		 ,@code_interface
		 ,@request_status
		 ,@approval_status
		 ,@approval_code
		 ,@reff_no ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			update	dbo.doc_interface_approval_request
			set		request_status			= @request_status
					,approval_status		= @approval_status
					,approval_category_code = @approval_code
					,mod_date				= @mod_date
					,mod_by					= @mod_by
					,mod_ip_address			= @mod_ip_address
			where	code					= @code_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			 --cek poin
			set @msg = error_message() ;
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;
			
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date
													 ,@p_log_description	= @msg
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id 
													 ,@p_to_id				= @id_interface
													 ,@p_number_of_rows		= @number_rows
													 ,@p_cre_date			= @current_mod_date 
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date 
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address  ;

			-- clear cursor when error
			close curr_approval_request ;
			deallocate curr_approval_request ;

			-- stop looping
			break ;
		end catch ;

		fetch next from curr_approval_request
		into @id_interface
			 ,@code_interface
			 ,@request_status
			 ,@approval_status
			 ,@approval_code
			 ,@reff_no ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_approval_request') >= -1
		begin
			if cursor_status('global', 'curr_approval_request') > -1
			begin
				close curr_approval_request ;
			end ;

			deallocate curr_approval_request ;
		end ;
	end ;

	--cek poin
	if (@last_id > 0)
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;
		
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= 'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date
												 ,@p_log_description	= ''
												 ,@p_run_by				= @mod_by
												 ,@p_from_id			= @from_id
												 ,@p_to_id				= @last_id
												 ,@p_number_of_rows		= @number_rows
												 ,@p_cre_date			= @current_mod_date
												 ,@p_cre_by				= @mod_by
												 ,@p_cre_ip_address		= @mod_ip_address
												 ,@p_mod_date			= @current_mod_date
												 ,@p_mod_by				= @mod_by
												 ,@p_mod_ip_address		= @mod_ip_address
	end ;
end ;
