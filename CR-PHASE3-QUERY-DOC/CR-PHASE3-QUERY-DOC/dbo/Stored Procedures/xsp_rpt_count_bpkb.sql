--Created, Jeff at 11-09-2023
CREATE PROCEDURE dbo.xsp_rpt_count_bpkb
(
	@p_user_id			NVARCHAR(50)
	,@p_branch_code		NVARCHAR(50)
	,@p_as_of_date		DATETIME
	,@p_cre_by			NVARCHAR(50)
	,@p_cre_date		DATETIME
	,@p_cre_ip_address	NVARCHAR(15)
    --,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
AS
BEGIN

	delete dbo.rpt_count_bpkb
	where	user_id = @p_user_id;

	delete dbo.rpt_count_bpkb_detail
	where	user_id = @p_user_id;

	delete dbo.rpt_count_bpkb_summary
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			--,@report_title_receive			nvarchar(250)
			,@report_image					nvarchar(250)
			,@branch_code					nvarchar(50)
			--,@branch_name					nvarchar(50)
			--,@delivery_or_collect			nvarchar(50)	
			--,@unit_condition				nvarchar(50)	
			--,@status_pengiriman				nvarchar(50)	
			--,@agreement_no					nvarchar(50)	
			--,@lessee						nvarchar(50)	
			--,@lessee_address				nvarchar(4000)	
			--,@pic_lessee					nvarchar(50)	
			--,@lessee_contact_number			nvarchar(50)	
			--,@description_unit_utama		nvarchar(50)	
			--,@year							int				
			--,@plat_no						nvarchar(50)	
			--,@chassis_no					nvarchar(50)	
			--,@engine_no						nvarchar(50)	
			--,@color							nvarchar(50)	
			--,@delivery_date					datetime		
			--,@bast_date						datetime		
			--,@upload_bast_date				datetime	
			,@nama							nvarchar(50)
			--,@jumlah_agreement_no			int
			--,@total_unit					int
			,@jabatan						nvarchar(250)

	--declare @rpt_count_bpkb_detail as table
	--(
	--	user_id			   nvarchar(50)
	--	,agreement_no	   nvarchar(50)
	--	,document_no	   nvarchar(50)
	--	,customer		   nvarchar(250)
	--	,asset_name		   nvarchar(250)
	--	,asset_type		   nvarchar(250)
	--	,asset_no		   nvarchar(50)
	--	,chassis_no		   nvarchar(50)
	--	,engine_no		   nvarchar(50)
	--	,year			   nvarchar(4)
	--	,trx_date		   datetime
	--	,registered_name   nvarchar(250)
	--	,bpkb_no		   nvarchar(250)
	--	,doc_type		   nvarchar(250)
	--	,plat_no		   nvarchar(250)
	--	,agreement_status  nvarchar(250)
	--	,document_location nvarchar(250)
	--	,outlet			   nvarchar(250)
	--	,branch_name	   nvarchar(250)
	--	,product		   nvarchar(250)
	--) ;

	BEGIN TRY
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

		set		@report_title = 'LIST OF EXISTING LEASE GOOD DOCUMENTS (ALL PRODUCT TYPES)';

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs with (nolock)
		inner join ifinsys.dbo.sys_employee_position sep with (nolock) on  sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo with (nolock) on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		select	@report_image = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'IMGDSF' ;

		INSERT INTO dbo.rpt_count_bpkb
		(
			user_id
			,report_company
			,report_image
			,report_title
			,doc_code
			,doc_type
			,product
			,as_of_date
			,branch_name
			,asset_type
			,input_by
			,checked_by
			,acknowledge_by
			,jabatan_acknowledge
			,total_agreement
			,total_unit
			,nama_user
			,cre_by
			,cre_date
			,cre_ip_address
			,mod_by
			,mod_date
			,mod_ip_address
		)
		SELECT	@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,dm.code
				,dm.document_type
				,'OPERATING LEASE'
				,@p_as_of_date
				,asset.branch_name
				,asset.category_name
				,nama.name
				,NULL
				,@nama
				,@jabatan
				,NULL
				,NULL
				,nama.name
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
		FROM	dbo.document_main dm
				--left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
				--left join dbo.document_movement dmt on dmt.code = dmd.movement_code
				OUTER APPLY (SELECT ass.branch_code, ass.branch_name, ass.category_name FROM ifinams.dbo.asset ass WHERE ass.code = dm.asset_no) asset
				--inner join ifinams.dbo.asset ast with (nolock) on ast.code = dm.asset_no
				--inner join dbo.fixed_asset_main fam with (nolock) on (fam.asset_no = dm.asset_no)
				--inner join ifinsys.dbo.sys_branch sbh on (sbh.code = ast.branch_code)
				--inner join ifinams.dbo.sys_general_subcode sgsb on sgsb.code = ast.type_code
				--outer apply
				--	(
				--		select	code
				--				,branch_code
				--				,type_code
				--		from	ifinams.dbo.asset
				--		where	code = dm.asset_no
				--	)ast
				OUTER APPLY
					(
						SELECT	sem2.name 'name'
						FROM	ifinsys.dbo.sys_employee_main sem2
						WHERE	sem2.code = @p_user_id
					) nama
				--outer apply
				--	(
				--		select	name
				--		from	ifinsys.dbo.sys_branch
				--		where	code = ast.branch_code
				--	)sbh
				--outer apply(
				--	select	code
				--			,isnull(description,'-') 'description'
				--	from	ifinams.dbo.sys_general_subcode
				--	where	code = ast.type_code
				--)sgsb
		WHERE	dm.document_status = 'ON HAND'
		AND		dm.document_type='BPKB'
		and		isnull(cast(dm.first_receive_date as date),dm.cre_date)		<= cast(@p_as_of_date as date) --(sepria: 27052024) untuk data dari migrasi ada yang first_receive_date nya NULL, jadi di set Cre_date 
		AND		asset.branch_code                      = CASE @p_branch_code
				                                                        WHEN 'ALL' THEN asset.branch_code
				                                                        ELSE @p_branch_code
                                                                 END  ;

		INSERT INTO rpt_count_bpkb_detail
		(
			user_id
			,agreement_no
			,document_no
			,customer
			,asset_no
			,asset_type
			,asset_name
			,chassis_no
			,engine_no
			,year
			,trx_date
			,registered_name
			,bpkb_no
			,doc_type
			,plat_no
			,agreement_status
			,document_location
			,outlet
			,branch_name
			,product
		)
		SELECT	DISTINCT @p_user_id
				,CASE
					WHEN ast.rental_status='IN USE' THEN ISNULL(ast.agreement_external_no,'-')
					ELSE 'UNIT '+ast.status
				END
				,dm.code
				,CASE
					WHEN ast.rental_status='IN USE' THEN ISNULL(ast.client_name,'-')
					ELSE 'UNIT '+ast.status
				END
				,ast.code
				,ast.category_name
				--,sgsb.description
				,dm.asset_name
				,avi.chassis_no
				,avi.engine_no
				,avi.built_year
				,CASE
					WHEN ast.rental_status='IN USE' THEN ama.agreement_date
					else dm.first_receive_date
				end
				,isnull(avi.stnk_name,bpkb_name.bpkb_name)
				,isnull(bpkb_name.bpkb_no,avi.bpkb_no)
				,case
					when ast.type_code='VHCL' then 'V01'
					when ast.type_code='HE' then 'H01'
					else '-'
				end
				,isnull(avi.plat_no,avi.PLAT_NO)
				,case
					when ast.rental_status='IN USE' then isnull(ama.agreement_status,'') + ' ' + isnull(ama.agreement_sub_status,'')
					else ''
				end
				,isnull(dm.branch_name,'-') + ' / ' + isnull(dm.locker_position,'-') + ' / ' + case 
					when dm.locker_position = 'IN LOCKER' then isnull(ml.locker_name,'-') + ' - ' + isnull(md.drawer_name,'-') + ' - ' + isnull(mr.row_name,'-')
					when dm.locker_position = 'OUT LOCKER' then isnull(ml2.locker_name,'-') + ' - ' + '- ' + '- '--isnull(md2.drawer_name,'-') + ' - ' + isnull(mr2.row_name,'-')
				 end 'locker_location'
				,ast.branch_name--scy.description
				,ast.branch_name
				,'OPERATING LEASE'
		from	dbo.document_main dm
		outer apply (select ass.code, ass.branch_code, ass.branch_name, ass.type_code, ass.rental_status, ass.agreement_external_no, ass.client_name, ass.category_name, ass.agreement_no, ass.status from ifinams.dbo.asset ass where ass.code = dm.asset_no and ass.status <> 'CANCEL') ast
		--outer apply (SELECT asv.BPKB_NO, asv.STNK_NAME, asv.PLAT_NO, asv.BUILT_YEAR, asv.ENGINE_NO, asv.CHASSIS_NO FROM ifinams.dbo.ASSET_VEHICLE asv where asv.ASSET_CODE = ast.CODE) avi
		outer apply (select asv.bpkb_no, asv.stnk_name, asv.plat_no, asv.built_year, asv.engine_no, asv.chassis_no from ifinams.dbo.asset_vehicle asv where asv.asset_code = ast.code and asv.asset_code in (select ast.code from ifinams.dbo.asset ast where ast.code = ast.code and ast.status <> 'CANCEL')) avi
				outer apply (
					select	locker_name
					from	dbo.master_locker
					where	code = dm.locker_code
				)ml
				outer apply (
					select	locker_name
					from	dbo.master_locker
					where	code = dm.last_locker_code
				)ml2
				outer apply (
					select	drawer_name
					from	dbo.master_drawer
					where	code = dm.drawer_code
				)md
				outer apply (
					select	row_name
					from	dbo.master_row
					where	code = dm.row_code
				)mr
				outer apply (
					select	dd.doc_name 'bpkb_name',dd.doc_no'BPKB_NO'
					from	dbo.document_detail dd
					where	dd.document_code	 = dm.code
							and dd.document_type = 'BPKB'
				)bpkb_name
				outer apply(
					select	agreement_no
							,agreement_external_no
							,agreement_status
							,agreement_sub_status
							,agreement_date
					from	ifinopl.dbo.agreement_main
					where	agreement_no = ast.agreement_no
				)ama
		where	dm.document_status = 'ON HAND'
		and		dm.document_type='BPKB'
		and		isnull(cast(dm.first_receive_date as date),dm.cre_date)		<= cast(@p_as_of_date as date) --(sepria: 27052024) untuk data dari migrasi ada yang first_receive_date nya NULL, jadi di set Cre_date 
		and		ast.branch_code							= case @p_branch_code
                                                                    when 'ALL' then ast.branch_code
                                                                    else @p_branch_code
                                                                 end  ;


		insert into dbo.rpt_count_bpkb_summary
		(
			user_id
			--,outlet
			,product
			,branch
			,total_agreement
			,total_unit
		)
		select	@p_user_id
				--,outlet
				,asset_type
				,branch_name
				,count(distinct agreement_no)
				,count(distinct asset_no)
		from	dbo.rpt_count_bpkb_detail
		where	user_id = @p_user_id 
		group by branch_name,product,asset_type;

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

