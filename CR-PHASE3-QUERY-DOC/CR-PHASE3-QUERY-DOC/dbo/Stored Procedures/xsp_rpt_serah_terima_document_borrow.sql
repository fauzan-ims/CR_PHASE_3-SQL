--created by, Bilal at 03/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_serah_terima_document_borrow
(
	@p_user_id			NVARCHAR(MAX)
	, @p_mutation_no	NVARCHAR(50)
	--
	, @p_cre_date		DATETIME
	, @p_cre_by			NVARCHAR(15)
	, @p_cre_ip_address nvarchar(15)
	, @p_mod_date		datetime
	, @p_mod_by			nvarchar(15)
	, @p_mod_ip_address nvarchar(15)
)
as
begin
	delete dbo.rpt_serah_terima_document_borrow
	where	user_id = @p_user_id ;

	delete dbo.rpt_serah_terima_document_borrow_detail
	where	user_id = @p_user_id ;

	declare @msg			  nvarchar(max)
			, @report_company nvarchar(250)
			, @report_image	  nvarchar(250)
			, @report_title	  nvarchar(250)
			, @perjanjian_no  nvarchar(50)
			, @atas_nama	  nvarchar(250)
			, @nama_dokumen	  nvarchar(250)
			, @nomor_dokumen  nvarchar(50)
			, @peminjam		  nvarchar(250)
			, @kota			  nvarchar(50)
			, @tanggal		  datetime 
			, @nama_user      nvarchar(250)
			, @nama_head      nvarchar(250)
			, @branch_code	  nvarchar(250)
			, @jabatan_user	  nvarchar(250)
			, @jabatan	      nvarchar(250);

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		set @report_title = 'Dokumen - Borrow' ;

		select	@branch_code = branch_code
		from	dbo.document_movement
		where	code = @p_mutation_no ;

		select	@kota = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;

		select	@nama_user = name
				,@jabatan_user = sps.description
		from	ifinsys.dbo.sys_employee_main sem
				inner join ifinsys.dbo.sys_employee_position sep on sem.code			  = sep.emp_code
																	and sep.base_position = '1'
				left join ifinsys.dbo.sys_position sps on sps.code						  = sep.position_code
		where	sem.code = @p_user_id ;

		select	@nama_head = sbs.signer_name
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
				inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code		  = sbs.emp_code
																	and sep.base_position = '1'
				inner join ifinsys.dbo.sys_position spo on spo.code						  = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code	 = @branch_code ;

		insert into dbo.rpt_serah_terima_document_borrow
		(
			user_id
			, mutation_no
			, report_company
			, report_title
			, report_image
			, perjanjian_no
			, atas_nama
			, nama_dokumen
			, nomor_dokumen
			, peminjam
			, kota
			, tanggal
			, user_login
			, pic_name
			, head_opl
			, jabatan
			, tanggal_surat_kuasa
			, asset_code
			, jabatan_user
			, cre_date
			, cre_by
			, cre_ip_address
			, mod_date
			, mod_by
			, mod_ip_address
		)
		select	distinct @p_user_id
				,@p_mutation_no
				,@report_company
				,@report_title
				,@report_image
				,case 
					when aa.rental_status='IN USE' then aa.agreement_external_no
					else 'Unit ' + aa.status
				end
				,case 
					when aa.rental_status='IN USE' then aa.client_name
					else 'Unit ' + aa.status
				end
				,dde.document_name--dom.document_type
				,dde.doc_no--doc_no.doc_no
				,case
						when dcm.movement_location='BORROW CLIENT' then aa.client_name
						when dcm.movement_location='THIRD PARTY' then dcm.movement_to
						else dcm.movement_to_client_name
				end
				,@kota
				,dbo.xfn_bulan_indonesia(dbo.xfn_get_system_date())
				,@nama_user
				,case
						when dcm.movement_location='BORROW CLIENT' then dcm.received_name
						when dcm.movement_location='THIRD PARTY' then dcm.received_name
						else '				'
				end
				,@nama_head
				,@jabatan
				,dbo.xfn_bulan_indonesia(dcm.movement_date)
				,ams.asset_no
				,@jabatan_user
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.document_movement dcm
				inner join dbo.document_movement_detail dmvd on (dmvd.movement_code = dcm.code)
				left join dbo.document_movement_replacement dmr on (dmr.movement_code = dcm.code)
				left join dbo.document_main dom on (dom.code = dmvd.document_code)
				left join dbo.document_detail dde on (dde.document_code = dom.code)
				left join ifinams.dbo.asset aa on (aa.code = dom.asset_no)
				left join dbo.fixed_asset_main ams on ( ams.asset_no = aa.code)
				outer apply (
					select	dde.doc_no 'doc_no'
					from	dbo.document_detail dde
					where	dde.document_code = dom.code 
				)doc_no
		where	dcm.code = @p_mutation_no ;

		-- INSERT INTO 
		insert into dbo.rpt_serah_terima_document_borrow_detail
		(
			user_id
			,asset_code
			,merk_name
			,engine_no
			,chasis_no
			,police_no
			,bpkb_name
		)
		select	@p_user_id
				,dm.asset_no
				,fam.asset_name + ' Th. ' + isnull(avi.built_year,'-')
				,fam.reff_no_3
				,fam.reff_no_2
				,fam.reff_no_1
				,isnull(dde.doc_name,avi.stnk_name)
				--,nama.doc_name
		from	dbo.document_movement_detail dmd
				inner join dbo.document_main dm on dm.code = dmd.document_code
				left join document_detail dde on dde.document_code = dm.code
				inner join dbo.fixed_asset_main fam on fam.asset_no = dm.asset_no
				left join ifinams.dbo.asset_vehicle avi on avi.asset_code = fam.asset_no
				outer apply
					(
						select	doc_name
						from	dbo.document_detail dd
						where	dd.document_code = dm.code
					) nama
		where	movement_code = @p_mutation_no ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
