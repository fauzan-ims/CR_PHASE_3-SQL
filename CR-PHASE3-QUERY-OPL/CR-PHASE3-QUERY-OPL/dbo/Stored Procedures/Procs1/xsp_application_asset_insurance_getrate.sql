CREATE PROCEDURE dbo.xsp_application_asset_insurance_getrate
(
	@p_asset_no							  nvarchar(50)
	,@p_main_coverage_code				  nvarchar(50)
	,@p_region_code						  nvarchar(50)
	,@p_is_use_tpl						  nvarchar(1)
	,@p_tpl_coverage_code				  nvarchar(50)	 = null
	,@p_is_use_pll						  nvarchar(1)
	,@p_pll_coverage_code				  nvarchar(50)	 = null
	,@p_is_use_pa_passenger				  nvarchar(1)
	,@p_pa_passenger_amount				  decimal(18, 2)
	,@p_pa_passenger_seat				  int
	,@p_is_use_pa_driver				  nvarchar(1)
	,@p_pa_driver_amount				  decimal(18, 2)
	,@p_is_use_srcc						  nvarchar(1)
	,@p_is_use_ts						  nvarchar(1)
	,@p_is_use_flood					  nvarchar(1)
	,@p_is_use_earthquake				  nvarchar(1)
	,@p_is_commercial_use				  nvarchar(1)
	,@p_is_authorize_workshop			  nvarchar(1)
	,@p_is_use_tbod						  nvarchar(1)
	,@p_main_coverage_premium_amount	  decimal(18, 2) output
	,@p_tpl_premium_amount				  decimal(18, 2) output
	,@p_pll_premium_amount				  decimal(18, 2) output
	,@p_pa_passenger_premium_amount		  decimal(18, 2) output
	,@p_pa_driver_premium_amount		  decimal(18, 2) output
	,@p_srcc_premium_amount				  decimal(18, 2) output
	,@p_ts_premium_amount				  decimal(18, 2) output
	,@p_flood_premium_amount			  decimal(18, 2) output
	,@p_earthquake_premium_amount		  decimal(18, 2) output
	,@p_commercial_premium_amount		  decimal(18, 2) output
	,@p_authorize_workshop_premium_amount decimal(18, 2) output
	,@p_tbod_premium_amount				  decimal(18, 2) output
)
as
begin
	declare @msg						  nvarchar(max)
			,@no						  int
			,@asset_year				  nvarchar(4)
			,@asset_type_code			  nvarchar(50)
			,@insurance_type_code		  nvarchar(50)
			,@count_year				  int
			,@periode					  int
			,@unit_amount				  decimal(18, 2)
			,@depre_amount				  decimal(18, 2)
			,@parameter_calculate_asset_2 decimal(9, 6)
			,@parameter_calculate_asset_4 decimal(9, 6) ;

	begin try
		select	@parameter_calculate_asset_2 = ((value * 1.00) / 100)
		from	dbo.sys_global_param
		where	code = 'PCAA2' ;

		select	@parameter_calculate_asset_4 = ((value * 1.00) / 100)
		from	dbo.sys_global_param
		where	code = 'PCAA4' ;

		if exists
		(
			select	1
			from	dbo.application_asset
			where	asset_no			= @p_asset_no
					and asset_condition = 'USED'
		)
		begin
			select	@unit_amount = initial_price_amount + (initial_price_amount * @parameter_calculate_asset_4)
					,@periode = periode
					,@asset_type_code = asset_type_code
					,@asset_year = asset_year
			from	dbo.application_asset
			where	asset_no = @p_asset_no ;
		end ;
		else
		begin
			select	@unit_amount = (otr_amount - discount_amount) + ((karoseri_amount + (karoseri_amount * @parameter_calculate_asset_2)) - discount_karoseri_amount)
					,@periode = periode
					,@asset_type_code = asset_type_code
					,@asset_year = asset_year
			from	dbo.application_asset
			where	asset_no = @p_asset_no ;
		end ;

		if (@asset_type_code = 'VHCL')
		begin
			select	@insurance_type_code = insurance_asset_type_code
			from	dbo.application_asset_vehicle aah
					inner join dbo.master_vehicle_unit mhu on (aah.vehicle_unit_code = mhu.code)
			where	asset_no = @p_asset_no ; 
		end ;
		else if (@asset_type_code = 'HE')
		begin
			select	@insurance_type_code = insurance_asset_type_code
			from	dbo.application_asset_he aah
					inner join dbo.master_he_unit mhu on (aah.he_unit_code = mhu.code)
			where	asset_no = @p_asset_no ;
		end ;
		else if (@asset_type_code = 'MCHN')
		begin
			select	@insurance_type_code = insurance_asset_type_code
			from	dbo.application_asset_machine aah
					inner join dbo.master_machinery_unit mhu on (aah.machinery_unit_code = mhu.code)
			where	asset_no = @p_asset_no ;
		end ;
		else if (@asset_type_code = 'ELEC')
		begin
			select	@insurance_type_code = insurance_asset_type_code
			from	dbo.application_asset_electronic aah
					inner join dbo.master_electronic_unit mhu on (aah.electronic_unit_code = mhu.code)
			where	asset_no = @p_asset_no ;
		end ;

		set @no = 1 ;
		
		--set @count_year = year(getdate()) - cast(@asset_year as int)
		
		--select ceiling((@periode*1.00) / 12) + @count_year
		while (@no <= ceiling((@periode*1.00) / 12)) 
		begin 
			select	@depre_amount = cast(description as decimal(18, 2))
			from	dbo.sys_general_subcode
			where	general_code = 'DEPRE'
					and code = case
							   when @no <= 1 then 'TAHUN1'
							   when @no <= 2 then 'TAHUN2'
							   when @no <= 3 then 'TAHUN3'
							   when @no <= 4 then 'TAHUN4'
							   when @no <= 5 then 'TAHUN5'
							   when @no <= 6 then 'TAHUN6'
							   when @no <= 7 then 'TAHUN7'
						   end ;
				--select dbo.xfn_get_get_coverage_amount(@p_main_coverage_code, @insurance_type_code, @unit_amount, @p_region_code, @asset_year, dbo.xfn_get_system_date(), @depre_amount) ;	    
				select @p_main_coverage_code, @insurance_type_code, @unit_amount, @p_region_code, @asset_year, dbo.xfn_get_system_date(), @depre_amount    
			set @p_main_coverage_premium_amount = @p_main_coverage_premium_amount + dbo.xfn_get_get_coverage_amount(@p_main_coverage_code, @insurance_type_code, @unit_amount, @p_region_code, @asset_year, dbo.xfn_get_system_date(), @depre_amount) ;
			--Use TPL
			if (@p_is_use_tpl = 1)
			begin
				set @p_tpl_premium_amount = @p_tpl_premium_amount + dbo.xfn_get_get_liability_amount(@p_tpl_coverage_code, dbo.xfn_get_system_date(), 1)
			end ;
			
			--Use PLL
			if (@p_is_use_pll = 1)
			begin
				set @p_pll_premium_amount = @p_pll_premium_amount + dbo.xfn_get_get_liability_amount(@p_pll_coverage_code, dbo.xfn_get_system_date(), 1)
			end ;
			
			-- Use PA. Passenger
			if (@p_is_use_pa_passenger = 1)
			begin
				set @p_pa_passenger_premium_amount = @p_pa_passenger_premium_amount + dbo.xfn_get_premium_amount('PAFP', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @p_pa_passenger_amount * @p_pa_passenger_seat, @depre_amount, 'NON DEPRE') ;
			end ;

			if (@p_is_use_pa_driver = 1)
			begin
				set @p_pa_driver_premium_amount = @p_pa_driver_premium_amount + dbo.xfn_get_premium_amount('PAFD', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @p_pa_driver_amount, @depre_amount, 'NON DEPRE') ;
			end ;

			--Use SRCC
			if (@p_is_use_srcc = 1)
			begin
				set @p_srcc_premium_amount = @p_srcc_premium_amount + dbo.xfn_get_premium_amount('SRCC', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;

			if (@p_is_use_ts = 1)
			begin
				set @p_ts_premium_amount = @p_ts_premium_amount + dbo.xfn_get_premium_amount('TRRSBT', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;
			-- Use Flood & Windstrom
			if (@p_is_use_flood = 1)
			begin
				set @p_flood_premium_amount = @p_flood_premium_amount + dbo.xfn_get_premium_amount('FLWINS', @p_region_code, @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;

			if (@p_is_use_earthquake = 1)
			begin
				set @p_earthquake_premium_amount = @p_earthquake_premium_amount + dbo.xfn_get_premium_amount('ERQTSN', @p_region_code, @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;

			if (@p_is_commercial_use = 1)
			begin
				set @p_commercial_premium_amount = @p_commercial_premium_amount + dbo.xfn_get_premium_amount('RNTLUS', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;

			if (@p_is_authorize_workshop = 1)
			begin
				set @p_authorize_workshop_premium_amount = @p_authorize_workshop_premium_amount + dbo.xfn_get_premium_amount('AUTHWOR', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
			end ;

			if (@p_is_use_tbod = 1)
			begin 
				--set @p_tbod_premium_amount = @p_tbod_premium_amount + dbo.xfn_get_premium_amount('TBOD', '', @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ;
				set @p_tbod_premium_amount = @p_tbod_premium_amount + dbo.xfn_get_premium_amount('TBOD', @p_region_code, @p_main_coverage_code, dbo.xfn_get_system_date(), @unit_amount, @depre_amount, 'DEPRE') ; --raffy (2025/06/11) region codenya harus diisi
			end ;
			
			set @depre_amount = 0 ;
			set @no += 1 ;
		end ;
	end try
	begin catch 
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


