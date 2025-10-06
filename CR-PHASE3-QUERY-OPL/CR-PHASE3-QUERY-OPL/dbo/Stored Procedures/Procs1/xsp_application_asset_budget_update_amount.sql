--created by, Rian at 13/06/2023 

CREATE PROCEDURE [dbo].[xsp_application_asset_budget_update_amount]
(
	@p_id						bigint
	,@p_asset_no				nvarchar(50)
	,@p_cost_code				nvarchar(50) 
	,@p_budget_amount			decimal(18, 2) = 0 
	-- 
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@asset_type_code				nvarchar(50)
			,@spaf_rate						decimal(9, 6)
			,@old_budget_maintanance_amount decimal(18, 2)
			,@budget_gps_amount				decimal(18, 2)
			,@yearly_amount					decimal(18, 2)
			,@budget_adjustment_amount		decimal(18, 2) ;

	begin try
		select	@asset_type_code = asset_type_code 
		from	dbo.application_asset
		where	asset_no = @p_asset_no ;

		if @asset_type_code = 'VHCL'
		begin
			select	@spaf_rate = spaf_pct
			from	dbo.master_vehicle_unit mvu
					inner join dbo.application_asset_vehicle aav on (aav.vehicle_unit_code = mvu.code)
			where	asset_no = @p_asset_no ;
		end ;
		else if @asset_type_code = 'MCHN'
		begin
			select	@spaf_rate = spaf_pct
			from	dbo.master_machinery_unit mmu
					inner join dbo.application_asset_machine aam on (aam.machinery_unit_code = mmu.code)
			where	asset_no = @p_asset_no ;
		end ;
		else if @asset_type_code = 'HE'
		begin
			select	@spaf_rate = spaf_pct
			from	dbo.master_he_unit mhu
					inner join dbo.application_asset_he aah on (aah.he_unit_code = mhu.code)
			where	asset_no = @p_asset_no ;
		end ;
		else if @asset_type_code = 'ELEC'
		begin
			select	@spaf_rate = spaf_pct
			from	dbo.master_electronic_unit meu
					inner join dbo.application_asset_electronic aae on (aae.electronic_unit_code = meu.code)
			where	asset_no = @p_asset_no ;
		end ;

		select	@yearly_amount	= cost_amount_yearly
				,@old_budget_maintanance_amount = budget_amount
		from	dbo.application_asset_budget
		where	asset_no		= @p_asset_no
				and cost_code	= @p_cost_code 
				and	id			= @p_id

		if exists
		(
			select	1
			from	dbo.application_asset
			where	asset_no			   = @p_asset_no
					and is_use_gps		   = '1'
					and gps_monthly_amount > 0
					and @p_cost_code = N'MBDC.2211.000003'
					and @old_budget_maintanance_amount <> @p_budget_amount
		)
		begin
			select	@budget_gps_amount = (isnull(gps_monthly_amount, 0) * periode)
			from	dbo.application_asset
			where	asset_no = @p_asset_no ;

			set @p_budget_amount = @p_budget_amount + isnull(@budget_gps_amount, 0) ;
		end ;

		set		@budget_adjustment_amount = @p_budget_amount - @yearly_amount
		

		update	dbo.application_asset_budget
		set		budget_amount				= @p_budget_amount
				,budget_adjustment_amount	= @budget_adjustment_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	asset_no					= @p_asset_no
				and	cost_code				= @p_cost_code
				and	id						= @p_id		

		--digunakan untuk mengcalculate nilai application asset (ROA, avg asset, yearly profit)
		exec dbo.xsp_application_asset_calculate @p_asset_no		= @p_asset_no
												 ,@p_spaf_rate		= @spaf_rate
												 ,@p_mod_date		= @p_mod_date		
												 ,@p_mod_by			= @p_mod_by			
												 ,@p_mod_ip_address = @p_mod_ip_address 
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


