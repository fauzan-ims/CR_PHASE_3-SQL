--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_tanda_terima_jaminan_backup122024
(
	@p_user_id			nvarchar(50)
	,@p_mutation_no		nvarchar(50) 
	,@p_cre_by			nvarchar(50)
	,@p_cre_date		datetime
	,@p_cre_ip_address	nvarchar(15)
    --,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
BEGIN

	delete dbo.rpt_tanda_terima_jaminan
	where	user_id = @p_user_id;

	delete dbo.rpt_tanda_terima_jaminan_detail
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
			,@nama_user						nvarchar(50)

	begin try
	
		select	@report_company = value
		from	dbo.sys_global_param
		where	CODE = 'COMP2' ;

		select	@branch_code = branch_code
		from	dbo.document_movement
		where	code = @p_mutation_no ;

		set	@report_title = 'Daily Receiving of Additional Collateral';
		set @report_title_receive = 'Daily Receiving of Borrowing Document';

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

		select	@nama_user = name
		from	ifinsys.dbo.sys_employee_main
		where	code = @p_user_id ;

		insert into dbo.RPT_TANDA_TERIMA_JAMINAN
		(
			USER_ID
			,REPORT_COMPANY
			,REPORT_IMAGE
			,REPORT_TITLE
			,DOC_CODE
			,DOC_TYPE
			,PRODUCT
			,PERIOD_START
			,PERIOD_END
			,BRANCH_NAME
			,INPUT_BY
			,CHECKED_BY
			,ACKNOWLEDGE_BY
			,JABATAN_ACKNOWLEDGE
			,TOTAL_AGREEMENT
			,TOTAL_UNIT
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
				,case
					when dmt.movement_type='SEND' then @report_title
					when dmt.movement_type='RECEIVED' then @report_title_receive
				end
				,dmt.code
				,dmt.movement_type
				,'Operating Lease'
				,dmt.movement_date
				,dmt.movement_date
				,sbh.name
				,nama.name
				,null
				,@nama
				,@jabatan
				,null
				,null
				,@nama_user
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
				,@p_cre_by
				,@p_cre_date
				,@p_cre_ip_address
		from	dbo.document_main dm
				left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
				left join dbo.document_movement dmt on dmt.code = dmd.movement_code
				left join ifinams.dbo.asset ast on ast.code = dm.asset_no
				left join dbo.fixed_asset_main fam on (fam.asset_no = dm.asset_no)
				left join ifinsys.dbo.sys_branch sbh on (sbh.code = dmt.BRANCH_CODE)
				outer apply
		(
			select	sem2.name 'name'
			from	ifinsys.dbo.sys_employee_main sem2
			where	sem2.code = dmt.cre_by
		) nama
		where	dmt.code = @p_mutation_no ;

		insert into dbo.rpt_tanda_terima_jaminan_detail
		(
			user_id
			,doc_code
			,agreement_no
			,customer_name
			,document_name
			,document_no
			,description
			,receiving_date
			,input_by
		)
		select	distinct @p_user_id
				,dmt.code
				,case 
					when ast.rental_status='IN USE' then ast.agreement_external_no
					else 'Unit ' + ast.status
				end
				,case 
					when ast.rental_status='IN USE' then ast.client_name
					else 'Unit ' + ast.status
				end
				,dmr.document_name--dm.document_type
				,dmr.document_no--fam.doc_asset_no
				,dmr.remarks--dmd.remarks
				,dbo.xfn_get_system_date()
				,nama.name
		from	dbo.document_main dm
				left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
				left join dbo.document_movement dmt on dmt.code = dmd.movement_code
				left join ifinams.dbo.asset ast on ast.code = dm.asset_no
				left join ifinopl.dbo.agreement_main ama on ama.agreement_no = ast.agreement_no
				left join dbo.DOCUMENT_MOVEMENT_REPLACEMENT dmr on dmr.MOVEMENT_CODE = dmt.CODE
				left join  dbo.fixed_asset_main fam on (fam.asset_no=dm.asset_no)
				outer apply (
					select	sem2.name 'name'
					from	ifinsys.dbo.sys_employee_main sem2
					where	sem2.code = dmt.cre_by 
				)nama
		where	dmt.code = @p_mutation_no ;

		--select		@jumlah_agreement_no = count(agreement_no)
		--from		dbo.rpt_tanda_terima_jaminan_detail
		--group by	agreement_no ;

		--select		@jumlah_agreement_no = count(*)
		--from
		--			(
		--				select		count(agreement_no) as GroupAmount
		--				from		rpt_tanda_terima_jaminan_detail
		--				group by	agreement_no
		--			) countjumlah
		--group by	GroupAmount ;

		--select		@total_unit = count(user_id)
		--from		dbo.rpt_tanda_terima_jaminan_detail
		--group by	agreement_no ;	

		--update	dbo.rpt_tanda_terima_jaminan
		--set		total_agreement = @jumlah_agreement_no
		--		,total_unit = @total_unit
		--where	user_id = @p_user_id ;

		select	@jumlah_agreement_no = count(distinct agreement_no)
				,@total_unit = count(user_id)
		from	dbo.rpt_tanda_terima_jaminan_detail
		where	user_id = @p_user_id ;

		update	dbo.rpt_tanda_terima_jaminan
		set		total_agreement = @jumlah_agreement_no
				,total_unit = @total_unit
		where	user_id = @p_user_id ;

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

