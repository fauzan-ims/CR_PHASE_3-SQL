CREATE PROCEDURE dbo.xsp_job_interface_pull_ifindoc_ifincore_collateral_switch_replaced
as

	declare @msg						nvarchar(max)
			,@id_interface				bigint --cursor
			,@row_to_process			int
			,@last_id					bigint			= 0
			,@last_id_from_job			bigint 
			,@code_sys_job				nvarchar(50)
			,@code						nvarchar(50)
			,@replaced_collateral_no	nvarchar(50)
			,@number_rows				int				= 0
			,@row_count					int				= 0
			,@current_mod_date			datetime
			,@from_id					bigint			= 0
			,@is_active					nvarchar(1)
			,@mod_date					datetime	    = getdate()
			,@mod_by					nvarchar(50)    = 'Admin'
			,@mode_address				nvarchar(50)    = '127.0.0'; 

	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name				= 'xsp_job_interface_pull_ifindoc_ifincore_collateral_switch_replaced' 

	if (@is_active = '1')
	begin
		--module core interface agreement main out
		declare cur_doccorecollateralswitch cursor for

			select 	id
					,code
			from ifincore.dbo.core_interface_collateral_switch
			where id > @last_id_from_job
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_doccorecollateralswitch		
		fetch next from cur_doccorecollateralswitch 
		into @id_interface
			,@code
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					--get data from module core

					insert into dbo.doc_interface_collateral_switch
					(
						code
						,source_type
						,source_code
						,branch_code
						,branch_name
						,agreement_no
						,switch_status
						,switch_date
						,switch_remarks
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select code
						  ,source_type
						  ,source_code
						  ,branch_code
						  ,branch_name
						  ,agreement_no
						  ,switch_status
						  ,switch_date
						  ,switch_remarks
						  ,cre_date
						  ,cre_by
						  ,cre_ip_address
						  ,mod_date
						  ,mod_by
						  ,mod_ip_address 
					from ifincore.dbo.core_interface_collateral_switch
					where code = @code

					insert into dbo.doc_interface_collateral_switch_released
					(
						interface_collateral_switch_code
						,collateral_no
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select 
						  interface_collateral_switch_code
						  ,collateral_no
						  ,cre_date
						  ,cre_by
						  ,cre_ip_address
						  ,mod_date
						  ,mod_by
						  ,mod_ip_address 
					from ifincore.dbo.core_interface_collateral_switch_released
					where interface_collateral_switch_code = @code

					insert into dbo.doc_interface_collateral_switch_replaced
					(
						replaced_collateral_no
						,interface_collateral_switch_code
						,collaterall_no
						,collateral_type
						,collateral_name
						,collateral_description
						,collateral_condition
						,collateral_value_amount
						,market_value_amount
						,doc_collateral_no
						,collateral_year
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select
						  replaced_collateral_no
						  ,interface_collateral_switch_code
						  ,collaterall_no
						  ,collateral_type
						  ,collateral_name
						  ,collateral_description
						  ,collateral_condition
						  ,collateral_value_amount
						  ,market_value_amount
						  ,doc_collateral_no
						  ,collateral_year
						  ,cre_date
						  ,cre_by
						  ,cre_ip_address
						  ,mod_date
						  ,mod_by
						  ,mod_ip_address 
					from ifincore.dbo.core_interface_collateral_switch_replaced
					where interface_collateral_switch_code = @code

					insert into dbo.doc_interface_collateral_switch_replaced_doc
					(
						replaced_collateral_no
						,document_code
						,filename
						,paths
						,expired_date
						,promise_date
						,is_required
						,status
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select 
						  rd.replaced_collateral_no
						  ,document_code
						  ,filename
						  ,paths
						  ,expired_date
						  ,promise_date
						  ,is_required
						  ,status
						  ,rd.cre_date
						  ,rd.cre_by
						  ,rd.cre_ip_address
						  ,rd.mod_date
						  ,rd.mod_by
						  ,rd.mod_ip_address 
					from ifincore.dbo.core_interface_collateral_switch_replaced_doc rd
					inner join ifincore.dbo.core_interface_collateral_switch_replaced sr on (sr.replaced_collateral_no = rd.replaced_collateral_no)
					where sr.interface_collateral_switch_code = @code

					set @number_rows =+ 1
					set @last_id = @id_interface
						
				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = isnull(error_message(),'');
			
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
																,@p_cre_ip_address		= @mode_address
																,@p_mod_date			= @current_mod_date--cek poin
																,@p_mod_by				= @mod_by
																,@p_mod_ip_address		= @mode_address  ; 

					--clear cursor when error
					close cur_doccorecollateralswitch
					deallocate cur_doccorecollateralswitch

					--stop looping
					break ;
				end catch ;

			fetch next from cur_doccorecollateralswitch 
			into @id_interface
				,@code
		end

		begin -- close cursor
			if cursor_status('global', 'cur_doccorecollateralswitch') >= -1
			begin
				if cursor_status('global', 'cur_doccorecollateralswitch') > -1
				begin
					close cur_doccorecollateralswitch ;
				end ;

				deallocate cur_doccorecollateralswitch ;
			end ;
		end ;

		if (@last_id > 0)
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job

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
													, @p_cre_ip_address		= @mode_address
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= @mod_by
													, @p_mod_ip_address		= @mode_address
					    
		end
	end
