CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinopl_asset_replacement]
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@id_interface	   bigint
		,@code_sys_job	   nvarchar(50)
		,@last_id		   bigint		 = 0
		,@number_rows	   int			 = 0
		,@is_active		   nvarchar(1)
		,@current_mod_date datetime
		,@mod_date		   datetime		 = getdate()
		,@mod_by		   nvarchar(15)	 = N'job'
		,@mod_ip_address   nvarchar(15)	 = N'127.0.0.1'
		,@from_id		   bigint		 = 0
		,@code			   nvarchar(50)
		,@agreement_no	   nvarchar(50)
		,@asset_no		   nvarchar(50)
		,@branch_code	   nvarchar(50)
		,@branch_name	   nvarchar(250)
		,@date			   datetime
		,@remark		   nvarchar(4000)
		,@code_interface   nvarchar(50) ;

select	@code_sys_job	   = code
		,@row_to_process   = row_to_process
		,@last_id_from_job = last_id
		,@is_active		   = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinopl_asset_replacement' ;	-- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	declare curr_asset_replacement cursor for
	select		agreement_no
				,date
				,branch_code
				,branch_name
				,remark
				,code
				,id
	from		dbo.opl_interface_asset_replacement
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset_replacement ;

	fetch next from curr_asset_replacement
	into @agreement_no
		 ,@date
		 ,@branch_code
		 ,@branch_name
		 ,@remark
		 ,@code_interface
		 ,@id_interface

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			exec dbo.xsp_asset_replacement_insert @p_code				= @code output
												  ,@p_agreement_no		= @agreement_no
												  ,@p_date				= @date
												  ,@p_branch_code		= @branch_code
												  ,@p_branch_name		= @branch_name
												  ,@p_remark			= @remark
												  ,@p_from_monitoring	= '0'
													--
												  ,@p_cre_date			= @mod_date
												  ,@p_cre_by			= @mod_by
												  ,@p_cre_ip_address	= @mod_ip_address
												  ,@p_mod_date			= @mod_date
												  ,@p_mod_by			= @mod_by
												  ,@p_mod_ip_address	= @mod_ip_address ;

			insert into dbo.asset_replacement_detail
			(
				replacement_code
				,old_asset_no
				,new_fa_code
				,new_fa_name
				,new_fa_ref_no_01
				,new_fa_ref_no_02
				,new_fa_ref_no_03
				,replacement_type
				,reason_code
				,estimate_return_date
				,old_handover_in_date
				,old_handover_out_date
				,new_handover_out_date
				,new_handover_in_date
				,remark
				,reff_no
				,delivery_address
				,contact_name
				,contact_phone_no
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,old_asset_no
					,new_fa_code
					,new_fa_name
					,new_fa_ref_no_01
					,new_fa_ref_no_02
					,new_fa_ref_no_03
					,replacement_type
					,reason_code
					,estimate_return_date
					,old_handover_in_date
					,old_handover_out_date
					,new_handover_out_date
					,new_handover_in_date
					,remark
					,reff_no
					,delivery_address
					,contact_name
					,contact_phone_no
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.opl_interface_asset_replacement_detail
			where	replacement_code = @code_interface ;

			update	dbo.opl_interface_asset_replacement
			set		job_status = 'POST'
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.opl_interface_asset_replacement --cek poin
			set		job_status = 'FAILED'
					,failed_remark = @msg
			where	id = @id_interface ;	--cek poin	

			print @msg ;

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date	--cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id				--cek poin
													 ,@p_to_id = @id_interface			--cek poin
													 ,@p_number_of_rows = @number_rows	--cek poin
													 ,@p_cre_date = @current_mod_date	--cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date	--cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_asset_replacement
		into @agreement_no
		 ,@date
		 ,@branch_code
		 ,@branch_name
		 ,@remark
		 ,@code_interface 
		 ,@id_interface
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset_replacement') >= -1
		begin
			if cursor_status('global', 'curr_asset_replacement') > -1
			begin
				close curr_asset_replacement ;
			end ;

			deallocate curr_asset_replacement ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		set @current_mod_date = getdate() ;

		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date	--cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = 'job'
												 ,@p_from_id = @from_id				--cek poin
												 ,@p_to_id = @last_id				--cek poin
												 ,@p_number_of_rows = @number_rows	--cek poin
												 ,@p_cre_date = @current_mod_date	--cek poin
												 ,@p_cre_by = 'job'
												 ,@p_cre_ip_address = '127.0.0.1'
												 ,@p_mod_date = @current_mod_date	--cek poin
												 ,@p_mod_by = 'job'
												 ,@p_mod_ip_address = '127.0.0.1' ;
	end ;
end ;
