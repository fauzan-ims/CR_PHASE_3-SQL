--Created, Jeff at 11-09-2023
CREATE PROCEDURE dbo.xsp_rpt_received_additional_collateral
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_from_date		datetime
	,@p_to_date			datetime
	,@p_cre_by			nvarchar(50)
	,@p_cre_date		datetime
	,@p_cre_ip_address	nvarchar(15)
    --,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
BEGIN

	delete dbo.rpt_received_additional_collateral
	where	user_id = @p_user_id;

	delete dbo.rpt_received_additional_collateral_detail
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

		select	@branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

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

		insert into dbo.rpt_received_additional_collateral
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
		SELECT	@p_user_id
				,@report_company
				,@report_image
				,CASE
					WHEN dmt.movement_type='SEND' THEN @report_title
					WHEN dmt.movement_type='RECEIVED' THEN @report_title_receive
				END
				,dmt.code
				,dmt.movement_type
				,'Operating Lease'
				,@p_from_date
				,@p_to_date
				,sbh.name
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
				LEFT JOIN dbo.document_movement_detail dmd ON dmd.document_code = dm.code
				LEFT JOIN dbo.document_movement dmt ON dmt.code = dmd.movement_code
				LEFT JOIN dbo.document_movement_replacement dmr ON dmr.movement_code = dmt.code
				LEFT JOIN ifinams.dbo.asset ast ON ast.code = dm.asset_no
				LEFT JOIN dbo.fixed_asset_main fam ON (fam.asset_no = dm.asset_no)
				LEFT JOIN ifinsys.dbo.sys_branch sbh ON (sbh.code = dmt.BRANCH_CODE)
				OUTER APPLY
					(
						SELECT	sem2.name 'name'
						from	ifinsys.dbo.sys_employee_main sem2
						where	sem2.code = @p_user_id--dmt.cre_by
					) nama
		where	dmt.movement_status = 'ON TRANSIT'
				--and dmt.movement_type = 'SEND'
				and dmt.movement_location = 'BORROW CLIENT'
				and cast(dmt.movement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
				and dm.branch_code                      = case @p_branch_code
																			when 'ALL' then dm.branch_code
																			else @p_branch_code
																		 end  ;

		insert into dbo.rpt_received_additional_collateral_detail
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
		select	 distinct @p_user_id
						,dmt.code
						,case
							 when ast.rental_status = 'IN USE' then ast.agreement_external_no
							 else 'UNIT ' + ast.status
						 end
						,case
							 when ast.rental_status = 'IN USE' then ast.client_name
							 else 'UNIT ' + ast.status
						 end
						,dmr.document_name
						,dmr.document_no--fam.doc_asset_no
						,dmr.remarks
						,dmt.movement_date--dmt.receive_date
						,nama.name
				from	dbo.document_main dm
						left join dbo.document_movement_detail dmd on dmd.document_code = dm.code
						left join dbo.document_movement dmt on dmt.code = dmd.movement_code
						left join dbo.document_movement_replacement dmr on dmr.movement_code = dmt.code
						left join ifinams.dbo.asset ast on ast.code = dm.asset_no
						left join ifinopl.dbo.agreement_main ama on ama.agreement_no = ast.agreement_no
						left join  dbo.fixed_asset_main fam on (fam.asset_no=dm.asset_no)
						outer apply (
							select	sem2.name 'name'
							from	ifinsys.dbo.sys_employee_main sem2
							where	sem2.code = dmt.cre_by 
						)nama
				where	dmt.movement_status = 'ON TRANSIT'
						--and dmt.movement_type = 'SEND'
						and dmt.movement_location = 'BORROW CLIENT'
						and cast(dmt.movement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						and dm.branch_code                      = case @p_branch_code
																					when 'ALL' then dm.branch_code
																					else @p_branch_code
																				 end  ;

		--select		@jumlah_agreement_no = count(agreement_no)
		--from		dbo.rpt_received_additional_collateral_detail
		--group by	agreement_no ;

		select	@jumlah_agreement_no = count(distinct agreement_no)
		from	dbo.rpt_received_additional_collateral_detail
		where	user_id = @p_user_id ;

		select	@total_unit = count(user_id)
		from	dbo.rpt_received_additional_collateral_detail
		where	user_id = @p_user_id ;

		--select		@total_unit = count(user_id)
		--from		dbo.rpt_received_additional_collateral_detail
		--group by	agreement_no ;	

		update	dbo.rpt_received_additional_collateral
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

