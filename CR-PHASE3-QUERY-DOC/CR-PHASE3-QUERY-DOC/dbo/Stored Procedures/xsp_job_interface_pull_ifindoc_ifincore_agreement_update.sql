/*
	created : Nia, 22 April 2021
*/

CREATE procedure dbo.xsp_job_interface_pull_ifindoc_ifincore_agreement_update
as
declare @msg			   nvarchar(max)
		,@id_interface	   bigint --cursor
		,@row_to_process   int
		,@last_id		   bigint		= 0
		,@last_id_from_job bigint
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@current_mod_date datetime
		,@from_id		   bigint		= 0
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(50) = 'Admin'
		,@mode_address	   nvarchar(50) = '127.0.0' ;

select	@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@code_sys_job = code
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifindoc_ifincore_agreement_update' ;

if (@is_active = '1')
begin
	--module core interface agreement agreement main
	declare cur_doccoreagreementmainupdate cursor for
	select		id
	from		ifincore.dbo.core_interface_agreement_update_out
	where		id > @last_id_from_job
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open cur_doccoreagreementmainupdate ;

	fetch next from cur_doccoreagreementmainupdate
	into @id_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.doc_interface_agreement_update
			(
				agreement_no
				,agreement_status
				,agreement_sub_status
				,termination_date
				,termination_status
				,client_no
				,client_name
				,next_due_date
				,last_paid_period
				,last_installment_due_date
				,overdue_period
				,overdue_days
				,is_wo
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	agreement_no
					,agreement_status
					,agreement_sub_status
					,termination_date
					,termination_status
					,client_no
					,client_name
					,next_due_date
					,last_paid_period
					,last_installment_due_date
					,overdue_period
					,overdue_days
					,is_wo
					,@mod_date
					,@mod_by
					,@mode_address
					,@mod_date
					,@mod_by
					,@mode_address
			from	ifincore.dbo.core_interface_agreement_update_out
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.doc_interface_agreement_update
			set		job_status = 'FAILED'
					,failed_remark = @msg
			where	id = @id_interface ;

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = 'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = @mod_by
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mode_address
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mode_address ;

			--clear cursor when error
			close cur_doccoreagreementmainupdate ;
			deallocate cur_doccoreagreementmainupdate ;

			--stop looping
			break ;
		end catch ;

		fetch next from cur_doccoreagreementmainupdate
		into @id_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'cur_doccoreagreementmainupdate') >= -1
		begin
			if cursor_status('global', 'cur_doccoreagreementmainupdate') > -1
			begin
				close cur_doccoreagreementmainupdate ;
			end ;

			deallocate cur_doccoreagreementmainupdate ;
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
												 ,@p_cre_ip_address = @mode_address
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = @mod_by
												 ,@p_mod_ip_address = @mode_address ;
	end ;
end ;
