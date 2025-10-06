/*
exec xsp_job_interface_in_ifindoc_fixed_asset_main
*/
-- Louis Senin, 13 Februari 2023 15.38.42 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_fixed_asset_main
as

	declare @msg				nvarchar(max)
			,@id_interface		bigint --cursor
			,@row_to_process	int
			,@last_id		    bigint	= 0
			,@last_id_from_job  bigint 
			,@code_sys_job	    nvarchar(50)
			,@number_rows	    int		= 0
			,@row_count		    int     = 0
			,@is_active			nvarchar(1)
			,@asset_no			nvarchar(50)
			,@mod_date		    datetime    = getdate()
			,@mod_by		    nvarchar(50) = 'Admin'
			,@mode_address      nvarchar(50) = '127.0.0'
			,@from_id		    bigint		 = 0
			,@current_mod_date	datetime; 

	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifindoc_fixed_asset_main' 

	if (@is_active = '1')
	begin
		--module core interface plafond main out
		declare cur_insfixedassetmain cursor for
		
			select 	id
			        ,asset_no
			from	dbo.doc_interface_fixed_asset_main
			where	job_status in ('HOLD','FAILED')
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_insfixedassetmain		
		fetch next from cur_insfixedassetmain 
		into @id_interface
			 ,@asset_no
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					insert into dbo.fixed_asset_main
					(
						asset_no
						,asset_type_code
						,asset_name
						,asset_condition
						,market_value
						,asset_value
						,doc_asset_no
						,asset_year
						,reff_no_1
						,reff_no_2
						,reff_no_3
						,vendor_code
						,vendor_name
						,vendor_address
						,vendor_pic_name
						,vendor_pic_area_phone_no
						,vendor_pic_phone_no
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					) 
					select	asset_no
							,asset_type_code
							,asset_name
							,asset_condition
							,market_value
							,asset_value
							,doc_asset_no
							,asset_year
							,reff_no_1
							,reff_no_2
							,reff_no_3
							,vendor_code
							,vendor_name
							,vendor_address
							,vendor_pic_name
							,vendor_pic_area_phone_no
							,vendor_pic_phone_no
							--
							,@mod_date
							,@mod_by
							,@mode_address
							,@mod_date
							,@mod_by
							,@mode_address
					from	dbo.doc_interface_fixed_asset_main
					where	asset_no = @asset_no ;

					set @number_rows =+ 1
					set @last_id = @id_interface ;

					update	dbo.doc_interface_fixed_asset_main  --cek poin
					set		job_status = 'POST'
					where	id = @id_interface	

				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = error_message();
				
					update	dbo.doc_interface_fixed_asset_main  --cek poin
					set		job_status		= 'FAILED'
							,failed_remark  = @msg
					where	id = @id_interface --cek poin	

					/*insert into dbo.sys_job_tasklist_log*/
					set @current_mod_date = getdate();
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
																,@p_status				= N'Error'
																,@p_start_date			= @mod_date
																,@p_end_date			= @current_mod_date--cek poin
																,@p_log_description		= @msg
																,@p_run_by				= @mod_by
																,@p_from_id				= @from_id  --cek poin
																,@p_to_id				= @id_interface --cek poin
																,@p_number_of_rows		= @number_rows --cek poin
																,@p_cre_date			= @current_mod_date--cek poin
																,@p_cre_by				= @mod_by
																,@p_cre_ip_address		= @mode_address
																,@p_mod_date			= @current_mod_date--cek poin
																,@p_mod_by				= @mod_by
																,@p_mod_ip_address		= @mode_address  ;

			end catch

			fetch next from cur_insfixedassetmain 
			into @id_interface
				 ,@asset_no
		end

		begin -- close cursor
			if cursor_status('global', 'cur_insfixedassetmain') >= -1
			begin
				if cursor_status('global', 'cur_insfixedassetmain') > -1
				begin
					close cur_insfixedassetmain ;
				end ;

				deallocate cur_insfixedassetmain ;
			end ;
		end ;
	
		if (@last_id > 0)--cek poin
		begin
			update dbo.sys_job_tasklist 
			set    last_id = @last_id 
			where  code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= 'Success'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date--cek poin
													 ,@p_log_description	= ''
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id  --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date--cek poin
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mode_address
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mode_address 
					    
		end
	end

