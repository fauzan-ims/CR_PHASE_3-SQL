/*
	created : Nia, 23 Sept 2021
*/

CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifincore_deposit_allocation
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
			,@mod_date		    datetime	 = getdate()
			,@mod_by		    nvarchar(50) = 'Admin'
			,@mode_address      nvarchar(50) = '127.0.0'
			,@current_mod_date	datetime
			,@from_id			bigint			= 0
			,@code				nvarchar(50);  

	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifincore_deposit_allocation' 

	if (@is_active = '1')
	begin
		--module core interface agreement agreement main out
		declare cur_depositallocation cursor for

			select 	id
					,code
			from ifincore.dbo.core_interface_deposit_allocation
			where id > @last_id_from_job
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_depositallocation		
		fetch next from cur_depositallocation 
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
					insert into dbo.fin_interface_deposit_allocation
					(
					    code
					    ,branch_code
					    ,branch_name
					    ,status
					    ,trx_date
					    ,orig_amount
					    ,currency_code
					    ,exch_rate
					    ,base_amount
					    ,remark
					    ,agreement_no
					    ,deposit_code
					    ,deposit_type
					    ,deposit_amount
					    ,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select code
							,branch_code
							,branch_name
							,status
							,trx_date
							,orig_amount
							,currency_code
							,exch_rate
							,base_amount
							,remark
							,agreement_no
							,deposit_code
							,deposit_type
							,deposit_amount
							--
							,@mod_date		
							,@mod_by		
							,@mode_address 
							,@mod_date		
							,@mod_by		
							,@mode_address       
					from   ifincore.dbo.core_interface_deposit_allocation
					where  id = @id_interface

					insert into dbo.fin_interface_deposit_allocation_detail
					(
					    fin_interface_deposit_allocation_code,
					    transaction_code,
					    innitial_amount,
					    orig_amount,
					    orig_currency_code,
					    exch_rate,
					    base_amount,
					    installment_no,
					    remark,
					    cre_date,
					    cre_by,
					    cre_ip_address,
					    mod_date,
					    mod_by,
					    mod_ip_address
					)
					select core_interface_deposit_allocation_code
                           ,transaction_code
                           ,innitial_amount
                           ,orig_amount
                           ,orig_currency_code
                           ,exch_rate
                           ,base_amount
                           ,installment_no
						   ,remark
                           ,@mod_date		
						   ,@mod_by		
						   ,@mode_address 
						   ,@mod_date		
						   ,@mod_by		
						   ,@mode_address  		
					from ifincore.dbo.core_interface_deposit_allocation_detail
					where core_interface_deposit_allocation_code = @code

					set @number_rows =+ 1
					set @last_id = @id_interface ;
						
				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = error_message();

					update dbo.fin_interface_deposit_allocation
					set		job_status		= 'FAILED'
							,failed_remark	= @msg
					where	id				= @id_interface

					set @current_mod_date = getdate();
					/*insert into dbo.sys_job_tasklist_log*/
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
															 ,@p_status				= N'Error'
															 ,@p_start_date			= @mod_date
															 ,@p_end_date			= @current_mod_date --cek poin
															 ,@p_log_description	= @msg
															 ,@p_run_by				= 'job'
															 ,@p_from_id			= @from_id  --cek poin
															 ,@p_to_id				= @id_interface --cek poin
															 ,@p_number_of_rows		= @number_rows --cek poin
															 ,@p_cre_date			= @current_mod_date--cek poin
															 ,@p_cre_by				= 'job'
															 ,@p_cre_ip_address		= '127.0.0.1'
															 ,@p_mod_date			= @current_mod_date--cek poin
															 ,@p_mod_by				= 'job'
															 ,@p_mod_ip_address		= '127.0.0.1'  ;

					--clear cursor when error
					close cur_depositallocation
					deallocate cur_depositallocation

					--stop looping
					break ;
				end catch ;

			fetch next from cur_depositallocation 
			into @id_interface
				 ,@code

		end

		begin -- close cursor
			if cursor_status('global', 'cur_depositallocation') >= -1
			begin
				if cursor_status('global', 'cur_depositallocation') > -1
				begin
					close cur_depositallocation ;
				end ;

				deallocate cur_depositallocation ;
			end ;
		end ;
	
	if (@last_id > 0)--cek poin
		begin
			set @current_mod_date = getdate();

			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													, @p_status				= 'Success'
													, @p_start_date			= @mod_date
													, @p_end_date			= @current_mod_date --cek poin
													, @p_log_description	= ''
													, @p_run_by				= 'job'
													, @p_from_id			= @from_id --cek poin
													, @p_to_id				= @last_id --cek poin
													, @p_number_of_rows		= @number_rows --cek poin
													, @p_cre_date			= @current_mod_date --cek poin
													, @p_cre_by				= 'job'
													, @p_cre_ip_address		= '127.0.0.1'
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= 'job'
													, @p_mod_ip_address		= '127.0.0.1'
					    
		end
	end
