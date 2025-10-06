/*
exec xsp_job_interface_pull_ifinopl_ifinfin_interface_agreement_deposit_history
*/
-- Louis Selasa, 14 Maret 2023 10.53.04 --
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinfin_interface_agreement_deposit_history
as

	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@is_active				nvarchar(1) 
			,@last_id				bigint			= 0 
			,@number_rows			int				= 0 
			,@from_id				bigint			= 0
			,@current_mod_date		datetime        = getdate()
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1' ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinfin_interface_agreement_deposit_history' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_agreement_deposit_history cursor for

		select 		id
					,agreement_no
		from		ifinfin.dbo.fin_interface_agreement_deposit_history
		where		id > @last_id_from_job
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_agreement_deposit_history
			
	fetch next from curr_agreement_deposit_history 
	into @id_interface
		 ,@agreement_no
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end
			
			if exists
			(
				select	1
				from	dbo.agreement_main
				where	agreement_no = @agreement_no
			)
			begin
			
				insert into dbo.opl_interface_agreement_deposit_history
				(
					branch_code
					,branch_name
					,agreement_deposit_code
					,agreement_no
					,deposit_type
					,transaction_date
					,orig_amount
					,orig_currency_code
					,exch_rate
					,base_amount
					,source_reff_module
					,source_reff_code
					,source_reff_name
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
				select	fiadh.branch_code
						,fiadh.branch_name
						,agreement_deposit_code
						,fiadh.agreement_no
						,fiadh.deposit_type
						,transaction_date
						,orig_amount
						,orig_currency_code
						,exch_rate
						,base_amount
						,source_reff_module
						,source_reff_code
						,source_reff_name
						,'HOLD'
						,''
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	ifinfin.dbo.fin_interface_agreement_deposit_history fiadh
				where	id = @id_interface ;

				exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																	   ,@p_mod_date			= @mod_date		
																	   ,@p_mod_by			= @mod_by		
																	   ,@p_mod_ip_address	= @mod_ip_address
			end ;
		
			set @number_rows =+ 1
			set @last_id = @id_interface 

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();

			update dbo.opl_interface_agreement_deposit_history
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface
		
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
														,@p_status				= N'Error'
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

			-- clear cursor when error
			close curr_agreement_deposit_history ;
			deallocate curr_agreement_deposit_history ;

			-- stop looping
			break ;		
		end catch ;   
	
		fetch next from curr_agreement_deposit_history
		into @id_interface
			 ,@agreement_no

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_agreement_deposit_history') >= -1
		begin
			if cursor_status('global', 'curr_agreement_deposit_history') > -1
			begin
				close curr_agreement_deposit_history ;
			end ;

			deallocate curr_agreement_deposit_history ;
		end ;
	end ;
	
	if (@last_id > 0)--cek poin
	begin
		update dbo.sys_job_tasklist 
		set last_id = @last_id 
		where code = @code_sys_job
		
		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate();
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= 'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date --cek poin
												 ,@p_log_description	= ''
												 ,@p_run_by				= @mod_by
												 ,@p_from_id			= @from_id  --cek poin
												 ,@p_to_id				= @id_interface --cek poin
												 ,@p_number_of_rows		= @number_rows --cek poin
												 ,@p_cre_date			= @current_mod_date--cek poin
												 ,@p_cre_by				= @mod_by
												 ,@p_cre_ip_address		= @mod_ip_address
												 ,@p_mod_date			= @current_mod_date--cek poin
												 ,@p_mod_by				= @mod_by
												 ,@p_mod_ip_address		= @mod_ip_address 
					    
	end
	end

