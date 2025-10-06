CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_update_tax]
(
	@p_id			   bigint
	,@p_tax_code	   nvarchar(50)
	,@p_tax_name	   nvarchar(250) = ''
	,@p_ppn_pct		   decimal(9, 6)
	,@p_pph_pct  	   decimal(9, 6)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@policy_code				nvarchar(50)
			,@sppa_code					nvarchar(50)
			,@buy_amount				decimal(18,2)
			,@admin_amount				decimal(18,2)
			,@ppn_amount				decimal(18,2)
			,@pph_amount				decimal(18,2)
			,@stamp_amount				decimal(18,2)
			,@discount_amount			decimal(18,2)
			,@initial_buy				decimal(18,2)
			,@initial_buy_amount		decimal(18,2)
			,@initial_disc_amoun		decimal(18,2)
			,@initial_admin_amount		decimal(18,2)
			,@initial_stamp_amount		decimal(18,2)


	begin try
		select	@policy_code			= ipm.code
				,@sppa_code				= ipm.sppa_code
				,@initial_buy_amount	= ipac.initial_buy_amount
				,@initial_disc_amoun	= ipac.initial_discount_amount
				,@initial_admin_amount	= ipac.initial_admin_fee_amount
				,@initial_stamp_amount	= ipac.initial_stamp_fee_amount
		from dbo.insurance_policy_asset_coverage ipac
		inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
		inner join dbo.insurance_policy_main ipm on (ipm.code = ipa.policy_code)
		where ipac.id = @p_id

		set @pph_amount = round(isnull(@initial_disc_amoun * @p_pph_pct / 100.00,0),0) ;
		set @ppn_amount = round(isnull(@initial_disc_amoun * @p_ppn_pct / 100.00,0),0) ;

		

		update	insurance_policy_asset_coverage
		set		buy_amount					= @initial_buy_amount - (@initial_disc_amoun + @ppn_amount - @pph_amount) + @initial_admin_amount + @initial_stamp_amount
				,master_tax_code			= @p_tax_code
				,master_tax_description		= @p_tax_name
				,master_tax_ppn_pct			= @p_ppn_pct
				,master_tax_pph_pct			= @p_pph_pct
				,initial_discount_ppn		= @ppn_amount
				,initial_discount_pph		= @pph_amount
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

		---------------------


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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
