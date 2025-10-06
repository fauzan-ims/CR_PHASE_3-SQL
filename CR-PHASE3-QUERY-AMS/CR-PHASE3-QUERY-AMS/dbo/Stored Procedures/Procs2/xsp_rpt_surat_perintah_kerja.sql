CREATE PROCEDURE [dbo].[xsp_rpt_surat_perintah_kerja]
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
)
as
begin
	delete dbo.rpt_surat_perintah_kerja
	where	user_id = @p_user_id ;

	delete dbo.rpt_surat_perintah_kerja_jasa
	where user_id = @p_user_id ;

	delete dbo.rpt_surat_perintah_kerja_item
	where user_id = @p_user_id ;

	delete dbo.rpt_surat_perintah_kerja_item
	where user_id = @p_user_id ;

	DELETE dbo.RPT_SURAT_PERINTAH_KERJA_APPROVAL
	WHERE user_id = @p_user_id ;

	declare @msg				    nvarchar(max)
			,@report_company	    nvarchar(250)
			,@report_title		    nvarchar(250)
			,@report_image		    nvarchar(250)
			,@branch_code		    nvarchar(50)
			,@nama				    nvarchar(50)
			,@year				    nvarchar(4)
			,@month				    nvarchar(4)
			,@spk_no			    nvarchar(50)
			,@jabatan			    nvarchar(250)
			,@report_address		nvarchar(250)
			,@company_fax_area		nvarchar(5)
			,@company_fax_phone		nvarchar(50)
			,@company_telp_area	 	nvarchar(50)
			,@company_telp_area1	nvarchar(50)
			,@company_telp	 		nvarchar(50)
			,@company_fax	 		nvarchar(50);

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'SURAT PERINTAH KERJA';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		select	@branch_code = branch_code
		from	ifinams.dbo.maintenance
		where	code = @p_code ;


		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		set @year = right(year(dbo.xfn_get_system_date()),2) ;
		set @month = replace(str(cast(datepart(month, dbo.xfn_get_system_date()) as nvarchar), 2, 0), ' ', '0') ;

		declare @unique_code nvarchar(50) ;
		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_generate_auto_skn_no @p_unique_code = @p_unique_code output -- nvarchar(50)
											,@p_branch_code = @branch_code -- nvarchar(10)
											,@p_year = @year -- nvarchar(4)
											,@p_month = @month -- nvarchar(4)
											,@p_opl_code = N'' -- nvarchar(250)
											,@p_jkn = N'DSF-SPK' -- nvarchar(250)
											,@p_run_number_length = 5 -- int
											,@p_delimiter = N'/' -- nvarchar(1)
											,@p_table_name = N'MAINTENANCE' -- nvarchar(250)
											,@p_column_name = N'SPK_NO' -- nvarchar(250)

		select	@spk_no = mnc.spk_no
		from	dbo.maintenance mnc
		where	mnc.code = @p_code ;

		select	@report_address = address
				,@company_telp_area = area_phone_no
				,@company_telp_area1 = phone_no
				,@company_fax_area = area_fax_no
				,@company_fax_phone = fax_no
		from	ifinsys.dbo.sys_branch
		where	code = @branch_code;

		if @spk_no is null
		begin

			update	dbo.maintenance
			set		spk_no = @p_unique_code
			where	code = @p_code ;

			set @spk_no = @unique_code ;
		end ;

		insert into dbo.rpt_surat_perintah_kerja
		(
			user_id
			,report_company
			,report_title
			,report_image
			,REPORT_ADDRESS
			,REPORT_PHONE_NO
			,REPORT_FAX_NO
			,vendor_code
			,vendor_name
			,address
			,phone_no
			,up
			,spk_no
			,branch_code
			,branch_name
			,date
			,service
			,quantity
			,asset_code
			,asset_name
			,engine_no
			,actual_km
			,pekerjaan
			,chassis_no
			,POLICE_NO
			,YEAR
			,NAMA_SIGNER
			,JABATAN
			,WARNA
			,MERK
			,TYPE
			,work_date
		)
				select	distinct @p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@report_address
				,'('+isnull(@company_telp_area,'')+')-('+isnull(@company_telp_area1,'')+')'
				,'('+isnull(@company_fax_area,'')+')-('+isnull(@company_fax_phone,'')+')'
				,case
					 when mnt.maintenance_by = 'INT' then 'INTERNAL'
					 else mnt.vendor_code
				 end
				,case
					 when mnt.maintenance_by = 'INT' then 'INTERNAL'
					 else mnt.vendor_name
				 end
				,case
					 when mnt.maintenance_by = 'INT' then 'INTERNAL'
					 else isnull(mnt.vendor_address, '-')
				 end
				,case
					 when mnt.maintenance_by = 'INT' then '-'
					 when mnt.maintenance_by = 'EXT' then case
															  when mnt.sa_vendor_area_phone is not null then mnt.sa_vendor_area_phone + ' - ' + mnt.sa_vendor_phone_no
															  else mnt.sa_vendor_phone_no
														  end
					 when mnt.MAINTENANCE_BY = 'CST' then case
															  when cmi.CLIENT_TYPE = 'CORPORATE' then case
																										  when cci.area_mobile_no is not null then cci.area_mobile_no + '-' + cci.mobile_no
																										  else cci.mobile_no
																									  end
															  when cmi.client_type = 'PERSONAL' then case
																										 when cpi.area_mobile_no is not null then cpi.area_mobile_no + '-' + cpi.mobile_no
																										 else cpi.mobile_no
																									 end
															  else '-'
														  end
				 end
				,case
					 when mnt.maintenance_by = 'INT' then '-'
					 when mnt.maintenance_by = 'EXT' then mnt.sa_vendor_name
					 when mnt.maintenance_by = 'CST' then ass.client_name
					 else '-'
				 end
				,mnt.spk_no
				,mnt.branch_code
				,mnt.branch_name
				,mnt.transaction_date
				,''
				,''
				,wo.asset_code
				,ass.item_name
				,av.engine_no
				,mnt.actual_km
				,mnt.remark
				,av.chassis_no
				,av.plat_no
				,isnull(av.built_year,'-')
				,@nama
				,@jabatan
				,av.colour
				,av.merk_name
				,ass.item_name
				,mnt.WORK_DATE
		from	dbo.maintenance mnt
				left join dbo.work_order wo on (mnt.code						   = wo.maintenance_code)
				left join ifinbam.dbo.master_vendor mv on (mv.CODE				   = mnt.vendor_code)
				left join dbo.asset ass on (ass.code							   = mnt.asset_code)
				left join dbo.asset_vehicle av on (av.asset_code				   = ass.code)
				left join ifinopl.dbo.CLIENT_MAIN cmi on cmi.CLIENT_NO			   = ass.CLIENT_NO
				left join ifinopl.dbo.CLIENT_CORPORATE_INFO cci on cci.CLIENT_CODE = cmi.CODE
				left join ifinopl.dbo.CLIENT_PERSONAL_INFO cpi on cpi.CLIENT_CODE  = cmi.CODE
		where	mnt.code = @p_code ;

		insert into dbo.rpt_surat_perintah_kerja_jasa
		(
			user_id
			,maintenance_code
			,jasa
			,quantity
		)
		select	@p_user_id
				,mnd.maintenance_code
				,mnd.service_name
				,mnd.quantity
		from dbo.maintenance_detail mnd
		where mnd.maintenance_code = @p_code
		and mnd.service_type = 'JASA'

		insert into dbo.rpt_surat_perintah_kerja_item
		(
			user_id
			,maintenance_code
			,item
			,quantity
		)
		select	@p_user_id
				,mnd.maintenance_code
				,mnd.service_name
				,mnd.quantity
		from dbo.maintenance_detail mnd
		where mnd.maintenance_code = @p_code
		and mnd.service_type = 'ITEM'



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

