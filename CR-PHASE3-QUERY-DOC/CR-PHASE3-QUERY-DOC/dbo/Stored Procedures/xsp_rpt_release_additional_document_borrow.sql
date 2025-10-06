--created by, Bilal at 03/07/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_release_additional_document_borrow]
(
	@p_user_id		   nvarchar(max)
	,@p_mutation_no	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	delete	dbo.rpt_release_additional_document_borrow
	where	user_id = @p_user_id ;

	declare @msg				  nvarchar(max)
			,@report_company	  nvarchar(250)
			,@report_image		  nvarchar(250)
			,@report_title		  nvarchar(250)
			,@perjanjian_no		  nvarchar(50)
			,@atas_nama			  nvarchar(250)
			,@tanggal_dikeluarkan datetime
			,@nama_dokumen		  nvarchar(250)
			,@no_dokumen		  nvarchar(50)
			,@keterangan		  nvarchar(4000)
			,@alasan			  nvarchar(250)
			,@kota				  nvarchar(50)
			,@tanggal			  datetime 
			,@nama_user			  nvarchar(250)
			,@nama_head           nvarchar(250)
			,@branch_code	      nvarchar(250)
			,@pic				  nvarchar(250)
			,@tgl_surat_kuasa	  datetime 
			,@jabatan			  nvarchar(250) ;

	begin try
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@branch_code = branch_code
		from	dbo.document_movement
		where	code = @p_mutation_no ;

		select	@kota = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;

		select  @nama_user = name
		from	ifinsys.dbo.sys_employee_main
		where	code = @p_user_id ;

		select	@nama_head = sbs.signer_name
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
				inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code		  = sbs.emp_code
																	and sep.base_position = '1'
				inner join ifinsys.dbo.sys_position spo on spo.code						  = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code	 = @branch_code ;

		set @report_title = N'Additional Collateral Released' ;

		--/* declare variables */
		--declare @variable int ;

		--declare curr_additional_released cursor fast_forward read_only for
		--select	fams.agreement_external_no
		--		,fams.client_name
		--		,dm.movement_date
		--		,rd.document_name
		--		,rd.document_no
		--		,dm.movement_remarks
		--		,fams.client_name
		--		,sc.description
		--		,getdate()
		--		,dm.received_name
		--		,dm.movement_date
		--from	dbo.document_movement				 dm
		--		inner join dbo.document_movement_detail	 dd on dd.movement_code		  = dm.code
		--		left join dbo.document_main dmn on dmn.code = dd.document_code
		--		inner join ifinams.dbo.asset	 fams on fams.code			  = dmn.asset_no
		--		left join dbo.fixed_asset_main ams on ( ams.asset_no = fams.code)
		--		left join dbo.document_movement_replacement rd on rd.movement_code			  = dm.code
		--		left join ifinsys.dbo.sys_branch sb with (nolock) on sb.code  = dmn.branch_code
		--		inner join ifinsys.dbo.sys_city	 sc with (nolock) on (sc.code = sb.city_code) 
		--where	dm.code = @p_mutation_no

		--open curr_additional_released ;

		--fetch next from curr_additional_released
		--into @perjanjian_no
		--	 ,@atas_nama
		--	 ,@tanggal_dikeluarkan
		--	 ,@nama_dokumen
		--	 ,@no_dokumen
		--	 ,@keterangan
		--	 ,@alasan
		--	 ,@kota
		--	 ,@tanggal
		--	 ,@pic 
		--	 ,@tgl_surat_kuasa;

		--while @@fetch_status = 0
		--begin
		--	fetch next from curr_additional_released
		--	into @perjanjian_no
		--		 ,@atas_nama
		--		 ,@tanggal_dikeluarkan
		--		 ,@nama_dokumen
		--		 ,@no_dokumen
		--		 ,@keterangan
		--		 ,@alasan
		--		 ,@kota
		--		 ,@tanggal 
		--		 ,@pic
		--		 ,@tgl_surat_kuasa;
		--end ;

		--close curr_additional_released ;
		--deallocate curr_additional_released ;

		insert into dbo.rpt_release_additional_document_borrow
		(
			user_id
			,mutation_no
			,report_company
			,report_title
			,report_image
			,perjanjian_no
			,atas_nama
			,tanggal_dikeluarkan
			,nama_dokumen
			,no_dokumen
			,keterangan
			,alasan
			,kota
			,tanggal
			,user_login
			,pic_name
			,head_opl
			,jabatan
			,tanggal_surat_kuasa
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	DISTINCT 
				@p_user_id
				,@p_mutation_no
				,@report_company
				,@report_title
				,@report_image
				,fams.agreement_external_no
				,fams.client_name
				,dm.movement_date
				,rd.document_name
				,rd.document_no
				,rd.remarks
				,fams.client_name
				,sc.description
				,getdate()
				,@nama_user--nama_mod.name
				,@nama_user
				,@nama_head
				,@jabatan
				,null--dm.movement_date
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
		from	dbo.document_movement				 dm
				inner join dbo.document_movement_detail	 dd on dd.movement_code		  = dm.code
				left join dbo.document_main dmn on dmn.code = dd.document_code
				inner join ifinams.dbo.asset	 fams on fams.code			  = dmn.asset_no
				left join dbo.fixed_asset_main ams on ( ams.asset_no = fams.code)
				left join dbo.document_movement_replacement rd on rd.movement_code			  = dm.code
				left join ifinsys.dbo.sys_branch sb with (nolock) on sb.code  = dmn.branch_code
				inner join ifinsys.dbo.sys_city	 sc with (nolock) on (sc.code = sb.city_code) 
				outer apply(
					select	sem.name
					from	dbo.document_movement dmtt
					left join ifinsys.dbo.sys_employee_main sem on sem.code = dmtt.cre_by
					where	dmtt.code = dm.code
				)nama_mod
		where	dm.code = @p_mutation_no;
		--values
		--(
		--	@p_user_id
		--	,@p_mutation_no
		--	,@report_company
		--	,@report_title
		--	,@report_image
		--	,@perjanjian_no
		--	,@atas_nama
		--	,@tanggal_dikeluarkan
		--	,@nama_dokumen
		--	,@no_dokumen
		--	,@keterangan
		--	,@alasan
		--	,@kota
		--	,@tanggal
		--	,@nama_user
		--	,@pic
		--	,@nama_head
		--	,@jabatan
		--	,@tgl_surat_kuasa
		--	----
		--	,@p_cre_date
		--	,@p_cre_by
		--	,@p_cre_ip_address
		--	,@p_mod_date
		--	,@p_mod_by
		--	,@p_mod_ip_address
		--) ;
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
