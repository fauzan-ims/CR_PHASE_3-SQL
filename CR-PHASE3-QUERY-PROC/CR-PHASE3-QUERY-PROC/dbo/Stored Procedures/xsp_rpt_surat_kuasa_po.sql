--created by, Bilal at 05/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_surat_kuasa_po
(
	@p_user_id		   nvarchar(max)
	,@p_po_no		   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
begin
	delete	dbo.rpt_surat_kuasa_po
	where	user_id = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_city			nvarchar(50)
			,@report_address		nvarchar(4000)
			,@report_area_phone		nvarchar(4)
			,@report_phone_no		nvarchar(15)
			,@report_fax			nvarchar(15)
			,@report_fax_area		nvarchar(4)
			,@report_address2		nvarchar(4000)
			,@report_address3		nvarchar(250)
			,@report_fax_area2		nvarchar(5)
			,@report_phone_area		nvarchar(5)
			,@report_fax_no			nvarchar(20)
			,@report_phone_no2		nvarchar(20)
			,@nama					nvarchar(250)
			,@jabatan				nvarchar(250)
			,@alamat				nvarchar(4000)
			,@nama_kuasa			nvarchar(250)
			,@alamat_kuasa			nvarchar(4000)
			,@merk					nvarchar(250)
			,@type					nvarchar(250)
			,@no_rangka				nvarchar(50)
			,@no_mesin				nvarchar(50)
			,@tahun					nvarchar(4)
			,@warna					nvarchar(50)
			,@atas_nama				nvarchar(250)
			,@alamat_stnk_or_bpkb	nvarchar(4000)
			,@kota					nvarchar(250)
			,@tanggal				datetime 
			,@category_type			nvarchar(50)
			,@branch_code			nvarchar(50) 
			,@branch_code_ho		nvarchar(50) ;

	begin try
    
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		-- select company addrss
		select	@report_address = value
		from	dbo.sys_global_param
		where	code = 'COMPADD' ;

		-- select company addrss
		select	@report_address2 = value
		from	dbo.sys_global_param
		where	code = 'COMPADD2' ;

		-- select company addrss
		select	@report_city = value
		from	dbo.sys_global_param
		where	code = 'COMCITY' ;

		---- select company area phone
		--select	@report_phone_no = value
		--from	dbo.sys_global_param
		--where	code = 'TELP' ;

		---- select company phone
		--select	@report_area_phone = value
		--from	dbo.sys_global_param
		--where	code = 'TELPAREA' ;

		---- select company fax
		--select	@report_fax = value
		--from	dbo.sys_global_param
		--where	code = 'FAX' ;

		---- select company fax area
		--select	@report_fax_area = value
		--from	dbo.sys_global_param
		--where	code = 'FAXAREA' ;

		select	@branch_code = po.BRANCH_CODE
		from	dbo.PURCHASE_ORDER po
		where	po.code = @p_po_no ;

		select	@report_address3    = sbr.address
				,@report_phone_area = sbr.area_phone_no
				,@report_phone_no2	= sbr.phone_no
				,@report_fax_area2	= sbr.area_fax_no
				,@report_fax_no		= sbr.fax_no
				,@kota				= scy.description
		from	ifinsys.dbo.sys_branch sbr  WITH (NOLOCK)
				left join ifinsys.dbo.sys_city scy WITH (NOLOCK) on scy.code = sbr.city_code
		where	sbr.code = @branch_code ;

		select	@branch_code_ho = value
		from	dbo.sys_global_param
		where	code = 'HO' ;

		select	@nama = sbs.signer_name
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs WITH (NOLOCK)
				inner join ifinsys.dbo.sys_employee_position sep WITH (NOLOCK) on sep.emp_code		  = sbs.emp_code
																	and sep.base_position = '1'
				inner join ifinsys.dbo.sys_position spo WITH (NOLOCK) on spo.code						  = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code	 = @branch_code ;

		set @report_title = N'SURAT KUASA' ;

		--select distinct	@category_type = mi.CATEGORY_TYPE
		--from	dbo.purchase_order								po
		--		left join dbo.purchase_order_detail				pod on (pod.po_code							  = po.code)
		--		left join dbo.purchase_order_detail_object_info podo on (podo.purchase_order_detail_id		  = pod.id and pod.po_code											 = po.code)
		--		left join ifinbam.dbo.master_vendor mv on (mv.code = po.supplier_code)
		--		left join ifinsys.dbo.sys_employee_main			sem on (sem.code							  = po.requestor_code)
		--		left join ifinsys.dbo.sys_employee_position		sep on (
		--																   sep.emp_code						  = sem.code
		--																   and sep.base_position			  = '1'
		--															   )
		--		left join ifinsys.dbo.sys_position				sp on (sp.code								  = sep.position_code)
		--		left join ifinbam.dbo.master_item				mi on (mi.code								  = pod.item_code)
		--		left join ifinbam.dbo.master_merk				mm on (mm.code								  = mi.merk_code)
		--		left join ifinbam.dbo.master_type				mt on (mt.code								  = mi.type_code)
		--		left join dbo.supplier_selection_detail ssd on (ssd.id											 = pod.supplier_selection_detail_id)
		--		left join dbo.quotation_review_detail qrd on (qrd.id											 = ssd.quotation_detail_id)
		--		left join dbo.procurement prc on (prc.code collate Latin1_General_CI_AS							 = qrd.reff_no)
		--		left join dbo.procurement prc2 on (prc2.code													 = ssd.reff_no)
		--		left join dbo.procurement_request pr on (pr.code												 = prc.procurement_request_code)
		--		left join dbo.procurement_request pr2 on (pr2.code												 = prc2.procurement_request_code)
		--		left join IFINOPL.dbo.APPLICATION_ASSET aps on (aps.ASSET_NO                                     = pr.ASSET_NO)
		--		left join IFINOPL.dbo.APPLICATION_ASSET_VEHICLE aam on (aam.ASSET_NO = aps.ASSET_NO)

		--where	po.code = @p_po_no;

		--if @category_type <> 'ASSET'
		--begin
	
		--	set @msg = 'Transaction doesnot contain asset.';
	
		--	raiserror(@msg, 16, -1) ;
	
		--end

		insert into dbo.rpt_surat_kuasa_po
		(
			user_id
			,po_no
			,report_company
			,report_title
			,report_image
			,report_area_phone
			,report_phone_no
			,report_fax_area
			,report_fax
			,report_address
			,nama
			,jabatan
			,alamat
			,nama_kuasa
			,alamat_kuasa
			,merk
			,type
			,no_rangka
			,no_mesin
			,tahun
			,warna
			,atas_nama
			,alamat_stnk_or_bpkb
			,kota
			,tanggal
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,@p_po_no
				,@report_company
				,@report_title
				,@report_image
				,@report_phone_area
				,@report_phone_no2
				,@report_fax_area2
				,@report_fax_no
				,@report_address3
				,@nama --po.requestor_name
				,@jabatan --sp.description
				,@report_address --sem.address
				,po.supplier_name
				,mv.address
				,mm.description
				,mt.description
				,podo.chassis_no
				,podo.engine_no
				,aps.asset_year
				,aam.COLOUR
				,case
					 when pri.bbn_name is not null then aps.client_bbn_name
					 else @report_company
				 end 'nama'
				,case
					 when pri.bbn_address is not null then aps.client_bbn_address
					 else @report_address2
				 end 'alamat'
				,@kota
				,dbo.xfn_get_system_date()
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.purchase_order po  WITH (NOLOCK)
				left join dbo.purchase_order_detail pod WITH (NOLOCK) on (pod.po_code									  = po.code)
				left join dbo.purchase_order_detail_object_info podo WITH (NOLOCK) on (
																			podo.purchase_order_detail_id = pod.id
																			and pod.po_code				  = po.code
																		)
				left join ifinbam.dbo.master_vendor mv  WITH (NOLOCK) on (mv.code										  = po.supplier_code)
				left join ifinsys.dbo.sys_employee_main sem WITH (NOLOCK) on (sem.code								  = po.requestor_code)
				left join ifinsys.dbo.sys_employee_position sep WITH (NOLOCK) on (
																	   sep.emp_code						  = sem.code
																	   and sep.base_position			  = '1'
																   )
				left join ifinsys.dbo.sys_position sp WITH (NOLOCK) on (sp.code										  = sep.position_code)
				left join ifinbam.dbo.master_item mi WITH (NOLOCK) on (mi.code										  = pod.item_code)
				left join ifinbam.dbo.master_merk mm WITH (NOLOCK) on (mm.code										  = mi.merk_code)
				left join ifinbam.dbo.master_type mt WITH (NOLOCK) on (mt.code										  = mi.type_code)
				left join dbo.supplier_selection_detail ssd WITH (NOLOCK) on (ssd.id									  = pod.supplier_selection_detail_id)
				left join dbo.quotation_review_detail qrd WITH (NOLOCK) on (qrd.id									  = ssd.quotation_detail_id)
				left join dbo.procurement prc WITH (NOLOCK) on (prc.code collate Latin1_General_CI_AS					  = qrd.reff_no)
				left join dbo.procurement prc2 WITH (NOLOCK) on (prc2.code											  = ssd.reff_no)
				left join dbo.procurement_request pr WITH (NOLOCK) on (pr.code										  = prc.procurement_request_code)
				left join dbo.procurement_request pr2 WITH (NOLOCK) on (pr2.code										  = prc2.procurement_request_code)
				left join ifinopl.dbo.application_asset aps WITH (NOLOCK) on (aps.asset_no							  = isnull(pr.asset_no, pr2.asset_no))
				left join ifinopl.dbo.application_asset_vehicle aam WITH (NOLOCK) on (aam.asset_no					  = aps.asset_no)
				left join dbo.procurement_request_item pri WITH (NOLOCK) on (pri.procurement_request_code				  = pr2.code and pod.item_code = pri.item_code)
		where	po.code				 = @p_po_no
				and mi.CATEGORY_TYPE = 'ASSET' ;

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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
