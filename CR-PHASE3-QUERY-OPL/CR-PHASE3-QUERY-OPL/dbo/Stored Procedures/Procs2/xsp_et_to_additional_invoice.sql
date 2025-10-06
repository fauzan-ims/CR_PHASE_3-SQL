CREATE PROCEDURE dbo.xsp_et_to_additional_invoice
(
	@p_code			   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_date		   datetime
	,@p_invoice_type   nvarchar(10)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@invoice_name			nvarchar(250)
			,@additional_invoice	nvarchar(50)
			,@asset_no				nvarchar(50)
			,@billing_no			int
			,@description			nvarchar(4000)
			,@billing_amount		decimal(18, 2) = 0
			,@discount_amount		decimal(18, 2) = 0
			,@ppn_pct				decimal(9, 6)
			,@ppn_amount			int
			,@pph_pct				decimal(9, 6)
			,@pph_amount			int
			,@total_amount			decimal(18, 2)
			,@after_discount		decimal(18, 2)
			,@client_no				nvarchar(50)
			,@client_name			nvarchar(250)
			,@client_address		nvarchar(4000)
			,@client_area_phone_no	nvarchar(4)
			,@client_phone_no		nvarchar(15)
			,@client_npwp			nvarchar(50)
			,@currency_code			nvarchar(3) 
			,@agrement_external_no	nvarchar(50)
			,@asset_count			int

	begin try
		select @ppn_pct = value 
		from dbo.sys_global_param
		where code = ('RTAXPPN')

		select @pph_pct = value 
		from dbo.sys_global_param
		where code = ('RTAXPPH') 

		select	@agrement_external_no = agreement_external_no
		from	dbo.agreement_main
		where	agreement_no = @p_agreement_no ;

		set @invoice_name = 'Invoice ET for Agreement : ' + @agrement_external_no;

		select	@asset_count = count(1)
		from	dbo.et_detail
		where	et_code			 = @p_code
				and is_terminate = '1' ;
				 
		declare curretdetail cursor fast_forward read_only for
		select	asset_no 
		from	dbo.et_detail
		where	et_code			 = @p_code
				and is_terminate = '1' ;

		open curretdetail ;

		fetch next from curretdetail
		into @asset_no;

		while @@fetch_status = 0
		begin 
			if (@p_invoice_type = 'RENTAL')
			begin

				set @billing_no = dbo.xfn_asset_get_installment_no(@asset_no)

				set @description = N'Rental Pelunasan Dipercepat, tanggal pelunasan : ' + convert(nvarchar(25), @p_date, 106)
				
				select	@billing_amount = round(total_amount / @asset_count, 0)
				from	dbo.et_transaction
				where	et_code			= @p_code
						and transaction_code = 'ET_INTERIM'; 

				  set @ppn_amount = 0 ;
				  
				  set @pph_amount = 0 ;
				  
				  set @pph_pct = 0 ;
				  
				  set @ppn_pct = 0 ;

				  set @total_amount = @billing_amount
			end
			else
			begin
				set @billing_no = dbo.xfn_asset_get_installment_no(@asset_no)

				--set @description = N'Penalty Pelunasan Dipercepat, tanggal pelunasan : ' + convert(nvarchar(25), @p_date, 106)
				set @description = N'Penalty Early Termination, Tanggal Early Termination : ' + convert(nvarchar(25), @p_date, 106) --Raffy issue 2792, 2942

				--set @billing_amount = dbo.xfn_agreement_get_et_penalty_by_asset(@asset_no, @p_agreement_no, @p_date) ;
				
				select	@billing_amount = round(total_amount / @asset_count, 0)
				from	dbo.et_transaction
				where	et_code			= @p_code
						and transaction_code = 'CETP';
				
				set @after_discount = @billing_amount

				set @ppn_amount = 0 ;

				set @pph_amount = 0 ;

				set @pph_pct = 0 ;

				set @ppn_pct = 0 ;

				set @total_amount = @after_discount
			end 

			select	@client_no				= am.client_no
					,@client_name			= am.client_name
					,@client_address		= isnull(aa.npwp_address, '')
					,@client_area_phone_no  = aa.billing_to_area_no
					,@client_phone_no		= aa.billing_to_phone_no
					,@client_npwp			= aa.billing_to_npwp
					,@currency_code			= am.currency_code
			from	dbo.agreement_asset aa
					inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	asset_no = @asset_no ;

			if (@total_amount > 0)
			begin
				exec dbo.xsp_additional_invoice_request_insert @p_code					= @additional_invoice output
															   ,@p_agreement_no			= @p_agreement_no
															   ,@p_asset_no				= @asset_no
															   ,@p_branch_code			= @p_branch_code
															   ,@p_branch_name			= @p_branch_name
															   ,@p_invoice_type			= @p_invoice_type
															   ,@p_invoice_date			= @p_date
															   ,@p_invoice_name			= @invoice_name
															   ,@p_client_no			= @client_no				
															   ,@p_client_name			= @client_name			
															   ,@p_client_address		= @client_address		
															   ,@p_client_area_phone_no = @client_area_phone_no  
															   ,@p_client_phone_no		= @client_phone_no		
															   ,@p_client_npwp			= @client_npwp			
															   ,@p_currency_code		= @currency_code			
															   ,@p_tax_scheme_code		= N''
															   ,@p_tax_scheme_name		= N''
															   ,@p_billing_no			= @billing_no
															   ,@p_description			= @description
															   ,@p_quantity				= 1
															   ,@p_billing_amount		= @total_amount
															   ,@p_discount_amount		= 0
															   ,@p_ppn_pct				= 0
															   ,@p_ppn_amount			= 0
															   ,@p_pph_pct				= 0
															   ,@p_pph_amount			= 0
															   ,@p_total_amount			= @total_amount
															   ,@p_reff_code			= @p_code
															   ,@p_reff_name			= 'ET'
															   --
															   ,@p_cre_date				= @p_cre_date
															   ,@p_cre_by				= @p_cre_by
															   ,@p_cre_ip_address		= @p_cre_ip_address
															   ,@p_mod_date				= @p_mod_date
															   ,@p_mod_by				= @p_mod_by
															   ,@p_mod_ip_address		= @p_mod_ip_address 
			end
			
			set @billing_no = 0
														  
			set @description = 0
														  
			set @billing_amount = 0
								
			set @discount_amount = 0
														  
			set @ppn_amount = 0
														  
			set @pph_amount = 0
														  
			set @total_amount = 0

			set @client_no				= ''
			set @client_name			= ''
			set @client_address			= ''
			set @client_area_phone_no	= ''
			set @client_phone_no		= ''
			set @client_npwp			= ''
			set @currency_code			= ''
			
			fetch next from curretdetail
			into @asset_no;
		end ;

		close curretdetail ;
		deallocate curretdetail ; 
		
	end try
	Begin catch
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






