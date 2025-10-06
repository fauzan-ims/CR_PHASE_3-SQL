-- raffy RABU, 06 AGUSTUS 2025 -- made for cr fase 3
CREATE PROCEDURE dbo.xsp_handover_to_monitoring_late_return
(
	@p_asset_no			nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
AS
begin

	declare @msg							  nvarchar(max)
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
			,@reff_name						  nvarchar(250) 
			,@ovd_days						  int
			,@maturity_date					  datetime
			,@bast_date						  datetime;

	
	begin try
    
		select		@agreement_no				= am.agreement_no
					,@client_name				= am.client_name
					,@branch_name				= am.branch_name
					,@branch_code				= am.branch_code
					,@client_no					= am.client_no
					,@currency_code				= am.currency_code
					,@maturity_date				= ags.maturity_date
					,@bast_date					= ags.return_date
					,@ovd_days					= datediff(day,ags.maturity_date, isnull(ags.return_date, dbo.xfn_get_system_date()))
		from		dbo.agreement_asset ags with (nolock)
					inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ags.agreement_no)
		where		ags.asset_no = @p_asset_no

		select		@billing_amount		= isnull(sum(ao.obligation_amount),0) - isnull(sum(aop.payment_amount),0)
		from		dbo.agreement_obligation ao with (nolock)
					outer apply
					(
						select	sum(isnull(aop.payment_amount,0)) 'payment_amount'
						from	dbo.agreement_obligation_payment aop with (nolock)
						where	aop.obligation_code = ao.code
					) aop
		where		obligation_type		= 'LRAP'
		and			ao.asset_no			= @p_asset_no
					
		set @billing_amount = isnull(@billing_amount,0)

		exec dbo.xsp_agreement_asset_late_return_insert @p_code					= '',
		                                                @p_agreement_no			= @agreement_no, 
		                                                @p_asset_no				= @p_asset_no,   
		                                                @p_branch_code			= @branch_code,  
		                                                @p_branch_name			= @branch_name,  
		                                                @p_currency_code		= @currency_code,
		                                                @p_os_obligation_amount = @billing_amount,
		                                                @p_maturity_date		= @maturity_date,
		                                                @p_bast_date			= @bast_date,    
		                                                @p_payment_status		= N'HOLD',       
		                                                @p_late_return_days		= @ovd_days,     
		                                                @p_invoice_no			= NULL,          
		                                                @p_credit_note_no		= NULL,          
		                                                @p_waive_no				= NULL,          
		                                                @p_cre_date				= @p_cre_date,
		                                                @p_cre_by				= @p_cre_by,			
		                                                @p_cre_ip_address		= @p_cre_ip_address,
		                                                @p_mod_date				= @p_mod_date,		
		                                                @p_mod_by				= @p_mod_by,			
		                                                @p_mod_ip_address		= @p_mod_ip_address
		
		
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
