/*
	created : Rizky, 16 September 2021
*/

CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_plafond_main
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
			,@plafond_code	    nvarchar(50)
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
	where	sp_name = 'xsp_job_interface_in_ifindoc_plafond_main' 

	if (@is_active = '1')
	begin
		--module core interface plafond main out
		declare cur_insplafondmain cursor for
		
			select 	id
			        ,code
			from	dbo.doc_interface_plafond_main
			where	job_status in ('HOLD','FAILED')
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_insplafondmain		
		fetch next from cur_insplafondmain 
		into @id_interface
			 ,@plafond_code
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					--get data from interface
					insert into dbo.plafond_main
					(
						code
						,branch_code
						,branch_name
						,plafond_no
						,plafond_date
						,plafond_name
						,plafond_status
						,marketing_code
						,marketing_name
						,client_no
						,client_name
						,currency_code
						,eff_date
						,exp_date
						,plafond_amount
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
							,plafond_no
							,plafond_date
							,plafond_name
							,plafond_status
							,marketing_code
							,marketing_name
							,client_no
							,client_name
							,currency_code
							,eff_date
							,exp_date
							,plafond_amount
							,@mod_date
							,@mod_by
							,@mode_address
							,@mod_date
							,@mod_by
							,@mode_address
					from	dbo.doc_interface_plafond_main
					where	id = @id_interface ;

					insert into dbo.plafond_collateral
					(
						collateral_no
						,plafond_code
						,collateral_type_code
						,collateral_name
						,collateral_condition
						,market_value
						,collateral_value
						,doc_collateral_no
						,collateral_year
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	collateral_no
							,plafond_code
							,collateral_type_code
							,collateral_name
							,collateral_condition
							,market_value
							,collateral_value
							,doc_collateral_no
							,collateral_year
							,@mod_date
							,@mod_by
							,@mode_address
							,@mod_date
							,@mod_by
							,@mode_address
					from	dbo.doc_interface_plafond_collateral
					where	plafond_code = @plafond_code ;

					set @number_rows =+ 1
					set @last_id = @id_interface ;

					update	dbo.doc_interface_plafond_main  --cek poin
					set		job_status = 'POST'
					where	id = @id_interface	

				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = error_message();
				
					update	dbo.doc_interface_plafond_main  --cek poin
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

			fetch next from cur_insplafondmain 
			into @id_interface
				 ,@plafond_code
		end

		begin -- close cursor
			if cursor_status('global', 'cur_insplafondmain') >= -1
			begin
				if cursor_status('global', 'cur_insplafondmain') > -1
				begin
					close cur_insplafondmain ;
				end ;

				deallocate cur_insplafondmain ;
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

