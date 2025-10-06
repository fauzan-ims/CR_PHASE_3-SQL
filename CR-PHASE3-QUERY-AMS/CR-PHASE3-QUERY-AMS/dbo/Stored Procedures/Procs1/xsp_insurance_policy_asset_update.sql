
create procedure xsp_insurance_policy_asset_update
(
	@p_code						 nvarchar(50)
	,@p_policy_code				 nvarchar(50)
	,@p_fa_code					 nvarchar(50)
	,@p_sum_insured_amount		 decimal(18, 2)
	,@p_depreciation_code		 nvarchar(50)
	,@p_collateral_type			 nvarchar(10)
	,@p_collateral_category_code nvarchar(50)
	,@p_occupation_code			 nvarchar(50)
	,@p_region_code				 nvarchar(50)
	,@p_collateral_year			 nvarchar(4)
	,@p_is_authorized_workshop	 nvarchar(1)
	,@p_is_commercial			 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_authorized_workshop = 'T'
		set @p_is_authorized_workshop = '1' ;
	else
		set @p_is_authorized_workshop = '0' ;

	if @p_is_commercial = 'T'
		set @p_is_commercial = '1' ;
	else
		set @p_is_commercial = '0' ;

	begin try
		update	insurance_policy_asset
		set		policy_code = @p_policy_code
				,fa_code = @p_fa_code
				,sum_insured_amount = @p_sum_insured_amount
				,depreciation_code = @p_depreciation_code
				,collateral_type = @p_collateral_type
				,collateral_category_code = @p_collateral_category_code
				,occupation_code = @p_occupation_code
				,region_code = @p_region_code
				,collateral_year = @p_collateral_year
				,is_authorized_workshop = @p_is_authorized_workshop
				,is_commercial = @p_is_commercial
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
