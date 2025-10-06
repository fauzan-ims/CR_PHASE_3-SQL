create PROCEDURE [dbo].[xsp_rpt_ext_subledger_detail_insert]
(
	 @p_id						bigint
	,@p_entry_date				datetime
	,@p_entry_time				nvarchar(6)
	,@p_system_id				nvarchar(50)
	,@p_gl_account				nvarchar(50)
	,@p_sbl_no					nvarchar(50)
	,@p_sbl_date				datetime
	,@p_voucher_number			nvarchar(50)
	,@p_voucher_date			datetime
	,@p_transaction_date		datetime
	,@p_profit_center			nvarchar(50)
	,@p_cost_center				nvarchar(50)
	,@p_dr_amount				decimal(18,2)
	,@p_cr_amount				decimal(18,2)
	,@p_address					nvarchar(4000)
	,@p_category_trx			nvarchar(50)
	,@p_persons					nvarchar(250)
	,@p_zposition				nvarchar(250)
	,@p_company_name			nvarchar(4)
	,@p_description				nvarchar(4000)
	,@p_input_date				datetime
	,@p_input_by				nvarchar(250)
	,@p_update_by				nvarchar(250)
	,@p_currency				nvarchar(4)
	,@p_company_profile			nvarchar(50)
	,@p_pph_amount				decimal(18,2)
	,@p_faktur_number			nvarchar(50)
	,@p_rev_status				nvarchar(1)
	,@p_npwp					nvarchar(25)
	,@p_company_code			nvarchar(4)
	,@p_fiscal_year				nvarchar(4)
	,@p_voucher_no_rev			nvarchar(50)
	,@p_voucher_date_rev		datetime
	,@p_sap_extract_date		datetime
	,@p_sap_extract_time		nvarchar(6)
	,@p_sap_post_message		nvarchar(4000)
	,@p_dsf_person				nvarchar(250)
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
		
		insert into dbo.rpt_ext_subledger_detail
		(
			entry_date
			,entry_time
			,system_id
			,gl_account
			,sbl_no
			,sbl_date
			,voucher_number
			,voucher_date
			,transaction_date
			,profit_center
			,cost_center
			,dr_amount
			,cr_amount
			,address
			,category_trx
			,persons
			,zposition
			,company_name
			,description
			,input_date
			,input_by
			,update_by
			,currency
			,company_profile
			,pph_amount
			,faktur_number
			,rev_status
			,npwp
			,company_code
			,fiscal_year
			,voucher_no_rev
			,voucher_date_rev
			,sap_extract_date
			,sap_extract_time
			,sap_post_message
			,dsf_person
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
			,@p_gl_account				
			,@p_sbl_no					
			,@p_sbl_date				
			,@p_voucher_number			
			,@p_voucher_date			
			,@p_transaction_date		
			,@p_profit_center			
			,@p_cost_center				
			,@p_dr_amount				
			,@p_cr_amount				
			,@p_address					
			,@p_category_trx			
			,@p_persons					
			,@p_zposition				
			,@p_company_name			
			,@p_description				
			,@p_input_date				
			,@p_input_by				
			,@p_update_by				
			,@p_currency				
			,@p_company_profile			
			,@p_pph_amount				
			,@p_faktur_number			
			,@p_rev_status				
			,@p_npwp					
			,@p_company_code			
			,@p_fiscal_year				
			,@p_voucher_no_rev			
			,@p_voucher_date_rev		
			,@p_sap_extract_date		
			,@p_sap_extract_time		
			,@p_sap_post_message		
			,@p_dsf_person				
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
