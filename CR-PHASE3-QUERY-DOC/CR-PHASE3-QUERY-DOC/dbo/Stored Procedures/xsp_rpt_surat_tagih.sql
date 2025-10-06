--created by, Bilal at 03/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_surat_tagih
(
	@p_user_id				nvarchar(max)
	,@p_id					NVARCHAR(50) 
	--
	,@p_cre_date			DATETIME
	,@p_cre_by				NVARCHAR(15)
	,@p_cre_ip_address		NVARCHAR(15)
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
as
begin
	declare @sql_cover_note_no		nvarchar(50);
	
	DELETE dbo.rpt_surat_tagih
	where user_id = @p_user_id ;

	delete dbo.rpt_surat_tagih_detail
	where user_id = @p_user_id ;

	--if (@p_cover_note_no <> '-')
	--begin
	--set @p_cover_note_no = RIGHT(@p_cover_note_no, LEN(@p_cover_note_no) - 1) 
	--end
	--set	@p_cover_note_no = REPLACE(@p_cover_note_no,']','')
	--set	@p_cover_note_no = REPLACE(@p_cover_note_no,'"','')
	--set	@p_cover_note_no = REPLACE(@p_cover_note_no,'\','')
	--set @p_cover_note_no = right(@p_cover_note_no + replace(@p_cover_note_no,'\]',''),4)
		--if	rtrim(@p_cover_note_no) = '''ALL'''
	--	set	@p_cover_note_no = '(rcubeData.branch_code)'
	--else
	--	set @p_cover_note_no = '('+@p_cover_note_no+')'

	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@branch_code				nvarchar(50)
			,@city						nvarchar(4000)
		    ,@date						datetime
		    ,@client_name				nvarchar(250)
		    ,@client_address			nvarchar(4000)
		    ,@client_telp				nvarchar(20)
		    ,@up_name					nvarchar(250)
		    ,@tenor						int
		    ,@tenor_desc				nvarchar(250)
			,@report_address			nvarchar(250)
			,@report_fax_area			nvarchar(5)
			,@report_phone_area			nvarchar(5)
			,@report_fax_no				nvarchar(20)
			,@report_phone_no			nvarchar(20)
			,@report_city_ho			nvarchar(50)
			,@kontak_bpkb				nvarchar(250)
			,@depthead					nvarchar(50)
			,@jabatan_head				nvarchar(250)

	begin try

		select @report_company = value
		from dbo.sys_global_param 
		where code = 'COMP2';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@branch_code = value
		from	dbo.sys_global_param
		where	code = 'HO' ;

		select	@kontak_bpkb = value
		from	dbo.sys_global_param
		where	code = 'KKBPKB' ;

		set	@report_title = 'Report Surat Tagih'

		select	@report_address = address
				,@report_phone_area = area_phone_no
				,@report_phone_no = phone_no
				,@report_fax_area = area_fax_no
				,@report_fax_no = fax_no
		from	ifinsys.dbo.sys_branch
		where	code = @branch_code ;

		select	@depthead = sem.name
				,@jabatan_head = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
				inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code		  = sbs.emp_code
																	and sep.base_position = '1'
				inner join ifinsys.dbo.sys_position spo on spo.code						  = sep.position_code
				inner join ifinsys.dbo.sys_employee_main sem on sem.code				  = sbs.emp_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code	 = @branch_code ;

		select	@report_city_ho = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;

		insert into dbo.rpt_surat_tagih
		(
		    user_id
		    ,cover_note_no
		    ,report_company
		    ,report_title
		    ,report_image
			,REPORT_ADDRESS
			,REPORT_TELP_NO
			,REPORT_FAX_NO
		    ,city
		    ,date
		    ,client_name
		    ,client_address
		    ,client_telp
		    ,up_name
			,tenor
			,tenor_desc
			,kontak_bpkb
			,NAMA_DEPT_HEAD
			,JABATAN_DEPT_HEAD
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select	distinct @p_user_id
				,@p_id
				,@report_company
				,@report_title
				,@report_image
				,@report_address
				,case
					 when isnull(@report_phone_area, '') = '' then ''
					 else @report_phone_area
				 end + @report_phone_no
				,case
					 when isnull(@report_fax_area, '') = '' then ''
					 else @report_fax_area
				 end + @report_fax_no
				,@report_city_ho
				,dbo.xfn_bulan_indonesia(ifindoc.dbo.xfn_get_system_date())
				,isnull(rrq.vendor_name, '-')
				,isnull(rrq.vendor_address, '-')
				,isnull(isnull(rrq.vendor_pic_area_phone_no,'') + ' - ' + isnull(rrq.vendor_pic_phone_no,''), '-')
				,isnull(rrq.vendor_pic_name, '-')
				,case 
					when ceiling(cast(datediff(day, rrq.cover_note_date, isnull(rrq.cover_note_exp_date,rrq.cover_note_date))as decimal(18,2))/30)=0 then '1'
					else ceiling(cast(datediff(day, rrq.cover_note_date, isnull(rrq.cover_note_exp_date,rrq.cover_note_date))as decimal(18,2))/30)
				end
				,dbo.Terbilang(case 
					when ceiling(cast(datediff(day, rrq.cover_note_date, isnull(rrq.cover_note_exp_date,rrq.cover_note_date))as decimal(18,2))/30)=0 then '1'
					else ceiling(cast(datediff(day, rrq.cover_note_date, isnull(rrq.cover_note_exp_date,rrq.cover_note_date))as decimal(18,2))/30)
				end)
				,@kontak_bpkb
				,@depthead
				,@jabatan_head
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	ifindoc.dbo.replacement_request rrq
				left join ifindoc.dbo.replacement rpm on rpm.code = rrq.replacement_code
				inner join ifinsys.dbo.sys_branch sbr on sbr.code = rrq.branch_code
				inner join ifinsys.dbo.sys_city scy on scy.code	  = sbr.city_code
		where	rrq.id = @p_id;

		insert into dbo.rpt_surat_tagih_detail
		(
			user_id
			,kendaraan
			,tahun
			,nomor_rangka
			,nomor_mesin
			,bpkb_atas_nama
		)
		select	distinct
				@p_user_id
				,isnull(ast.item_name,'-') + ' - ' + isnull(avi.plat_no,'-')
				,isnull(built_year,'-')
				,isnull(chassis_no,'-')
				,isnull(engine_no,'-')
				,isnull(avi.stnk_name,'-')
				--,isnull(ast.client_name,'-')
		from	ifindoc.dbo.replacement_request_detail rqd
				inner join ifindoc.dbo.replacement_request rrq on rrq.id = rqd.replacement_request_id
				left join ifinams.dbo.asset ast on ast.code = rqd.asset_no
				left join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
		where	rrq.id = @p_id ;

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
