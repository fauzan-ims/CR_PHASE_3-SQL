CREATE PROCEDURE dbo.xsp_rpt_borrow_bpkb
(
	@p_user_id		   nvarchar(max)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_as_of_date	   DATETIME
	,@p_is_condition   NVARCHAR(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	delete dbo.rpt_borrow_bpkb
	where	user_id = @p_user_id ;

	delete dbo.rpt_borrow_bpkb_detail
	where	user_id = @p_user_id ;

	declare @msg			  nvarchar(max)
			,@report_company  nvarchar(250)
			,@report_image	  nvarchar(250)
			,@report_title	  nvarchar(250)
			,@branch_code	  nvarchar(50)
			,@branch_name	  nvarchar(250)
			,@agreement_no	  nvarchar(50)
			,@client_name	  nvarchar(250)
			,@seq			  int
			,@merk			  nvarchar(50)
			,@model			  nvarchar(50)
			,@type			  nvarchar(50)
			,@chasis_no		  nvarchar(50)
			,@engine_no		  nvarchar(50)
			,@bpkb_no		  nvarchar(50)
			,@year			  nvarchar(4)
			,@plat_no		  nvarchar(50)
			,@faktur		  nvarchar(50)
			,@kwintasi		  nvarchar(50)
			,@registered_name nvarchar(250)
			,@reason		  nvarchar(250)
			,@borrowed_date	  datetime
			,@returned_date	  datetime
			,@respons_person  nvarchar(50)
			,@nama			  nvarchar(50)
			,@jabatan		  nvarchar(250)
			,@mo			  nvarchar(50)
			,@reasonal		  nvarchar(250);

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = VALUE
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = 'Report Borrow BPKB' ;

		select	@branch_code = value
		from	dbo.sys_global_param
		where	code = 'HO' ;

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		insert into dbo.rpt_borrow_bpkb
		(
			user_id
			,filter_branch_code
			,filter_branch_name
			,filter_as_of_date
			,report_company
			,report_title
			,report_image
			,branch_name
			,agreement_no
			,client_name
			,item_name
			--,seq
			--,merk
			--,model
			--,type
			,chasis_no
			,engine_no
			,bpkb_no
			,year
			,plat_no
			,faktur
			,kwintasi
			,registered_name
			,reason
			,borrowed_date
			,returned_date
			,respons_person
			,mo
			,input_by
			,checked_by
			,acknowledge_by
			,jabatan_acknowledge
			,nama_user
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct @p_user_id
				,@p_branch_code
				,@p_branch_name
				,@p_as_of_date
				,@report_company
				,@report_title
				,@report_image
				,aa.branch_name
				,isnull(aa.agreement_external_no,'') + ' / ' + isnull(aa.client_name,'')
				,''
				,aa.item_name
				--,((row_number() over (partition by aa.agreement_no
				--					  order by aa.agreement_no
				--					 ) - 1
				--  ) % 9999
				-- ) + 1
				--,aa.merk_name
				--,aa.model_name
				--,aa.type_name_asset
				,fam.reff_no_2
				,fam.reff_no_3
				,case when isnull(fam.doc_asset_no,'') = '' then dde.doc_no else fam.doc_asset_no end
				,case when fam.asset_year = '' then vhcl.built_year else fam.asset_year end
				,fam.reff_no_1
				,'' --kosong dlu kata pak hari nanti di tanya ke mereka
				,'' --kosong dlu kata pak hari nanti di tanya ke mereka
				,dde.doc_name--dde.document_name--vhcl.stnk_name
				,case
					when dmv.movement_location = 'BORROW CLIENT' then 'BORROW CUSTOMER'
					when dmv.movement_location = 'BRANCH' then 'BORROW BRANCH'
					when dmv.movement_location = 'CLIENT' then 'RELEASE PERMANENT'
					when dmv.movement_location = 'DEPARTMENT' then 'BORROW DEPARTMENT'
					when dmv.movement_location = 'THIRD PARTY' then 'BORROW THIRD PARTY'
					else null
				end
				,apv.result_date--dmv.movement_date
				,mov.estimate_return_date
				,mov.received_name
				----,case
				----	when aast.asset_status = 'RENTED' then am.marketing_name
				----	else null
				----end
				,isnull(am.marketing_name,'')
				,nama.name
				,null
				,@nama
				,@jabatan
				,nama.name
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.document_movement_detail dhm
				inner join dbo.document_movement dmv on dmv.code = dhm.movement_code
				inner join dbo.document_main dm on (dm.code					  = dhm.document_code)
				left join dbo.document_detail dde on (dde.document_code = dm.code)
				--inner join dbo.document_history dhist on dhist.document_code = dm.code
				inner join ifinams.dbo.asset aa on (aa.code					  = dm.asset_no)
				inner join dbo.fixed_asset_main fam on (fam.asset_no		  = dm.asset_no)
				inner join ifinams.dbo.asset_vehicle vhcl on (vhcl.asset_code = aa.code)
				left join ifinopl.dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
				left join ifinopl.dbo.agreement_asset aast on (aast.agreement_no = aa.agreement_no)
				outer apply
					(
						select	sem2.name 'name'
						from	ifinsys.dbo.sys_employee_main sem2
						where	sem2.code = @p_user_id
					) nama
				outer apply
					(
						select	top 1 dm1.received_name, dm1.estimate_return_date, dm1.code
						from	dbo.document_movement dm1
						inner join dbo.document_movement_detail dmd on dmd.movement_code = dm1.code
						where	dmd.document_code = dm.code
						AND ((dm1.MOVEMENT_STATUS <> 'CANCEL') and (NOT (dm1.MOVEMENT_LOCATION = 'borrow client' AND dm1.MOVEMENT_STATUS = 'POST')))
						order by dm1.cre_date desc
					)mov
				outer apply
					(
						select	top 1 aps.result_date 'result_date'
						from	ifinapv.dbo.approval_schedule aps 
						inner join ifinapv.dbo.approval_main am on am.code = aps.approval_code
						inner join ifinapv.dbo.approval_request ar on ar.code = am.request_code
						where mov.code =  ar.reff_no
						order by aps.result_date desc
                    ) apv
		where	dm.document_status = 'ON BORROW'--dmv.movement_status					= 'ON TRANSIT'
				AND ((dmv.MOVEMENT_STATUS <> 'CANCEL') and (NOT (dmv.MOVEMENT_LOCATION = 'borrow client' AND dmv.MOVEMENT_STATUS = 'POST')))
				--and dmv.movement_location			in ('BORROW CLIENT','BRANCH','THIRD PARTY','DEPARTMENT')
				and cast(dmv.movement_date as date) between cast(dateadd(day, -365, @p_as_of_date) as date) and cast(@p_as_of_date as date) -- info pak hari at date aja wlwpun di doc nya as of 
				and dm.branch_code                      = case @p_branch_code
				                                                        when 'ALL' then dm.branch_code
				                                                        else @p_branch_code
                                                                 end  ;

		if not exists
		(
			select	1
			from	dbo.rpt_borrow_bpkb
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_borrow_bpkb
			(
				user_id
				,filter_branch_code
				,filter_branch_name
				,filter_as_of_date
				,report_company
				,report_title
				,report_image
				,branch_name
				,agreement_no
				,client_name
				,item_name
				--,seq
				--,merk
				--,model
				--,type
				,chasis_no
				,engine_no
				,bpkb_no
				,year
				,plat_no
				,faktur
				,kwintasi
				,registered_name
				,reason
				,borrowed_date
				,returned_date
				,respons_person
				,mo
				,is_condition
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_user_id
				,@p_branch_code
				,@p_branch_name
				,@p_as_of_date
				,@report_company
				,@report_title
				,@report_image
				,@branch_name
				,@agreement_no
				,@client_name
				,null
				--,@seq
				--,@merk
				--,@model
				--,@type
				,@chasis_no
				,@engine_no
				,@bpkb_no
				,@year
				,@plat_no
				,@faktur
				,@kwintasi
				,@registered_name
				,@reason
				,@borrowed_date
				,@returned_date
				,@respons_person
				,@mo
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;

		declare cur_reason cursor fast_forward read_only for
			
		select	distinct reason
		from	dbo.RPT_BORROW_BPKB
		where	user_id = @p_user_id ;

		open cur_reason
		
		fetch next from cur_reason 
		into	@reasonal

		while @@fetch_status = 0
		begin

			insert into dbo.RPT_BORROW_BPKB_DETAIL
			(
				USER_ID
				,PRODUCT_NAME
				,REASON
				,TOTAL
			)
			select	@p_user_id
					,'OPERATING LEASE'
					,@reasonal
					,count(reason)
			from	dbo.rpt_borrow_bpkb
			where	user_id	   = @p_user_id
					and reason = @reasonal ;

			fetch next from cur_reason 
			into	@reasonal
			
		end
		close cur_reason
		deallocate cur_reason

		--insert into dbo.rpt_borrow_bpkb_detail
		--(
		--    user_id,
		--    product_name,
		--    reason,
		--    total
		--)
		--select
  --              @p_user_id
		--		,'OPERATING LEASE'
		--		,isnull(am.APPLICATION_REMARKS,'-')
		--		,count(aa.code)
		--from	dbo.document_movement_detail dhm
		--		inner join dbo.DOCUMENT_MOVEMENT dmv on dmv.CODE = dhm.MOVEMENT_CODE
		--		inner join dbo.document_main dm on (dm.code					  = dhm.DOCUMENT_CODE)
		--		--inner join dbo.DOCUMENT_HISTORY dhist on dhist.DOCUMENT_CODE = dm.CODE
		--		inner join ifinams.dbo.asset aa on (aa.code					  = dm.asset_no)
		--		inner join dbo.fixed_asset_main fam on (fam.asset_no		  = dm.asset_no)
		--		inner join ifinams.dbo.asset_vehicle vhcl on (vhcl.asset_code = aa.code)
		--		left join ifinopl.dbo.application_main am on (am.agreement_no = aa.agreement_no)
		--where	dm.document_status					= 'ON BORROW'
		--		and dmv.movement_location			in ('BORROW CLIENT','BRANCH','THIRD PARTY','DEPARTMENT')
		--		and cast(dmv.movement_date as date) = cast(@p_as_of_date as date) -- info pak hari at date aja wlwpun di doc nya as of 
		--		and dm.branch_code                      = case @p_branch_code
		--		                                                        when 'ALL' then dm.branch_code
		--		                                                        else @p_branch_code
  --                                                               end 
		--group by am.application_remarks;

		if not exists (select 1 from dbo.rpt_borrow_bpkb_detail where user_id = @p_user_id)
		begin
		   insert into dbo.rpt_borrow_bpkb_detail
		   (
				user_id,
				product_name,
				reason,
				total
		   )
		   values
		   (   @p_user_id
		      ,''
		      ,''
		      ,null
		   ) 
		end
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
