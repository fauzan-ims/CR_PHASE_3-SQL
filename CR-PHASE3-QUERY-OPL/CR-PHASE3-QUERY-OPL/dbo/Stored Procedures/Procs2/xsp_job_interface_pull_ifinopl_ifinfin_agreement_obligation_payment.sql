/*
exec dbo.xsp_job_interface_pull_ifinopl_ifinfin_agreement_obligation_payment
*/
-- Louis Kamis, 13 Juli 2023 14.27.15 -- 
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinfin_agreement_obligation_payment
as

	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@is_active				nvarchar(1) 
			,@last_id				bigint	= 0 
			,@number_rows			int		= 0 
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1' ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinfin_agreement_obligation_payment' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_agreement_obligation_payment cursor for

		select 		id
		from		ifinfin.dbo.fin_interface_agreement_obligation_payment
		where		id > @last_id_from_job
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_agreement_obligation_payment
			
	fetch next from curr_agreement_obligation_payment 
	into @id_interface
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction 
			insert into dbo.opl_interface_agreement_obligation_payment
			(
				code
				,agreement_no
				,installment_no
				,obligation_type
				,payment_date
				,value_date
				,payment_source_type
				,payment_source_no
				,payment_amount
				,payment_remarks
				,is_waive 
				,job_status
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
					,installment_no
					,obligation_type
					,payment_date
					,value_date
					,payment_source_type
					,payment_source_no
					,payment_amount
					,payment_remarks
					,is_waive 
					,'HOLD'
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address 
			from	ifinfin.dbo.fin_interface_agreement_obligation_payment
			where	id = @id_interface

			set @number_rows =+ 1

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();

			update dbo.opl_interface_agreement_obligation_payment
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @mod_date
													 ,@p_log_description	= @msg
													 ,@p_run_by				= N'job'
													 ,@p_from_id			= 0
													 ,@p_to_id				= 0
													 ,@p_number_of_rows		= @number_rows
													 ,@p_cre_date			= @mod_date
													 ,@p_cre_by				= N'job'
													 ,@p_cre_ip_address		= N'127.0.0.1'
													 ,@p_mod_date			= @mod_date
													 ,@p_mod_by				= N'job'
													 ,@p_mod_ip_address		= N'127.0.0.1' ;

			-- clear cursor when error
			close curr_agreement_obligation_payment ;
			deallocate curr_agreement_obligation_payment ;

			-- stop looping
			break ;
		end catch ;   
	
		fetch next from curr_agreement_obligation_payment
		into @id_interface

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_agreement_obligation_payment') >= -1
		begin
			if cursor_status('global', 'curr_agreement_obligation_payment') > -1
			begin
				close curr_agreement_obligation_payment ;
			end ;

			deallocate curr_agreement_obligation_payment ;
		end ;
	end ;

	begin -- get last id job
		set @last_id = @id_interface ;

		if (isnull(@last_id, 0) = 0)
		begin
			if exists
			(
				-- if no new data
				select	1
				from	ifinfin.dbo.fin_interface_agreement_obligation_payment
				where	id > @last_id_from_job
			)
			begin
				select	@last_id = min(id) - 1
				from	ifinfin.dbo.fin_interface_agreement_obligation_payment
				where	id > @last_id_from_job ;
			end ;
			else
			begin
				set @last_id = @last_id_from_job ;
			end ;
		end ;
	end ;

	if (@last_id is not null)
	begin
		update	dbo.sys_job_tasklist 
		set		last_id				= @last_id
				,mod_date			= @mod_date
				,mod_by				= @mod_by
				,mod_ip_address		= @mod_ip_address
		where	code				= @code_sys_job

		/*insert into dbo.sys_job_tasklist_log*/
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
		                                       , @p_status = N'Success'
		                                       , @p_start_date = @mod_date
		                                       , @p_end_date = @mod_date
		                                       , @p_log_description = N''
		                                       , @p_run_by = N'job'
		                                       , @p_from_id = 0
		                                       , @p_to_id = 0
		                                       , @p_number_of_rows = @number_rows
		                                       , @p_cre_date = @mod_date
		                                       , @p_cre_by = N'job'
		                                       , @p_cre_ip_address = N'127.0.0.1'
		                                       , @p_mod_date = @mod_date
		                                       , @p_mod_by = N'job'
		                                       , @p_mod_ip_address = N'127.0.0.1'
	end
	end
