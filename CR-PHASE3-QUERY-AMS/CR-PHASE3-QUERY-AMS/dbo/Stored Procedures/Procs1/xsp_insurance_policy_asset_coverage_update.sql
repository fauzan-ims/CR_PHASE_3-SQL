CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_coverage_update]
(
	@p_id								bigint
	,@p_initial_buy_amount				decimal(18, 2)	= 0
	,@p_initial_discount_amount			decimal(18,2)	= 0
	,@p_initial_discount_ppn			decimal(18,2)	= 0
	,@p_initial_discount_pph			decimal(18,2)	= 0
	,@p_initial_admin_fee_amount		decimal(18,2)	= 0
	,@p_initial_stamp_fee_amount		decimal(18,2)	= 0
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@policy_code		nvarchar(50)
			,@sppa_code			nvarchar(50)
			,@buy_amount		decimal(18,2)
			,@admin_amount		decimal(18,2)
			,@ppn_amount		decimal(18,2)
			,@pph_amount		decimal(18,2)
			,@stamp_amount		decimal(18,2)
			,@discount_amount	decimal(18,2)
			,@initial_buy		decimal(18,2)
			,@ppn_before		decimal(18, 2)
			,@ppn_pct_before	decimal(18, 2)
			,@pph_pct_before	decimal(18, 2)
			,@buy_amount_before decimal(18, 2)
			,@val_ppn			decimal(18, 2)
			,@disc_before		decimal(18, 2)
			,@ppn				decimal(18, 2)
			,@pph				decimal(18, 2) 
			,@tax_code			nvarchar(50)
			,@tax_name			nvarchar(50)
			,@periode			int
			,@coverage_name		nvarchar(250)

	begin try

		select	@policy_code		= ipm.code
				,@sppa_code			= ipm.sppa_code
				,@ppn_before		= ipac.initial_discount_ppn
				,@ppn_pct_before	= ipac.master_tax_ppn_pct
				,@pph_pct_before	= ipac.master_tax_pph_pct
				,@buy_amount_before = ipac.buy_amount
				,@disc_before		= ipac.initial_discount_amount
				,@tax_code			= isnull(ipac.master_tax_code,'')
				,@tax_name			= isnull(ipac.master_tax_description,'')
				,@periode			= ipac.year_periode
				,@coverage_name		= mc.coverage_name
		from	dbo.insurance_policy_asset_coverage	  ipac
				inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
				inner join dbo.insurance_policy_main  ipm on (ipm.code = ipa.policy_code)
				inner join dbo.master_coverage mc on mc.code = ipac.coverage_code
		where	ipac.id = @p_id ;

		if(@tax_code = '' or @tax_name = '')
		begin
			set @msg = N'Please input tax for Periode(Year): ' + convert(nvarchar(2), @periode) + ', Coverage: ' + @coverage_name ;

			raiserror(@msg, 16, 1) ;
		end

		-- (+) Ari 2024-01-02 ket : validasi  
		set @val_ppn = @p_initial_discount_amount * (@ppn_pct_before / 100) ;

		if (right(@p_initial_discount_amount, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (right(@p_initial_admin_fee_amount, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (right(@p_initial_stamp_fee_amount, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (isnull(@disc_before, 0) <> isnull(@p_initial_discount_amount, 0))
		begin
			set @ppn = isnull(@p_initial_discount_amount, 0) * (@ppn_pct_before / 100) ;
			set @pph = isnull(@p_initial_discount_amount, 0) * (@pph_pct_before / 100) ;
			set @p_initial_discount_ppn = round(@ppn, 0) ;
			set @p_initial_discount_pph = round(@pph, 0) ;
		end ;
		--else if (isnull(@p_initial_discount_amount, 0) = 0)
		--begin
		--	set @ppn = isnull(@p_initial_discount_amount, 0) * (@ppn_pct_before / 100) ;
		--	set @pph = isnull(@p_initial_discount_amount, 0) * (@pph_pct_before / 100) ;
		--	set @p_initial_discount_ppn = round(@ppn, 0) ;
		--	set @p_initial_discount_pph = round(@pph, 0) ;
		--end ;
		else if ((
					 isnull(@ppn_pct_before, 0) = 0
					 and isnull(@p_initial_discount_ppn, 0) <> 0
				 )
				)
		begin
			set @msg = 'Cannot set PPN amount because PPN PCT = 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--else if((isnull(@pph_pct_before,0) = 0 and isnull(@p_initial_discount_pph,0) <> 0))  
		--begin  
		-- set @msg = 'Cannot set PPH amount because PPH PCT = 0'   
		-- raiserror(@msg, 16, -1)    
		--end  
		else if (isnull(@p_initial_discount_pph, 0) > @disc_before)
		begin
			set @msg = 'PPH cannot bigger than Discount Amount ' + convert(nvarchar(50), @p_initial_discount_amount) ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (isnull(@p_initial_discount_ppn, 0) > @disc_before)
		begin
			set @msg = 'PPN cannot bigger than Discount Amount ' + convert(nvarchar(50), @p_initial_discount_amount) ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (@p_initial_discount_ppn > @p_initial_buy_amount)
		begin
			set @msg = N'PPN cannot bigger than Buy Amount ' + convert(nvarchar(50), @p_initial_buy_amount) ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (
					isnull(@p_initial_discount_ppn, 0) <= 0
					and isnull(@ppn_pct_before, 0) <> 0
				)
		begin
			set @msg = 'PPN cannot less than and must be greater than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (@p_initial_discount_ppn > (@val_ppn + 100))
		begin
			set @msg = N'PPN cannot bigger than ' + convert(nvarchar(50), (@val_ppn + 100)) ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (@p_initial_discount_ppn < (@val_ppn - 100))
		begin
			set @msg = N'PPN cannot less than ' + convert(nvarchar(50), (@val_ppn - 100)) ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (right(@p_initial_discount_ppn, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (right(@p_initial_discount_pph, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, 1) ;
		end ;
		else if (
					isnull(@p_initial_discount_pph, 0) <= 0
					and isnull(@pph_pct_before, 0) <> 0
				)
		begin
			set @msg = 'PPH cannot less than and must be greater than 0' ;

			raiserror(@msg, 16, 1) ;
		end 
		else if(right(@p_initial_buy_amount,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if(right(@p_initial_discount_amount,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if(right(@p_initial_admin_fee_amount,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if(right(@p_initial_stamp_fee_amount,2) <> '00')  
		begin  
			set @msg = N'The Comma at the end cannot be anything other than 0'   
			raiserror(@msg, 16, 1)  
		end
		else if (
					isnull(@pph_pct_before, 0) = 0 and isnull(@p_initial_discount_pph,0) <> 0
				)
		begin
			set @msg = 'PPH cannot less than and must be greater than 0' ;

			raiserror(@msg, 16, 1) ;
		end 

		update	insurance_policy_asset_coverage
		set		initial_buy_amount			= @p_initial_buy_amount
				,initial_discount_amount	= @p_initial_discount_amount
				,initial_discount_ppn		= @p_initial_discount_ppn
				,initial_discount_pph		= @p_initial_discount_pph
				,initial_admin_fee_amount	= @p_initial_admin_fee_amount
				,initial_stamp_fee_amount	= @p_initial_stamp_fee_amount
				--,buy_amount					= @p_initial_buy_amount - (@p_initial_discount_amount + @p_initial_discount_ppn - @p_initial_discount_pph) + @p_initial_admin_fee_amount + @p_initial_stamp_fee_amount --initial_buy_amount + (initial_discount_amount + initial_discount_ppn - initial_discount_pph) + initial_admin_fee_amount + initial_stamp_fee_amount
				,buy_amount = isnull(@p_initial_buy_amount, 0) - (isnull(@p_initial_discount_amount, 0) + isnull(@p_initial_discount_ppn, 0) - isnull(@p_initial_discount_pph, 0)) + isnull(@p_initial_admin_fee_amount, 0) + isnull(@p_initial_stamp_fee_amount, 0) --initial_buy_amount + (initial_discount_amount + initial_discount_ppn - initial_discount_pph) + initial_admin_fee_amount + initial_stamp_fee_amount  
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;

		select	@buy_amount			= isnull(sum(ipac.buy_amount),0) 
				,@discount_amount	= isnull(sum(ipac.initial_discount_amount),0)
				,@ppn_amount		= isnull(sum(ipac.initial_discount_ppn),0)
				,@pph_amount		= isnull(sum(ipac.initial_discount_pph),0)
				,@admin_amount		= isnull(sum(ipac.initial_admin_fee_amount),0)
				,@stamp_amount		= isnull(sum(ipac.initial_stamp_fee_amount),0)
				,@initial_buy		= isnull(sum(ipac.initial_buy_amount),0)
		from dbo.insurance_policy_asset_coverage ipac
		inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
		where ipa.policy_code = @policy_code
		and ipac.sppa_code = @sppa_code

		update dbo.insurance_policy_main
		set		total_net_premi_amount	= @initial_buy - (@discount_amount + @ppn_amount - @pph_amount) + @admin_amount + @stamp_amount --@buy_amount
				,total_discount_amount	= @discount_amount
				,total_premi_buy_amount	= @initial_buy--@initial_buy
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where code = @policy_code

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
