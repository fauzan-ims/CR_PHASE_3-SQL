
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_application_asset_update_fix_asset]
(
	@p_asset_no					 nvarchar(50)  
	,@p_fa_code					 nvarchar(50)	= null 
	,@p_fa_name					 nvarchar(250)	= null 
	,@p_fa_reff_no_01			 nvarchar(250)  = null
	,@p_fa_reff_no_02			 nvarchar(250)  = null
	,@p_fa_reff_no_03			 nvarchar(250)  = null
	,@p_type					 nvarchar(15)   = 'fixedAsset'
	--											
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@client_no				nvarchar(50)
			,@application_no		nvarchar(50)
			,@realization_status	nvarchar(50)
			,@realization_code		nvarchar(50)
			,@realization_result	nvarchar(4000)
			,@item_code_asset_opl	nvarchar(50)
			,@item_code_asset_proc	nvarchar(50)

	begin try

		select	@application_no = application_no
		from	dbo.application_asset
		where	asset_no = @p_asset_no ;

		select	@client_no = client_no
		from	dbo.client_main cm
				inner join dbo.application_main am on (am.client_code = cm.code)
		where	am.application_no = @application_no ;

		--validasi continue Rental jika client no <> @p_client_no
		if exists
		(
			select	1
			from	ifinams.dbo.asset a
					inner join dbo.application_asset aa on (aa.fa_code = a.code)
			where	aa.application_no			= @application_no
					and isnull(a.re_rent_status, '') = 'CONTINUE'
					and isnull(a.client_no, '') <> ''
		)
		begin
			if exists
			(
				select	1
				from	ifinams.dbo.asset a
						inner join dbo.application_asset aa on (aa.fa_code = a.code)
				where	aa.application_no			= @application_no
						and isnull(a.re_rent_status, '') = 'CONTINUE'
						and isnull(a.client_no, '') <> @client_no
			)
			begin
				select @msg = N'Fixed Asset : ' + a.code + N' is already booked for Client : ' + a.client_name
					from	ifinams.dbo.asset a
						inner join dbo.application_asset aa on (aa.fa_code = a.code)
				where	aa.application_no			= @application_no
						and isnull(a.re_rent_status, '') = 'CONTINUE'
						and isnull(a.client_no, '') <> @client_no

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		if(@p_type = 'fixedAsset')
		begin
			update	dbo.application_asset
			set		fa_code					= @p_fa_code
					,fa_name				= @p_fa_name
					,purchase_status		= 'NONE'
					,fa_reff_no_01			= @p_fa_reff_no_01 
					,fa_reff_no_02			= @p_fa_reff_no_02 
					,fa_reff_no_03			= @p_fa_reff_no_03 
					--hidden by dicky ,request_delivery_date	= null
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	asset_no				= @p_asset_no ; 

		end
		--dampak work around
		else if(@p_type = 'Procurement')
		begin
			if exists 
			(	
				select	1
				from	dbo.application_asset
				where	application_no = @application_no
				and		(fa_code	= @p_fa_code  or replacement_fa_code  = @p_fa_code)

			)
			begin
				SET	@msg = 'The asset is already in use'
				raiserror (@msg, 16, -1)
			end
			else
			begin
				SELECT	@item_code_asset_opl = mvu.code
				from	dbo.application_asset_vehicle			 aav
						left join dbo.master_vehicle_category	 mvc on (mvc.code	= aav.vehicle_category_code)
						left join dbo.master_vehicle_subcategory mvs on (mvs.code	= aav.vehicle_subcategory_code)
						left join dbo.master_vehicle_merk		 mvm on (mvm.code	= aav.vehicle_merk_code)
						left join dbo.master_vehicle_model		 mvmo on (mvmo.code = aav.vehicle_model_code)
						left join dbo.master_vehicle_type		 mvt on (mvt.code	= aav.vehicle_type_code)
						left join dbo.master_vehicle_unit		 mvu on (mvu.code	= aav.vehicle_unit_code)
				where	aav.asset_no = @p_asset_no ;

				select	@item_code_asset_proc = item_code
				from	ifinproc.dbo.proc_asset_lookup
				where	asset_code = @p_fa_code ;

				if(@item_code_asset_opl <> @item_code_asset_proc)
				begin
					set @msg = N'Asset did not match with application.' ;
					raiserror(@msg, 16, 1) ;
				end

				update	dbo.application_asset
				set		fa_code					= @p_fa_code
						,fa_name				= @p_fa_name
						,fa_reff_no_01			= @p_fa_reff_no_01 
						,fa_reff_no_02			= @p_fa_reff_no_02 
						,fa_reff_no_03			= @p_fa_reff_no_03 
						--hidden by dicky ,request_delivery_date	= null
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	asset_no				= @p_asset_no ; 

			end
		end
		else
		begin
			update	dbo.application_asset
			set		replacement_fa_code			= @p_fa_code
					,replacement_fa_name		= @p_fa_name
					,purchase_gts_status		= 'NONE'
					,replacement_fa_reff_no_01	= @p_fa_reff_no_01 
					,replacement_fa_reff_no_02	= @p_fa_reff_no_02 
					,replacement_fa_reff_no_03	= @p_fa_reff_no_03 
					--hidden by dicky ,request_delivery_date	= null
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	asset_no					= @p_asset_no ; 
		end

		--13082025 SEPRIA: CR PRIORITY: UPDATE KE ASSET SEBAGAI RESERVED
		update ifinams.dbo.asset
		set		rental_status		= 'RESERVED'
				,reserved_date		= @p_mod_date
				,reserved_by		= @p_mod_by
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_fa_code ; 

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


