-- Stored Procedure

CREATE PROCEDURE dbo.xsp_mtn_application_asset_purchase_request_for_cr_priority
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
			,@asset_no						nvarchar(50)
			,@category_type					nvarchar(50)
			,@amount						decimal(18,2)
			,@asset_amount					nvarchar(50)
			,@asset_detail_code				nvarchar(50)
			,@id_asset_detail				bigint
			,@unit_amount					nvarchar(50)
			,@system_date					datetime	 = dbo.xfn_get_system_date()
			--workaround
			,@requestor_name				nvarchar(250)
			,@application_date				datetime
			,@total_purchase_data			int
			,@final_request_no				nvarchar(50)
			,@id_interface					bigint
			,@delivery_to					nvarchar(4000)
			,@plat_colour					nvarchar(50)
			,@year							nvarchar(4)
			,@client_bbn_name				nvarchar(250)
			,@bbn_location_description		nvarchar(4000)
			,@client_bbn_address			nvarchar(4000)

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
				,@unit_amount				= format(aa.otr_amount - aa.discount_amount, '#,###.00', 'DE-de') --format (aa.market_value - aa.discount_amount, '#,###.00', 'DE-de')-- Louis Selasa, 06 Februari 2024 17.33.06 -- diambil dari otr-discount amount
				,@requestor_name			= am.marketing_name
				,@application_date			= am.application_date
		from	dbo.application_asset aa
				left join dbo.application_main am on (am.application_no = aa.application_no) 
				left join dbo.client_main cm on (cm.code = am.client_code)
				left join dbo.sys_general_subcode sgs on (sgs.code		  = aa.asset_type_code)
		where	asset_no = @p_asset_no ; 

		if (@asset_type = 'VHCL')
		begin
			select	@fa_category_code = aav.vehicle_category_code
					,@fa_category_name = mvc.description
					,@fa_merk_code = aav.vehicle_merk_code
					,@fa_merk_name = mvm.description
					,@fa_model_code = aav.vehicle_model_code
					,@fa_model_name = mvmo.description
					,@fa_type_code = mvt.code
					,@fa_type_name = mvt.description
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
					,@fa_type_code = mvt.code
					,@fa_type_name = mvt.description
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
					,@fa_type_code = mvt.code
					,@fa_type_name = mvt.description
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

		set @description = 'Application Purchase : ' + @application_external_no + ' - ' + @client_name + ' Price. ' + @unit_amount

		--exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
		--									 ,@p_asset_no			= @p_asset_no
		--									 ,@p_branch_code		= @branch_code
		--									 ,@p_branch_name		= @branch_name
		--									 ,@p_request_date		= @system_date
		--									 ,@p_request_status		= 'HOLD'
		--									 ,@p_description		= @description
		--									 ,@p_fa_category_code	= @fa_category_code	
		--									 ,@p_fa_category_name	= @fa_category_name	
		--									 ,@p_fa_merk_code		= @fa_merk_code		
		--									 ,@p_fa_merk_name		= @fa_merk_name		
		--									 ,@p_fa_model_code		= @fa_model_code		
		--									 ,@p_fa_model_name		= @fa_model_name		
		--									 ,@p_fa_type_code		= @fa_type_code		
		--									 ,@p_fa_type_name		= @fa_type_name		
		--									 ,@p_result_fa_code		= null
		--									 ,@p_result_fa_name		= null
		--									 ,@p_result_date		= null
		--									 ,@p_unit_from			= 'BUY'
		--									 ,@p_category_type		= 'ASSET'
		--									 --
		--									 ,@p_cre_date			= @p_mod_date		
		--									 ,@p_cre_by				= @p_mod_by			
		--									 ,@p_cre_ip_address		= @p_mod_ip_address	
		--									 ,@p_mod_date			= @p_mod_date		
		--									 ,@p_mod_by				= @p_mod_by			
		--									 ,@p_mod_ip_address		= @p_mod_ip_address	

		----update tidak bisa dibawah karena butuh purchase code dan jika di bawah maka dapet nya puchase code dari detail nya
		--update	dbo.application_asset
		--set		purchase_status		= 'ON PROCESS'
		--		,purchase_code		= @purchase_request_code
		--		--
		--		,@p_mod_date		= @p_mod_date		
		--		,@p_mod_by			= @p_mod_by			
		--		,@p_mod_ip_address	= @p_mod_ip_address	
		--where	asset_no			= @p_asset_no ;

		----otomatis post purchase request
		--exec dbo.xsp_purchase_request_post @p_code		       = @purchase_request_code
		--									--
		--									,@p_mod_date       = @p_mod_date		
		--									,@p_mod_by	       = @p_mod_by			
		--									,@p_mod_ip_address = @p_mod_ip_address

		--alter louis 14/06/2023 tambah looping untuk accessories
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset_detail
		--	where	asset_no					= @p_asset_no
		--			and is_subject_to_purchase	= '1'
		--			--and type					= 'ACCESSORIES'
		--)
		--begin

		--	declare c_asset_detail cursor for
		--	select	id
		--			,code
		--			,asset_no
		--			,type
		--			,description
		--			,amount
		--			,merk_code
		--			,merk_description
		--			,model_code
		--			,model_description
		--			,type_code
		--			,type_description
		--	from	dbo.application_asset_detail
		--	where	asset_no					= @p_asset_no
		--			and is_subject_to_purchase	= '1'
		--			and amount > 0
		--			--and type					= 'ACCESSORIES'

		--	open	c_asset_detail

		--	fetch	c_asset_detail
		--	into	@id_asset_detail
		--			,@asset_detail_code
		--			,@asset_no
		--			,@category_type
		--			,@fa_category_name
		--			,@amount
		--			,@fa_merk_code
		--			,@fa_merk_name
		--			,@fa_model_code
		--			,@fa_model_name
		--			,@fa_type_code
		--			,@fa_type_name

		--	while @@fetch_status = 0
		--	begin

		--		set @asset_amount = format (@amount, '#,###.00', 'DE-de')

		--		set @description = 'Application Purchase for '+ @category_type +' :  ' + @application_external_no + ' - ' + @client_name + ' Price. ' + @asset_amount

		--		exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
		--											 ,@p_asset_no			= @p_asset_no
		--											 ,@p_branch_code		= @branch_code
		--											 ,@p_branch_name		= @branch_name
		--											 ,@p_request_date		= @system_date
		--											 ,@p_request_status		= 'HOLD'
		--											 ,@p_description		= @description
		--											 ,@p_fa_category_code	= @category_type
		--											 ,@p_fa_category_name	= @fa_category_name
		--											 ,@p_fa_merk_code		= @fa_merk_code		
		--											 ,@p_fa_merk_name		= @fa_merk_name		
		--											 ,@p_fa_model_code		= @fa_model_code		
		--											 ,@p_fa_model_name		= @fa_model_name		
		--											 ,@p_fa_type_code		= @fa_type_code		
		--											 ,@p_fa_type_name		= @fa_type_name		
		--											 ,@p_result_fa_code		= null
		--											 ,@p_result_fa_name		= null
		--											 ,@p_result_date		= null
		--											 ,@p_unit_from			= 'BUY'
		--											 ,@p_category_type		= @category_type
		--											 --
		--											 ,@p_cre_date			= @p_mod_date		
		--											 ,@p_cre_by				= @p_mod_by			
		--											 ,@p_cre_ip_address		= @p_mod_ip_address	
		--											 ,@p_mod_date			= @p_mod_date		
		--											 ,@p_mod_by				= @p_mod_by			
		--											 ,@p_mod_ip_address		= @p_mod_ip_address


		--		update	dbo.application_asset_detail
		--		set		purchase_code = @purchase_request_code
		--				,purchase_status	= 'ON PROCESS'
		--				--
		--				,@p_mod_date		= @p_mod_date		
		--				,@p_mod_by			= @p_mod_by			
		--				,@p_mod_ip_address	= @p_mod_ip_address	
		--		where	id					= @id_asset_detail

		--		--otomatis post purchase request
		--		exec dbo.xsp_purchase_request_post @p_code		      = @purchase_request_code
		--										   --
		--										   ,@p_mod_date       = @p_mod_date		
		--										   ,@p_mod_by	      = @p_mod_by			
		--										   ,@p_mod_ip_address = @p_mod_ip_address

		--		set @asset_amount = '';

		--		fetch	c_asset_detail
		--		into	@id_asset_detail
		--				,@asset_detail_code
		--				,@asset_no
		--				,@category_type
		--				,@fa_category_name
		--				,@amount
		--				,@fa_merk_code
		--				,@fa_merk_name
		--				,@fa_model_code
		--				,@fa_model_name
		--				,@fa_type_code
		--				,@fa_type_name
		--	end

		--	close		c_asset_detail
		--	deallocate	c_asset_detail

		--end

		--alter louis 14/06/2023 tambah looping untuk karoseri
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset_detail
		--	where	asset_no					= @p_asset_no
		--			and type					= 'KAROSERI'
		--)
		--begin

		--	declare c_asset_detail cursor for
		--	select	id
		--			,code
		--			,asset_no
		--			,type
		--			,description
		--			,amount
		--			,merk_code
		--			,merk_description
		--			,model_code
		--			,model_description
		--			,type_code
		--			,type_description
		--	from	dbo.application_asset_detail
		--	where	asset_no					= @p_asset_no
		--			and type					= 'KAROSERI'

		--	open	c_asset_detail

		--	fetch	c_asset_detail
		--	into	@id_asset_detail
		--			,@asset_detail_code
		--			,@asset_no
		--			,@category_type
		--			,@fa_category_name
		--			,@amount
		--			,@fa_merk_code
		--			,@fa_merk_name
		--			,@fa_model_code
		--			,@fa_model_name
		--			,@fa_type_code
		--			,@fa_type_name

		--	while @@fetch_status = 0
		--	begin

		--		set @asset_amount = format (@amount, '#,###.00', 'DE-de')

		--		set @description = 'Application Purchase for '+ @category_type +' :  ' + @application_external_no + ' - ' + @client_name + ' Price. ' + @asset_amount

		--		exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
		--											 ,@p_asset_no			= @p_asset_no
		--											 ,@p_branch_code		= @branch_code
		--											 ,@p_branch_name		= @branch_name
		--											 ,@p_request_date		= @system_date
		--											 ,@p_request_status		= 'HOLD'
		--											 ,@p_description		= @description
		--											 ,@p_fa_category_code	= @category_type
		--											 ,@p_fa_category_name	= @fa_category_name
		--											 ,@p_fa_merk_code		= @fa_merk_code		
		--											 ,@p_fa_merk_name		= @fa_merk_name		
		--											 ,@p_fa_model_code		= @fa_model_code		
		--											 ,@p_fa_model_name		= @fa_model_name		
		--											 ,@p_fa_type_code		= @fa_type_code		
		--											 ,@p_fa_type_name		= @fa_type_name		
		--											 ,@p_result_fa_code		= null
		--											 ,@p_result_fa_name		= null
		--											 ,@p_result_date		= null
		--											 ,@p_unit_from			= 'BUY'
		--											 ,@p_category_type		= @category_type
		--											 --
		--											 ,@p_cre_date			= @p_mod_date		
		--											 ,@p_cre_by				= @p_mod_by			
		--											 ,@p_cre_ip_address		= @p_mod_ip_address	
		--											 ,@p_mod_date			= @p_mod_date		
		--											 ,@p_mod_by				= @p_mod_by			
		--											 ,@p_mod_ip_address		= @p_mod_ip_address


		--		update	dbo.application_asset_detail
		--		set		purchase_code = @purchase_request_code
		--				,purchase_status	= 'ON PROCESS'
		--				--
		--				,@p_mod_date		= @p_mod_date		
		--				,@p_mod_by			= @p_mod_by			
		--				,@p_mod_ip_address	= @p_mod_ip_address	
		--		where	id					= @id_asset_detail

		--		--otomatis post purchase request
		--		exec dbo.xsp_purchase_request_post @p_code		      = @purchase_request_code
		--										   --
		--										   ,@p_mod_date       = @p_mod_date		
		--										   ,@p_mod_by	      = @p_mod_by			
		--										   ,@p_mod_ip_address = @p_mod_ip_address

		--		set @asset_amount = '';

		--		fetch	c_asset_detail
		--		into	@id_asset_detail
		--				,@asset_detail_code
		--				,@asset_no
		--				,@category_type
		--				,@fa_category_name
		--				,@amount
		--				,@fa_merk_code
		--				,@fa_merk_name
		--				,@fa_model_code
		--				,@fa_model_name
		--				,@fa_type_code
		--				,@fa_type_name
		--	end

		--	close		c_asset_detail
		--	deallocate	c_asset_detail

		--end

		-- Louis Selasa, 16 April 2024 20.06.36 -- looping untuk budget
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset_budget
		--	where	asset_no					= @p_asset_no
		--			and is_subject_to_purchase	= '1'
		--)
		--begin

		--	declare curr_budget cursor fast_forward read_only for
		--	select	id
		--			,'BUDGET'--aab.cost_code
		--		    ,mbc.description 
		--		    ,aab.budget_amount  
		--	from	dbo.application_asset_budget aab inner join dbo.master_budget_cost mbc on (mbc.code = aab.cost_code)
		--	where	asset_no				   = @p_asset_no
		--			and aab.is_subject_to_purchase = '1' ;

		--	open curr_budget ;

		--	fetch next from curr_budget
		--	into @id_asset_detail
		--		 ,@category_type
		--		 ,@fa_category_name
		--		 ,@amount

		--	while @@fetch_status = 0
		--	begin

		--		set @asset_amount = format (@amount, '#,###.00', 'DE-de')

		--		set @description = 'Application Purchase for '+ @fa_category_name +' :  ' + @application_external_no + ' - ' + @client_name + ' Price. ' + @asset_amount

		--		exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
		--											 ,@p_asset_no			= @p_asset_no
		--											 ,@p_branch_code		= @branch_code
		--											 ,@p_branch_name		= @branch_name
		--											 ,@p_request_date		= @system_date
		--											 ,@p_request_status		= 'HOLD'
		--											 ,@p_description		= @description
		--											 ,@p_fa_category_code	= @category_type
		--											 ,@p_fa_category_name	= @fa_category_name
		--											 ,@p_fa_merk_code		= null
		--											 ,@p_fa_merk_name		= null
		--											 ,@p_fa_model_code		= null	
		--											 ,@p_fa_model_name		= null	
		--											 ,@p_fa_type_code		= null
		--											 ,@p_fa_type_name		= null
		--											 ,@p_result_fa_code		= null
		--											 ,@p_result_fa_name		= null
		--											 ,@p_result_date		= null
		--											 ,@p_unit_from			= 'BUY'
		--											 ,@p_category_type		= @category_type
		--											 --
		--											 ,@p_cre_date			= @p_mod_date		
		--											 ,@p_cre_by				= @p_mod_by			
		--											 ,@p_cre_ip_address		= @p_mod_ip_address	
		--											 ,@p_mod_date			= @p_mod_date		
		--											 ,@p_mod_by				= @p_mod_by			
		--											 ,@p_mod_ip_address		= @p_mod_ip_address

		--		update	dbo.application_asset_budget
		--		set		purchase_code		= @purchase_request_code
		--				,purchase_status	= 'ON PROCESS'
		--				--
		--				,@p_mod_date		= @p_mod_date		
		--				,@p_mod_by			= @p_mod_by			
		--				,@p_mod_ip_address	= @p_mod_ip_address	
		--		where	id					= @id_asset_detail

		--		--otomatis post purchase request
		--		exec dbo.xsp_purchase_request_post @p_code		      = @purchase_request_code
		--										   --
		--										   ,@p_mod_date       = @p_mod_date		
		--										   ,@p_mod_by	      = @p_mod_by			
		--										   ,@p_mod_ip_address = @p_mod_ip_address

		--		set @asset_amount = '';

		--		fetch next from curr_budget
		--		into @id_asset_detail
		--			 ,@category_type
		--			 ,@fa_category_name
		--			 ,@amount
		--	end ;

		--	close curr_budget ;
		--	deallocate curr_budget ;
		--end

		---- Louis Rabu, 17 April 2024 15.06.28 -- push budget GPS
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset
		--	where	asset_no					= @p_asset_no
		--			and gps_installation_amount > 0
		--)
		--begin 
		--		set @purchase_request_code = null

		--		select	@asset_amount = format (gps_installation_amount, '#,###.00', 'DE-de')
		--		from	dbo.application_asset
		--		where	asset_no					= @p_asset_no
		--				and gps_installation_amount > 0

		--		set @description = 'Application Purchase for GPS Installation :  ' + @application_external_no + ' - ' + @client_name + ' Price. ' + @asset_amount

		--		exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
		--											 ,@p_asset_no			= @p_asset_no
		--											 ,@p_branch_code		= @branch_code
		--											 ,@p_branch_name		= @branch_name
		--											 ,@p_request_date		= @system_date
		--											 ,@p_request_status		= 'HOLD'
		--											 ,@p_description		= @description
		--											 ,@p_fa_category_code	= 'GPS'
		--											 ,@p_fa_category_name	= 'GPS Installation'
		--											 ,@p_fa_merk_code		= null
		--											 ,@p_fa_merk_name		= null
		--											 ,@p_fa_model_code		= null	
		--											 ,@p_fa_model_name		= null	
		--											 ,@p_fa_type_code		= null
		--											 ,@p_fa_type_name		= null
		--											 ,@p_result_fa_code		= null
		--											 ,@p_result_fa_name		= null
		--											 ,@p_result_date		= null
		--											 ,@p_unit_from			= 'BUY'
		--											 ,@p_category_type		= 'GPS'
		--											 --
		--											 ,@p_cre_date			= @p_mod_date		
		--											 ,@p_cre_by				= @p_mod_by			
		--											 ,@p_cre_ip_address		= @p_mod_ip_address	
		--											 ,@p_mod_date			= @p_mod_date		
		--											 ,@p_mod_by				= @p_mod_by			
		--											 ,@p_mod_ip_address		= @p_mod_ip_address

		--		--otomatis post purchase request
		--		exec dbo.xsp_purchase_request_post @p_code		      = @purchase_request_code
		--										   --
		--										   ,@p_mod_date       = @p_mod_date		
		--										   ,@p_mod_by	      = @p_mod_by			
		--										   ,@p_mod_ip_address = @p_mod_ip_address
		--		set @asset_amount = '';
		--		set @description = '';
		--end

		--push ke interface final grn request
		select	@total_purchase_data = count(1)
		from	dbo.application_asset
		where	application_no		= @application_no
		and		unit_source = 'PURCHASE'
				--and asset_condition = 'NEW' ;

		begin
			if not exists (select 1 from dbo.opl_interface_final_grn_request where application_no = @application_external_no)
			begin
				exec dbo.xsp_opl_interface_final_grn_request_insert @p_id						= @id_interface
																	,@p_final_grn_request_no	= @final_request_no output
																	,@p_application_no			= @application_external_no
																	,@p_client_name				= @client_name
																	,@p_branch_code				= @branch_code
																	,@p_branch_name				= @branch_name
																	,@p_requestor_name			= @requestor_name
																	,@p_application_date		= @application_date
																	,@p_total_purchase_data		= @total_purchase_data
																	,@p_status					= 'HOLD'
																	,@p_job_status				= 'HOLD'
																	,@p_failed_remarks			= ''
																	,@p_cre_date				= @p_mod_date
																	,@p_cre_by					= @p_mod_by
																	,@p_cre_ip_address			= @p_mod_ip_address
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address


				declare curr_final_req_detail cursor fast_forward read_only for
				select	asset_no
						,deliver_to_address
						,asset_year
						,plat_colour
						,client_bbn_name
						,bbn_location_description
						,client_bbn_address
				from	dbo.application_asset
				where	application_no		= @application_no
				and		unit_source = 'PURCHASE'
						--and asset_condition = 'NEW' 
						and		isnull(fa_code,'') = ''

				open curr_final_req_detail ;

				fetch next from curr_final_req_detail
				into @asset_no
					,@delivery_to
					,@year
					,@plat_colour
					,@client_bbn_name
					,@bbn_location_description
					,@client_bbn_address

				while @@fetch_status = 0
				begin
					insert into dbo.opl_interface_final_grn_request_detail
					(
						final_grn_request_no
						,asset_no
						,delivery_to
						,bbn_name
						,bbn_location
						,bbn_address
						,year
						,colour
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
						@final_request_no
						,@asset_no
						,@delivery_to
						,@client_bbn_name
						,@bbn_location_description
						,@client_bbn_address
						,@year
						,@plat_colour
						--
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;

				fetch next from curr_final_req_detail
				into @asset_no
					 ,@delivery_to
					 ,@year
					 ,@plat_colour
					 ,@client_bbn_name
					 ,@bbn_location_description
					 ,@client_bbn_address
			end ;

				close curr_final_req_detail ;
				deallocate curr_final_req_detail ;
			end
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

end


