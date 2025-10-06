--create by jeffry 13/07/2023
CREATE PROCEDURE [dbo].[xsp_rpt_surat_persetujuan_pengeluaran_dokumen]
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
	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@agreement_date			nvarchar(50)
			,@value_date				nvarchar(50)
			,@leese_consumer_name		nvarchar(250)
			,@leese_consumer_no			nvarchar(50)
			,@type						nvarchar(50)
			,@reason					nvarchar(50)
			,@document_quantity			bigint
			,@document_name				nvarchar(50)
			,@branch_code_dept			nvarchar(250)
			,@headofbranch				nvarchar(250)
			,@depthead					nvarchar(250) 
			,@document_type				nvarchar(50)
			,@jabatan_head				nvarchar(50)
			,@jabatan_user				nvarchar(50)
			,@nama_user					nvarchar(50)
			,@object					nvarchar(250)
			,@objects					NVARCHAR(250)
			,@bpkb_no					nvarchar(250)
			,@suplementary_no			nvarchar(250);
	
	delete dbo.rpt_surat_persetujuan_pengeluaran_dokumen
	where user_id = @p_user_id ;

	delete dbo.rpt_surat_persetujuan_pengeluaran_dokumen_detail
	where user_id = @p_user_id ;

	select	@branch_code_dept = branch_code
	from	dbo.document_movement
	where	code = @p_mutation_no ;

	select	@depthead = sbs.signer_name
	from	ifinsys.dbo.sys_branch_signer sbs
	where	branch_code			 = @branch_code_dept
			and signer_type_code = 'DEPTHEAD' ;

	select	@depthead = sem.name
			,@jabatan_head = spo.description
	from	ifinsys.dbo.sys_branch_signer sbs
			inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code		  = sbs.emp_code
																and sep.base_position = '1'
			inner join ifinsys.dbo.sys_position spo on spo.code						  = sep.position_code
			inner join ifinsys.dbo.sys_employee_main sem on sem.code				  = sbs.emp_code
	where	sbs.signer_type_code = 'HEADOPR'
			and sbs.branch_code	 = @branch_code_dept ;

	select	@jabatan_user = spo.description
			,@nama_user = sem.name
	from	ifinsys.dbo.sys_employee_position sep
			inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
			inner join ifinsys.dbo.sys_employee_main sem on sem.code=sep.emp_code
	where	sep.emp_code		  = @p_user_id
			and sep.base_position = '1' ;

	select	@headofbranch = sbs.signer_name
	from	ifinsys.dbo.sys_branch_signer sbs
	where	branch_code			 = @branch_code_dept
			and signer_type_code = 'HOB' ;

	begin try

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set	@report_title = 'SURAT PERSETUJUAN PENGELUARAN DOKUMEN' ;

		insert into dbo.rpt_surat_persetujuan_pengeluaran_dokumen
		(
			user_id
			,report_company
			,report_title
			,report_image
			,headofbranch
			,depthead
			,city
			,agreement_no
			,agreement_date
			,value_date
			,leesee_consumer_name
			,leesee_consumer_no
			,type
			,reason
			,document_quantity
			,document_name
			,JANJI_TANGGAL_KEMBALI
			,JABATAN_USER
			,JABATAN_DEPT
			,TANGGAL_PRINT
			,NAMA_USER
			,object_name
			,object_suplementary
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	DISTINCT 
		@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@headofbranch
				,@depthead
				,scy.description
				,case
					 when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no, '-')
					 else 'UNIT ' + ast.status
				 end
				,case
					 when ast.rental_status = 'IN USE' then dbo.xfn_bulan_indonesia(ami.agreement_date)
					 else '-'
				 end
				,case
					 when ast.rental_status = 'IN USE' then dbo.xfn_bulan_indonesia(isnull(asat.handover_bast_date,ami.agreement_date))
					 else '-'
				 end
				,case
					 when ast.rental_status = 'IN USE' then ast.client_name
					 else 'UNIT ' + ast.status
				 end
				,ami.client_no
				,case dmt.movement_location
					 when 'BRANCH' then 'SEMENTARA'
					 when 'DEPARTMENT' then 'SEMENTARA'
					 when 'THIRD PARTY' then 'SEMENTARA'
					 when 'CLIENT' then 'PERMANEN'
					 when 'BORROW CLIENT' then 'SEMENTARA'
					 else '-'
				 end 'location'
				,case dmt.movement_location
					 when 'BRANCH' then 'BORROW'
					 when 'DEPARTMENT' then 'BORROW'
					 when 'THIRD PARTY' then 'BORROW'
					 when 'CLIENT' then case
											when sa.sell_type='CLAIM' then 'CLAIM TLO'
											--when sa.sell_type='COP' then 'SELLING ASSET'
											--when sa.sell_type='AUCTION' then 'SELLING ASSET'
											--when sa.sell_type='MOCIL'  then 'SELLING ASSET'
											else 'SELLING ASSET'
										end
					 when 'BORROW CLIENT' then 'BORROW'
					 else '-'
				 end 'location'
				,null --tes.jumlah
				,dm.document_type
				,dbo.xfn_bulan_indonesia(dmt.estimate_return_date)
				,@jabatan_head
				,@jabatan_user
				,dbo.xfn_bulan_indonesia(dbo.xfn_get_system_date())
				,@nama_user
				,NULL
                ,null
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	ifindoc.dbo.document_movement dmt
				inner join ifindoc.dbo.document_movement_detail dmd on dmt.code			= dmd.movement_code
				left join ifindoc.dbo.document_main dm on (dmd.document_code			= dm.code)
				left join ifindoc.dbo.fixed_asset_main dmfam on (dmfam.asset_no			= dm.asset_no)
				left join ifindoc.dbo.document_pending dp on (dmd.document_pending_code = dp.code)
				left join ifinams.dbo.asset_vehicle av with (nolock) on (av.asset_code	= dmfam.asset_no)
				left join ifinams.dbo.asset ast on ast.code								= case
																							  when dmd.document_code is null then dp.asset_no
																							  else dm.asset_no
																						  end
				left join ifinams.dbo.sale_detail sd on sd.asset_code = ast.code
				left join ifinams.dbo.sale sa on sa.code = sd.sale_code
				left join ifinsys.dbo.sys_branch sbr on sbr.code						= dmt.branch_code
				left join ifinsys.dbo.sys_city scy on scy.code							= sbr.city_code
				left join ifinopl.dbo.agreement_main ami on (ami.agreement_no			= ast.agreement_no)
				left join ifinopl.dbo.agreement_asset asat on (ast.asset_no = asat.asset_no)
		--outer apply
		--	(
		--		select		ast1.agreement_no
		--					,dm1.document_type
		--					,count(dm1.document_type) 'jumlah'
		--		from		ifindoc.dbo.document_movement dmt
		--					inner join ifindoc.dbo.document_movement_detail dmd on dmt.code			= dmd.movement_code
		--					left join ifindoc.dbo.document_main dm1 on (dmd.document_code			= dm1.code)
		--					left join ifindoc.dbo.document_pending dp on (dmd.document_pending_code = dp.code)
		--					left join ifinams.dbo.asset ast1 on ast.code							= case
		--																								  when dmd.document_code is null then dp.asset_no
		--																								  else dm1.asset_no
		--																							  end
		--		where		dm.document_type is not null
		--					and ast1.agreement_no = ast.agreement_no
		--					and dm1.document_type = dm.document_type
		--		group by	ast1.agreement_no
		--					,dm1.document_type
		--					,ast1.agreement_no
		--	) tes
		where	dm.document_type is not null
				and dmt.code = @p_mutation_no ;

		insert into dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL
		(
			user_id
			,report_company
			,report_title
			,report_image
			,agreement_no
			,agreement_date
			,value_date
			,leesee_consumer_name
			,leesee_consumer_no
			,asset_code
			,id
			,object_name
			,document_type
			,document_no
			,remark
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct @p_user_id
				,@report_company
				,@report_title
				,@report_image
				,case
					when ast.rental_status = 'IN USE' then isnull(ast.agreement_external_no,'-')
					else 'UNIT '+ast.status
				end
				,case
					when ast.rental_status = 'IN USE' then dbo.xfn_bulan_indonesia(ami.agreement_date)
					else '-'
				end
				,case
					when ast.rental_status = 'IN USE' then dbo.xfn_bulan_indonesia((isnull(asat.handover_bast_date,ami.agreement_date)))
					else '-'
				end
				,case
					when ast.rental_status = 'IN USE' then ast.client_name
					else 'UNIT '+ast.status
				end
				,isnull(ast.agreement_external_no,'-')
				,ast.code
				,dmd.id
				,ast.item_name + ' Th. '+ isnull(av.built_year, '-') + ' - '  + ISNULL(av.plat_no, '')
				,dm.document_type
				,case
					 when dm.document_type = 'bpkb' then ' - '+isnull(dde.doc_no,av.bpkb_no)
					 else dde.doc_no
				 end 'document_no'
				,dmt.movement_remarks
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address  
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address	
		from	ifindoc.dbo.document_movement dmt
				inner join ifindoc.dbo.document_movement_detail dmd on dmt.code = dmd.movement_code
				left join ifindoc.dbo.document_main dm on (dmd.document_code = dm.code)
				left join ifindoc.dbo.document_detail dde on (dde.document_code = dm.code)
				left join ifindoc.dbo.fixed_asset_main dmfam on (dmfam.asset_no = dm.asset_no)
				left join ifindoc.dbo.document_pending dp on (dmd.document_pending_code = dp.code)
				left join ifinams.dbo.asset_vehicle av with (nolock) on (av.asset_code = dmfam.asset_no)
				left join ifinams.dbo.asset ast on ast.code = case
																  when dmd.document_code is null then dp.asset_no
																  else dm.asset_no
															  end
				left join ifinsys.dbo.sys_branch sbr on sbr.code = ast.branch_code
				left join ifinsys.dbo.sys_city scy on scy.code = sbr.city_code
				left join ifinopl.dbo.agreement_main ami on (ami.agreement_no = ast.agreement_no)
				left join ifinopl.dbo.agreement_asset asat on (ast.asset_no = asat.asset_no)
				outer apply
					(
						select		ast1.agreement_no
									,dm1.document_type
									,count(dm1.document_type) 'jumlah'
						from		ifindoc.dbo.document_movement dmt
									inner join ifindoc.dbo.document_movement_detail dmd on dmt.code			= dmd.movement_code
									left join ifindoc.dbo.document_main dm1 on (dmd.document_code			= dm1.code)
									left join ifindoc.dbo.document_pending dp on (dmd.document_pending_code = dp.code)
									left join ifinams.dbo.asset ast1 on ast.code							= case
																												  when dmd.document_code is null then dp.asset_no
																												  else dm1.asset_no
																											  end
						where		dm.document_type is not null
									and ast1.agreement_no = ast.agreement_no
									and dm1.document_type = dm.document_type
						group by	ast1.agreement_no
									,dm1.document_type
									,ast1.agreement_no
					) tes
		where	dm.document_type is not null
		and		dmt.code = @p_mutation_no ;

		/* declare main cursor */
		declare c_document_borrow cursor local fast_forward read_only for 
		select distinct document_type
		from dbo.rpt_surat_persetujuan_pengeluaran_dokumen_detail ;

		/* fetch record */
		open	c_document_borrow
		fetch	c_document_borrow
		into	@document_type								
																	
		while @@fetch_status = 0
		begin 
				
			update	dbo.rpt_surat_persetujuan_pengeluaran_dokumen
			set		document_quantity =
					(
						select	count(DOCUMENT_TYPE)
						from	dbo.rpt_surat_persetujuan_pengeluaran_dokumen_detail
						where	document_type = @document_type
						and		user_id = @p_user_id
					)
			where	document_name = @document_type ;

		/* fetch record berikutnya */
		fetch	c_document_borrow
		into	@document_type			
								
		end		
		
		/* tutup cursor */
		close		c_document_borrow
		deallocate	c_document_borrow

		SELECT @object = COUNT(DISTINCT OBJECT_NAME) 
		FROM dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL
		WHERE user_id = @p_user_id


		SELECT @bpkb_no = document_no
		FROM dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL
		WHERE USER_ID = @p_user_id AND document_type = 'BPKB'

		SELECT @suplementary_no = document_no
		FROM dbo.RPT_SURAT_PERSETUJUAN_PENGELUARAN_DOKUMEN_DETAIL
		WHERE USER_ID = @p_user_id AND document_type = 'SUPLEMENTARY'

		if (@object = 1)
		begin
			update dbo.rpt_surat_persetujuan_pengeluaran_dokumen
			set object_name = ISNULL(@bpkb_no, '-')
			where user_id = @p_user_id
		end
        else
		begin
			UPDATE dbo.rpt_surat_persetujuan_pengeluaran_dokumen
			set object_name = 'TERLAMPIR'
			where user_id = @p_user_id
		END
        
		if (@object = 1)
		begin
			update dbo.rpt_surat_persetujuan_pengeluaran_dokumen
			set object_suplementary = ISNULL(@suplementary_no, '-')
			where user_id = @p_user_id
		end
        else
		begin
			UPDATE dbo.rpt_surat_persetujuan_pengeluaran_dokumen
			set object_suplementary = 'TERLAMPIR'
			where user_id = @p_user_id
		end

	end TRY
    


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

