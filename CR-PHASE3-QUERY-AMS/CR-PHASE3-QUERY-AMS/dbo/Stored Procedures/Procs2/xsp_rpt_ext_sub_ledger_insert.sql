create PROCEDURE [dbo].[xsp_rpt_ext_sub_ledger_insert]
(
	 @p_id							bigint  
	,@p_entry_date					datetime
	,@p_entry_time					nvarchar(6)
	,@p_system_id					nvarchar(10)
	,@p_doc_number					nvarchar(50)
	,@p_item_no						nvarchar(5)
	,@p_company_code				nvarchar(4)
	,@p_fiscal_year					nvarchar(4)
	,@p_posting_date				datetime
	,@p_document_date				datetime
	,@p_rev_status					nvarchar(1)
	,@p_pph_type					nvarchar(50)
	,@p_vendor						nvarchar(50)
	,@p_income_type					nvarchar(250)
	,@p_income_bruto				decimal(18,2)
	,@p_tariff_rate					decimal(9,6)
	,@p_pph_amount					decimal(18,2)
	,@p_description					nvarchar(4000)
	,@p_tax_number					nvarchar(50)
	,@p_sale_type					nvarchar(4)	
	,@p_sap_extract_date			datetime
	,@p_sap_extract_time			nvarchar(6)
	,@p_sap_post_message			nvarchar(4000)
	,@p_cre_date               		datetime           
	,@p_cre_by                 		nvarchar(15)       
	,@p_cre_ip_address         		nvarchar(15)       
	,@p_mod_date               		datetime           
	,@p_mod_by                 		nvarchar(15)       
	,@p_mod_ip_address 				nvarchar(15)       
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		insert into dbo.rpt_ext_subledger
		(
			entry_date
			,entry_time
			,system_id
			,doc_number
			,item_no
			,company_code
			,fiscal_year
			,posting_date
			,document_date
			,rev_status
			,pph_type
			,vendor
			,income_type
			,income_bruto
			,tariff_rate
			,pph_amount
			,description
			,tax_number
			,sale_type
			,sap_extract_date
			,sap_extract_time
			,sap_post_message
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
			@p_entry_date					
			,@p_entry_time					
			,@p_system_id					
			,@p_doc_number					
			,@p_item_no						
			,@p_company_code				
			,@p_fiscal_year					
			,@p_posting_date				
			,@p_document_date				
			,@p_rev_status					
			,@p_pph_type					
			,@p_vendor						
			,@p_income_type					
			,@p_income_bruto				
			,@p_tariff_rate					
			,@p_pph_amount					
			,@p_description					
			,@p_tax_number					
			,@p_sale_type					
			,@p_sap_extract_date			
			,@p_sap_extract_time			
			,@p_sap_post_message			
			--
			,@p_cre_date				
			,@p_cre_by					
			,@p_cre_ip_address			
			,@p_mod_date				
			,@p_mod_by					
			,@p_mod_ip_address
		)
		set @p_id = @@identity
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
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
