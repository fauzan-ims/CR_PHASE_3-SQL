/*
exec xsp_job_interface_in_ifinopl_agreement_obligation_payment
*/
-- Louis Kamis, 13 Juli 2023 15.01.08 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_agreement_obligation_payment
as

	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@is_active				nvarchar(1) 
			,@last_id				bigint	     = 0 
			,@number_rows			int		     = 0 
			,@from_id		        bigint		 = 0
			,@current_mod_date	    datetime
			,@mod_date				datetime	 = getdate()
			,@mod_by				nvarchar(15) = 'job'
			,@mod_ip_address		nvarchar(15) = '127.0.0.1' ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_agreement_obligation_payment' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_agreement_obligation_payment cursor for

			select 		id
			from		dbo.opl_interface_agreement_obligation_payment
			where		job_status in ('HOLD','FAILED')
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_agreement_obligation_payment
			
		fetch next from curr_agreement_obligation_payment 
		into @id_interface
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
				if (@number_rows = 0)
				begin
					set @from_id = @id_interface
				end

				-- insert ke obligation_payment by interface obligation_payment id
				exec dbo.xsp_agreement_obligation_payment_by_interface_job_insert @p_id = @id_interface -- bigint
				 
				set @number_rows =+ 1
				set @last_id = @id_interface ;

				update	dbo.opl_interface_agreement_obligation_payment  --cek poin
				set		job_status		 = 'POST'
						,failed_remark	 = null
				where	id = @id_interface	

				commit transaction
			end try
			begin catch

				rollback transaction 
			
				set @msg = error_message();
				update	dbo.opl_interface_agreement_obligation_payment  --cek poin
				set		job_status		 = 'FAILED'
						,failed_remark	 = @msg
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
															,@p_cre_ip_address		= @mod_ip_address
															,@p_mod_date			= @current_mod_date--cek poin
															,@p_mod_by				= @mod_by
															,@p_mod_ip_address		= @mod_ip_address  ;
			end catch   
	
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

		if (@last_id > 0)--cek poin
		begin
			update dbo.sys_job_tasklist 
			set last_id	 = @last_id 
			where code	 = @code_sys_job
		
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
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address 
					    
		end
	end
