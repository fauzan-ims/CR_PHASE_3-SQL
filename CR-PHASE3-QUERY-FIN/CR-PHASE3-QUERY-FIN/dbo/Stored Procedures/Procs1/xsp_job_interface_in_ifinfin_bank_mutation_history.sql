/*
	created : Nia, 1 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_bank_mutation_history
as
declare @msg					nvarchar(max)
		,@row_to_process		int
		,@last_id_from_job		bigint
		,@id_interface			bigint
		,@code_sys_job			nvarchar(50)
		,@code_interface		nvarchar(50)
		,@is_active				nvarchar(1)
		,@last_id				bigint		= 0
		,@number_rows			int			= 0
		,@current_mod_date		datetime
		,@mod_date				datetime		= getdate()
		,@mod_by				nvarchar(15) = 'job'
		,@mod_ip_address		nvarchar(15) = '127.0.0.1'
		,@from_id				bigint		= 0 
		,@bank_mutation_code	nvarchar(50)
		,@branch_code			nvarchar(50)
		,@branch_name			nvarchar(250)
		,@gl_link_code			nvarchar(50)
		,@branch_bank_code		nvarchar(50)
		,@branch_bank_name		nvarchar(250)
		,@orig_amount			decimal(18,2)
		,@source_reff_code		nvarchar(50)
		,@source_reff_name		nvarchar(250)
		,@remarks				nvarchar(4000)
		,@value_date			datetime
        ,@transaction_date		datetime
		,@exch_rate				decimal(18,6)
		,@orig_currency_code	nvarchar(3);

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinfin_bank_mutation_history' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get cashier received request
	declare curr_interfacebankmutation cursor for
	select		id
				,branch_code
				,branch_name
				,gl_link_code
				,branch_bank_code
				,branch_bank_name
				,orig_amount
				,source_reff_code
				,source_reff_name
				,value_date
				,transaction_date
				,exch_rate
				,orig_currency_code
				,remarks
	from		dbo.fin_interface_bank_mutation_history
	where		job_status in
				(
					'HOLD', 'FAILED'
				)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_interfacebankmutation ;

	fetch next from curr_interfacebankmutation
	into @id_interface
		 ,@branch_code
		 ,@branch_name
		 ,@gl_link_code
		 ,@branch_bank_code
		 ,@branch_bank_name
		 ,@orig_amount
		 ,@source_reff_code
		 ,@source_reff_name
		 ,@value_date
		 ,@transaction_date
		 ,@exch_rate
		 ,@orig_currency_code
		 ,@remarks;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			exec dbo.xsp_bank_mutation_insert @p_code					= @bank_mutation_code output 
											  ,@p_branch_code			= @branch_code
											  ,@p_branch_name			= @branch_name
											  ,@p_gl_link_code			= @gl_link_code
											  ,@p_branch_bank_code		= @branch_bank_code
											  ,@p_branch_bank_name		= @branch_bank_name
											  ,@p_balance_amount		= @orig_amount
											  ,@p_cre_date				= @mod_date		
											  ,@p_cre_by				= @mod_by		
											  ,@p_cre_ip_address		= @mod_ip_address
											  ,@p_mod_date				= @mod_date		
											  ,@p_mod_by				= @mod_by			
											  ,@p_mod_ip_address		= @mod_ip_address

			exec dbo.xsp_bank_mutation_history_insert @p_id						= 0
													  ,@p_bank_mutation_code	= @bank_mutation_code
													  ,@p_transaction_date		= @transaction_date
													  ,@p_value_date			= @value_date
													  ,@p_source_reff_code		= @source_reff_code
													  ,@p_source_reff_name		= @source_reff_name
													  ,@p_orig_amount			= @orig_amount
													  ,@p_orig_currency_code	= @orig_currency_code
													  ,@p_exch_rate				= @exch_rate
													  ,@p_base_amount			= @orig_amount
													  ,@p_remarks				= @remarks
													  ,@p_cre_date				= @mod_date		
													  ,@p_cre_by				= @mod_by		
													  ,@p_cre_ip_address		= @mod_ip_address
													  ,@p_mod_date				= @mod_date		
													  ,@p_mod_by				= @mod_by		
													  ,@p_mod_ip_address		= @mod_ip_address
			
			update	dbo.fin_interface_bank_mutation_history
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
			select @msg
			update	dbo.fin_interface_bank_mutation_history --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_interfacebankmutation
		into @id_interface
			 ,@branch_code
			 ,@branch_name
			 ,@gl_link_code
			 ,@branch_bank_code
			 ,@branch_bank_name
			 ,@orig_amount
			 ,@source_reff_code
			 ,@source_reff_name
			 ,@value_date
			 ,@transaction_date
			 ,@exch_rate
			 ,@orig_currency_code
			 ,@remarks;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_interfacebankmutation') >= -1
		begin
			if cursor_status('global', 'curr_interfacebankmutation') > -1
			begin
				close curr_interfacebankmutation ;
			end ;

			deallocate curr_interfacebankmutation ;
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
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = 'job'
												 ,@p_from_id = @from_id --cek poin
												 ,@p_to_id = @last_id --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = 'job'
												 ,@p_cre_ip_address = '127.0.0.1'
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = 'job'
												 ,@p_mod_ip_address = '127.0.0.1' ;
	end ;
end ;
