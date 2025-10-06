/*
	created : Nia, 1 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_account_transfer
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@id_interface	   bigint
		,@code_sys_job	   nvarchar(50)
		,@code_interface   nvarchar(50)
		,@is_active		   nvarchar(1)
		,@last_id		   bigint		= 0
		,@number_rows	   int			= 0
		,@current_mod_date datetime
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@from_id		   bigint		= 0 ;

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinfin_account_transfer' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get cashier received request
	declare curr_accounttransfer cursor for
	select		id
				,code
	from		dbo.fin_interface_account_transfer
	where		job_status in
				(
					'HOLD', 'FAILED'
				)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_accounttransfer ;

	fetch next from curr_accounttransfer
	into @id_interface
		 ,@code_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.account_transfer
			(
			    code
			    ,transfer_status
			    ,transfer_trx_date
			    ,transfer_value_date
			    ,transfer_remarks
			    ,cashier_code
			    ,cashier_amount
				,is_from
			    ,from_branch_code
			    ,from_branch_name
			    ,from_currency_code
			    ,from_exch_rate
			    ,from_orig_amount
			    ,from_branch_bank_code
			    ,from_branch_bank_name
			    ,from_gl_link_code
			    ,to_branch_code
			    ,to_branch_name
			    ,to_currency_code
			    ,to_exch_rate
			    ,to_orig_amount
			    ,to_branch_bank_code
			    ,to_branch_bank_name
			    ,to_gl_link_code
			    ,cre_date
			    ,cre_by
			    ,cre_ip_address
			    ,mod_date
			    ,mod_by
			    ,mod_ip_address
			)
			select code
					,'HOLD'
                    ,transfer_trx_date
                    ,transfer_value_date
                    ,transfer_remarks
					,NULL
					,NULL
					,case isnull(from_branch_code,'')
						when '' then '0'
						else '1'
					end
                    ,isnull(from_branch_code,to_branch_code)
                    ,isnull(from_branch_name,to_branch_name)
                    ,from_currency_code
                    ,from_exch_rate
                    ,from_orig_amount
                    ,from_branch_bank_code
                    ,from_branch_bank_name
                    ,from_gl_link_code
                    ,to_branch_code
                    ,to_branch_name
                    ,to_currency_code
                    ,to_exch_rate
                    ,to_orig_amount
                    ,to_branch_bank_code
                    ,to_branch_bank_name
                    ,to_gl_link_code
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.fin_interface_account_transfer
			where	id = @id_interface ;

			update	dbo.fin_interface_account_transfer
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
			update	dbo.fin_interface_account_transfer --cek poin
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

		fetch next from curr_accounttransfer
		into @id_interface
			 ,@code_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_accounttransfer') >= -1
		begin
			if cursor_status('global', 'curr_accounttransfer') > -1
			begin
				close curr_accounttransfer ;
			end ;

			deallocate curr_accounttransfer ;
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
