CREATE PROCEDURE dbo.xsp_register_realization_update
(
	@p_code									nvarchar(50)
	,@p_realization_invoice_no				nvarchar(50)
	,@p_realization_internal_income			decimal(18, 2)
	,@p_realization_actual_fee				decimal(18, 2)
	,@p_realization_service_fee				decimal(18, 2)
	,@p_dp_to_public_service_amount			decimal(18, 2) = 0
	,@p_realization_date					datetime
	,@p_dp_to_public_service_date			datetime = null
	,@p_dp_to_public_service_voucher		nvarchar(50) = ''
	,@p_payment_bank_name					nvarchar(250)		= ''
	,@p_payment_bank_account_no				nvarchar(50)		= ''
	,@p_payment_bank_account_name			nvarchar(250)		= ''
	,@p_realization_service_tax_code		nvarchar(50)
	,@p_realization_service_tax_name		nvarchar(250)
	,@p_realization_service_tax_ppn_pct		decimal(18,2)
	,@p_realization_service_tax_pph_pct		decimal(18,2)
	,@p_faktur_no							nvarchar(50)		= null
	,@p_is_reimburse						nvarchar(1)
	,@p_faktur_date							DATETIME			= null
	,@p_service_ppn_amount					decimal(18,2)		= 0 -- (+) Ari 2023-12-28 ket : add service ppn amount
	,@p_service_pph_amount					decimal(18,2)		= 0
	,@p_is_reimburse_to_customer			nvarchar(1)
	,@p_realization_invoic_date				datetime			= null

	--
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
declare @msg				nvarchar(max)
		,@register_date		datetime
		,@client_name		nvarchar(250)
		,@fa_code			nvarchar(50)
		,@val_ppn_amount	decimal(18, 2)	-- (+) Ari 2023-12-28
		,@ppn_pct_before	decimal(18, 2)
		,@pph_pct_before	decimal(18, 2)
		,@ppn_before		decimal(18, 2)
		,@pph_before		decimal(18, 2)
		,@fee_amount_before decimal(18, 2)
		,@value1			int
		,@value2			int ;

	begin try

		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else
			set @p_is_reimburse = '0' ;

		if @p_is_reimburse_to_customer = 'T'
			set @p_is_reimburse_to_customer = '1' ;
		else
			set @p_is_reimburse_to_customer = '0' ;
		
		select	@register_date	= register_date
				,@fa_code		= fa_code
		from	dbo.register_main
		where	code = @p_code

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZFKT' ;

		if(@p_realization_invoic_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
		begin
			if(@value1 <> 0)
			begin
				set @msg = N'Realization invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value1 = 0)
			begin
				set @msg = N'Realization invoice date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@p_faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			if(@value2 <> 0)
			begin
				set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value2 = 0)
			begin
				set @msg = N'Faktur date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		--if (@p_realization_internal_income < 1)
		--begin
		--	set @msg ='Realization Internal Income must be greater then 0';
		--	raiserror(@msg,16,1) ;
		--end
		--else if (@p_realization_actual_fee < 1)
		--begin
		--	set @msg ='Realization Actual Fee must be greater then 0';
		--	raiserror(@msg,16,1) ;
		--end
		--else if (@p_realization_service_fee < 1)
		--begin
		--	set @msg ='Realization Service Fee must be greater then 0';
		--    raiserror(@msg,16,1) ;
		--end

		--if (month(@p_realization_invoic_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Realization invoice month must be equal than system date.' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;

		if(@p_faktur_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Faktur date must be less or equal than system date.' ;

			raiserror(@msg, 16, 1) ;
		end

		if(@p_realization_invoic_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Invoice date must be less or equal than system date.' ;

			raiserror(@msg, 16, 1) ;
		end

		if cast(@p_realization_date as date) > dbo.xfn_get_system_date()
		begin
			set @msg = 'Realization Date must be less or equal than System Date'
			raiserror(@msg ,16,-1)
		end
		
		if cast(@p_realization_date as date) < cast(@register_date as date)
		begin
			set @msg = 'Realization Date must be greater than Register Date'
			raiserror(@msg ,16,-1)
		end

		--if (month(@p_faktur_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Faktur month must be equal than system date.' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;
		
		if  (len(@p_faktur_no) != 16)
		begin
			set	@msg = 'Faktur Number Must be 16 Digits.'
			raiserror(@msg, 16, -1) ;
		end

		select @client_name = isnull(client_name,'') 
		from dbo.asset
		where code = @fa_code

		if (@client_name = '' and @p_is_reimburse = '1')
		begin
			set @msg = N'Cannot disburse this asset to customer.' ;
			raiserror(@msg, 16, 1) ;
		end ;

		if (@client_name = '' and @p_is_reimburse_to_customer = '1')
		begin
			set @msg = N'Cannot reimburse this asset to customer.' ;
			raiserror(@msg, 16, 1) ;
		end ;
		
		if(@p_realization_service_tax_ppn_pct > 0) and ((@p_faktur_no = '') or (isnull(@p_faktur_no,'')=''))
		begin
			set @msg = N'Please Input Faktur No!';
			raiserror(@msg, 16, 1)
		end;

		if(@p_realization_service_tax_ppn_pct > 0) and ((@p_faktur_date = '') or (isnull(@p_faktur_date,'')=''))
		begin
			set @msg = N'Please Input Faktur Date!';
			raiserror(@msg, 16, 1)
		end;

		-- (+) Ari 2023-12-28 ket : get ppn amount from getrow
		select	@val_ppn_amount = cast(ceiling(rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)) as int)    
				,@ppn_pct_before = rm.realization_service_tax_ppn_pct  
				,@pph_pct_before = rm.realization_service_tax_pph_pct
				,@ppn_before = rm.service_ppn_amount    
				,@pph_before = rm.service_pph_amount
				,@fee_amount_before = rm.realization_service_fee
		from	register_main      rm  
		where	rm.code = @p_code ;

		if(right(@p_realization_service_fee,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if(right(@p_realization_actual_fee,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if(isnull(@ppn_before,0) = 0 and isnull(@pph_before,0) = 0)  
		begin   
				if((@p_service_pph_amount < 0 and isnull(@p_realization_service_tax_pph_pct,0) = 0) or (@p_service_pph_amount > 0 and isnull(@p_realization_service_tax_pph_pct,0) = 0))
				begin
					set @p_service_pph_amount = 0;
					set @msg = N'Cannot set PPH amount because PPH PCT = 0'   
					raiserror(@msg, 16, 1)  
				end
				else if((@p_service_ppn_amount < 0 and isnull(@p_realization_service_tax_ppn_pct,0) = 0) or (@p_service_ppn_amount > 0 and isnull(@p_realization_service_tax_ppn_pct,0) = 0))
				begin
					set @p_service_ppn_amount = 0;
					set @msg = N'Cannot set PPN amount because PPN PCT = 0'   
					raiserror(@msg, 16, 1)  
				end
				else
				begin 
					set @p_service_ppn_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_ppn_pct as decimal(18,2))/100),0) 
					set @p_service_pph_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_pph_pct as decimal(18,2))/100),0)
				end
		end
		else if(isnull(@fee_amount_before,0) <> isnull(@p_realization_service_fee,0))
		begin 	
			set @p_service_ppn_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_ppn_pct as decimal(18,2))/100),0)
			set @p_service_pph_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_pph_pct as decimal(18,2))/100),0)
		end  
		else  
		begin 
			if(isnull(@ppn_pct_before,0) <> @p_realization_service_tax_ppn_pct or isnull(@pph_pct_before,0) <> @p_realization_service_tax_pph_pct)  
			begin  
				if(isnull(@p_realization_service_tax_pph_pct,0) = 0)
				begin
					set @p_service_ppn_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_ppn_pct as decimal(18,2))/100),0)
					set @p_service_pph_amount = 0
				end
				else
				begin 
					set @p_service_ppn_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_ppn_pct as decimal(18,2))/100),0)
					set @p_service_pph_amount = round(@p_realization_service_fee * (cast(@p_realization_service_tax_pph_pct as decimal(18,2))/100),0)
				end
			end  
			else  
			begin  
				if(@p_service_ppn_amount <= 0 and isnull(@p_realization_service_tax_ppn_pct,0) <> 0)  
				begin  
					set @p_service_ppn_amount = 0
					set @msg = 'PPN cannot less than and must be greater than 0'  
					raiserror(@msg, 16, 1)  
				end
				else if(@p_service_pph_amount <= 0 and isnull(@p_realization_service_tax_pph_pct,0) <> 0)  
				begin  
					set @p_service_pph_amount = 0
					set @msg = 'PPH cannot less than and must be greater than 0'  
					raiserror(@msg, 16, 1)  
				end  
				else if(@p_service_ppn_amount > @p_realization_service_fee)  
				begin  
					set @p_service_ppn_amount = 0
					set @msg = N'PPN cannot more than Service Fee ' + convert(nvarchar(50),@p_realization_service_fee)  
					raiserror(@msg, 16, 1)  
				end 
				else if(@p_service_pph_amount > @p_realization_service_fee)  
				begin  
					set @p_service_pph_amount = 0
					set @msg = N'PPH cannot more than Service Fee ' + convert(nvarchar(50),@p_realization_service_fee)  
					raiserror(@msg, 16, 1)  
				end  
				else if(@p_service_ppn_amount > (@val_ppn_amount+100))  
				begin  
					set @p_service_ppn_amount = 0
					set @msg = N'PPN cannot more than ' + convert(nvarchar(50),(@val_ppn_amount+100))  
					raiserror(@msg, 16, 1)  
				end  
				else if(@p_service_ppn_amount < (@val_ppn_amount-100))  
				begin  
					set @p_service_ppn_amount = 0
					set @msg = N'PPN cannot less than ' + convert(nvarchar(50),(@val_ppn_amount-100))  
					raiserror(@msg, 16, 1)  
				end  
				else if(right(@p_service_ppn_amount,2) <> '00')  
				begin  
					set @msg = N'The Comma at the end cannot be anything other than 0'   
					raiserror(@msg, 16, 1)  
				end 
				else if(right(@p_service_pph_amount,2) <> '00')  
				begin  
					set @msg = N'The Comma at the end cannot be anything other than 0'   
					raiserror(@msg, 16, 1)  
				end
				else if(@p_service_pph_amount <= 0 and isnull(@p_realization_service_tax_pph_pct,0) <> 0)
				begin 
					set @msg = N'Cannot set PPH amount because PPH PCT = 0'   
					raiserror(@msg, 16, 1)  
				end
				else if(@p_service_ppn_amount <= 0 and isnull(@p_realization_service_tax_ppn_pct,0) <> 0)
				begin
					set @msg = N'Cannot set PPN amount because PPN PCT = 0'   
					raiserror(@msg, 16, 1)  
				end
				else if((@p_service_pph_amount < 0 and isnull(@p_realization_service_tax_pph_pct,0) = 0) or (@p_service_pph_amount > 0 and isnull(@p_realization_service_tax_pph_pct,0) = 0) )
				begin 
					set @p_service_pph_amount = 0
					set @msg = N'Cannot set PPH amount because PPH PCT = 0'   
					raiserror(@msg, 16, 1)  
				end
				else if((@p_service_ppn_amount < 0 and isnull(@p_realization_service_tax_ppn_pct,0) = 0) or (@p_service_ppn_amount > 0 and isnull(@p_realization_service_tax_ppn_pct,0) = 0))
				begin
					set @p_service_ppn_amount = 0
					set @msg = N'Cannot set PPN amount because PPN PCT = 0'   
					raiserror(@msg, 16, 1)  
				end			
			end  
		end	
		-- (+) Ari 2023-12-28  
		
		UPDATE	register_main
		set		realization_invoice_no				= @p_realization_invoice_no
				,realization_internal_income		= @p_realization_internal_income
				,realization_actual_fee				= @p_realization_actual_fee
				,realization_service_fee			= @p_realization_service_fee
				,realization_date					= @p_realization_date
				--,dp_to_public_service_amount		= @p_dp_to_public_service_amount
				--,dp_to_public_service_date			= @p_dp_to_public_service_date
				--,dp_to_public_service_voucher		= @p_dp_to_public_service_voucher
				--,customer_settlement_amount			= (dp_from_customer_amount - @p_realization_internal_income - @p_realization_actual_fee - @p_realization_service_fee) * -1
				--,public_service_settlement_amount	= dp_to_public_service_amount - @p_realization_actual_fee - @p_realization_service_fee
				--,public_service_settlement_amount	= cast(@p_realization_actual_fee + @p_realization_service_fee + ceiling((@p_realization_service_fee * @p_realization_service_tax_ppn_pct / 100)) - (ceiling(@p_realization_service_fee * @p_realization_service_tax_pph_pct / 100))- @p_dp_to_public_service_amount AS int)
				,public_service_settlement_amount	= cast(@p_realization_actual_fee + @p_realization_service_fee + @p_service_ppn_amount - @p_service_pph_amount - @p_dp_to_public_service_amount as int) -- (+) Ari 2024-01-11 ket : perubahan tax
				,payment_bank_name					= @p_payment_bank_name
				,payment_bank_account_no			= @p_payment_bank_account_no
				,payment_bank_account_name			= @p_payment_bank_account_name
				,realization_service_tax_code		= @p_realization_service_tax_code
				,realization_service_tax_name		= @p_realization_service_tax_name
				,realization_service_tax_ppn_pct	= @p_realization_service_tax_ppn_pct
				,realization_service_tax_pph_pct	= @p_realization_service_tax_pph_pct
				,faktur_no							= @p_faktur_no
				,faktur_date						= @p_faktur_date
				,is_reimburse						= @p_is_reimburse
				,service_ppn_amount					= @p_service_ppn_amount  -- (+) Ari 2023-12-28 ket : add service ppn amount
				,service_pph_amount					= @p_service_pph_amount
				,is_reimburse_to_customer			= @p_is_reimburse_to_customer
				,realization_invoic_date			= @p_realization_invoic_date
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code								= @p_code ;

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


