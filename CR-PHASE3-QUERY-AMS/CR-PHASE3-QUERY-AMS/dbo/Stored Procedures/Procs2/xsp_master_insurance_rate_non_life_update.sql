CREATE PROCEDURE dbo.xsp_master_insurance_rate_non_life_update
(
	@p_code						 nvarchar(50)
	,@p_insurance_code			 nvarchar(50)
	,@p_collateral_type_code	 nvarchar(50)
	,@p_collateral_category_code nvarchar(50)
	,@p_coverage_code			 nvarchar(50)
	,@p_day_in_year				 nvarchar(10)
	,@p_region_code				 nvarchar(50) = null
	,@p_occupation_code			 nvarchar(50) = null
	,@p_is_active				 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_insurance_rate_non_life 
					where	code						<> @p_code 
					and		insurance_code				= @p_insurance_code
					and		collateral_type_code		= @p_collateral_type_code
					and		coverage_code				= @p_coverage_code
					and		isnull(occupation_code,'')	= isnull(@p_occupation_code,'')
					and		isnull(region_code,'')		= isnull(@p_region_code  ,'')
					and		collateral_category_code	= @p_collateral_category_code)
		begin
			SET @msg = 'Combination already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		update	master_insurance_rate_non_life
		set		insurance_code				= @p_insurance_code
				,collateral_type_code		= @p_collateral_type_code
				,collateral_category_code	= @p_collateral_category_code
				,coverage_code				= @p_coverage_code
				,day_in_year				= @p_day_in_year
				,region_code				= @p_region_code
				,occupation_code			= @p_occupation_code
				,is_active					= @p_is_active
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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




