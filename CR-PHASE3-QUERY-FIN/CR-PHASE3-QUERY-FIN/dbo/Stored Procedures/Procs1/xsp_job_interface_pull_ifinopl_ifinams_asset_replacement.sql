CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinopl_ifinams_asset_replacement]
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@last_id		   bigint		= 0
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@request_code	   nvarchar(50)
		,@id_interface	   bigint
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = N'job'
		,@mod_ip_address   nvarchar(15) = N'127.0.0.1'
		,@current_mod_date datetime
		,@from_id		   bigint		= 0
		,@code			   nvarchar(50) ;

begin try
	-- sesuai dengan nama sp ini
	select	@code_sys_job	   = code
			,@row_to_process   = row_to_process
			,@last_id_from_job = last_id
			,@is_active		   = is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinams_asset_replacement' ;

	if (@is_active <> '0')
	begin
		declare curr_additional_invoice cursor for
		select		id
		from		ifinams.dbo.ams_interface_asset_replacement
		where		id			   > @last_id_from_job
					and job_status = 'HOLD'
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_additional_invoice ;

		fetch next from curr_additional_invoice
		into @id_interface ;

		while @@fetch_status = 0
		begin
			begin try
				begin transaction ;

				if (@number_rows = 0)
				begin
					set @from_id = @id_interface ;
				end ;

				insert into dbo.opl_interface_asset_replacement
				(
					code
					,agreement_no
					,date
					,branch_code
					,branch_name
					,remark
					,status
					,job_status
					,failed_remark
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	code
						,agreement_no
						,date
						,branch_code
						,branch_name
						,remark
						,status
						,'HOLD'
						,''
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	ifinams.dbo.ams_interface_asset_replacement
				where	id = @id_interface ;

				select	@code = code
				from	ifinams.dbo.ams_interface_asset_replacement
				where	id = @id_interface ;

				insert into dbo.opl_interface_asset_replacement_detail
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
				select	replacement_code
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
						,ref_no
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
				from	ifinams.dbo.ams_interface_asset_replacement_detail
				where	replacement_code = @code ;

				update	ifinams.dbo.ams_interface_asset_replacement
				set		job_status = 'POST'
				where	id = @id_interface ;

				set @number_rows = +1 ;
				set @last_id = @id_interface ;

				commit transaction ;
			end try
			begin catch
				rollback transaction ;

				set @msg = error_message() ;

				update	ifinams.dbo.ams_interface_asset_replacement
				set		job_status = 'FAILED'
						,failed_remark = @msg
				where	id = @id_interface ;

				set @current_mod_date = getdate() ;

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

				--clear cursor when error
				close curr_additional_invoice ;
				deallocate curr_additional_invoice ;

				--stop looping
				break ;
			end catch ;

			fetch next from curr_additional_invoice
			into @id_interface ;
		end ;

		begin -- close cursor
			if cursor_status('global', 'curr_additional_invoice') >= -1
			begin
				if cursor_status('global', 'curr_additional_invoice') > -1
				begin
					close curr_additional_invoice ;
				end ;

				deallocate curr_additional_invoice ;
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
end try
begin catch
	declare @error int ;

	set @error = @@error ;

	if (@error = 2627)
	begin
		set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
	end ;

	if (len(@msg) <> 0)
	begin
		set @msg = N'V' + N';' + @msg ;
	end ;
	else
	begin
		if (
			   error_message() like '%V;%'
			   or	error_message() like '%E;%'
		   )
		begin
			set @msg = error_message() ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;
	end ;

	raiserror(@msg, 16, -1) ;

	return ;
end catch ;
