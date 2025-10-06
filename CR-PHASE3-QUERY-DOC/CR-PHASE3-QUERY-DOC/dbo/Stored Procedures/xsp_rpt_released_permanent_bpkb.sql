--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_released_permanent_bpkb
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(50) = ''
	,@p_from_date		datetime
    ,@p_to_date			datetime
	--,@p_as_of_date	 nvarchar(50) = ''
	,@p_is_condition	nvarchar(1) --(+) Untuk Kondisi Excel Data Only
)
as
begin
	delete rpt_released_permanent_bpkb
	where	user_id = @p_user_id ;

	delete dbo.rpt_released_permanent_bpkb_summary
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250)
			,@report_image	 nvarchar(250)
			,@branch_code	 nvarchar(50)
			,@branch_name	 nvarchar(50)
			,@agreement_no	 nvarchar(50)
			,@client_name	 nvarchar(50)
			,@seq			 int
			,@merk			 nvarchar(50)
			,@model			 nvarchar(50)
			,@type			 nvarchar(50)
			,@chassis_no	 nvarchar(50)
			,@engine_no		 nvarchar(50)
			,@bpkb_no		 nvarchar(50)
			,@year			 int
			,@plat_no		 nvarchar(50)
			,@reason		 nvarchar(50)
			,@release_date	 datetime
			,@release_by	 nvarchar(50) 
			,@nama			 nvarchar(50)
			,@jabatan		 nvarchar(50);

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = 'Report Released Permanent BPKB' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		if @p_branch_code = 'ALL'
			select	@branch_code = value
			from	dbo.SYS_GLOBAL_PARAM
			where	code = 'HO' ;
	
		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		begin
			insert into rpt_released_permanent_bpkb
			(
				user_id
				,report_company
				,report_title
				,report_image
				,filter_branch_name
				,branch_code
				,branch_name
				,filter_from_date
				,filter_to_date
				,agreement_no
				,client_name
				,seq
				,merk
				,model
				,type
				,chassis_no
				,engine_no
				,bpkb_no
				,year
				,plat_no
				,reason
				,release_date
				,release_by
				,NAMA_USER
				,NAMA_ACKNOWLEDGE
				,JABATAN_ACKNOWLEDGE
				--	
				,is_condition
			)
			select		@p_user_id
						,@report_company
						,@report_title
						,@report_image
						,@p_branch_name
						,dm.BRANCH_CODE
						,sb.name--dm.branch_name
						,@p_from_date
						,@p_to_date
						,isnull(aa.agreement_external_no,'') + '/' + isnull(aa.client_name,'')
						,null--aa.client_name
						,((row_number() over (partition by aa.agreement_no
											  order by aa.agreement_no
											 ) - 1
						  ) % 9999
						 ) + 1 -- untuk nyari brpa byk asset nya utk masing2 kontrak 			
						,''
						,''
						,aa.ITEM_NAME
						,isnull(fam.reff_no_2,'') + '/' +isnull(fam.reff_no_3,'')
						,null--fam.reff_no_3
						,case when isnull(dde.doc_no,'') = '' then fam.doc_asset_no else dde.doc_no end
						,case when isnull(fam.asset_year,'') = '' then vhcl.built_year else fam.asset_year end
						,fam.reff_no_1
						,dmv.movement_remarks
						--,max(dhs.movement_date)
						,max(dhs.mod_date) -- (+) Ari 2023-11-30 ket : get last date approve
						,dmv.movement_by_emp_name
						,nama.name
						,@nama
						,@jabatan
						,@p_is_condition
			from		dbo.document_movement dmv
						inner join dbo.document_movement_detail mmd on (mmd.movement_code  = dmv.code)
						inner join dbo.document_main dm on (dm.code						   = mmd.document_code)
						left join dbo.document_detail dde on (dde.document_code = dm.code)
						inner join dbo.fixed_asset_main fam on (fam.asset_no			   = dm.asset_no)
						inner join ifinams.dbo.asset aa on (aa.code						   = fam.asset_no)
						inner join ifinams.dbo.asset_vehicle vhcl on (vhcl.asset_code = aa.code)
						left join ifinsys.dbo.sys_branch sb on sb.code = dm.branch_code
						left join dbo.document_history dhs on (
																  dhs.document_code		   = dm.code
																  and  dhs.document_status = 'RELEASE'
															  )
						outer apply
						(
							select	sem2.name 'name'
							from	ifinsys.dbo.sys_employee_main sem2
							where	sem2.code = @p_user_id
						) nama
			where		dm.document_status										  = 'RELEASE'
						and dhs.document_status =  'RELEASE'
						and	dmv.movement_location = 'CLIENT'		--Raffy 2024-09-24 (+) agar yang terambil hanya data document yang di released saja 
						and dm.document_type = 'BPKB'
						--and cast(isnull(dhs.movement_date, '1900-01-01') as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						and cast(isnull(dhs.mod_date, '1900-01-01') as date) between cast(@p_from_date as date) and cast(@p_to_date as date) -- (+) Ari 2023-11-30
						and dmv.branch_code = case @p_branch_code
										  when 'ALL' then dmv.branch_code
										  else @p_branch_code
									  end
			group by	dm.branch_code
						,sb.name--dm.branch_name
						,aa.agreement_no
						,agreement_external_no
						,aa.client_name
						,aa.ITEM_NAME
						,aa.type_name_asset
						,fam.reff_no_2
						,fam.reff_no_3
						,fam.doc_asset_no
						,fam.asset_year
						,fam.reff_no_1
						,dmv.movement_remarks
						,dmv.movement_by_emp_name
						,nama.name
						,case when isnull(dde.doc_no,'') = '' then fam.doc_asset_no else dde.doc_no end
						,case when isnull(fam.asset_year,'') = '' then vhcl.built_year else fam.asset_year end
		end ;

		insert into dbo.rpt_released_permanent_bpkb_summary
		(
			user_id
			,report_company
			,report_title
			,report_image
			,branch_code
			,branch_name
			,product
			,reason
			,total
		)
		select	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_code
				,@p_branch_name
				,'OPERATING LEASE'
				,REASON
				,count(reason)
		FROM dbo.RPT_RELEASED_PERMANENT_BPKB
		where user_id = @p_user_id
		group by reason
		--select		@p_user_id
		--			,@report_company
		--			,@report_title
		--			,@report_image
		--			,@branch_code
		--			,@branch_name
		--			,'OPERATING LEASE'
		--			,dmv.movement_remarks
		--			,count(aa.code)
		--from		dbo.document_movement dmv
		--			inner join dbo.document_movement_detail mmd on (mmd.movement_code  = dmv.code)
		--			inner join dbo.document_main dm on (dm.code						   = mmd.document_code)
		--			inner join dbo.fixed_asset_main fam on (fam.asset_no			   = dm.asset_no)
		--			inner join ifinams.dbo.asset aa on (aa.code						   = fam.asset_no)
		--			left join dbo.document_history dhs on (
		--													  dhs.document_code		   = dm.code
		--													  and  dhs.document_status = 'RELEASE'
		--												  )
		--where		dm.document_status										  = 'RELEASE'
		--			and cast(isnull(dhs.movement_date, '1900-01-01') as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		--			and dmv.branch_code = case @p_branch_code
		--								  when 'ALL' then dmv.branch_code
		--								  else @p_branch_code
		--							  end
		--group by	dmv.movement_remarks ;

		if not exists
		(
			select	1
			from	dbo.rpt_released_permanent_bpkb
			where	user_id = @p_user_id
		)
		begin
			insert into rpt_released_permanent_bpkb
			(
				user_id
				,report_company
				,report_title
				,report_image
				,filter_branch_name
				,branch_code
				,branch_name
				,filter_from_date
				,filter_to_date
				,agreement_no
				,client_name
				,seq
				,merk
				,model
				,type
				,chassis_no
				,engine_no
				,bpkb_no
				,year
				,plat_no
				,reason
				,release_date
				,release_by
				,is_condition
			)
			values
			(	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_branch_name
				,@p_branch_code
				,''
				,@p_from_date
				,@p_to_date
				,''
				,''
				,null
				,''
				,''
				,''
				,''
				,''
				,''
				,null
				,''
				,''
				,null
				,''
				,@p_is_condition
			) ;

			if not exists
			(
				select	1
				from	dbo.rpt_released_permanent_bpkb_summary
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_released_permanent_bpkb_summary
				(
					user_id
					,report_company
					,report_title
					,report_image
					,branch_code
					,branch_name
					,product
					,reason
					,total
				)
				values
				(	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@branch_code
					,@branch_name
					,''
					,''
					,null
				) ;
			end ;
		end ;
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
