--Created by, Rian at 06/06/2023 

CREATE PROCEDURE [dbo].[xsp_asset_insurance_detail_insert]
(
	@p_id								  bigint		output
	,@p_asset_no						  nvarchar(50)
	,@p_main_coverage_code				  nvarchar(50)	= ''
	,@p_main_coverage_description		  nvarchar(250) = ''
	,@p_region_code						  nvarchar(50)	= ''
	,@p_region_description				  nvarchar(250) = ''
	,@p_is_use_tpl						  nvarchar(1)
	,@p_tpl_coverage_code				  nvarchar(50)	= ''
	,@p_tpl_coverage_description		  nvarchar(250) = ''
	,@p_is_use_pll						  nvarchar(1)
	,@p_pll_coverage_code				  nvarchar(50)	= ''
	,@p_pll_coverage_description		  nvarchar(250) = ''
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
	,@p_is_tbod							  nvarchar(1)
	--
	,@p_cre_date						  datetime
	,@p_cre_by							  nvarchar(15)
	,@p_cre_ip_address					  nvarchar(15)
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@main_coverage_premium_amount		decimal(18, 2) = 0
			,@tpl_premium_amount				decimal(18, 2) = 0
			,@pll_premium_amount				decimal(18, 2) = 0
			,@pa_passenger_premium_amount		decimal(18, 2) = 0
			,@pa_driver_premium_amount			decimal(18, 2) = 0
			,@srcc_premium_amount				decimal(18, 2) = 0
			,@ts_premium_amount					decimal(18, 2) = 0
			,@flood_premium_amount				decimal(18, 2) = 0
			,@earthquake_premium_amount			decimal(18, 2) = 0
			,@commercial_premium_amount			decimal(18, 2) = 0
			,@authorize_workshop_premium_amount decimal(18, 2) = 0
			,@budget_insurance_amount			decimal(18, 2) = 0
			,@tbod_premium_amount				decimal(18, 2) = 0

	begin try
		-- set use tpl
		if @p_is_use_tpl = 'T'
			set @p_is_use_tpl = '1' ;
		else
			set @p_is_use_tpl = '0' ;

		-- set use pll
		if @p_is_use_pll = 'T'
			set @p_is_use_pll = '1' ;
		else
			set @p_is_use_pll = '0' ;

		-- set use passenger
		if @p_is_use_pa_passenger = 'T'
			set @p_is_use_pa_passenger = '1' ;
		else
			set @p_is_use_pa_passenger = '0' ;

		-- set use pa driver
		if @p_is_use_pa_driver = 'T'
			set @p_is_use_pa_driver = '1' ;
		else
			set @p_is_use_pa_driver = '0' ;

		-- set use srcc
		if @p_is_use_srcc = 'T'
			set @p_is_use_srcc = '1' ;
		else
			set @p_is_use_srcc = '0' ;

		-- set use ts
		if @p_is_use_ts = 'T'
			set @p_is_use_ts = '1' ;
		else
			set @p_is_use_ts = '0' ;

		-- set use flood
		if @p_is_use_flood = 'T'
			set @p_is_use_flood = '1' ;
		else
			set @p_is_use_flood = '0' ;

		-- set use earthquake
		if @p_is_use_earthquake = 'T'
			set @p_is_use_earthquake = '1' ;
		else
			set @p_is_use_earthquake = '0' ;

		-- set commercial use
		if @p_is_commercial_use = 'T'
			set @p_is_commercial_use = '1' ;
		else
			set @p_is_commercial_use = '0' ;

		-- set authorize workshop
		if @p_is_authorize_workshop = 'T'
			set @p_is_authorize_workshop = '1' ;
		else
			set @p_is_authorize_workshop = '0' ;

		-- set tbod
		if @p_is_tbod = 'T'
			set	@p_is_tbod = '1'
		else
			set	@p_is_tbod = '0'
			
		--calculate insurance coverage rate
		begin
			exec dbo.xsp_application_asset_insurance_getrate @p_asset_no							= @p_asset_no				
															 ,@p_main_coverage_code					= @p_main_coverage_code		
															 ,@p_region_code						= @p_region_code			
															 ,@p_is_use_tpl							= @p_is_use_tpl				
															 ,@p_tpl_coverage_code					= @p_tpl_coverage_code		
															 ,@p_is_use_pll							= @p_is_use_pll				
															 ,@p_pll_coverage_code					= @p_pll_coverage_code		
															 ,@p_is_use_pa_passenger				= @p_is_use_pa_passenger	
															 ,@p_pa_passenger_amount				= @p_pa_passenger_amount	
															 ,@p_pa_passenger_seat					= @p_pa_passenger_seat		
															 ,@p_is_use_pa_driver					= @p_is_use_pa_driver		
															 ,@p_pa_driver_amount					= @p_pa_driver_amount		
															 ,@p_is_use_srcc						= @p_is_use_srcc			
															 ,@p_is_use_ts							= @p_is_use_ts				
															 ,@p_is_use_flood						= @p_is_use_flood			
															 ,@p_is_use_earthquake					= @p_is_use_earthquake		
															 ,@p_is_commercial_use					= @p_is_commercial_use		
															 ,@p_is_authorize_workshop				= @p_is_authorize_workshop	
															 ,@p_is_use_tbod						= @p_is_tbod
															 ,@p_main_coverage_premium_amount		= @main_coverage_premium_amount output
															 ,@p_tpl_premium_amount					= @tpl_premium_amount output
															 ,@p_pll_premium_amount					= @pll_premium_amount output
															 ,@p_pa_passenger_premium_amount		= @pa_passenger_premium_amount output
															 ,@p_pa_driver_premium_amount			= @pa_driver_premium_amount output
															 ,@p_srcc_premium_amount				= @srcc_premium_amount output
															 ,@p_ts_premium_amount					= @ts_premium_amount output
															 ,@p_flood_premium_amount				= @flood_premium_amount output
															 ,@p_earthquake_premium_amount			= @earthquake_premium_amount output
															 ,@p_commercial_premium_amount			= @commercial_premium_amount output
															 ,@p_authorize_workshop_premium_amount	= @authorize_workshop_premium_amount output 
															 ,@p_tbod_premium_amount				= @tbod_premium_amount output
		end

		insert into dbo.asset_insurance_detail
		(
			asset_no
			,main_coverage_code
			,main_coverage_description
			,region_code
			,region_description
			,main_coverage_premium_amount
			,is_use_tpl
			,tpl_coverage_code
			,tpl_coverage_description
			,tpl_premium_amount
			,is_use_pll
			,pll_coverage_code
			,pll_coverage_description
			,pll_premium_amount
			,is_use_pa_passenger
			,pa_passenger_amount
			,pa_passenger_seat
			,pa_passenger_premium_amount
			,is_use_pa_driver
			,pa_driver_amount
			,pa_driver_premium_amount
			,is_use_srcc
			,srcc_premium_amount
			,is_use_ts
			,ts_premium_amount
			,is_use_flood
			,flood_premium_amount
			,is_use_earthquake
			,earthquake_premium_amount
			,is_commercial_use
			,commercial_premium_amount
			,is_authorize_workshop
			,authorize_workshop_premium_amount
			,is_tbod			
			,tbod_premium_amount
			,total_premium_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_no
			,@p_main_coverage_code
			,@p_main_coverage_description
			,@p_region_code
			,@p_region_description
			,@main_coverage_premium_amount
			,@p_is_use_tpl
			,@p_tpl_coverage_code
			,@p_tpl_coverage_description
			,@tpl_premium_amount
			,@p_is_use_pll
			,@p_pll_coverage_code
			,@p_pll_coverage_description
			,@pll_premium_amount
			,@p_is_use_pa_passenger
			,@p_pa_passenger_amount
			,@p_pa_passenger_seat
			,@pa_passenger_premium_amount
			,@p_is_use_pa_driver
			,@p_pa_driver_amount
			,@pa_driver_premium_amount
			,@p_is_use_srcc
			,@srcc_premium_amount
			,@p_is_use_ts
			,@ts_premium_amount
			,@p_is_use_flood
			,@flood_premium_amount
			,@p_is_use_earthquake
			,@earthquake_premium_amount
			,@p_is_commercial_use
			,@commercial_premium_amount
			,@p_is_authorize_workshop
			,@authorize_workshop_premium_amount
			,@p_is_tbod			
			,@tbod_premium_amount
			,0
			--			
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
		
		-- update total amount	
		update	dbo.asset_insurance_detail
		set		total_premium_amount = main_coverage_premium_amount + tpl_premium_amount + pll_premium_amount + pa_passenger_premium_amount + pa_driver_premium_amount + srcc_premium_amount + ts_premium_amount + flood_premium_amount + earthquake_premium_amount + commercial_premium_amount + authorize_workshop_premium_amount + tbod_premium_amount
				--				
				,mod_date			 = @p_mod_date							
				,mod_by				 = @p_mod_by								
				,mod_ip_address		 = @p_mod_ip_address		
		where	asset_no			 = @p_asset_no
		and		id					 = @p_id	

		select	@budget_insurance_amount = isnull(total_premium_amount, 0)
		from	dbo.asset_insurance_detail
		where	asset_no = @p_asset_no ;
			
		if exists (select 1 from dbo.application_asset_budget where asset_no = @p_asset_no and cost_code = N'MBDC.2211.000001')
		begin
			exec dbo.xsp_application_asset_budget_update @p_asset_no				= @p_asset_no
														 ,@p_cost_code				= N'MBDC.2211.000001'
														 ,@p_cost_amount_monthly	= @budget_insurance_amount
														 ,@p_cost_amount_yearly		= @budget_insurance_amount
														 ,@p_mod_date				= @p_mod_date
														 ,@p_mod_by					= @p_mod_by
														 ,@p_mod_ip_address			= @p_mod_ip_address  
		end
		else
		begin
			exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
														 ,@p_asset_no			 = @p_asset_no
														 ,@p_cost_code			 = N'MBDC.2211.000001'
														 ,@p_cost_type			 = N'FIXED'
														 ,@p_cost_amount_monthly = @budget_insurance_amount
														 ,@p_cost_amount_yearly  = @budget_insurance_amount
														 ,@p_cre_date			 = @p_mod_date
														 ,@p_cre_by				 = @p_mod_by
														 ,@p_cre_ip_address		 = @p_mod_ip_address
														 ,@p_mod_date			 = @p_mod_date
														 ,@p_mod_by				 = @p_mod_by
														 ,@p_mod_ip_address		 = @p_mod_ip_address
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

