/*
exec xsp_job_interface_in_ifinopl_additional_invoice_request
*/
-- Louis Selasa, 30 Mei 2023 11.55.18 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_additional_invoice_request
as

	declare @msg							  nvarchar(max)
			,@row_to_process				  int
			,@last_id_from_job				  bigint
			,@id_interface					  bigint
			,@code_sys_job					  nvarchar(50)
			,@last_id						  bigint		= 0
			,@number_rows					  int			= 0
			,@is_active						  nvarchar(1)
			,@current_mod_date				  datetime
			,@mod_date						  datetime		= getdate()
			,@mod_by						  nvarchar(15)	= 'job'
			,@mod_ip_address				  nvarchar(15)	= '127.0.0.1'
			,@from_id						  bigint		= 0
			,@additional_invoice_request_code nvarchar(50)
			,@agreement_no					  nvarchar(50)
			,@asset_no						  nvarchar(50)
			,@branch_code					  nvarchar(50)
			,@branch_name					  nvarchar(250)
			,@invoice_type					  nvarchar(10)
			,@invoice_date					  datetime
			,@invoice_name					  nvarchar(250)
			,@client_no						  nvarchar(50)
			,@client_name					  nvarchar(250)
			,@client_address				  nvarchar(4000)
			,@client_area_phone_no			  nvarchar(4)
			,@client_phone_no				  nvarchar(15)
			,@client_npwp					  nvarchar(50)
			,@currency_code					  nvarchar(3)
			,@tax_scheme_code				  nvarchar(50)
			,@tax_scheme_name				  nvarchar(250)
			,@billing_no					  int
			,@description					  nvarchar(4000)
			,@quantity						  int
			,@billing_amount				  decimal(18, 2)
			,@discount_amount				  decimal(18, 2)
			,@ppn_pct						  decimal(9, 6)
			,@ppn_amount					  int
			,@pph_pct						  decimal(9, 6)
			,@pph_amount					  int
			,@total_amount					  decimal(18, 2)
			,@reff_code						  nvarchar(50)
			,@reff_name						  nvarchar(250) ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_additional_invoice_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	declare curr_additional_invoice_request cursor for
	select		id
				,agreement_no
				,asset_no
				,branch_code
				,branch_name
				,invoice_type
				,invoice_date
				,invoice_name
				,client_no
				,client_name
				,client_address
				,client_area_phone_no
				,client_phone_no
				,client_npwp
				,currency_code
				,tax_scheme_code
				,tax_scheme_name
				,billing_no
				,description
				,quantity
				,billing_amount
				,discount_amount
				,ppn_pct
				,ppn_amount
				,pph_pct
				,pph_amount
				,total_amount
				,reff_code
				,reff_name
	from		dbo.opl_interface_additional_invoice_request
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_additional_invoice_request
			
	fetch next from curr_additional_invoice_request 
	into @id_interface
		 ,@agreement_no				
		 ,@asset_no					
		 ,@branch_code				
		 ,@branch_name				
		 ,@invoice_type				
		 ,@invoice_date				
		 ,@invoice_name				
		 ,@client_no				
		 ,@client_name				
		 ,@client_address			
		 ,@client_area_phone_no		
		 ,@client_phone_no			
		 ,@client_npwp				
		 ,@currency_code			
		 ,@tax_scheme_code			
		 ,@tax_scheme_name			
		 ,@billing_no				
		 ,@description				
		 ,@quantity					
		 ,@billing_amount			
		 ,@discount_amount			
		 ,@ppn_pct					
		 ,@ppn_amount				
		 ,@pph_pct					
		 ,@pph_amount				
		 ,@total_amount				
		 ,@reff_code				
		 ,@reff_name;				
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end 

			exec dbo.xsp_additional_invoice_request_insert @p_code					= @additional_invoice_request_code output
														   ,@p_agreement_no			= @agreement_no			
														   ,@p_asset_no				= @asset_no				
														   ,@p_branch_code			= @branch_code			
														   ,@p_branch_name			= @branch_name			
														   ,@p_invoice_type			= @invoice_type			
														   ,@p_invoice_date			= @invoice_date
														   ,@p_invoice_name			= @invoice_name			
														   ,@p_client_no			= @client_no			
														   ,@p_client_name			= @client_name			
														   ,@p_client_address		= @client_address		
														   ,@p_client_area_phone_no = @client_area_phone_no
														   ,@p_client_phone_no		= @client_phone_no		
														   ,@p_client_npwp			= @client_npwp			
														   ,@p_currency_code		= @currency_code		
														   ,@p_tax_scheme_code		= @tax_scheme_code		
														   ,@p_tax_scheme_name		= @tax_scheme_name		
														   ,@p_billing_no			= @billing_no			
														   ,@p_description			= @description			
														   ,@p_quantity				= @quantity				
														   ,@p_billing_amount		= @billing_amount		
														   ,@p_discount_amount		= @discount_amount		
														   ,@p_ppn_pct				= @ppn_pct				
														   ,@p_ppn_amount			= @ppn_amount			
														   ,@p_pph_pct				= @pph_pct				
														   ,@p_pph_amount			= @pph_amount			
														   ,@p_total_amount			= @total_amount			
														   ,@p_reff_code			= @reff_code			
														   ,@p_reff_name			= @reff_name
														   --
														   ,@p_cre_date				= @mod_date		
														   ,@p_cre_by				= @mod_by		
														   ,@p_cre_ip_address		= @mod_ip_address
														   ,@p_mod_date				= @mod_date		
														   ,@p_mod_by				= @mod_by		
														   ,@p_mod_ip_address		= @mod_ip_address
			

			update dbo.opl_interface_additional_invoice_request
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

			update	dbo.opl_interface_additional_invoice_request  --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface --cek poin	

			print @msg

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
	
		fetch next from curr_additional_invoice_request
		into @id_interface
			 ,@agreement_no				
			 ,@asset_no					
			 ,@branch_code				
			 ,@branch_name				
			 ,@invoice_type				
			 ,@invoice_date				
			 ,@invoice_name				
			 ,@client_no				
			 ,@client_name				
			 ,@client_address			
			 ,@client_area_phone_no		
			 ,@client_phone_no			
			 ,@client_npwp				
			 ,@currency_code			
			 ,@tax_scheme_code			
			 ,@tax_scheme_name			
			 ,@billing_no				
			 ,@description				
			 ,@quantity					
			 ,@billing_amount			
			 ,@discount_amount			
			 ,@ppn_pct					
			 ,@ppn_amount				
			 ,@pph_pct					
			 ,@pph_amount				
			 ,@total_amount				
			 ,@reff_code				
			 ,@reff_name;

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_additional_invoice_request') >= -1
		begin
			if cursor_status('global', 'curr_additional_invoice_request') > -1
			begin
				close curr_additional_invoice_request ;
			end ;

			deallocate curr_additional_invoice_request ;
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

