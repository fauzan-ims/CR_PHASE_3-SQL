/*
	created : Nia, 8 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifinlgl_cashier_received_request
as

	declare @msg							nvarchar(max)
			,@row_to_process				int
			,@last_id_from_job				bigint
			,@last_id						bigint		 = 0
			,@code_sys_job					nvarchar(50)
			,@number_rows					int			 = 0
			,@is_active						nvarchar(1)
			,@id_interface					bigint
			,@mod_date						datetime	 = getdate()
			,@mod_by						nvarchar(15) = 'job'
			,@mod_ip_address				nvarchar(15) = '127.0.0.1'
			,@cashier_received_request_code nvarchar(50) 
			,@current_mod_date				datetime
			,@from_id						bigint			= 0; 
			
	select	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
			,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifinlgl_cashier_received_request' -- sesuai dengan nama sp ini
	
	if(@is_active = '1')
	begin
	--get cashier received request
	declare curr_ifinfinifinlglcrr cursor for
		select 		id
					,code
		from		ifinlgl.dbo.lgl_interface_cashier_received_request
		where		id > @last_id_from_job
					and request_status = 'HOLD'
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_ifinfinifinlglcrr
			
	fetch next from curr_ifinfinifinlglcrr 
	into @id_interface
		 ,@cashier_received_request_code
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			insert into dbo.fin_interface_cashier_received_request
			(
				code
				,branch_code
				,branch_name
				,request_status
				,request_currency_code
				,request_date
				,request_amount
				,request_remarks
				,agreement_no
				,pdc_code
				,pdc_no
				,doc_ref_code
				,doc_ref_name
				,process_date
				,process_reff_no
				,process_reff_name
				,manual_upload_status
				,manual_upload_remarks
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	 code
					,branch_code
					,branch_name
					,request_status
					,request_currency_code
					,request_date
					,request_amount
					,request_remarks
					,agreement_no
					,pdc_code
					,pdc_no
					,doc_ref_code
					,doc_ref_name
					,process_date
					,process_reff_no
					,process_reff_name
					,null
					,null
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address 
			from	ifinlgl.dbo.lgl_interface_cashier_received_request
			where	id = @id_interface

			insert into dbo.fin_interface_cashier_received_request_detail
			(
				cashier_received_request_code
				,branch_code
				,branch_name
				,gl_link_code
				,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	 crrd.cashier_received_request_code
					,crrd.branch_code
					,crrd.branch_name
					,crrd.gl_link_code
					,crrd.agreement_no
					,crrd.facility_code
					,crrd.facility_name
					,crrd.purpose_loan_code
					,crrd.purpose_loan_name
					,crrd.purpose_loan_detail_code
					,crrd.purpose_loan_detail_name
					,crrd.orig_currency_code
					,crrd.orig_amount
					,crrd.division_code
					,crrd.division_name
					,crrd.department_code
					,crrd.department_name
					,crrd.remarks
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address 
			from	ifinlgl.dbo.lgl_interface_cashier_received_request_detail crrd 
			where	crrd.cashier_received_request_code = @cashier_received_request_code
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch
			rollback transaction 

			set @msg = error_message();

			update dbo.fin_interface_cashier_received_request
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
			close curr_ifinfinifinlglcrr
			deallocate curr_ifinfinifinlglcrr

			--stop looping
			break ;
		end catch ;   
	
		fetch next from curr_ifinfinifinlglcrr
		into @id_interface
			 ,@cashier_received_request_code

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_ifinfinifinlglcrr') >= -1
		begin
			if cursor_status('global', 'curr_ifinfinifinlglcrr') > -1
			begin
				close curr_ifinfinifinlglcrr ;
			end ;

			deallocate curr_ifinfinifinlglcrr ;
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
