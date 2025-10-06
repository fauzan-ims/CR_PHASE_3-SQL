CREATE PROCEDURE [dbo].[xsp_asset_vehicle_update]
(
	@p_asset_code					nvarchar(50)
	,@p_merk_code					nvarchar(50)	= ''
	,@p_merk_name					nvarchar(250)	= ''
	,@p_type_code					nvarchar(50)	= ''
	,@p_type_name					nvarchar(250)	= ''
	,@p_model_code					nvarchar(50)	= ''
	,@p_model_name					nvarchar(250)	= ''
	,@p_plat_no						nvarchar(50)	= ''
	,@p_chassis_no					nvarchar(50)	= ''
	,@p_engine_no					nvarchar(50)	= ''
	,@p_bpkb_no						nvarchar(50)	= ''
	,@p_colour						nvarchar(50)	= ''
	,@p_cylinder					nvarchar(20)	= ''
	,@p_stnk_no						nvarchar(50)	= ''
	,@p_stnk_expired_date			datetime		= null
	,@p_stnk_tax_date				datetime		= null
	,@p_stnk_renewal				nvarchar(15)	= ''
	,@p_built_year					nvarchar(4)		= ''
	,@p_remark						nvarchar(4000)	= ''
	,@p_keur_no						nvarchar(50)	= ''
	,@p_keur_date					datetime		= null
	,@p_keur_expired_date			datetime		= null
    ,@p_stnk_name					nvarchar(50)	= ''
	,@p_stnk_date					datetime		= null
    ,@p_stnk_address				nvarchar(4000)	= ''	
	,@p_stck_no						nvarchar(50)	= ''
	,@p_stck_date					datetime		= null
    ,@p_stck_expired_date			datetime		= ''					
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max) 
			,@id	bigint;

	begin try
		if exists (select 1 from dbo.asset_vehicle av
		inner join dbo.asset a on a.code = av.asset_code
		WHERE av.plat_no  = @p_plat_no and av.plat_no <> '' and av.asset_code <> @p_asset_code and a.status <> 'CANCEL')
		begin
			set @msg = 'Plat No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_vehicle av
		inner join dbo.asset a on a.code = av.asset_code
		WHERE av.chassis_no  = @p_chassis_no and av.chassis_no <> '' and av.asset_code <> @p_asset_code and a.status <> 'CANCEL')
		begin
			set @msg = 'Chasis No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_vehicle av
		inner join dbo.asset a on a.code = av.asset_code 
		WHERE av.engine_no  = @p_engine_no and av.engine_no <> '' and av.asset_code <> @p_asset_code and a.status <> 'CANCEL')
		begin
			set @msg = 'Engine No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_vehicle av
		inner join dbo.asset a on a.code = av.asset_code where av.bpkb_no  = @p_bpkb_no and av.bpkb_no <> '' and av.asset_code <> @p_asset_code and a.status <> 'CANCEL')
		begin
			set @msg = 'BPKB No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_vehicle av
		inner join dbo.asset a on a.code = av.asset_code where av.stnk_no  = @p_stnk_no and av.stnk_no <> '' and av.asset_code <> @p_asset_code and a.status <> 'CANCEL')
		begin
			set @msg = 'STNK No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end
        -- (+) Ari 2024-04-03 ket : add stck
        if exists (
					select	1 
					from	dbo.asset_vehicle av
					inner	join dbo.asset a on (a.code = av.asset_code) 
					where	av.stck_no  = @p_stnk_no 
					and		av.stck_no <> '' 
					and		av.asset_code <> @p_asset_code 
					and		a.status <> 'CANCEL'
				 )
		begin
			set @msg = 'STCK No Already Exist.';
			raiserror(@msg ,16,-1);	    
		end

		update	asset_vehicle
		set		merk_code					= @p_merk_code
				,merk_name					= @p_merk_name
				,type_item_code				= @p_type_code
				,type_item_name				= @p_type_name
				,model_code					= @p_model_code
				,model_name					= @p_model_name
				,plat_no					= @p_plat_no
				,chassis_no					= @p_chassis_no
				,engine_no					= @p_engine_no
				,bpkb_no					= @p_bpkb_no
				,colour						= @p_colour
				,cylinder					= @p_cylinder
				,stnk_no					= @p_stnk_no
				,stnk_expired_date			= @p_stnk_expired_date
				,stnk_tax_date				= @p_stnk_tax_date
				,stnk_renewal				= @p_stnk_renewal
				,built_year					= @p_built_year
				,remark						= @p_remark
				,keur_no					= @p_keur_no
				,keur_date					= @p_keur_date
				,keur_expired_date			= @p_keur_expired_date
				,stnk_name					= @p_stnk_name
				,stnk_date					= @p_stnk_date
				,stnk_address				= @p_stnk_address
				-- (+) Ari 2024-04-03 ket : add stck
				,stck_no					= @p_stck_no
				,stck_date					= @p_stck_date
				,stck_exp_date				= @p_stck_expired_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	asset_code					= @p_asset_code ;

		if exists
		(
			select	1
			from	dbo.asset
			where	code			   = @p_asset_code
					and fisical_status in ('ON HAND', 'ON CUSTOMER')
		)
		begin
			exec dbo.xsp_ams_interface_asset_vehicle_update_insert	@p_id				= @id output 
																	,@p_fa_code			= @p_asset_code
																	,@p_fa_reff_no_1	= @p_plat_no
																	,@p_fa_reff_no_2	= @p_chassis_no
																	,@p_fa_reff_no_3	= @p_engine_no
																	,@p_job_status		= 'HOLD'
																	--
																	,@p_cre_date		= @p_mod_date
																	,@p_cre_by			= @p_mod_by
																	,@p_cre_ip_address	= @p_mod_ip_address
																	,@p_mod_date		= @p_mod_date
																	,@p_mod_by			= @p_mod_by
																	,@p_mod_ip_address	= @p_mod_ip_address
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
