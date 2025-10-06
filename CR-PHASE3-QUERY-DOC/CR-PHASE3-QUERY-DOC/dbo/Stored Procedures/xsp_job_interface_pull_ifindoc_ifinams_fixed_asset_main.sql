/*
exec xsp_job_interface_pull_ifindoc_ifinams_fixed_asset_main
*/
-- Louis Senin, 13 Februari 2023 15.58.22 -- 
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifindoc_ifinams_fixed_asset_main
as

	declare @msg				 nvarchar(max)
			,@id_interface		 bigint --cursor
			,@row_to_process	 int
			,@last_id		     bigint			= 0
			,@last_id_from_job   bigint 
			,@code_sys_job	     nvarchar(50)
			,@number_rows	     int			= 0
			,@is_active			 nvarchar(1)
			,@asset_no			 nvarchar(50)
			,@current_mod_date	 datetime
			,@from_id		     bigint			= 0
			,@mod_date		     datetime		= getdate()
			,@mod_by		     nvarchar(50)	= 'Admin'
			,@mod_ip_address     nvarchar(50)	= '127.0.0'; 
								 
	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifindoc_ifinams_fixed_asset_main' 

	if (@is_active = '1')
	begin
	
		--module core interface plafond main out
		declare cur_inscorefixedassetmain cursor for

		select		id
					,asset_no
		from		ifinams.dbo.ams_interface_asset_main
		where		id > @last_id_from_job
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open cur_inscorefixedassetmain		
		fetch next from cur_inscorefixedassetmain 
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
					
					--get data from module core 
					insert into dbo.doc_interface_fixed_asset_main
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
							,'HOLD'
							,''
							--
							,@mod_date
							,@mod_by
							,@mod_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address
					from	ifinams.dbo.ams_interface_asset_main
					where	asset_no = @asset_no ;
				
					set @number_rows =+ 1
					set @last_id = @id_interface ;
						
				commit transaction fixed_asset_main
			end try
			begin catch
					rollback transaction FIXED_ASSET_MAIN

					set @msg = error_message();

					update dbo.doc_interface_fixed_asset_main
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
					close cur_inscorefixedassetmain
					deallocate cur_inscorefixedassetmain

					--stop looping
					break ;
				end catch ;

			fetch next from cur_inscorefixedassetmain 
			into @id_interface
				 ,@asset_no
		end

		begin -- close cursor
			if cursor_status('global', 'cur_inscorefixedassetmain') >= -1
			begin
				if cursor_status('global', 'cur_inscorefixedassetmain') > -1
				begin
					close cur_inscorefixedassetmain ;
				end ;

				deallocate cur_inscorefixedassetmain ;
			end ;
		end ;

		if (@last_id > 0)
		begin
			update dbo.sys_job_tasklist 
			set    last_id = @last_id 
			where  code = @code_sys_job

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
