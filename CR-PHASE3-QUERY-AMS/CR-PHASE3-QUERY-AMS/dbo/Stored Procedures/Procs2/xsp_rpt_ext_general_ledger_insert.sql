create PROCEDURE [dbo].[xsp_rpt_ext_general_ledger_insert]
(
	 @p_id						bigint
	,@p_entry_date				datetime
	,@p_entry_time				nvarchar(6)
	,@p_system_id				nvarchar(50)
	,@p_doc_number				nvarchar(50)
	,@p_item_no					int
	,@p_company_code			nvarchar(4)
	,@p_fiscal_year				nvarchar(4)
	,@p_currency				nvarchar(4)
	,@p_posting_date			datetime
	,@p_document_date			datetime
	,@p_period					nvarchar(2)
	,@p_user_name				nvarchar(250)
	,@p_doc_type				nvarchar(3)
	,@p_header_text				nvarchar(4000)
	,@p_reference				nvarchar(4000)
	,@p_gl_account				nvarchar(50)
	,@p_vendor_id				nvarchar(50)
	,@p_customer_id				nvarchar(50)
	,@p_dc_indicator			nvarchar(1)
	,@p_internal_order			nvarchar(50)
	,@p_assigment				nvarchar(50)
	,@p_reference_key1			nvarchar(50)
	,@p_reference_key2			nvarchar(50)
	,@p_reference_key3			nvarchar(50)
	,@p_item_text				nvarchar(50)
	,@p_amount_doc				decimal(18,2)
	,@p_amount_loc				decimal(18,2)
	,@p_cost_center				nvarchar(50)
	,@p_profit_center			nvarchar(50)
	,@p_plant					nvarchar(4)
	,@p_currency_rate			decimal(9,6)
	,@p_sap_extract_date		datetime
	,@p_sap_extract_time		nvarchar(6)
	,@p_sap_post_message		nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		insert into dbo.rpt_ext_general_ledger
		(
			entry_date
			,entry_time
			,system_id
			,doc_number
			,item_no
			,company_code
			,fiscal_year
			,currency
			,posting_date
			,document_date
			,period
			,user_name
			,doc_type
			,header_text
			,reference
			,gl_account
			,vendor_id
			,customer_id
			,dc_indicator
			,internal_order
			,assigment
			,reference_key1
			,reference_key2
			,reference_key3
			,item_text
			,amount_doc
			,amount_loc
			,cost_center
			,profit_center
			,plant
			,currency_rate
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
			,@p_currency
			,@p_posting_date
			,@p_document_date
			,@p_period
			,@p_user_name
			,@p_doc_type
			,@p_header_text
			,@p_reference
			,@p_gl_account
			,@p_vendor_id
			,@p_customer_id
			,@p_dc_indicator
			,@p_internal_order
			,@p_assigment
			,@p_reference_key1
			,@p_reference_key2
			,@p_reference_key3
			,@p_item_text
			,@p_amount_doc
			,@p_amount_loc
			,@p_cost_center
			,@p_profit_center
			,@p_plant
			,@p_currency_rate
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
