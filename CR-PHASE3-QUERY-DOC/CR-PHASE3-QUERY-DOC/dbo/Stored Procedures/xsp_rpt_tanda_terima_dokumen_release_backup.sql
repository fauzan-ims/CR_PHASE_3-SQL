--create by jeffry 13/07/2023
CREATE PROCEDURE dbo.xsp_rpt_tanda_terima_dokumen_release_backup
(
	@p_user_id				nvarchar(max)
	,@p_mutation_no			nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	delete dbo.rpt_tanda_terima_dokumen_release
	where user_id = @p_user_id ;

	delete dbo.rpt_tanda_terima_dokumen_release_detail
	where user_id = @p_user_id ;

	declare	@msg				nvarchar(max)
			,@agreement_no		nvarchar(50)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@report_subtitle	nvarchar(250)
			,@client_name		nvarchar(250)
			,@merk_name			nvarchar(250)
			,@chassis_no		nvarchar(50)
			,@plat_no			nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@city_name			nvarchar(250)
			,@depthead			nvarchar(250)
			,@branch_code_dept	nvarchar(50)
			,@jabatan			nvarchar(250)
			,@nama_user			nvarchar(50)
			,@jabatan_user		nvarchar(250)

	begin try

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'TANDA TERIMA' ;
		set @report_subtitle = 'Dokumen - Release' ;

		select	@branch_code_dept = branch_code
		from	dbo.document_movement
		where	code = @p_mutation_no ;

		--select	@depthead = sbs.signer_name
		--from	ifinsys.dbo.sys_branch_signer sbs
		--where	branch_code			 = @branch_code_dept
		--		and signer_type_code = 'DEPTHEAD' ;

		select	@depthead = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code_dept ;

		select	@nama_user = name
				,@jabatan_user = sps.description
		from	ifinsys.dbo.sys_employee_main sem
				inner join ifinsys.dbo.sys_employee_position sep on sem.code			  = sep.emp_code
																	and sep.base_position = '1'
				left join ifinsys.dbo.sys_position sps on sps.code						  = sep.position_code
		where	sem.code = @p_user_id ;

		--select	@depthead = sbs.signer_name
		--from	ifinsys.dbo.sys_branch_signer sbs
		--where	branch_code			 = @branch_code_dept
		--		and signer_type_code = 'HEADOFBRANCH' ;

		insert into dbo.RPT_TANDA_TERIMA_DOKUMEN_RELEASE
		(
			user_id
			,report_company
			,report_title
			,report_sub_title
			,report_image
			,depthead
			,JABATAN_DEPT
			,agreement_no
			,client_name
			--,merk_name
			--,engine_no
			--,chassis_no
			--,plat_no
			,branch_code
			,branch_name
			,city_name
			,TANGGAL_SURAT_KUASA
			,NAMA_USER
			,TANGGAL_CETAK
			,pic_name
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select @p_user_id			
				,@report_company	
				,@report_title		
				,@report_subtitle	
				,@report_image	
				,isnull(@depthead,'')
				,@jabatan
				,case
					 when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no, '-')
					 else 'UNIT ' + ast.status
				 end
				--,ISNULL(ast.AGREEMENT_EXTERNAL_NO, ast.STATUS)
				,case
					 when ast.rental_status = 'IN USE' then ast.client_name
					 else 'UNIT ' + ast.status
				 end
				--,ast.client_name
				--,av.merk_name
				--,av.engine_no
				--,av.chassis_no
				--,av.plat_no
				,ast.branch_code
				,ast.branch_name
				,scy.description
				,dmt.movement_date
				,@nama_user
				,dbo.xfn_bulan_indonesia(@p_cre_date)
				,dmt.received_name
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address  
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address	
		from	document_movement_detail dmd
				inner join dbo.document_movement dmt on dmt.CODE = dmd.MOVEMENT_CODE
				left join dbo.document_main dm on (dmd.document_code				   = dm.code)
				left join dbo.fixed_asset_main dmfam on (dmfam.asset_no				   = dm.asset_no)
				left join dbo.document_pending dp on (dmd.document_pending_code		   = dp.code)
				left join dbo.fixed_asset_main dpfam on (dpfam.asset_no				   = dp.asset_no)
				left join ifinams.dbo.asset_vehicle av with (nolock) on (av.asset_code = dmfam.asset_no)
				left join ifinams.dbo.asset ast on ast.code						   = case
																							 when dmd.document_code is null then dp.asset_no
																							 else dm.asset_no
																						 end
				left join ifinsys.dbo.sys_branch sbr on sbr.code					   = dmt.branch_code
				left join ifinsys.dbo.sys_city scy on scy.code						   = sbr.city_code
		where	dmt.CODE = @p_mutation_no ;

		insert into dbo.rpt_tanda_terima_dokumen_release_detail
		(
			user_id
			,report_company
			,report_title
			,report_image
			,agreement_no
			,asset_code
			,document_name
			,document_no
			,merk_name
			,engine_no
			,chassis_no
			,plat_no
			,BPKB_NAME
			,reason
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,case
					 when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no, '-')
					 else 'UNIT ' + ast.status
				 end
				,dm.asset_no
				,dm.document_type
				,case
					 when dm.document_type = 'BPKB' then av.bpkb_no
					 WHEN dm.DOCUMENT_TYPE = 'SUPPLEMENTARY' THEN dd.doc_no
					 else '-'
				 end 'document_no'
				,isnull(av.merk_name,'') + case
					when av.merk_name is null then ''
					else ' ' 
				end + isnull(av.model_name,'') + case
					when av.model_name is null then ''
					else ' ' 
				end + isnull(av.type_item_name,'') + ' Th. '+ isnull(av.built_year,'-')
				,av.engine_no
				,av.chassis_no
				,av.plat_no
				,docdetail.doc_name
				,dmt.movement_remarks
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	document_movement_detail dmd
				inner join dbo.document_movement dmt on dmt.code					   = dmd.movement_code
				left join dbo.document_main dm on (dmd.document_code				   = dm.code)
				left join dbo.document_detail dd on (dd.DOCUMENT_CODE				   = dm.code)
				left join dbo.fixed_asset_main dmfam on (dmfam.asset_no				   = dm.asset_no)
				left join dbo.document_pending dp on (dmd.document_pending_code		   = dp.code)
				left join dbo.fixed_asset_main dpfam on (dpfam.asset_no				   = dp.asset_no)
				left join ifinams.dbo.asset_vehicle av with (nolock) on (av.asset_code = dmfam.asset_no)
				left join ifinams.dbo.asset ast on ast.code							   = case
																							 when dmd.document_code is null then dp.asset_no
																							 else dm.asset_no
																						 end
				left join ifinsys.dbo.sys_branch sbr on sbr.code					   = ast.branch_code
				left join ifinsys.dbo.sys_city scy on scy.code						   = sbr.city_code
				OUTER APPLY 
				(	
					select dd.doc_name
					from dbo.document_detail dd 
					left join dbo.document_main dma on dma.code = dd.document_code
					left join dbo.document_movement_detail dmde on dmde.document_code = dma.code
					left join dbo.document_movement dmt on dmt.code = dmde.movement_code
					where dmt.code = @p_mutation_no
					and dd.document_type = 'BPKB'
				)docdetail
		where	dmt.code = @p_mutation_no ;

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
END


