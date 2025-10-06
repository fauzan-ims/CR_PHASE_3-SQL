/*
exec xsp_job_interface_in_ifinopl_additional_invoice_request
*/
-- raffy RABU, 06 AGUSTUS 2025 -- made for cr fase 3
CREATE PROCEDURE [dbo].[xsp_monitoring_invoice_late_return_post]
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
			,@ppn_pct						  DECIMAL(9, 6)
			,@ppn_amount					  INT
			,@pph_pct						  DECIMAL(9, 6)
			,@pph_amount					  INT
			,@total_amount					  DECIMAL(18, 2)
			,@reff_code						  NVARCHAR(50)
			,@reff_name						  nvarchar(250) 
			,@ovd_days						  int;

	
	begin try
		
		if exists
		(
			select	1
			from	dbo.agreement_asset_late_return
			where	asset_no = @p_asset_no
			and		payment_status <> 'HOLD'
		)
		begin
			set @msg = 'Data already proceed'
			raiserror (@msg, 16, -1)
		end


		update	dbo.agreement_asset_late_return
		set		payment_status	= 'ON PROCESS'
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	asset_no =  @p_asset_no

		SELECT		@agreement_no				= am.AGREEMENT_NO
					,@client_name				= am.client_name
					,@branch_name				= am.branch_name
					,@branch_code				= am.BRANCH_CODE
					,@client_no					= am.CLIENT_NO
					,@client_address			= aa.BILLING_TO_ADDRESS
					,@client_area_phone_no		= aa.BILLING_TO_AREA_NO
					,@client_phone_no			= aa.BILLING_TO_PHONE_NO
					,@client_npwp				= aa.BILLING_TO_NPWP
					,@currency_code				= am.currency_code
					,@ovd_days					= datediff(day, aaa.due_date, isnull(aa.return_date, dbo.xfn_get_system_date()))
					,@billing_amount			= SUM(ao.obligation_amount - ISNULL(aop.payment_amount, 0))
		from		dbo.agreement_obligation ao with (nolock)
					inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ao.agreement_no)
					outer apply
					(
						select	sum(aop.payment_amount) 'payment_amount'
						from	dbo.agreement_obligation_payment aop with (nolock)
						where	aop.obligation_code = ao.code
					) aop
								outer apply
					(
						select		top 1
									case
										when am.FIRST_PAYMENT_TYPE = 'ARR' then aaa.DUE_DATE
										else dateadd(month, 1, aaa.DUE_DATE)
									end 'DUE_DATE'
						from		dbo.agreement_asset_amortization as aaa with (nolock)
						where		aaa.asset_no = ao.asset_no
						order by	aaa.due_date desc
					) aaa
								inner join dbo.agreement_information ai with (nolock) on (ai.agreement_no = ao.agreement_no)
								inner join dbo.agreement_asset aa with (nolock) on (
																					   aa.agreement_no	  = ao.agreement_no
																					   and aa.asset_no	  = ao.asset_no
																				   )
					where		obligation_type		= 'LRAP'
					and			ao.asset_no			= @p_asset_no
					group by	am.agreement_no
								,am.client_name
								,am.branch_name
								,am.branch_code
								,am.client_no
								,aa.billing_to_address
								,aa.billing_to_area_no
								,aa.billing_to_phone_no
								,aa.billing_to_npwp
								,am.currency_code
								,datediff(day, aaa.due_date, isnull(aa.return_date, dbo.xfn_get_system_date()))

		set @invoice_name	= 'Invoice Late Return for Asset : ' + @p_asset_no
		set @description	= 'Late Return asset ' + isnull(@p_asset_no,'') + ' overdue ' + cast(isnull(@ovd_days,0) as nvarchar(10))

		exec dbo.xsp_additional_invoice_request_insert @p_code					= @additional_invoice_request_code output
													   ,@p_agreement_no			= @agreement_no			
													   ,@p_asset_no				= @p_asset_no				
													   ,@p_branch_code			= @branch_code			
													   ,@p_branch_name			= @branch_name			
													   ,@p_invoice_type			= 'LATERETURN'			
													   ,@p_invoice_date			= @p_cre_date
													   ,@p_invoice_name			= @invoice_name		
													   ,@p_client_no			= @client_no			
													   ,@p_client_name			= @client_name			
													   ,@p_client_address		= @client_address		
													   ,@p_client_area_phone_no = @client_area_phone_no
													   ,@p_client_phone_no		= @client_phone_no		
													   ,@p_client_npwp			= @client_npwp			
													   ,@p_currency_code		= @currency_code		
													   ,@p_tax_scheme_code		= ''		
													   ,@p_tax_scheme_name		= ''		
													   ,@p_billing_no			= ''			
													   ,@p_description			= @description			
													   ,@p_quantity				= 1				
													   ,@p_billing_amount		= @billing_amount		
													   ,@p_discount_amount		= 0		
													   ,@p_ppn_pct				= 0				
													   ,@p_ppn_amount			= 0			
													   ,@p_pph_pct				= 0				
													   ,@p_pph_amount			= 0			
													   ,@p_total_amount			= @billing_amount			
													   ,@p_reff_code			= @p_asset_no			
													   ,@p_reff_name			= 'LATE RETURN'
													   --
													   ,@p_cre_date				= @p_cre_date		
													   ,@p_cre_by				= @p_cre_by		
													   ,@p_cre_ip_address		= @p_cre_ip_address
													   ,@p_mod_date				= @p_mod_date		
													   ,@p_mod_by				= @p_mod_by		
													   ,@p_mod_ip_address		= @p_mod_ip_address
		


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
