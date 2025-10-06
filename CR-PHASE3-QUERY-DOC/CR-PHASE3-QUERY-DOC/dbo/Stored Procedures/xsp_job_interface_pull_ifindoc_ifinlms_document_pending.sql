CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifindoc_ifinlms_document_pending]
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@id_interface	   bigint
		,@code			   nvarchar(50)
		,@code_sys_job	   nvarchar(50)
		,@last_id		   bigint		= 0
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@current_mod_date datetime
		,@from_id		   bigint		= 0
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1' ;

select	@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@code_sys_job = code
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifindoc_ifinlms_document_pending' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	declare curr_document_pending cursor for
	select		id
				,code
	from		ifinlms.dbo.lms_interface_document_pending
	where		id					> @last_id_from_job
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_document_pending ;

	fetch next from curr_document_pending
	into @id_interface
		 ,@code ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.doc_interface_document_pending
			(
				code
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,document_type
				,document_status
				,client_no
				,client_name
				,plafond_no
				,agreement_no
				,collateral_no
				,collateral_name
				,plafond_collateral_no
				,plafond_collateral_name
				,asset_no
				,asset_name
				,entry_date
				,job_status
				,failed_remark
				---
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	sr.code
					,sr.branch_code
					,sr.branch_name
					,sr.initial_branch_code
					,sr.initial_branch_name
					,sr.document_type
					,sr.document_status
					,sr.client_no
					,sr.client_name
					,sr.plafond_no
					,sr.agreement_no
					,sr.collateral_no
					,sr.collateral_name
					,sr.plafond_collateral_no
					,sr.plafond_collateral_name
					,sr.asset_no
					,sr.asset_name
					,isnull(sr.entry_date, getdate())
					,'HOLD'
					,''
					---
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	ifinlms.dbo.lms_interface_document_pending sr
			where	id = @id_interface ;
			
			insert into dbo.doc_interface_document_pending_detail
			(
				document_pending_code
				,document_name
				,document_description
				,file_name
				,paths
				,expired_date
				---
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	ldp.document_pending_code
					,ldp.document_name
					,ldp.document_description
					,ldp.file_name
					,ldp.paths
					,ldp.expired_date
					---
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	ifinlms.dbo.lms_interface_document_pending_detail ldp
			where	ldp.document_pending_code = @code ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update dbo.doc_interface_document_pending
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;
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
			close curr_document_pending
			deallocate curr_document_pending

			--stop looping
			break ;
		end catch ;

		fetch next from curr_document_pending
		into @id_interface
			 ,@code ;
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

	if (@last_id > 0)
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
												 ,@p_log_description = ''
												 ,@p_run_by = @mod_by
												 ,@p_from_id = @last_id --cek poin
												 ,@p_to_id = @last_id --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = @mod_by
												 ,@p_cre_ip_address = @mod_ip_address
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = @mod_by
												 ,@p_mod_ip_address = @mod_ip_address ;
	end ;
end ;
