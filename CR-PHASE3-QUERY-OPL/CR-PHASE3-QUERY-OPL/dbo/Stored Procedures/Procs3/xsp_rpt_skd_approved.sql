--created by, Rian at 21/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_skd_approved
(
	@p_user_id		   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_from_date	   datetime
	,@p_to_date		   datetime
	,@p_is_condition   nvarchar(1)
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
	delete dbo.rpt_skd_approved
	where	user_id = @p_user_id ;

	declare @msg			   nvarchar(max)
			,@report_company   nvarchar(250)
			,@report_image	   nvarchar(250)
			,@report_title	   nvarchar(250)
			,@head			   nvarchar(250)
			,@pic_mkt		   nvarchar(250)
			,@skd_number	   nvarchar(50)
			,@customer_name	   nvarchar(250)
			,@total			   int	
			,@merk			   nvarchar(50)
			,@unit_type		   nvarchar(250)
			,@product_category nvarchar(50)
			,@unit_condition   nvarchar(50)
			,@tenor			   int
			,@date_of_approval datetime
			,@lr_pct		   decimal(9, 6)
			,@rv_pct		   decimal(9, 6)
			,@roa_pct		   decimal(9, 6)
			,@remarks		   nvarchar(4000)
			,@branch_name	   nvarchar(250) ;

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = 'Report SKD Approved' ;

		insert into dbo.rpt_skd_approved
		(
			user_id
			,REPORT_COMPANY
			,report_image
			,report_title
			,from_date
			,to_date
			,head
			,pic_mkt
			,skd_number
			,customer_name
			,total
			,merk
			,unit_type
			,product_category
			,unit_condition
			,tenor
			,date_of_approval
			,lr_pct
			,rv_pct
			,roa_pct
			,remarks
			,branch_code
			,branch_name
			,is_condition
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,@p_from_date
				,@p_to_date
				,sem.name 'head_emp_name'
				,am.marketing_name
				,am.application_external_no
				,am.client_name
				,aa.total_asset
				,stuff((
						   select	distinct ', ' + isnull(replace(count(mvm.DESCRIPTION),'&',' DAN '), ''), ', ' + isnull(replace(mvm.description,'&',' DAN '), '')
						   from		dbo.application_asset aps
									inner join dbo.application_asset_vehicle asv on (asv.asset_no = aps.asset_no)
									inner join dbo.master_vehicle_merk mvm on (mvm.code = asv.vehicle_merk_code)
						   where	aps.application_no = am.application_no
						   group by mvm.description
						   for xml path('')
					   ), 1, 1, ''
					  )
				,stuff((
						   select	distinct ', ' + isnull(replace(count(mvu.description),'&',' DAN '), ''), ', ' + isnull(replace(mvu.description,'&',' DAN '), '')
						   from		dbo.application_asset aps
									inner join dbo.application_asset_vehicle asv on (asv.asset_no = aps.asset_no)
									inner join dbo.master_vehicle_unit mvu on (mvu.code = asv.vehicle_unit_code)
						   where	aps.application_no = am.application_no
						   group by mvu.description
						   for xml path('')
					   ), 1, 1, ''
					  )
				,stuff((
						   select	distinct ', ' + isnull(replace(count(mvc.description),'&',' DAN '), ''), ', ' + isnull(replace(mvc.description,'&',' DAN '), '')
						   from		dbo.application_asset aps
									inner join dbo.application_asset_vehicle asv on (asv.asset_no = aps.asset_no)
									inner join dbo.master_vehicle_category mvc on (mvc.code = asv.vehicle_category_code)
						   where	aps.application_no = am.application_no
						   group by mvc.description
						   for xml path('')
					   ), 1, 1, ''
					  )
				,stuff((
						   select	distinct ', ' + isnull(replace(count(aps.asset_condition ),'&',' DAN '), ''), ', ' + isnull(replace(aps.asset_condition,'&',' DAN '), '')
						   from		dbo.application_asset aps
						   where	aps.application_no = am.application_no
						   group by aps.asset_condition
						   for xml path('')
					   ), 1, 1, ''
					  )
				,am.periode
				,apv.last_result_result_date
				,aa.asset_interest_rate--aa.borrowing_interest_rate
				,aa.asset_rv_pct
				,aa.roa_pct
				,am.application_remarks
				,@p_branch_code
				,@p_branch_name
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.application_main am
				left join ifinsys.dbo.sys_employee_main sem on (sem.code = am.marketing_code)
				outer apply
				(
					select	count(aas.asset_no) 'total_asset'
							,avg(isnull(aas.borrowing_interest_rate, 0)) 'borrowing_interest_rate'
							,avg(isnull(aas.asset_interest_rate, 0)) 'asset_interest_rate'
							,avg(isnull(aas.asset_rv_pct, 0)) 'asset_rv_pct'
							,avg(isnull(aas.roa_pct, 0)) 'roa_pct'
					from	dbo.application_asset aas
					where	aas.application_no = am.application_no
				) aa
				outer apply
				(
					select	max(apm.last_result_result_date) 'last_result_result_date'
					from	ifinapv.dbo.approval_request apr
							inner join ifinapv.dbo.approval_main apm on (apm.request_code = apr.code)
					where	apr.reff_no				 = am.application_no
							and apr.reff_module_code = 'IFINOPL'
							and apm.approval_status	 = 'APPROVE'
				) apv
		where	am.application_status				  in ('APPROVE', 'GO LIVE')
				and am.is_simulation				  = '0'
				and branch_code						  = case @p_branch_code
															when 'ALL' then branch_code
															else @p_branch_code
														end
				and cast(apv.last_result_result_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

		if not exists
		(
			select	1
			from	dbo.rpt_skd_approved
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_skd_approved
			(
				user_id
				,report_company
				,report_image
				,report_title
				,from_date
				,to_Date
				,head
				,pic_mkt
				,skd_number
				,customer_name
				,total
				,merk
				,unit_type
				,product_category
				,unit_condition
				,tenor
				,date_of_approval
				,lr_pct
				,rv_pct
				,roa_pct
				,remarks
				,branch_code
				,branch_name
				,is_condition
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,@p_from_date
				,@p_to_date
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,@p_branch_code
				,@p_branch_name
				,@p_is_condition
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
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
