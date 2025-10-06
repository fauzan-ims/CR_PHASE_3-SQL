CREATE PROCEDURE dbo.xsp_opl_interface_payment_request_insert
(
	@p_code								nvarchar(50) output
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_payment_branch_code				nvarchar(50)
	,@p_payment_branch_name				nvarchar(250)
	,@p_payment_source					nvarchar(50)
	,@p_payment_request_date			datetime
	,@p_payment_source_no				nvarchar(50)
	,@p_payment_status					nvarchar(10)
	,@p_payment_currency_code			nvarchar(3)
	,@p_payment_amount					decimal(18, 2)
	,@p_payment_remarks					nvarchar(4000)
	,@p_to_bank_account_name			nvarchar(250)
	,@p_to_bank_name					nvarchar(250)
	,@p_to_bank_account_no				nvarchar(50)
	,@p_process_date					datetime
	,@p_process_reff_no					nvarchar(50)
	,@p_process_reff_name				nvarchar(250)
	,@p_manual_upload_status			nvarchar(10)
	,@p_manual_upload_remarks			nvarchar(4000)
	,@p_job_status						nvarchar(50)
	,@p_failed_remarks					nvarchar(4000)
	--
	,@p_cre_date 						datetime
	,@p_cre_by 							nvarchar(15)
	,@p_cre_ip_address 					nvarchar(15)
	,@p_mod_date 						datetime
	,@p_mod_by 							nvarchar(15)
	,@p_mod_ip_address 					nvarchar(15)
)
as
BEGIN

	declare @year					nvarchar(4)
			,@month					nvarchar(2)
			,@msg					nvarchar(max) 
			,@agent_no				nvarchar(50)
			,@id					BIGINT=0
			,@count					int
			,@code					nvarchar(50);
		
	if(isnull(@p_code,'') = '')
	begin
		
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output -- nvarchar(50)
													,@p_branch_code = @p_branch_code -- nvarchar(10)
													,@p_sys_document_code = N'' -- nvarchar(10)
													,@p_custom_prefix = N'IPR' -- nvarchar(10)
													,@p_year = @year -- nvarchar(2)
													,@p_month = @month -- nvarchar(2)
													,@p_table_name = N'OPL_INTERFACE_PAYMENT_REQUEST' -- nvarchar(100)
													,@p_run_number_length = 5 -- int
													,@p_delimiter = N'.' -- nvarchar(1)
													,@p_run_number_only = N'0' -- nvarchar(1)

    end

	begin try
		insert into dbo.opl_interface_payment_request
		(
		    code
		    ,branch_code
		    ,branch_name
		    ,payment_branch_code
		    ,payment_branch_name
		    ,payment_source
		    ,payment_request_date
		    ,payment_source_no
		    ,payment_status
		    ,payment_currency_code
		    ,payment_amount
		    ,payment_remarks
		    ,to_bank_account_name
		    ,to_bank_name
		    ,to_bank_account_no
		    ,process_date
		    ,process_reff_no
		    ,process_reff_name
		    ,manual_upload_status
			,manual_upload_remarks
			,job_status
			,failed_remarks
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		values
		(   
			@p_code						
			,@p_branch_code				
			,@p_branch_name				
			,@p_payment_branch_code		
			,@p_payment_branch_name		
			,@p_payment_source			
			,@p_payment_request_date	
			,@p_payment_source_no		
			,@p_payment_status			
			,@p_payment_currency_code	
			,@p_payment_amount			
			,@p_payment_remarks			
			,@p_to_bank_account_name	
			,@p_to_bank_name			
			,@p_to_bank_account_no		
			,@p_process_date			
			,@p_process_reff_no			
			,@p_process_reff_name		
			,@p_manual_upload_status
			,@p_manual_upload_remarks
			,@p_job_status
			,@p_failed_remarks
			--
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address	
		);
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	

end    
