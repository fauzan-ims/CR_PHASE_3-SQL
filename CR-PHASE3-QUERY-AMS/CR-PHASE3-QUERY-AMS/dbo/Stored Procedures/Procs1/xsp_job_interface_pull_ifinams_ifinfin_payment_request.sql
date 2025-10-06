CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinams_ifinfin_payment_request]
AS

	DECLARE @msg				NVARCHAR(MAX)
			,@row_to_process	INT
			,@id_interface		BIGINT
			,@code_sys_job		NVARCHAR(50)
			,@last_id			BIGINT	= 0 
			,@last_id_from_job  BIGINT 
			,@number_rows		INT		= 0  
			,@code_interface	NVARCHAR(50) 
			,@is_active			NVARCHAR(1) 
			,@process_reff_no	NVARCHAR(50) 
			,@process_reff_name	NVARCHAR(250) 
			,@process_date		DATETIME		
			,@payment_status	NVARCHAR(10)	
			,@mod_date			DATETIME		= GETDATE()
			,@mod_by			nvarchar(15)	= 'job'
			,@mod_ip_address	nvarchar(15)	= '127.0.0.1'
			,@current_mod_date	datetime
			,@from_id			bigint			= 0; 

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
		    ,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinams_ifinfin_payment_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin

	--get cashier received request
	declare curr_payment_request cursor for

		SELECT 		fpr.id
					,fpr.code
					,fpr.payment_status
					,fpr.process_date
					,fpr.process_reff_no
					,fpr.process_reff_name
		FROM		ifinfin.dbo.fin_interface_payment_request fpr
					INNER JOIN dbo.efam_interface_payment_request ppr ON (ppr.code = fpr.code)
		WHERE		fpr.payment_status IN ('PAID','CANCEL')
					and ppr.payment_status = 'HOLD'
					--and fpr.id > @last_id_from_job
		order by	fpr.id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_payment_request
			
	fetch next from curr_payment_request 
	into @id_interface
		 ,@code_interface
		 ,@payment_status
		 ,@process_date
		 ,@process_reff_no
		 ,@process_reff_name

	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end
            
			if @payment_status = 'PAID'
			BEGIN
				SELECT @payment_status
				UPDATE	dbo.efam_interface_payment_request
				set		payment_status			= 'PAID'
						,process_date			= @process_date
						,process_reff_no		= @process_reff_no
						,process_reff_name		= @process_reff_name
						,mod_date				= @mod_date
						,mod_by					= @mod_by
						,mod_ip_address			= @mod_ip_address
				where	code					= @code_interface
			end
			else
			begin
				update	dbo.efam_interface_payment_request
				set		payment_status			= 'CANCEL'
						,process_date			= @process_date
						,process_reff_no		= @process_reff_no
						,process_reff_name		= @process_reff_name
						,mod_date				= @mod_date
						,mod_by					= @mod_by
						,mod_ip_address			= @mod_ip_address
				where	code					= @code_interface
			end

			set @number_rows =+ 1

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();

			update dbo.opl_interface_payment_request
			set		job_status		= 'FAILED'
					,failed_remarks	= @msg
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
														,@p_cre_by				= N'job'
														,@p_cre_ip_address		= N'127.0.0.1'
														,@p_mod_date			= @current_mod_date--cek poin
														,@p_mod_by				= N'job'
														,@p_mod_ip_address		= N'127.0.0.1'  ;

			--clear cursor when error
			close curr_payment_request
			deallocate curr_payment_request

			--stop looping
			break ;
		end catch ;
	
		fetch next from curr_payment_request
		into	@id_interface
				,@code_interface
				,@payment_status
				,@process_date
				,@process_reff_no
				,@process_reff_name

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_payment_request') >= -1
		begin
			if cursor_status('global', 'curr_payment_request') > -1
			begin
				close curr_payment_request ;
			end ;

			deallocate curr_payment_request ;
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
