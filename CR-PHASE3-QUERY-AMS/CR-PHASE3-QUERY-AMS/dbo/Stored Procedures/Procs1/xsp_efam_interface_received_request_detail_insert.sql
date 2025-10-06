

CREATE PROCEDURE dbo.xsp_efam_interface_received_request_detail_insert
(
	@p_id							bigint = 0 output
	,@p_received_request_code		nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_gl_link_code				nvarchar(50)
	,@p_agreement_no				nvarchar(50)
	,@p_facility_code				nvarchar(50)
	,@p_facility_name				nvarchar(250)
	,@p_purpose_loan_code			nvarchar(50)
	,@p_purpose_loan_name			nvarchar(250)
	,@p_purpose_loan_detail_code	nvarchar(50)
	,@p_purpose_loan_detail_name	nvarchar(250)
	,@p_orig_currency_code			nvarchar(3)
	,@p_orig_amount					decimal(18, 2)
	,@p_division_code				nvarchar(50)
	,@p_division_name				nvarchar(250)
	,@p_department_code				nvarchar(50)
	,@p_department_name				nvarchar(250)
	,@p_remarks						nvarchar(4000)
	,@p_ext_pph_type				nvarchar(20)	= null
	,@p_ext_vendor_code				nvarchar(50)	= null
	,@p_ext_vendor_name				nvarchar(250)	= null
	,@p_ext_vendor_npwp				nvarchar(20)	= null
	,@p_ext_vendor_address			nvarchar(4000)	= null
	,@p_ext_vendor_type				nvarchar(20)	= null
	,@p_ext_income_type				nvarchar(20)	= null
	,@p_ext_income_bruto_amount		decimal(18,2)	= null
	,@p_ext_tax_rate_pct			decimal(5,2)	= null
	,@p_ext_pph_amount				decimal(18,2)	= null
	,@p_ext_description				nvarchar(4000)	= null
	,@p_ext_tax_number				nvarchar(50)	= null
	,@p_ext_sale_type				nvarchar(50)	= NULL
    ,@p_ext_tax_date				DATETIME
    ,@p_ext_nitku					NVARCHAR(50)	= ''
	,@p_ext_npwp_ho					NVARCHAR(50)	= ''
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		insert into efam_interface_received_request_detail
		(
			received_request_code
			,company_code
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
			,remarks
			,ext_tax_date
			,ext_nitku
			,ext_npwp_ho
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_received_request_code
			,@p_company_code
			,@p_branch_code
			,@p_branch_name
			,@p_gl_link_code
			,@p_agreement_no
			,@p_facility_code
			,@p_facility_name
			,@p_purpose_loan_code
			,@p_purpose_loan_name
			,@p_purpose_loan_detail_code
			,@p_purpose_loan_detail_name
			,@p_orig_currency_code
			,@p_orig_amount
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_ext_pph_type			
			,@p_ext_vendor_code			
			,@p_ext_vendor_name			
			,@p_ext_vendor_npwp			
			,@p_ext_vendor_address		
			,@p_ext_vendor_type			
			,@p_ext_income_type			
			,@p_ext_income_bruto_amount	
			,@p_ext_tax_rate_pct		
			,@p_ext_pph_amount			
			,@p_ext_description			
			,@p_ext_tax_number			
			,@p_ext_sale_type			
			,@p_remarks
			,@p_ext_tax_date
			,@p_ext_nitku
			,@p_ext_npwp_ho
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
end ;
