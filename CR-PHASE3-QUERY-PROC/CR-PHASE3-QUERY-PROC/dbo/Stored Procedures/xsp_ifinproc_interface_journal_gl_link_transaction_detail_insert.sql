
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_ifinproc_interface_journal_gl_link_transaction_detail_insert]
(
	@p_gl_link_transaction_code			nvarchar(50)
	,@p_company_code					nvarchar(50)
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_cost_center_code				nvarchar(50)
	,@p_cost_center_name				nvarchar(250)
	,@p_gl_link_code					nvarchar(50)
	,@p_agreement_no					nvarchar(50)
	,@p_facility_code					nvarchar(50)
	,@p_facility_name					nvarchar(250)
	,@p_purpose_loan_code				nvarchar(50)
	,@p_purpose_loan_name				nvarchar(250)
	,@p_purpose_loan_detail_code		nvarchar(50)
	,@p_purpose_loan_detail_name		nvarchar(250)
	,@p_orig_currency_code				nvarchar(3)
	,@p_orig_amount_db					decimal(18, 2)
	,@p_orig_amount_cr					decimal(18, 2)
	,@p_exch_rate						decimal(9, 6)
	,@p_base_amount_db					decimal(18, 2)
	,@p_base_amount_cr					decimal(18, 2)
	,@p_division_code					nvarchar(50)
	,@p_division_name					nvarchar(250)
	,@p_department_code					nvarchar(50)
	,@p_department_name					nvarchar(250)
	,@p_remarks							nvarchar(4000)	= ''
	,@p_ext_pph_type					nvarchar(20)	= null
	,@p_ext_vendor_code					nvarchar(50)	= null
	,@p_ext_vendor_name					nvarchar(250)	= null
	,@p_ext_vendor_npwp					nvarchar(20)	= null
	,@p_ext_vendor_address				nvarchar(4000)	= null
	,@p_ext_income_type					nvarchar(250)	= null
	,@p_ext_income_bruto_amount			decimal(18,2)	= null
	,@p_ext_tax_rate_pct				decimal(5,2)	= null
	,@p_ext_pph_amount					decimal(18,2)	= null
	,@p_ext_description					nvarchar(4000)	= null
	,@p_ext_tax_number					nvarchar(50)	= null
	,@p_ext_sale_type					nvarchar(10)	= NULL
    ,@p_ext_vendor_nitku				NVARCHAR(50)	= ''
	,@p_ext_vendor_npwp_pusat			NVARCHAR(50)	= ''
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
    ,@p_po_detail_object_id				bigint = 0 -- sepria cr priority 26082025, kebutuhan untuk jurnal final dan invoice

)
as
begin
	declare @msg	nvarchar(max) ;

	begin try
		if(@p_base_amount_db + @p_base_amount_cr <> 0)
		begin 
			insert into dbo.ifinproc_interface_journal_gl_link_transaction_detail
			(
				gl_link_transaction_code
				,company_code
				,branch_code
				,branch_name
				,cost_center_code
				,cost_center_name
				,gl_link_code
				,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount_db
				,orig_amount_cr
				,exch_rate
				,base_amount_db
				,base_amount_cr
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
				,ext_income_type
				,ext_income_bruto_amount
				,ext_tax_rate_pct
				,ext_pph_amount
				,ext_description
				,ext_tax_number
				,ext_sale_type
				--(+) Raffy 2025/02/01 cr nitku
				,ext_vendor_nitku
				,ext_vendor_npwp_pusat
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,po_detail_object_id
			)
			values
			(	@p_gl_link_transaction_code
				,@p_company_code
				,@p_branch_code
				,@p_branch_name
				,@p_cost_center_code
				,@p_cost_center_name
				,@p_gl_link_code
				,@p_agreement_no
				,@p_facility_code
				,@p_facility_name
				,@p_purpose_loan_code
				,@p_purpose_loan_name
				,@p_purpose_loan_detail_code
				,@p_purpose_loan_detail_name
				,@p_orig_currency_code
				,@p_orig_amount_db
				,@p_orig_amount_cr
				,@p_exch_rate
				,@p_base_amount_db
				,@p_base_amount_cr
				,@p_division_code
				,@p_division_name
				,@p_department_code
				,@p_department_name
				,@p_remarks
				,@p_ext_pph_type			
				,@p_ext_vendor_code			
				,@p_ext_vendor_name			
				,@p_ext_vendor_npwp			
				,@p_ext_vendor_address		
				,@p_ext_income_type			
				,@p_ext_income_bruto_amount	
				,@p_ext_tax_rate_pct		
				,@p_ext_pph_amount			
				,@p_ext_description			
				,@p_ext_tax_number			
				,@p_ext_sale_type			
				,@p_ext_vendor_nitku
				,@p_ext_vendor_npwp_pusat
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_po_detail_object_id
			) ;
		end

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

