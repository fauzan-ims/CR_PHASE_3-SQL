--created by, Rian at 29/05/2023  

CREATE PROCEDURE [dbo].[xsp_application_asset_purchase_request_gts]
(
	@p_asset_no			nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@purchase_request_code			nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@asset_type					nvarchar(50)
			,@description					nvarchar(4000)
			,@fa_category_code				nvarchar(50)
			,@fa_category_name				nvarchar(250)
			,@fa_merk_code					nvarchar(50)
			,@fa_merk_name					nvarchar(250)
			,@fa_model_code					nvarchar(50)
			,@fa_model_name					nvarchar(250)
			,@fa_type_code					nvarchar(50)
			,@fa_type_name					nvarchar(250) 
			,@application_no				nvarchar(50)
			,@application_external_no		nvarchar(50)
			,@client_name					nvarchar(250) 
			,@asset_name					nvarchar(250) 
			,@category_type					nvarchar(50)
			,@system_date					datetime	 = dbo.xfn_get_system_date()

	begin try
		select	
				 @branch_code				= am.branch_code
				,@branch_name				= am.branch_name 
				,@asset_type				= aa.asset_type_code
				,@description				= ''
				,@fa_type_code				= aa.asset_type_code
				,@fa_type_name				= sgs.description 
				,@application_no			= aa.application_no
				,@client_name				= cm.client_name
				,@asset_name				= aa.asset_name
				,@application_external_no	= am.application_external_no
		from	dbo.application_asset aa
				left join dbo.application_main am on (am.application_no = aa.application_no) 
				left join dbo.client_main cm on (cm.code = am.client_code)
				left join dbo.sys_general_subcode sgs on (sgs.code		  = aa.asset_type_code)
		where	asset_no = @p_asset_no ; 

		if not exists
		(
			select	1
			from	dbo.purchase_request
			where	asset_no in
					(
						select	asset_no
						from	dbo.application_asset
						where	application_no = @application_no
					)
					and request_status <> 'CANCEL'
					and unit_from	   = 'BUY'
		)
		begin
			set @msg = 'Cannot Purchase GTS because Main Asset already Cancel from Procurement' ;
			raiserror(@msg, 16, 1) ;
			return
		end ;

		if (@asset_type = 'VHCL')
		begin
			select	@fa_category_code = aav.vehicle_category_code
					,@fa_category_name = mvc.description
					,@fa_merk_code = aav.vehicle_merk_code
					,@fa_merk_name = mvm.description
					,@fa_model_code = aav.vehicle_model_code
					,@fa_model_name = mvmo.description
					,@fa_type_code = @asset_type
			from	application_asset_vehicle aav
					left join dbo.master_vehicle_category mvc on (mvc.code	  = aav.vehicle_category_code)
					left join dbo.master_vehicle_subcategory mvs on (mvs.code = aav.vehicle_subcategory_code)
					left join dbo.master_vehicle_merk mvm on (mvm.code		  = aav.vehicle_merk_code)
					left join dbo.master_vehicle_model mvmo on (mvmo.code	  = aav.vehicle_model_code)
					left join dbo.master_vehicle_type mvt on (mvt.code		  = aav.vehicle_type_code)
					left join dbo.master_vehicle_unit mvu on (mvu.code		  = aav.vehicle_unit_code)
			where	asset_no = @p_asset_no ;
		end ;
		else if (@asset_type = 'MCHN')
		begin
			select	@fa_category_code = mam.machinery_category_code
					,@fa_category_name = mvc.description
					,@fa_merk_code = mam.machinery_merk_code
					,@fa_merk_name = mvm.description
					,@fa_model_code = mam.machinery_model_code
					,@fa_model_name = mvmo.description
			from	application_asset_machine mam
					left join dbo.master_machinery_category mvc on (mvc.code	= mam.machinery_category_code)
					left join dbo.master_machinery_subcategory mvs on (mvs.code = mam.machinery_subcategory_code)
					left join dbo.master_machinery_merk mvm on (mvm.code		= mam.machinery_merk_code)
					left join dbo.master_machinery_model mvmo on (mvmo.code		= mam.machinery_model_code)
					left join dbo.master_machinery_type mvt on (mvt.code		= mam.machinery_type_code)
					left join dbo.master_machinery_unit mvu on (mvu.code		= mam.machinery_unit_code)
			where	asset_no = @p_asset_no ;
		end ;
		else if (@asset_type = 'HE')
		begin
			select	@fa_category_code = mah.he_category_code
					,@fa_category_name = mvc.description
					,@fa_merk_code = mah.he_merk_code
					,@fa_merk_name = mvm.description
					,@fa_model_code = mah.he_model_code
					,@fa_model_name = mvmo.description
			from	application_asset_he mah
					left join dbo.master_he_category mvc on (mvc.code	 = mah.he_category_code)
					left join dbo.master_he_subcategory mvs on (mvs.code = mah.he_subcategory_code)
					left join dbo.master_he_merk mvm on (mvm.code		 = mah.he_merk_code)
					left join dbo.master_he_model mvmo on (mvmo.code	 = mah.he_model_code)
					left join dbo.master_he_type mvt on (mvt.code		 = mah.he_type_code)
					left join dbo.master_he_unit mvu on (mvu.code		 = mah.he_unit_code)
			where	asset_no = @p_asset_no ;
		end ;
		else if (@asset_type = 'ELEC')
		begin
			select	@fa_category_code = mah.electronic_category_code
					,@fa_category_name = mvc.description
					,@fa_merk_code = mah.electronic_merk_code
					,@fa_merk_name = mvm.description
					,@fa_model_code = mah.electronic_model_code
					,@fa_model_name = mvmo.description
			from	application_asset_electronic mah
					left join dbo.master_electronic_category mvc on (mvc.code	 = mah.electronic_category_code)
					left join dbo.master_electronic_subcategory mvs on (mvs.code = mah.electronic_subcategory_code)
					left join dbo.master_electronic_merk mvm on (mvm.code		 = mah.electronic_merk_code)
					left join dbo.master_electronic_model mvmo on (mvmo.code	 = mah.electronic_model_code)
					left join dbo.master_electronic_unit mvu on (mvu.code		 = mah.electronic_unit_code)
			where	asset_no = @p_asset_no ;
		end ;

		set @description = 'Application Purchase GTS : ' + @application_external_no + ' - ' + @client_name

		exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
											 ,@p_asset_no			= @p_asset_no
											 ,@p_branch_code		= @branch_code
											 ,@p_branch_name		= @branch_name
											 ,@p_request_date		= @system_date
											 ,@p_request_status		= 'HOLD'
											 ,@p_description		= @description
											 ,@p_fa_category_code	= @fa_category_code	
											 ,@p_fa_category_name	= @fa_category_name	
											 ,@p_fa_merk_code		= @fa_merk_code		
											 ,@p_fa_merk_name		= @fa_merk_name		
											 ,@p_fa_model_code		= @fa_model_code		
											 ,@p_fa_model_name		= @fa_model_name		
											 ,@p_fa_type_code		= @fa_type_code		
											 ,@p_fa_type_name		= @fa_type_name		
											 ,@p_result_fa_code		= null
											 ,@p_result_fa_name		= null
											 ,@p_result_date		= null
											 ,@p_unit_from			= 'RENT'
											 ,@p_category_type		= 'ASSET'
											 --
											 ,@p_cre_date			= @p_mod_date		
											 ,@p_cre_by				= @p_mod_by			
											 ,@p_cre_ip_address		= @p_mod_ip_address	
											 ,@p_mod_date			= @p_mod_date		
											 ,@p_mod_by				= @p_mod_by			
											 ,@p_mod_ip_address		= @p_mod_ip_address	

		update	dbo.application_asset
		set		purchase_gts_status		= 'ON PROCESS'
				,purchase_gts_code		= @purchase_request_code
				--
				,@p_mod_date			= @p_mod_date		
				,@p_mod_by				= @p_mod_by			
				,@p_mod_ip_address		= @p_mod_ip_address	
		where	asset_no				= @p_asset_no ;
											
		--otomatis post purchase request
		exec dbo.xsp_purchase_request_post @p_code		       = @purchase_request_code
											--
											,@p_mod_date       = @p_mod_date		
											,@p_mod_by	       = @p_mod_by			
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

end


