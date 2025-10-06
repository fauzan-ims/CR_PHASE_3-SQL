--created by, Bilal at 04/07/2023 

CREATE PROCEDURE  dbo.xsp_rpt_surat_kuasa
(
	@p_user_id		   nvarchar(max)
	,@p_order_no	   nvarchar(50)
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
	delete	dbo.rpt_surat_kuasa
	where	user_id = @p_user_id ;

	declare @msg					  nvarchar(max)
			,@report_company		  nvarchar(250)
			,@report_image			  nvarchar(250)
			,@report_title			  nvarchar(250)
			,@report_address		  nvarchar(250)
			,@report_fax_area		  nvarchar(5)
			,@report_phone_area		  nvarchar(5)
			,@report_fax_no			  nvarchar(20)
			,@report_phone_no		  nvarchar(20)
			,@bertanda_tangan_nama	  nvarchar(250)
			,@bertanda_tangan_jabatan nvarchar(50)
			,@bertanda_tangan_alamat  nvarchar(4000)
			,@memberi_kuasa_nama	  nvarchar(250)
			,@memberi_kuasa_alamat	  nvarchar(4000)
			,@nopol					  nvarchar(50)
			,@merk					  nvarchar(50)
			,@warna					  nvarchar(50)
			,@no_rangka				  nvarchar(50)
			,@no_mesin				  nvarchar(50)
			,@tahun					  nvarchar(4)
			,@kota					  nvarchar(50)
			,@tanggal				  datetime
			,@nama					  nvarchar(50)
			,@branch_code			  nvarchar(50)
			,@pemberi_kuasa_name	  nvarchar(50)
			,@pemberi_kuasa_jabatan	  nvarchar(50)
			,@position_name			  nvarchar(250)
			,@ho_branch_code		  nvarchar(50);

	begin try
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@ho_branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

		select	@branch_code = branch_code
		from	dbo.asset
		where	code = @p_order_no ;

		--select	@report_address = address
		--		,@report_phone_area = area_phone_no
		--		,@report_phone_no = phone_no
		--		,@report_fax_area = area_fax_no
		--		,@report_fax_no = fax_no
		--from	ifinsys.dbo.sys_branch
		--where	code = @branch_code ;

		select	@nama = sbs.signer_name 
				,@position_name = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'DIREKOPL'
				and sbs.branch_code = @ho_branch_code ;

		--select	@nama = signer_name 
		--from	ifinsys.dbo.sys_branch_signer
		--where	signer_type_code = 'HEADOPR'
		--		and branch_code = @branch_code ;

		set @report_title = N'SURAT KUASA' ;

		select	@bertanda_tangan_nama	 = sem.name
				,@bertanda_tangan_alamat = sb.address
				,@bertanda_tangan_jabatan = sd.description
		from	ifinsys.dbo.sys_user_main				   sum
				inner join ifinsys.dbo.sys_employee_main   sem on sem.code		   = sum.code
				inner join ifinsys.dbo.sys_department	   sd on sd.code		   = sem.department_code
				inner join ifinsys.dbo.sys_employee_branch seb on seb.emp_code	   = sum.code
														  and  seb.is_base = '1'
				inner join ifinsys.dbo.sys_branch		   sb on sb.code		   = seb.branch_code
		where	sum.code = @p_user_id ;

		insert into dbo.rpt_surat_kuasa
		(
			user_id
			,order_no
			,report_company
			,report_title
			,report_image
			,REPORT_PHONE_AREA
			,REPORT_PHONE_NO
			,REPORT_FAX_AREA
			,REPORT_FAX_NO
			,bertanda_tangan_nama
			,bertanda_tangan_jabatan
			,bertanda_tangan_alamat
			,memberi_kuasa_nama
			,memberi_kuasa_alamat
			,STNK_NAME
			,STNK_ADDRESS
			,nopol
			,merk
			,warna
			,no_rangka
			,no_mesin
			,tahun
			,kota
			,tanggal
			,pemberi_kuasa_name
			,pemberi_kuasa_jabatan
			,service
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_order_no
				,@report_company
				,@report_title
				,@report_image
				,sbh.AREA_PHONE_NO
				,sbh.PHONE_NO
				,sbh.AREA_FAX_NO
				,sbh.FAX_NO
				,nama_signer.SIGNER_NAME
				,nama_signer.DESCRIPTION--'Direktur Operational'
				,sbh.ADDRESS
				,mps.public_service_name 'memberi_kuasa_nama'
				,mpa.address 'memberi_kuasa_alamat'
				,@report_company
				,sbh.address
				,av.plat_no 'nopol'
				,av.merk_name 'merk'
				,av.colour 'warna'
				,av.chassis_no 'no_rangka'
				,av.engine_no 'no_mesin'
				,av.built_year 'tahun'
				,sc.description 'kota'
				,om.order_date 'tanggal'
				,nama_signer.SIGNER_NAME
				,nama_signer.DESCRIPTION
				,replace(lower(sgs.description),'stnk','STNK')
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.order_main om
				inner join dbo.order_detail od on (om.code								 = od.order_code)
				left join dbo.register_main rm on (rm.code								 = od.register_code)
				inner join dbo.register_detail rd on (rd.register_code					 = rm.code)
				left join dbo.asset_vehicle av on (rm.fa_code							 = av.asset_code)
				inner join dbo.asset ass on ass.CODE = rm.FA_CODE
				inner join ifinsys.dbo.SYS_BRANCH sbh on sbh.code=ass.BRANCH_CODE
				left join dbo.master_public_service mps on (mps.code					 = om.public_service_code)
				left join dbo.master_public_service_address mpa on (
																	   mps.code			 = mpa.public_service_code
																	   and mpa.is_latest = '1'
																   )
				left join ifinsys.dbo.sys_branch sb on sb.code							 = om.branch_code
				inner join ifinsys.dbo.sys_city sc on (sc.code							 = sb.city_code)
				left join ifinams.dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
				outer apply (
					select	sbs.signer_name 
							,spo.description
					from	ifinsys.dbo.sys_branch_signer sbs
					inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
					inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
					where	sbs.signer_type_code = 'DIREKOPL'
							and sbs.branch_code = ass.BRANCH_CODE
				) nama_signer
		where	om.code				= @p_order_no
				and (rd.service_code = 'PBSPSTN' or rd.service_code like '%STNK%');
	--values
	--(   
	--	@p_user_id
	--    ,@p_order_no
	--    ,@report_company
	--    ,@report_title 
	--    ,@report_image 
	--    ,@bertanda_tangan_nama
	--    ,@bertanda_tangan_jabatan
	--    ,@bertanda_tangan_alamat 
	--    ,@memberi_kuasa_nama
	--    ,@memberi_kuasa_alamat
	--    ,@nopol
	--    ,@merk 
	--    ,@warna
	--    ,@no_rangka
	--    ,@no_mesin 
	--    ,@tahun
	--	,@kota					
	--	,@tanggal				
	--	,@pemberi_kuasa_name	
	--	,@pemberi_kuasa_jabatan	
	--	--
	--    ,@p_cre_date		
	--	,@p_cre_by			
	--	,@p_cre_ip_address	
	--	,@p_mod_date		
	--	,@p_mod_by			
	--	,@p_mod_ip_address
	--)
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
