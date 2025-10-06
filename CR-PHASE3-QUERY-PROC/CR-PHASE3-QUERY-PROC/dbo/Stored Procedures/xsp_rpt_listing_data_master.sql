CREATE PROCEDURE [dbo].[xsp_rpt_listing_data_master]
(
	@p_table_name nvarchar(100)
)
as
begin
	declare @msg	nvarchar(max)
			,@value	nvarchar(max)

	begin TRY
    
			set @value = 'SELECT * FROM .dbo.' + @p_table_name
			exec sp_executesql @value	

		--if (@p_table_name = 'MASTER_APPROVAL')
		--begin
		--	select	map.code
		--			,map.approval_name
		--			,map.reff_approval_category_code
		--			,map.reff_approval_category_name
		--			,case map.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_approval map;
		--end ;
		--else if (@p_table_name = 'MASTER_APPROVAL_DIMENSION')
		--begin
		--	select	mapd.id
		--			,mapd.approval_code
		--			,mapd.reff_dimension_code
		--			,mapd.reff_dimension_name
		--			,mapd.dimension_code
		--	from	dbo.master_approval_dimension mapd;
		--end ;
		--else if (@p_table_name = 'MASTER_DASHBOARD')
		--begin
		--	select	mdb.code
		--			,mdb.dashboard_name
		--			,mdb.dashboard_type
		--			,mdb.dashboard_grid
		--			,mdb.sp_name
		--			,case mdb.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--			,case mdb.IS_EDITABLE
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_editable'
		--	from	dbo.master_dashboard mdb;
		--end ;
		--else if (@p_table_name = 'MASTER_DASHBOARD_USER')
		--begin
		--	select	mdbu.id
		--			,mdbu.employee_code
		--			,mdbu.employee_name
		--			,mdbu.dashboard_code
		--			,mdbu.order_key
		--	from	dbo.master_dashboard_user mdbu;
		--end ;
		--else if (@p_table_name = 'MASTER_FAQ')
		--begin
		--	select	msf.id
		--			,msf.question
		--			,msf.answer
		--			,msf.filename
		--			,msf.paths
		--			,case msf.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_faq msf;
		--end ;
		--else if (@p_table_name = 'MASTER_ITEM')
		--begin
		--	select	msi.code
		--			,msi.company_code
		--			,msi.transaction_type
		--			,msi.item_group_code
		--			,msi.merk_code
		--			,msi.model_code
		--			,msi.type_code
		--			,msi.uom_code
		--			,msi.type_asset_code
		--			,msi.fa_category_code
		--			,msi.fa_category_name
		--			,msi.po_latest_price
		--			,msi.po_average_price
		--			,msi.description
		--			,msi.is_rent
		--			,case msi.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_item msi;
		--end ;
		--else if (@p_table_name = 'MASTER_ITEM_GROUP')
		--begin
		--	select	mig.code
		--			,mig.company_code
		--			,mig.description
		--			,mig.group_level
		--			,mig.parent_code
		--			,mig.transaction_type
		--			,case mig.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_item_group mig;
		--end ;
		--else if (@p_table_name = 'MASTER_ITEM_GROUP_GL')
		--begin
		--	select	migg.id
		--			,migg.company_code
		--			,migg.item_group_code
		--			,migg.currency_code
		--			,migg.gl_asset_code
		--			,migg.gl_asset_name
		--			,migg.gl_asset_rent_code
		--			,migg.gl_asset_rent_name
		--			,migg.gl_expend_code
		--			,migg.gl_inprogress_code
		--			,migg.category
		--	from	dbo.master_item_group_gl migg;
		--end ;
		--else if (@p_table_name = 'MASTER_LOCATION')
		--begin
		--	select	msl.code
		--			,msl.company_code
		--			,msl.branch_code
		--			,msl.branch_name
		--			,msl.description
		--			,msl.address
		--			,case msl.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_location msl;
		--end ;
		--else if (@p_table_name = 'MASTER_TASK_USER')
		--begin
		--	select	mtu.code
		--			,mtu.company_code
		--			,mtu.sys_code
		--			,mtu.description
		--			,case mtu.is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_task_user mtu;
		--end ;
		--else if (@p_table_name = 'MASTER_TASK_USER_DETAIL')
		--begin
		--	select	mtud.code
		--			,mtud.company_code
		--			,mtud.sys_code
		--			,mtud.main_task_user_code
		--			,mtud.role_group_code
		--	from	dbo.master_task_user_detail mtud;
		--end ;
		--else if (@p_table_name = 'MASTER_TRANSACTION_PARAMETER')
		--begin

		--	select	mstp.company_code
		--			,mstp.transaction_code
		--			,mstp.process_code
		--			,mstp.order_key
		--			,mstp.parameter_amount
		--			,mstp.is_calculate_by_system
		--			,mstp.is_transaction
		--			,mstp.is_amount_editable
		--			,mstp.is_discount_editable
		--			,mstp.gl_link_code
		--			,mstp.gl_link_name
		--			,mstp.discount_gl_link_code
		--			,mstp.discount_gl_link_name
		--			,mstp.maximum_disc_pct
		--			,mstp.maximum_disc_amount
		--			,mstp.is_journal
		--			,mstp.debet_or_credit
		--			,mstp.is_discount_jurnal
		--			,mstp.is_reduce_transaction
		--			,mstp.is_psak
		--			,mstp.psak_gl_link_code
		--			,mstp.psak_gl_link_name
		--	from	dbo.master_transaction_parameter mstp;
		--end ;
		--else if (@p_table_name = 'MASTER_VENDOR')
		--BEGIN    

		--	select	code
		--			,company_code
		--			,name
		--			,address
		--			,city_code
		--			,province_code
		--			,zipcode
		--			,vendor_type
		--			,id_type
		--			,id_no
		--			,tax_calculation_method
		--			,pkp_no
		--			,phone
		--			,fax
		--			,service_type_code
		--			,business_type_code
		--			,owner_name
		--			,owner_phone
		--			,contact_name
		--			,contact_position
		--			,contact_phone
		--			,website_address
		--			,email
		--			,npwp
		--			,siup_no
		--			,sku_no
		--			,tdp_no
		--			,remark
		--			,id_vendor
		--			,status
		--			,case is_active
		--				 when '1' then 'Yes'
		--				 else 'No'
		--			 end 'is_active'
		--	from	dbo.master_vendor;
		--end ;
		--else if (@p_table_name = 'MASTER_VENDOR_ITEM_GROUP')
		--begin
		--	select	id
		--			,vendor_code
		--			,transaction_type
		--			,group_code
		--			,description
		--	from	dbo.master_vendor_item_group;
		--end ;
		--else if (@p_table_name = 'MASTER_WAREHOUSE')
		--begin
		--	select	code
		--			,company_code
		--			,branch_code
		--			,branch_name
		--			,description
		--			,city_code
		--			,city_name
		--			,address
		--			,pic
		--			,case is_active
		--				 when '1' then 'yes'
		--				 else 'no'
		--			 end 'is_active'
		--	from	dbo.master_warehouse;
		--end ;

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
