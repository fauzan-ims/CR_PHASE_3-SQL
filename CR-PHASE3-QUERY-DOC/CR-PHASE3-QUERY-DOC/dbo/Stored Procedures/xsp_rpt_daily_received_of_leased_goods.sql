--Created, Jeff at 05-09-2023
CREATE PROCEDURE dbo.xsp_rpt_daily_received_of_leased_goods
(
	@p_user_id			nvarchar(50)
	,@p_replacement_no	nvarchar(50) 
	,@p_cre_by			nvarchar(50)
	,@p_cre_date		datetime
	,@p_cre_ip_address	nvarchar(15)
    --,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
BEGIN

	delete dbo.rpt_daily_received_of_leased_goods
	where	user_id = @p_user_id;

	delete dbo.rpt_daily_received_of_leased_goods_detail
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_title_receive			nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@delivery_or_collect			nvarchar(50)	
			,@unit_condition				nvarchar(50)	
			,@status_pengiriman				nvarchar(50)	
			,@agreement_no					nvarchar(50)	
			,@lessee						nvarchar(50)	
			,@lessee_address				nvarchar(4000)	
			,@pic_lessee					nvarchar(50)	
			,@lessee_contact_number			nvarchar(50)	
			,@description_unit_utama		nvarchar(50)	
			,@year							int				
			,@plat_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@color							nvarchar(50)	
			,@delivery_date					datetime		
			,@bast_date						datetime		
			,@upload_bast_date				datetime	
			,@nama							nvarchar(50)
			,@jumlah_agreement_no			int
			,@total_unit					int
			,@jabatan						nvarchar(250)

	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	CODE = 'COMP2' ;

		select	@branch_code = branch_code
		from	dbo.REPLACEMENT
		where	code = @p_replacement_no ;

		set	@report_title = 'Daily Received of Leased Goods Documents';

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		insert into dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS
		(
			USER_ID
			,REPORT_COMPANY
			,REPORT_IMAGE
			,REPORT_TITLE
			,DOC_CODE
			,DOC_TYPE
			,PERIOD_START
			,PERIOD_END
			,PRODUCT
			,PRODUCT_TYPE
			,BRANCH_NAME
			,INPUT_BY
			,CHECKED_BY
			,ACKNOWLEDGE_BY
			,JABATAN_ACKNOWLEDGE
			,NAMA_USER
			,CRE_BY
			,CRE_DATE
			,CRE_IP_ADDRESS
			,MOD_BY
			,MOD_DATE
			,MOD_IP_ADDRESS
		)
		select	@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,rpl.code
				,''
				,rpl.replacement_date
				,rpl.replacement_date
				,'OPERATING LEASE'
				,sbs.DESCRIPTION
				,sbh.NAME
				,nama.name
				,null
				,@nama
				,@jabatan
				,nama.name
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
		from	dbo.replacement rpl
				inner join dbo.replacement_detail rde on rde.replacement_code = rpl.code
				left join ifinams.dbo.asset ast on ast.code = rde.asset_no
				left join ifinsys.dbo.sys_branch sbh on (sbh.code = rpl.branch_code)
				left join ifinams.dbo.sys_general_subcode sbs on (sbs.code = ast.type_code)
				outer apply
					(
						select	sem2.name 'name'
						from	ifinsys.dbo.sys_employee_main sem2
						where	sem2.code = @p_user_id
					) nama
		where	rpl.CODE = @p_replacement_no ;

		insert into dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS_DETAIL
		(
			user_id
			,doc_code
			,agreement_no
			,product_type
			,customer_name
			,brand
			,type_model
			,register_name
			,bpkb_no
			,faktur
			,nik
			,form_a
			,sph_no
			,kwitansi_no
			,supplier
			,chasis_no
			,engine_no
			,year
			,input_date
			,input_by
		)
		select	@p_user_id
				,rpl.code
				,case
					 when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no, '-')
					 else 'UNIT ' + ast.status
				 end
				,sbs.description
				,case
					 when ast.rental_status = 'IN USE' then ast.client_name
					 else 'UNIT ' + ast.status
				 end
				,isnull(avi.merk_name,mme.description)
				,ast.item_name
				,rde.bpkb_name--ast.client_name
				,rde.bpkb_no
				,null
				,null
				,null
				,null
				,null
				,fam.vendor_name
				,fam.reff_no_2
				,fam.reff_no_3
				,isnull(avi.built_year,fam.asset_year)
				,rpl.replacement_date
				,nama.name
		from	dbo.replacement rpl
				inner join dbo.replacement_detail rde on rde.replacement_code = rpl.code
				left join ifinams.dbo.asset ast on ast.code = rde.asset_no
				left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
				left join ifinams.dbo.sys_general_subcode sbs on (sbs.code = ast.type_code)
				left join ifinopl.dbo.agreement_main ama on ama.agreement_no = ast.agreement_no
				left join ifinbam.dbo.master_item mit on mit.code=ast.item_code
				left join ifinbam.dbo.master_merk mme on mme.code=mit.merk_code
				left join dbo.fixed_asset_main fam on (fam.asset_no = rde.asset_no)
				outer apply
					(
						select	sem2.name 'name'
						from	ifinsys.dbo.sys_employee_main sem2
						where	sem2.code = rpl.cre_by
					) nama
		where	rde.replacement_code = @p_replacement_no 
				and rde.type='REPLACE';

		--insert into dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS
		--(
		--	user_id
		--	,report_company
		--	,report_image
		--	,report_title
		--	,doc_code
		--	,doc_type
		--	,PERIOD_START
		--	,period_end
		--	,product
		--	,product_type
		--	,branch_name
		--	,input_by
		--	,checked_by
		--	,acknowledge_by
		--	,jabatan_acknowledge
		--	,nama_user
		--	,cre_by
		--	,cre_date
		--	,cre_ip_address
		--	,mod_by
		--	,mod_date
		--	,mod_ip_address
		--)
		--select	@p_user_id
		--		,@report_company
		--		,@report_image
		--		,@report_title
		--		,dmt.code
		--		,dm.document_type
		--		,dmt.RECEIVE_DATE
		--		,dmt.RECEIVE_DATE
		--		,'OPERATING LEASE'
		--		,sbs.description
		--		,sbh.name
		--		,nama.name
		--		,null
		--		,@nama
		--		,@jabatan
		--		,nama.name
		--		,@p_cre_by
		--		,@p_cre_date
		--		,@p_cre_ip_address
		--		,@p_cre_by
		--		,@p_cre_date
		--		,@p_cre_ip_address
		--from	dbo.document_main dm
		--		left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
		--		left join dbo.document_movement dmt on dmt.code = dmd.movement_code
		--		left join ifinams.dbo.asset ast on ast.code = dm.asset_no
		--		left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
		--		left join ifinsys.dbo.sys_branch sbh on (sbh.code = dmt.BRANCH_CODE)
		--		left join ifinams.dbo.SYS_GENERAL_subcode sbs on (sbs.code = ast.type_code)
		--		outer apply
		--(
		--	select	sem2.name 'name'
		--	from	ifinsys.dbo.sys_employee_main sem2
		--	where	sem2.code = dmt.cre_by
		--) nama
		--where	dmt.code = @p_mutation_no ;

		--insert into dbo.RPT_DAILY_RECEIVED_OF_LEASED_GOODS_DETAIL
		--(
		--	user_id
		--	,doc_code
		--	,agreement_no
		--	,product_type
		--	,customer_name
		--	,brand
		--	,type_model
		--	,register_name
		--	,bpkb_no
		--	,faktur
		--	,nik
		--	,form_a
		--	,sph_no
		--	,kwitansi_no
		--	,supplier
		--	,chasis_no
		--	,engine_no
		--	,year
		--	,input_date
		--	,input_by
		--)
		--select	@p_user_id
		--		,dmt.code
		--		,case
		--			 when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no, '-')
		--			 else 'UNIT ' + ast.status
		--		 end
		--		,sbs.description
		--		,case
		--			 when ast.rental_status = 'IN USE' then ast.client_name
		--			 else 'UNIT ' + ast.status
		--		 end
		--		,ast.merk_name
		--		,ast.item_name
		--		,ast.client_name
		--		,null
		--		,null
		--		,null
		--		,null
		--		,null
		--		,null
		--		,ast.vendor_name
		--		,avi.chassis_no
		--		,avi.engine_no
		--		,avi.built_year
		--		,dmt.receive_date
		--		,nama.name
		--from	dbo.document_main dm
		--		left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
		--		left join dbo.document_movement dmt on dmt.code = dmd.movement_code
		--		left join ifinams.dbo.asset ast on ast.code = dm.asset_no
		--		left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
		--		left join ifinams.dbo.SYS_GENERAL_subcode sbs on (sbs.code = ast.type_code)
		--		left join ifinopl.dbo.agreement_main ama on ama.agreement_no = ast.agreement_no
		--		left join dbo.fixed_asset_main fam on (fam.asset_no=dm.asset_no)
		--		outer apply (
		--			select	sem2.name 'name'
		--			from	ifinsys.dbo.sys_employee_main sem2
		--			where	sem2.code = dmt.cre_by 
		--		)nama
		--where	dmt.code = @p_mutation_no ;

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

