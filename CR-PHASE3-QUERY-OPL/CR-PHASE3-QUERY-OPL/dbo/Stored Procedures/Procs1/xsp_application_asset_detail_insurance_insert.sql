--Created by, Rian at 06/06/2023 

CREATE PROCEDURE [dbo].[xsp_application_asset_detail_insurance_insert]
(
	@p_id								  bigint = 0
	,@p_asset_no						  nvarchar(50)
	,@p_main_coverage_code				  nvarchar(50)	 = ''
	,@p_main_coverage_description		  nvarchar(250)  = ''
	,@p_region_code						  nvarchar(50)	 = ''
	,@p_region_description				  nvarchar(250)  = ''
	,@p_main_coverage_premium_amount	  decimal(18, 2) 
	,@p_is_use_tpl						  nvarchar(1)	 
	,@p_tpl_coverage_code				  nvarchar(50)	 = ''
	,@p_tpl_coverage_description		  nvarchar(250)  = ''
	,@p_tpl_premium_amount				  decimal(18, 2) 
	,@p_is_use_pll						  nvarchar(1)	 
	,@p_pll_coverage_code				  nvarchar(50)	 = ''
	,@p_pll_coverage_description		  nvarchar(250)  = ''
	,@p_is_use_pa_passenger				  nvarchar(1)
	,@p_pa_passenger_amount				  decimal(18, 2)
	,@p_pa_passenger_seat			      int
	,@p_pa_passenger_premium_amount		  decimal(18, 2)
	,@p_is_use_pa_driver				  nvarchar(1)
	,@p_pa_driver_amount				  decimal(18, 2)
	,@p_pa_driver_premium_amount		  decimal(18, 2)
	,@p_is_use_srcc						  nvarchar(1)
	,@p_srcc_premium_amount				  decimal(18, 2)
	,@p_is_use_ts						  nvarchar(1)
	,@p_ts_premium_amount				  decimal(18, 2)
	,@p_is_use_flood					  nvarchar(1)
	,@p_flood_premium_amount			  decimal(18, 2)
	,@p_is_use_earthquake				  nvarchar(1)
	,@p_earthquake_premium_amount		  decimal(18, 2)
	,@p_is_commercial_use				  nvarchar(1)
	,@p_commercial_premium_amount		  decimal(18, 2)
	,@p_is_authorize_workshop			  nvarchar(1)
	,@p_authorize_workshop_premium_amount decimal(18, 2)
	,@p_total_premium_amount			  decimal(18, 2)
	,@p_is_tbod							  nvarchar(1)
	,@p_tbod_premium_amount				  decimal(18, 2)
	,@p_cre_date						  datetime
	,@p_cre_by							  nvarchar(15)
	,@p_cre_ip_address					  nvarchar(15)
	,@p_mod_date						  datetime
	,@p_mod_by							  nvarchar(15)
	,@p_mod_ip_address					  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if exists
		(
			select	1
			from	dbo.asset_insurance_detail
			where	asset_no = @p_asset_no
		)
		begin 
			 exec dbo.xsp_asset_insurance_detail_update @p_id							= @p_id
			 										   ,@p_asset_no						= @p_asset_no					
			 										   ,@p_main_coverage_code			= @p_main_coverage_code			
			 										   ,@p_main_coverage_description	= @p_main_coverage_description	
			 										   ,@p_region_code					= @p_region_code					
			 										   ,@p_region_description			= @p_region_description			
			 										   ,@p_is_use_tpl					= @p_is_use_tpl					
			 										   ,@p_tpl_coverage_code			= @p_tpl_coverage_code			
			 										   ,@p_tpl_coverage_description		= @p_tpl_coverage_description	
			 										   ,@p_is_use_pll					= @p_is_use_pll					
			 										   ,@p_pll_coverage_code			= @p_pll_coverage_code			
			 										   ,@p_pll_coverage_description		= @p_pll_coverage_description	
			 										   ,@p_is_use_pa_passenger			= @p_is_use_pa_passenger			
			 										   ,@p_pa_passenger_amount			= @p_pa_passenger_amount			
			 										   ,@p_pa_passenger_seat			= @p_pa_passenger_seat			
			 										   ,@p_is_use_pa_driver				= @p_is_use_pa_driver			
			 										   ,@p_pa_driver_amount				= @p_pa_driver_amount			
			 										   ,@p_is_use_srcc					= @p_is_use_srcc					
			 										   ,@p_is_use_ts					= @p_is_use_ts					
			 										   ,@p_is_use_flood					= @p_is_use_flood				
			 										   ,@p_is_use_earthquake			= @p_is_use_earthquake			
			 										   ,@p_is_commercial_use			= @p_is_commercial_use			
			 										   ,@p_is_authorize_workshop		= @p_is_authorize_workshop		
			 										   ,@p_is_tbod						= @p_is_tbod						
													   --
													   ,@p_mod_date						= @p_mod_date
													   ,@p_mod_by						= @p_mod_by
													   ,@p_mod_ip_address				= @p_mod_ip_address ;
			 
		end ;
		else
		begin
			
			exec dbo.xsp_asset_insurance_detail_insert @p_id									= @p_id	output						 
													   ,@p_asset_no								= @p_asset_no
													   ,@p_main_coverage_code					= @p_main_coverage_code
													   ,@p_main_coverage_description			= @p_main_coverage_description
													   ,@p_region_code							= @p_region_code
													   ,@p_region_description					= @p_region_description
													   ,@p_is_use_tpl							= @p_is_use_tpl
													   ,@p_tpl_coverage_code					= @p_tpl_coverage_code
													   ,@p_tpl_coverage_description				= @p_tpl_coverage_description
													   ,@p_is_use_pll							= @p_is_use_pll
													   ,@p_pll_coverage_code					= @p_pll_coverage_code
													   ,@p_pll_coverage_description				= @p_pll_coverage_description
													   ,@p_is_use_pa_passenger					= @p_is_use_pa_passenger
													   ,@p_pa_passenger_amount					= @p_pa_passenger_amount
													   ,@p_pa_passenger_seat					= @p_pa_passenger_seat
													   ,@p_is_use_pa_driver						= @p_is_use_pa_driver
													   ,@p_pa_driver_amount						= @p_pa_driver_amount
													   ,@p_is_use_srcc							= @p_is_use_srcc
													   ,@p_is_use_ts							= @p_is_use_ts
													   ,@p_is_use_flood							= @p_is_use_flood
													   ,@p_is_use_earthquake					= @p_is_use_earthquake
													   ,@p_is_commercial_use					= @p_is_commercial_use
													   ,@p_is_authorize_workshop				= @p_is_authorize_workshop
													   ,@p_is_tbod								= @p_is_tbod
													   --		 
													   ,@p_cre_date								= @p_cre_date
													   ,@p_cre_by								= @p_cre_by
													   ,@p_cre_ip_address						= @p_cre_ip_address				 
													   ,@p_mod_date								= @p_mod_date
													   ,@p_mod_by								= @p_mod_by
													   ,@p_mod_ip_address						= @p_mod_ip_address				 
			
		end ;

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
