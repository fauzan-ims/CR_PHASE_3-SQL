-- Stored Procedure

CREATE PROCEDURE dbo.xsp_additional_invoice_request_for_additional_invoice_proceed
(
	@p_code					nvarchar(50) 
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg					  nvarchar(max)
			,@additional_invoice_code nvarchar(50)
			,@invoice_type			  nvarchar(10)
			,@invoice_date			  datetime
			,@invoice_due_date		  datetime
			,@invoice_name			  nvarchar(250)
			,@invoice_status		  nvarchar(10)
			,@client_no				  nvarchar(50)
			,@client_name			  nvarchar(250)
			,@client_address		  nvarchar(4000)
			,@client_area_phone_no	  nvarchar(4)
			,@client_phone_no		  nvarchar(15)
			,@client_npwp			  nvarchar(50)	 = ''
			,@currency_code			  nvarchar(3)	 = ''
			,@total_billing_amount	  decimal(18, 2) = 0
			,@total_discount_amount	  decimal(18, 2) = 0
			,@total_ppn_amount		  int = 0
			,@total_pph_amount		  int = 0
			,@total_amount			  decimal(18, 2) = 0
			,@branch_code			  nvarchar(50)
			,@branch_name			  nvarchar(250)
			,@agreement_no			  nvarchar(50)
			,@asset_no				  nvarchar(50)
			,@tax_scheme_code		  nvarchar(50)
			,@tax_scheme_name		  nvarchar(250)
			,@billing_no			  int
			,@description			  nvarchar(4000)
			,@quantity				  int
			,@billing_amount		  decimal(18, 2)
			,@discount_amount		  decimal(18, 2)
			,@ppn_pct				  decimal(9, 6)
			,@ppn_amount			  int
			,@pph_pct				  decimal(9, 6)
			,@pph_amount			  int
			,@reff_code				  nvarchar(50)
			,@reff_name				  nvarchar(250) ;

	begin try
		select	@invoice_type		   = invoice_type			 
				,@invoice_date		   = invoice_date		 		 
				,@invoice_name		   = invoice_name	 	 
				,@client_no			   = client_no				 
				--,@client_name		   = agrs.billing_to_name			 
				,@client_name		   = air.client_name -- (+) Ari 2023-09-13 ket : change billing to name to client name		 
				,@client_address	   = agrs.billing_to_address		 
				,@client_area_phone_no = agrs.billing_to_area_no	 
				,@client_phone_no	   = agrs.billing_to_phone_no		 
				,@client_npwp		   = agrs.billing_to_npwp			 
				,@currency_code		   = currency_code		 
				,@branch_code		   = branch_code			 
				,@branch_name		   = branch_name
				,@agreement_no		   = air.agreement_no
				,@asset_no			   = air.asset_no
				,@tax_scheme_code	   = tax_scheme_code
				,@tax_scheme_name	   = tax_scheme_name
				,@billing_no		   = billing_no
				,@description		   = description
				,@quantity			   = quantity
				,@billing_amount	   = billing_amount
				,@discount_amount	   = air.discount_amount
				,@ppn_pct			   = ppn_pct
				,@ppn_amount		   = ppn_amount
				,@pph_pct			   = pph_pct
				,@pph_amount		   = pph_amount
				,@total_amount		   = total_amount
				,@reff_code			   = reff_code
				,@reff_name			   = reff_name
		from	dbo.additional_invoice_request air with (nolock)
		left join dbo.agreement_asset agrs on (agrs.asset_no = air.asset_no) 
		where   air.code			   = @p_code

		if exists
		(
			select	1
			from	dbo.additional_invoice_request with (nolock)
			where	code			   = @p_code
					and status <> 'HOLD'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;

			raiserror(@msg, 16, -1) ;
		end ; 
		
		begin   

			if not exists	(
							select	1 
							from	dbo.additional_invoice ai with (nolock)
							left join dbo.additional_invoice_detail aid on aid.additional_invoice_code = ai.code
							where	invoice_status				= 'HOLD'
									and client_no				= @client_no
									and branch_code				= @branch_code
									and isnull(invoice_type,'')	= isnull(@invoice_type,'') 
									and aid.agreement_no		= @agreement_no -- 20231230 - hari - tambahkan logic gabungan invoice hanya untuk 1 customer saja

						)
			begin  
		
				exec dbo.xsp_additional_invoice_insert @p_code						= @additional_invoice_code output -- nvarchar(50)
													   ,@p_invoice_type				= @invoice_type
													   ,@p_invoice_date				= @invoice_date
													   ,@p_invoice_due_date			= null
													   ,@p_invoice_name				= @invoice_name
													   ,@p_invoice_status			= N'HOLD'
													   ,@p_client_no				= @client_no			   
													   ,@p_client_name				= @client_name		   
													   ,@p_client_address			= @client_address	   
													   ,@p_client_area_phone_no		= @client_area_phone_no 
													   ,@p_client_phone_no			= @client_phone_no	   
													   ,@p_client_npwp				= @client_npwp		   
													   ,@p_currency_code			= @currency_code		   
													   ,@p_total_billing_amount		= 0
													   ,@p_total_discount_amount	= 0
													   ,@p_total_ppn_amount			= 0
													   ,@p_total_pph_amount			= 0
													   ,@p_total_amount				= 0
													   ,@p_branch_code				= @branch_code
													   ,@p_branch_name				= @branch_name
													   --
													   ,@p_cre_date					= @p_cre_date
													   ,@p_cre_by					= @p_cre_by
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_cre_date
													   ,@p_mod_by					= @p_cre_by
													   ,@p_mod_ip_address			= @p_cre_ip_address
			end
			else
			begin
				select	@additional_invoice_code	= code 
				from	dbo.additional_invoice with (nolock)
				where	invoice_status				= 'HOLD'  
						and client_no				= @client_no
						and branch_code				= @branch_code
						and isnull(invoice_type,'')	= isnull(@invoice_type,'') 
			end

			exec dbo.xsp_additional_invoice_detail_insert @p_id									= 0
														  ,@p_additional_invoice_code			= @additional_invoice_code
														  ,@p_agreement_no						= @agreement_no		
														  ,@p_asset_no							= @asset_no			
														  ,@p_tax_scheme_code					= @tax_scheme_code	
														  ,@p_tax_scheme_name					= @tax_scheme_name	
														  ,@p_billing_no						= @billing_no		
														  ,@p_description						= @description		
														  ,@p_quantity							= @quantity			
														  ,@p_billing_amount					= @billing_amount		
														  ,@p_discount_amount					= @discount_amount		
														  ,@p_ppn_pct							= @ppn_pct				
														  ,@p_ppn_amount						= @ppn_amount			
														  ,@p_pph_pct							= @pph_pct				
														  ,@p_pph_amount						= @pph_amount			
														  ,@p_total_amount						= @total_amount			
														  ,@p_reff_code							= @reff_code				
														  ,@p_reff_name							= @reff_name	
														  ,@p_additional_invoice_request_code	= @p_code			
														  --
														  ,@p_cre_date							= @p_cre_date
														  ,@p_cre_by							= @p_cre_by
														  ,@p_cre_ip_address					= @p_cre_ip_address
														  ,@p_mod_date							= @p_mod_date
														  ,@p_mod_by							= @p_mod_by
														  ,@p_mod_ip_address					= @p_mod_ip_address 
		
		update	additional_invoice_request
		set		status			= 'ON PROCESS'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_code ;


		select	@total_billing_amount	= isnull(sum(isnull(billing_amount, 0)), 0)
				,@total_discount_amount = isnull(sum(isnull(discount_amount, 0)), 0)
				,@total_ppn_amount		= isnull(sum(isnull(ppn_amount, 0)), 0)
				,@total_pph_amount		= isnull(sum(isnull(pph_amount, 0)), 0)
				,@total_amount			= isnull(sum(isnull(total_amount, 0)), 0)
		from	dbo.additional_invoice_detail
		where	additional_invoice_code = @additional_invoice_code ;

		update	dbo.additional_invoice
		set		total_billing_amount	= @total_billing_amount	
				,total_discount_amount	= @total_discount_amount 
				,total_ppn_amount		= @total_ppn_amount		
				,total_pph_amount		= @total_pph_amount		
				,total_amount			= @total_amount		
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address	
		where	code					= @additional_invoice_code ;
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

end

