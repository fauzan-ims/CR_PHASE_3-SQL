--created, arif at 01-02-2023

CREATE PROCEDURE dbo.xsp_rpt_surat_jalan
(
	@p_code			   nvarchar(50)
	,@p_user_id		   nvarchar(50)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(50)
	,@p_cre_ip_address nvarchar(50)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(50)
	,@p_mod_ip_address nvarchar(50)
	--,@p_first_data	   int
)
as
begin
	declare @msg				  nvarchar(max)
			,@report_company	  nvarchar(250)
			,@report_title		  nvarchar(250) = 'SURAT TUGAS'
			,@report_image		  nvarchar(250)
			,@report_company_city nvarchar(50)
			,@company_address	  nvarchar(4000)
			,@nama				  nvarchar(250)
			,@jabatan			  nvarchar(250)
			,@name				  nvarchar(250)
			,@report_area_phone	  nvarchar(4)
			,@report_phone_no	  nvarchar(15)
			,@report_fax		  nvarchar(15)
			,@report_fax_area	  nvarchar(4)
			,@report_address2	  nvarchar(4000)
			,@kota				  nvarchar(50)
			,@branch_code		  nvarchar(50);

	--delete data yg ada di tb.rpt_surat jalan. 
	--karena di looping, maka delete di loop pertama saja
	--if @p_first_data = 1
	--begin
		delete dbo.rpt_surat_jalan
		where	user_id = @p_user_id ;

		delete dbo.rpt_surat_jalan_detail
		where	user_id = @p_user_id ;

	--end ;

	--select nama perusahaan
	select	@report_company = value
	from	dbo.sys_global_param
	where	code = 'COMP2' ;

	--select lokasi file logo
	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGDSF' ;

	-- select company addrss
	select	@company_address = value
	from	dbo.sys_global_param
	where	code = 'COMPADD' ;

	select	@report_company_city = value
	from	dbo.SYS_GLOBAL_PARAM
	where	CODE = 'INVCITY' ;

	select	@branch_code = branch_code
	from	ifinams.dbo.handover_asset
	where	code = @p_code ;

	select	@nama = sbs.signer_name 
			,@jabatan = spo.description
	from	ifinsys.dbo.sys_branch_signer sbs
	inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
	inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
	where	sbs.signer_type_code = 'HEADOPR'
			and sbs.branch_code = @branch_code ;

	-- select company area phone
	select	@report_phone_no = value
	from	dbo.sys_global_param
	where	code = 'TELP' ;

	-- select company phone
	select	@report_area_phone = value
	from	dbo.sys_global_param
	where	code = 'TELPAREA' ;

	-- select company fax
	select	@report_fax = value
	from	dbo.sys_global_param
	where	code = 'FAX' ;

	-- select company fax area
	select	@report_fax_area = value
	from	dbo.sys_global_param
	where	code = 'FAXAREA' ;

	--select @kota = description
	--from ifinsys.dbo.SYS_CITY scy
	--inner join ifinsys.dbo.SYS_BRANCH sbh on SYS_BRANCH.CITY_CODE = scy.CODE
	--where sbh.code = 

	begin try
		insert into dbo.rpt_surat_jalan
		(
			user_id
			,report_company
			,company_address
			,report_title
			,report_image
			,report_company_city
			,report_fax
			,report_fax_area
			,report_telp
			,report_telp_area
			,code
			,type
			,handover_from
			,handover_to
			,handover_address
			,handover_phone_area
			,handover_phone_no
			,eta_date
			,remark
			,reff_code
			,reff_name
			,handover_code
			,new_pages
			,nama
			,jabatan
			,tanggal
			,pickup_name
			,pickup_address
			,pickup_area_phone
			,pickup_phone
			,PIC_NAME
			,PIC_AREA_PHONE
			,PIC_PHONE_NO
			,kota	
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@company_address
				,@report_title
				,@report_image
				,@report_company_city
				,@report_fax
				,@report_fax_area
				,@report_phone_no
				,@report_area_phone
				,ha.code
				,ha.type
				,ha.handover_from
				,case 
					when ha.type='DELIVERY' then ha.handover_to
					when ha.type='MAINTENANCE OUT' then ha.handover_to
					when ha.type='REPLACE OUT' then ha.handover_to
					when ha.type='REPLACE GTS OUT' then ha.handover_to
					when ha.type='MOBILISASI' then ha.handover_to
					when ha.type='SELL OUT' then ha.handover_to
					when ha.type='RETURN OUT' then ha.handover_to
					when ha.type='PICK UP' then ha.handover_from
					when ha.type='MAINTENANCE IN' then ha.handover_from
					when ha.type='RETURN IN' then ha.handover_from
					when ha.type='REPLACE IN' then ha.handover_from
					when ha.type='REPLACE GTS IN' then ha.handover_from
					else '-'
				end
				,ha.handover_address
				,ha.handover_phone_area
				,ha.handover_phone_no
				,hrq.eta_date--eta_date
				,ha.remark
				,ha.reff_code
				,isnull(dbo.xfn_asset_get_asset_name_detail(ha.fa_code),'')
				,ha.code
				,'0'
				,@nama
				,case
					when @nama is null then ''
					else @jabatan
				end
				,dbo.xfn_bulan_indonesia(dbo.xfn_get_system_date())
				,ha.pic_handover_name		
				,ha.pic_handover_address	
				,ha.pic_handover_phone_area	
				,ha.pic_handover_phone_no	
				,ha.pic_recipient_name		
				,ha.pic_recipient_phone_area
				,ha.pic_recipient_phone_no	
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_name
				--	when ha.type='PICK UP' then ast.pickup_name
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_address
				--	when ha.type='PICK UP' then ast.pickup_address
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_area_no
				--	when ha.type='PICK UP' then ast.pickup_phone_area_no
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_phone_no
				--	when ha.type='PICK UP' then ast.pickup_phone_no
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_name
				--	when ha.type='PICK UP' then ast.pickup_name
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_area_no
				--	when ha.type='PICK UP' then ast.pickup_phone_area_no
				--	else '-'
				--end
				--,case 
				--	when ha.type='DELIVERY' then ast.deliver_to_phone_no
				--	when ha.type='PICK UP' then ast.pickup_phone_no
				--	else '-'
				--end
				,scy.description
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.handover_asset ha
		inner join dbo.handover_request hrq on hrq.handover_code = ha.code
		left join ifinopl.dbo.agreement_asset ast on (ast.asset_no = hrq.asset_no and ast.AGREEMENT_NO = hrq.AGREEMENT_NO)
		left join ifinsys.dbo.sys_branch sbh on sbh.code=ha.branch_code
		left join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	ha.code = @p_code ;

		insert into dbo.rpt_surat_jalan_detail
		(
			user_id
			,code
			,object
			,year
			,chasis_no
			,engine_no
			,plat_no
		)
		select	@p_user_id
				,@p_code
				,ass.item_name
				,avi.built_year
				,avi.chassis_no
				,avi.engine_no
				,avi.plat_no
		from	dbo.handover_asset ha
		inner join dbo.handover_request hrq on hrq.handover_code = ha.code
		left join dbo.asset ass on ass.code = ha.fa_code
		left join dbo.asset_vehicle avi on avi.asset_code = ass.code
		where	ha.code = @p_code ;

		if not exists (select 1 from dbo.RPT_SURAT_JALAN)
		insert into dbo.rpt_surat_jalan
		(
			USER_ID
			,REPORT_COMPANY
			,COMPANY_ADDRESS
			,REPORT_TITLE
			,REPORT_IMAGE
			,REPORT_COMPANY_CITY
			,REPORT_FAX
			,REPORT_FAX_AREA
			,REPORT_TELP
			,REPORT_TELP_AREA
			,CODE
			,TYPE
			,HANDOVER_FROM
			,HANDOVER_TO
			,HANDOVER_ADDRESS
			,HANDOVER_PHONE_AREA
			,HANDOVER_PHONE_NO
			,ETA_DATE
			,REMARK
			,REFF_CODE
			,REFF_NAME
			,PICKUP_NAME
			,PICKUP_ADDRESS
			,HANDOVER_CODE
			,NEW_PAGES
			,NAMA
			,JABATAN
			,TANGGAL
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		values
		(
			@p_user_id -- USER_ID - nvarchar(50)
			,@report_company
			,@company_address
			,@report_title
			,@report_image
			,@report_company_city
			,@report_fax
			,@report_fax_area
			,@report_phone_no
			,@report_area_phone
			,@p_code -- CODE - nvarchar(50)
			,null -- TYPE - nvarchar(50)
			,null -- HANDOVER_FROM - nvarchar(250)
			,null -- HANDOVER_TO - nvarchar(250)
			,null -- HANDOVER_ADDRESS - nvarchar(4000)
			,null -- HANDOVER_PHONE_AREA - nvarchar(5)
			,null -- HANDOVER_PHONE_NO - nvarchar(15)
			,null -- ETA_DATE - datetime
			,null -- REMARK - nvarchar(4000)
			,null -- REFF_CODE - nvarchar(50)
			,null -- REFF_NAME - nvarchar(4000)
			,null -- PICKUP_NAME - nvarchar(50)
			,null -- PICKUP_ADDRESS - nvarchar(250)
			,null -- HANDOVER_CODE - nvarchar(50)
			,null -- NEW_PAGES - nvarchar(2)
			,null -- NAMA - nvarchar(250)
			,null -- JABATAN - nvarchar(250)
			,null -- TANGGAL - datetime
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		if not exists (select 1 from dbo.RPT_SURAT_JALAN_DETAIL)
		insert into dbo.RPT_SURAT_JALAN_DETAIL
		(
			USER_ID
			,CODE
			,OBJECT
			,YEAR
			,CHASIS_NO
			,ENGINE_NO
			,PLAT_NO
		)
		values
		(
			@p_user_id -- USER_ID - nvarchar(50)
			,@p_code -- CODE - nvarchar(50)
			,'-' -- OBJECT - nvarchar(250)
			,null -- YEAR - nvarchar(4)
			,'-' -- CHASIS_NO - nvarchar(50)
			,'-' -- ENGINE_NO - nvarchar(50)
			,'-' -- PLAT_NO - nvarchar(50)
		);

		--/* declare variables */
		--declare @handover nvarchar(1000) ;
		--declare @req_code_before nvarchar(50) = '' ;
		--declare @req_code nvarchar(50) ;

		--update	rpt_surat_jalan
		--set		NEW_PAGES = '0'
		--where	USER_ID = @p_user_id ;

		--declare curr_asse_page cursor fast_forward read_only for
		--select		CODE
		--			,isnull(handover_to, '') + isnull(handover_phone_area, '') + isnull(handover_phone_no, '')
		--from		dbo.rpt_surat_jalan
		--where		USER_ID = @p_user_id
		--order by	isnull(handover_to, '') + isnull(handover_phone_area, '') + isnull(handover_phone_no, '') ;

		--open curr_asse_page ;

		--fetch next from curr_asse_page
		--into @req_code
		--	 ,@handover ;

		--while @@fetch_status = 0
		--begin

		--	-- AMBIL JIKA SEBELUMNYA BERBEDA MAKA JADIKAN 1
		--	if exists
		--	(
		--		select	1
		--		from	rpt_surat_jalan
		--		where	USER_ID																						  = @p_user_id
		--				and CODE																					  = @req_code_before
		--				and isnull(handover_to, '') + isnull(handover_phone_area, '') + isnull(handover_phone_no, '') <> @handover
		--	)
		--	begin
		--		update	rpt_surat_jalan
		--		set		NEW_PAGES = '1'
		--		where	USER_ID	 = @p_user_id
		--				and CODE = @req_code_before ;
		--	end ;

		--	set @req_code_before = @req_code ;

		--	fetch next from curr_asse_page
		--	into @req_code
		--		 ,@handover ;
		--end ;

		--close curr_asse_page ;
		--deallocate curr_asse_page ;
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
