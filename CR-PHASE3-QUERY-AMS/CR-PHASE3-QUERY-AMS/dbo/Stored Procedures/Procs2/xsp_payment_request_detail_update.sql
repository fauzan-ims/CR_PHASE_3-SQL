create procedure xsp_payment_request_detail_update
(
	@p_id								bigint
	,@p_payment_request_code			nvarchar(50)
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_gl_link_code					nvarchar(50)
	,@p_agreement_no					nvarchar(50)
	,@p_facility_code					nvarchar(50)
	,@p_facility_name					nvarchar(250)
	,@p_purpose_loan_code				nvarchar(50)
	,@p_purpose_loan_name				nvarchar(250)
	,@p_purpose_loan_detail_code		nvarchar(250)
	,@p_purpose_loan_detail_name		nvarchar(50)
	,@p_orig_currency_code				nvarchar(3)
	,@p_exch_rate						decimal(9,6)
	,@p_orig_amount						decimal(18,2)
	,@p_division_code					nvarchar(50)
	,@p_division_name					nvarchar(250)
	,@p_department_code					nvarchar(50)
	,@p_department_name					nvarchar(250)
	,@p_remarks							nvarchar(4000)
	,@p_is_taxable						nvarchar(1)
	,@p_tax_amount						decimal(18,2)
	,@p_tax_pct							decimal(9,6)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(50)
	,@p_mod_ip_address					nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		update	payment_request_detail
		set		payment_request_code		= @p_payment_request_code	
				,branch_code				= @p_branch_code				
				,branch_name				= @p_branch_name				
				,gl_link_code				= @p_gl_link_code			
				,agreement_no				= @p_agreement_no			
				,facility_code				= @p_facility_code			
				,facility_name				= @p_facility_name			
				,purpose_loan_code			= @p_purpose_loan_code		
				,purpose_loan_name			= @p_purpose_loan_name		
				,purpose_loan_detail_code	= @p_purpose_loan_detail_code
				,purpose_loan_detail_name	= @p_purpose_loan_detail_name
				,orig_currency_code			= @p_orig_currency_code		
				,exch_rate					= @p_exch_rate				
				,orig_amount				= @p_orig_amount				
				,division_code				= @p_division_code			
				,division_name				= @p_division_name			
				,department_code			= @p_department_code			
				,department_name			= @p_department_name			
				,remarks					= @p_remarks					
				,is_taxable					= @p_is_taxable				
				,tax_amount					= @p_tax_amount				
				,tax_pct					= @p_tax_pct									
				,mod_date					= @p_mod_date				
				,mod_by						= @p_mod_by							
				,mod_ip_address 			= @p_mod_ip_address
		where	id							= @p_id
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
