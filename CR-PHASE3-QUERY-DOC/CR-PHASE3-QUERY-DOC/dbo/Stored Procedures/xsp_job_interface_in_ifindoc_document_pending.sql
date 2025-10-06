-- Louis Selasa, 04 Juli 2023 16.50.42 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_document_pending
as
declare @row_to_process		  int
		,@msg				  nvarchar(max)
		,@last_id_from_job	  bigint
		,@id_interface		  bigint
		,@code_sys_job		  nvarchar(50)
		,@last_id			  bigint	   = 0
		,@number_rows		  int		   = 0
		,@is_active			  nvarchar(1)
		,@asset_no			  nvarchar(50)
		,@code_pending		  nvarchar(50)
		,@from_id			  bigint	   = 0
		,@request_branch_code nvarchar(50)
		,@request_branch_name nvarchar(250)
		,@is_custody_branch	  nvarchar(1)
		,@custody_branch_code nvarchar(50)
		,@custody_branch_name nvarchar(250)
		,@branch_code		  nvarchar(50)
		,@branch_name		  nvarchar(250)
		,@initial_branch_code nvarchar(50)
		,@initial_branch_name nvarchar(250)
		,@current_mod_date	  datetime
		,@mod_date			  datetime	   = getdate()
		,@mod_by			  nvarchar(15) = 'job'
		,@mod_ip_address	  nvarchar(15) = '127.0.0.1' ;

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifindoc_document_pending' ;

if (@is_active = '1')
begin
	--get cashier received request
	declare curr_document_pending cursor for
	select		id
				,branch_code
				,branch_name
				,code
				,asset_no
	from		dbo.doc_interface_document_pending
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_document_pending ;

	fetch next from curr_document_pending
	into @id_interface
		 ,@request_branch_code
		 ,@request_branch_name
		 ,@code_pending 
		 ,@asset_no

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			select	@is_custody_branch = is_custody_branch
					,@custody_branch_code = custody_branch_code
					,@custody_branch_name = custody_branch_name
			from	dbo.sys_branch
			where	branch_code = @request_branch_code ;

			if (@is_custody_branch = '1')
			begin
				set @branch_code = @request_branch_code ;
				set @branch_name = @request_branch_name ;
				set @initial_branch_code = @request_branch_code ;
				set @initial_branch_name = @request_branch_name ;
			end ;
			else
			begin
				set @branch_code = @request_branch_code ;
				set @branch_name = @request_branch_name ;
				set @initial_branch_code = @custody_branch_code ;
				set @initial_branch_name = @custody_branch_name ;
			end ;
			 
			insert into  dbo.document_pending
			(
				code
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,document_type
				,document_status
				,asset_no
				,asset_name
				,cover_note_no
				,cover_note_date
				,cover_note_exp_date
				,file_name
				,file_path
				,entry_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	code
					,branch_code
					,branch_name
					,initial_branch_code
					,initial_branch_name
					,document_type
					,document_status
					,asset_no
					,asset_name
					,cover_note_no
					,cover_note_date
					,cover_note_exp_date
					,file_name
					,file_path
					,entry_date
					--
					,@mod_date		
					,@mod_by		
					,@mod_ip_address
					,@mod_date		
					,@mod_by		
					,@mod_ip_address
			from	dbo.doc_interface_document_pending
			where	id = @id_interface ; 

			---insert ke interface document pending detail
			insert into dbo.document_pending_detail
			(
				document_pending_code
				,document_name
				,document_description
				,file_name
				,paths
				,expired_date
				,is_temporary
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	document_pending_code
					,document_name
					,document_description
					,file_name
					,paths
					,expired_date
					,is_temporary
					--
					,@mod_date		
					,@mod_by		
					,@mod_ip_address
					,@mod_date		
					,@mod_by		
					,@mod_ip_address
			from	dbo.doc_interface_document_pending_detail
			where	document_pending_code = @code_pending ;

			insert into dbo.sys_document_upload
			(
				reff_no
				,reff_name
				,reff_trx_code
				,file_name
				,doc_file 
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	reff_no
					,reff_name
					,reff_trx_code
					,file_name
					,doc_file
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.doc_interface_sys_document_upload
			where	reff_no = @asset_no ;

			--end
			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.doc_interface_document_pending --cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.doc_interface_document_pending --cek poin
			set		job_status = 'FAILED'
					,failed_remark = @msg
			where	id = @id_interface ;

			print @msg

			--cek poin	
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = @mod_by
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mod_ip_address
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mod_ip_address ;
		end catch ;

		fetch next from curr_document_pending
		into @id_interface
			 ,@request_branch_code
			 ,@request_branch_name
			 ,@code_pending 
			 ,@asset_no
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_document_pending') >= -1
		begin
			if cursor_status('global', 'curr_document_pending') > -1
			begin
				close curr_document_pending ;
			end ;

			deallocate curr_document_pending ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = @msg
												 ,@p_run_by = @mod_by
												 ,@p_from_id = @from_id --cek poin
												 ,@p_to_id = @id_interface --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = @mod_by
												 ,@p_cre_ip_address = @mod_ip_address
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = @mod_by
												 ,@p_mod_ip_address = @mod_ip_address ;
	end ;
end ;


