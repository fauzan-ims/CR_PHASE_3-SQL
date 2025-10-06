/*
	exec dbo.xsp_job_interface_pull_ifinopl_ifinbam_master_item
*/
-- Louis Kamis, 05 Januari 2023 10.53.04 --
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinbam_master_item
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
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@current_mod_date datetime
		,@from_id		   bigint		= 0 ;
	
	begin try
		-- sesuai dengan nama sp ini
		select	@code_sys_job = code
				,@row_to_process = row_to_process
				,@last_id_from_job = last_id
				,@is_active = is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinbam_master_item' ;

		if (@is_active <> '0')
		begin
			--get cashier received request
			declare curr_master_item cursor for
			select		id
						,item_code
			from		ifinbam.dbo.bam_interface_master_item
			where		id			   > @last_id_from_job
						and job_status = 'HOLD'
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

			open curr_master_item ;

			fetch next from curr_master_item
			into @id_interface
				 ,@request_code ;

			while @@fetch_status = 0
			begin
				begin try
					begin transaction ;

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface ;
					end ;

					insert into dbo.opl_interface_master_item
					(
						type_asset_code
						,item_code
						,item_name
						,merk_code
						,merk_name
						,model_code
						,model_name
						,type_code
						,type_name
						,category_type
						,class_type_code
						,class_type_name
						,insurance_asset_type_code
						,insurance_asset_type_name
						,registration_class_type_code
						,registration_class_type_name
						,is_spaf
						,spaf_pct
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	type_asset_code
							,item_code
							,item_name
							,merk_code
							,merk_name
							,model_code
							,model_name
							,type_code
							,type_name 
							,category_type
							,class_type_code
							,class_type_name
							,insurance_asset_type_code
							,insurance_asset_type_name
							,registration_class_type_code
							,registration_class_type_name
							,is_spaf
							,spaf_pct
							--
							,@mod_date
							,@mod_by
							,@mod_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address
					from	ifinbam.dbo.bam_interface_master_item
					where	id = @id_interface ;

					update	ifinbam.dbo.bam_interface_master_item
					set		job_status = 'POST'
					where	id = @id_interface ;

					set @number_rows = +1 ;
					set @last_id = @id_interface ;

					commit transaction ;
				end try
				begin catch
					rollback transaction ;

					set @msg = error_message() ;
					select @msg
					update dbo.opl_interface_master_item
					set		job_status		= 'FAILED'
							,failed_remarks	= @msg
					where	id				= @id_interface
	
					set @current_mod_date = getdate() ;
					/*insert into dbo.sys_job_tasklist_log*/
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
															 ,@p_status				= N'Error'
															 ,@p_start_date			= @mod_date
															 ,@p_end_date			= @current_mod_date --cek poin
															 ,@p_log_description	= @msg
															 ,@p_run_by				= 'job'
															 ,@p_from_id			= @from_id --cek poin
															 ,@p_to_id				= @id_interface --cek poin
															 ,@p_number_of_rows		= @number_rows --cek poin
															 ,@p_cre_date			= @current_mod_date --cek poin
															 ,@p_cre_by				= N'job'
															 ,@p_cre_ip_address		= N'127.0.0.1'
															 ,@p_mod_date			= @current_mod_date --cek poin
															 ,@p_mod_by				= N'job'
															 ,@p_mod_ip_address		= N'127.0.0.1' ;

					--clear cursor when error
					close curr_master_item
					deallocate curr_master_item

					--stop looping
					break ;
				end catch ;

				fetch next from curr_master_item
				into @id_interface
					 ,@request_code ;
			end ;

			begin -- close cursor
				if cursor_status('global', 'curr_master_item') >= -1
				begin
					if cursor_status('global', 'curr_master_item') > -1
					begin
						close curr_master_item ;
					end ;

					deallocate curr_master_item ;
				end ;
			end ;

			if (@last_id > 0) --cek poin
			begin
				set @current_mod_date = getdate() ;

				update	dbo.sys_job_tasklist
				set		last_id = @last_id
				where	code = @code_sys_job ;

				/*insert into dbo.sys_job_tasklist_log*/
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
														 ,@p_status				= 'Success'
														 ,@p_start_date			= @mod_date
														 ,@p_end_date			= @current_mod_date --cek poin
														 ,@p_log_description	= ''
														 ,@p_run_by				= 'job'
														 ,@p_from_id			= @from_id --cek poin
														 ,@p_to_id				= @last_id --cek poin
														 ,@p_number_of_rows		= @number_rows --cek poin
														 ,@p_cre_date			= @current_mod_date --cek poin
														 ,@p_cre_by				= 'job'
														 ,@p_cre_ip_address		= '127.0.0.1'
														 ,@p_mod_date			= @current_mod_date --cek poin
														 ,@p_mod_by				= 'job'
														 ,@p_mod_ip_address		= '127.0.0.1' ;
			end ;
		end ;
	end try
	Begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
