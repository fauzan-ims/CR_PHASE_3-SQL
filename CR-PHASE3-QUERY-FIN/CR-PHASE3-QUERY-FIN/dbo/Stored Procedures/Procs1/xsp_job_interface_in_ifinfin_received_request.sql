
/*
	created : Nia, 1 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_received_request

as

	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@is_active				nvarchar(1) 
			,@last_id				bigint	= 0 
			,@number_rows			int		= 0 
			,@current_mod_date		datetime
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1' 
			,@from_id			    bigint			= 0; 

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinfin_received_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_interfacereceivedrequest cursor for

		select 		id
		from		dbo.fin_interface_received_request
		where		received_status = 'HOLD'
					and case isnull(job_status,'') when '' then 'HOLD' else JOB_STATUS end in ('HOLD','FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_interfacereceivedrequest
			
	fetch next from curr_interfacereceivedrequest 
	into @id_interface
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			insert into dbo.received_request
			(
			    code
			    ,branch_code
			    ,branch_name
			    ,received_source
			    ,received_request_date
			    ,received_source_no
			    ,received_status
			    ,received_currency_code
			    ,received_amount
			    ,received_remarks
			    ,received_transaction_code
			    ,branch_bank_code
			    ,branch_bank_name
			    ,branch_bank_gl_link_code
				--
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
				  ,received_source
				  ,received_request_date
				  ,received_source_no
				  ,received_status
				  ,received_currency_code
				  ,received_amount
				  ,received_remarks
				  ,NULL
                  ,branch_bank_code
				  ,branch_bank_name
				  ,branch_bank_gl_link_code
				  ,@mod_date			
				  ,@mod_by			
				  ,@mod_ip_address	
				  ,@mod_date			
				  ,@mod_by			
				  ,@mod_ip_address	
			from   dbo.fin_interface_received_request
			where  id = @id_interface

			insert into dbo.received_request_detail
			(
				received_request_code
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
				,ext_pph_type
				,ext_vendor_code
				,ext_vendor_name
				,ext_vendor_npwp
				,ext_vendor_address
				,ext_vendor_type
				,ext_income_type
				,ext_income_bruto_amount
				,ext_tax_rate_pct
				,ext_pph_amount
				,ext_description
				,ext_tax_number
				,ext_sale_type
				,ext_tax_date
				,EXT_NITKU
				,EXT_NPWP_HO
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	rrd.received_request_code
				   ,rrd.branch_code
				   ,rrd.branch_name
				   ,rrd.gl_link_code
				   ,rrd.agreement_no
				   ,rrd.facility_code
				   ,rrd.facility_name
				   ,rrd.purpose_loan_code
				   ,rrd.purpose_loan_name
				   ,rrd.purpose_loan_detail_code
				   ,rrd.purpose_loan_detail_name
				   ,rrd.orig_currency_code
				   ,rrd.orig_amount
				   ,rrd.division_code
				   ,rrd.division_name
				   ,rrd.department_code
				   ,rrd.department_name
				   ,rrd.remarks
				   ,rrd.ext_pph_type
				   ,rrd.ext_vendor_code
				   ,rrd.ext_vendor_name
				   ,rrd.ext_vendor_npwp
				   ,rrd.ext_vendor_address
				   ,rrd.ext_vendor_type
				   ,rrd.ext_income_type
				   ,rrd.ext_income_bruto_amount
				   ,rrd.ext_tax_rate_pct
				   ,rrd.ext_pph_amount
				   ,rrd.ext_description
				   ,rrd.ext_tax_number
				   ,rrd.ext_sale_type
				   ,rrd.ext_tax_date
				   ,rrd.EXT_NITKU
				   ,rrd.EXT_NPWP_HO
				   --
				   ,@mod_date			
				   ,@mod_by			
				   ,@mod_ip_address	
				   ,@mod_date			
				   ,@mod_by			
				   ,@mod_ip_address	
			from	dbo.fin_interface_received_request_detail rrd
					inner join dbo.fin_interface_received_request rr on (rr.code = rrd.received_request_code)
			where	rr.id = @id_interface

			update dbo.fin_interface_received_request
			set    job_status = 'POST'
			where  id		   = @id_interface
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();
			set @current_mod_date = getdate();
			select @msg

			update	dbo.fin_interface_received_request  --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface --cek poin	

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

		end catch   
	
		fetch next from curr_interfacereceivedrequest
		into @id_interface

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_interfacereceivedrequest') >= -1
		begin
			if cursor_status('global', 'curr_interfacereceivedrequest') > -1
			begin
				close curr_interfacereceivedrequest ;
			end ;

			deallocate curr_interfacereceivedrequest ;
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
