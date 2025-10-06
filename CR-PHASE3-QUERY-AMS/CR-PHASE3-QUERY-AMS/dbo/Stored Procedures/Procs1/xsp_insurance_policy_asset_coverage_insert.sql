CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_coverage_insert]
(
	@p_id							bigint = 0 output
	,@p_register_asset_code			nvarchar(50)
	,@p_rate_depreciation			decimal(9, 6)
	,@p_is_loading					nvarchar(1)
	,@p_coverage_code				nvarchar(50)
	,@p_year_periode				int
	,@p_initial_buy_rate			decimal(9, 6)
	,@p_initial_buy_amount			decimal(18, 2)
	,@p_initial_discount_pct		decimal(9, 6)
	,@p_initial_discount_amount		decimal(18, 2)
	,@p_initial_discount_pph		decimal(18,2)
	,@p_initial_discount_ppn		decimal(18,2)
	,@p_initial_admin_fee_amount	decimal(18, 2)
	,@p_initial_stamp_fee_amount	decimal(18, 2)
	,@p_buy_amount					decimal(18, 2)
	,@p_coverage_type				nvarchar(20)	= null
	,@p_sppa_code					nvarchar(50)	= null
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_loading = 'T'
		set @p_is_loading = '1' ;
	else
		set @p_is_loading = '0' ;

	begin try
		insert into insurance_policy_asset_coverage
		(
			register_asset_code
			,rate_depreciation
			,is_loading
			,coverage_code
			,year_periode
			,initial_buy_rate
			,initial_buy_amount
			,initial_discount_pct
			,initial_discount_amount
			,initial_discount_pph
			,initial_discount_ppn
			,initial_admin_fee_amount
			,initial_stamp_fee_amount
			,buy_amount
			,coverage_type
			,sppa_code
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
			@p_register_asset_code
			,@p_rate_depreciation
			,@p_is_loading
			,@p_coverage_code
			,@p_year_periode
			,@p_initial_buy_rate
			,@p_initial_buy_amount
			,@p_initial_discount_pct
			,@p_initial_discount_amount
			,@p_initial_discount_pph
			,@p_initial_discount_ppn
			,@p_initial_admin_fee_amount
			,@p_initial_stamp_fee_amount
			,@p_buy_amount
			,@p_coverage_type
			,@p_sppa_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
