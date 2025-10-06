CREATE PROCEDURE [dbo].[xsp_application_main_getrow]
(
	@p_application_no	 nvarchar(50)
	,@p_approval_summary nvarchar(1) = ''
)
as
begin
	declare @fee_amount					   decimal(18, 2)
			,@application_survey_code	   nvarchar(50)
			,@contact_person_area_phone_no nvarchar(4)
			,@contact_person_phone_no	   nvarchar(15)
			,@client_address			   nvarchar(4000)
			,@count_installment			   int
			,@count_asset				   int
			,@is_request				   nvarchar(1)
			,@is_approval				   nvarchar(1)
			,@is_sign					   nvarchar(1)
			,@table_name				   nvarchar(250)
			,@sp_name					   nvarchar(250)
			,@check_black_list_url		   nvarchar(250) 
			,@count_deliver_asset		   int
			,@last_approval_code		   nvarchar(50)

	select	@check_black_list_url = value
	from	dbo.sys_global_param
	where	code = 'ENFOU09' ;

	--select table Report
	select	@table_name = table_name
			,@sp_name = sp_name
	from	dbo.sys_report
	where	table_name = 'RPT_ASSET_ALLOCATION_PERMOHONAN_PENGIRIMAN_BARANG' ;

	select	@count_asset = count(1)
	from	dbo.application_asset
	where	application_no = @p_application_no ;

	select	@fee_amount = isnull(sum(fee_amount), 0)
	from	dbo.application_fee
	where	application_no = @p_application_no ;


	select	@is_approval = isnull(mafd.is_approval, '0')
			,@is_sign = isnull(mafd.is_sign, '0')
	from	dbo.application_information am
			inner join dbo.master_application_flow_detail mafd on (mafd.workflow_code = am.application_flow_code)
	where	am.application_no = @p_application_no ;

	if exists
	(
		select	1
		from	dbo.application_information
		where	application_no	 = @p_application_no
				and isnull(approval_code, '') <> ''
	)
	begin
		select		@last_approval_code = max(am.code)
		from		dbo.opl_interface_approval_request piar
					inner join ifinapv.dbo.apv_interface_approval_request apiar on apiar.code = piar.code
					inner join ifinapv.dbo.approval_request ar on ar.code					  = apiar.code
					inner join ifinapv.dbo.approval_main am on am.request_code				  = ar.code
		where		apiar.reff_no = @p_application_no
	end ;

	if (@p_approval_summary <> '')
	begin
		select	ap.application_no
				,ap.branch_code
				,ap.branch_name
				,ap.application_date
				,ap.application_date 'applicationDate' -- for validasi di screen
				,ap.application_status
				,ap.level_status 'level_code'
				,isnull(mw.description, ap.level_status) 'level_status'
				,case
					 when ap.application_date is null then '1'
					 else '0'
				 end 'is_application_date'
				,ap.application_external_no
				,ap.application_remarks
				,ap.branch_region_code
				,ap.branch_region_name
				,ap.marketing_code
				,ap.marketing_name
				,ap.facility_code
				,ap.currency_code
				,ap.golive_date
				,ap.agreement_sign_date
				,ap.first_installment_date
				,'0' 'is_blacklist_area'
				,cm.watchlist_status
				,ap.is_blacklist_job
				,ap.client_code
				,cm.client_no
				,cm.client_id
				,cm.client_type
				,ca.address
				,cd.document_no
				,isnull(cpi.area_mobile_no, cci.area_mobile_no) 'area_mobile_no'
				,isnull(cpi.mobile_no, cci.mobile_no) 'mobile_no'
				,mf.description 'facility_desc'
				,mafd.is_approval 'is_approval'
				,ai.is_refunded
				,ap.return_count
				,ap.agreement_no
				,ap.agreement_external_no
				,ap.rental_amount
				,@fee_amount 'total_fee_amount'
				,ap.periode
				,ap.billing_type
				,mbt.description 'billing_type_desc'
				,@count_asset 'count_asset'
				,ap.first_payment_type
				,ap.credit_term
				,isnull(ap.lease_option, 'FULL') 'lease_option'
				,ap.is_purchase_requirement_after_lease
				,ap.round_type
				,ap.round_amount
				,@is_approval 'is_approval'
				,@table_name 'table_name'
				,@sp_name 'sp_name'
				,ap.client_name
				,ap.client_phone_area
				,ap.client_phone_no
				,ap.client_email
				,ap.client_address
				,ap.is_simulation
				,aex.main_contract_no
				,@check_black_list_url 'check_black_list_url'
				,@is_sign 'is_sign'
				,@last_approval_code 'last_approval_code'
				,ai.approval_code
		from	application_main ap
				left join dbo.master_billing_type mbt on (mbt.code = ap.billing_type)
				left join dbo.client_main cm on (cm.code = ap.client_code)
				left join dbo.client_personal_info cpi on (cpi.client_code = cm.code)
				left join dbo.client_corporate_info cci on (cci.client_code = cm.code)
				--left join dbo.client_address ca on (
				--									   ca.client_code								= cm.code
				--									   and ca.is_legal								= '1'
				--								   )
				outer apply
		(
			select	top 1
					ca.address
			from	dbo.client_address ca
			where	ca.client_code	= cm.code
					and ca.is_legal = '1'
		) ca
				--left join dbo.client_doc cd on (
				--								   cd.client_code									= cm.code
				--								   and cd.doc_type_code								= 'TAXID'
				--							   )
				outer apply
		(
			select	top 1
					cd.document_no
			from	dbo.client_doc cd
			where	cd.client_code		 = cm.code
					and cd.doc_type_code = 'TAXID'
		) cd
				left join dbo.master_facility mf on (mf.code										= ap.facility_code)
				left join dbo.master_workflow mw on (mw.code										= ap.level_status)
				left join dbo.application_information ai on (ai.application_no						= ap.application_no)
				left join dbo.master_application_flow_detail mafd on (
																		 mafd.application_flow_code = ai.application_flow_code
																		 and   mafd.workflow_code	= ap.level_status
																	 )
				left join dbo.application_extention aex on (aex.application_no						= ap.application_no)
		where	ap.application_no = @p_application_no ;
	end ;
	else
	begin

		select	@count_installment = count(1)
		from	dbo.application_amortization
		where	application_no = @p_application_no ;
	
		select	top 1
				@application_survey_code = code
		from	dbo.application_survey_request
		where	application_no = @p_application_no
				and survey_status in
		(
			'HOLD', 'REQUEST', 'POST'
		) ;

		if not exists
		(
			select	1
			from	dbo.application_survey_request
			where	application_no = @p_application_no
					and survey_status in
		(
			'HOLD', 'REQUEST', 'POST'
		)
		)
		begin
			set @is_request = N'1' ;
		end ;
		else
		begin
			set @is_request = N'0' ;
		end ;
		
		select	top 1
				@client_address = ca.province_name + N' - ' + ca.city_name + N' - ' + ca.zip_code_code + N' - ' + ca.address
				,@contact_person_area_phone_no = isnull(cci.contact_person_area_phone_no, cpi.area_mobile_no)
				,@contact_person_phone_no = isnull(cci.contact_person_phone_no, cpi.mobile_no)
		from	dbo.client_address ca
				inner join dbo.application_main am on (am.client_code		= ca.client_code)
				left join dbo.client_corporate_info cci on (cci.client_code = am.client_code)
				left join dbo.client_personal_info cpi on (cpi.client_code	= am.client_code)
		where	am.application_no = @p_application_no
				and ca.is_legal	  = '1' ;

		select	@count_deliver_asset = count(1)
		from	dbo.application_asset
		where	application_no			= @p_application_no
				and (purchase_status		<> 'AGREEMENT'
				or	purchase_gts_status <> 'AGREEMENT') ;

		select	ap.application_no
				,ap.branch_code
				,ap.branch_name
				,ap.application_date
				,ap.application_date 'applicationDate' -- for validasi di screen
				,ap.application_status
				,ap.level_status 'level_code'
				,isnull(mw.description, ap.level_status) 'level_status'
				,case
					 when ap.application_date is null then '1'
					 else '0'
				 end 'is_application_date'
				,ap.application_external_no
				,ap.application_remarks
				,ap.branch_region_code
				,ap.branch_region_name
				,ap.marketing_code
				,ap.marketing_name
				,ap.facility_code
				,ap.currency_code
				,ap.golive_date
				,ap.agreement_sign_date
				,ap.first_installment_date
				,'0' 'is_blacklist_area'
				,cm.watchlist_status
				,ap.is_blacklist_job
				,ap.client_code
				,cm.client_no
				,cm.client_id
				,cm.client_type
				,ca.address
				,cd.document_no
				,isnull(cpi.area_mobile_no, cci.area_mobile_no) 'area_mobile_no'
				,isnull(cpi.mobile_no, cci.mobile_no) 'mobile_no'
				,mf.description 'facility_desc'
				,mafd.is_approval 'is_approval'
				,ai.is_refunded
				,ap.return_count
				,ap.agreement_no
				,ap.agreement_external_no
				,@fee_amount 'total_fee_amount'
				--,aa.asset_no
				,ap.rental_amount
				,@application_survey_code 'application_survey_code'
				,isnull(@count_installment, 0) 'count_installment'
				,@contact_person_area_phone_no 'contact_person_area_phone_no'
				,@contact_person_phone_no 'contact_person_phone_no'
				,@is_request 'is_request'
				,ap.periode
				,ap.billing_type
				,mbt.description 'billing_type_desc'
				,@count_asset 'count_asset'
				,ap.first_payment_type
				,ap.credit_term
				,ap.lease_option
				,ap.is_purchase_requirement_after_lease
				,ap.round_type
				,ap.round_amount
				,@is_approval 'is_approval'
				,@table_name 'table_name'
				,@sp_name 'sp_name'
				,ap.client_name
				,ap.client_phone_area
				,ap.client_phone_no
				,ap.client_email
				,isnull(ap.client_address, @client_address) 'client_address'
				,ap.is_simulation
				,aex.main_contract_no
				,@check_black_list_url 'check_black_list_url'
				,@is_sign 'is_sign'
				,isnull(@count_deliver_asset, 0) 'count_deliver_asset'
				,@last_approval_code 'last_approval_code'
				,ai.approval_code
		from	application_main ap
				left join dbo.master_billing_type mbt on (mbt.code = ap.billing_type)
				left join dbo.client_main cm on (cm.code = ap.client_code)
				left join dbo.client_personal_info cpi on (cpi.client_code = cm.code)
				left join dbo.client_corporate_info cci on (cci.client_code = cm.code)
				--left join dbo.client_address ca on (
				--									   ca.client_code								= cm.code
				--									   and ca.is_legal								= '1'
				--								   )
				outer apply
		(
			select	top 1
					ca.address
			from	dbo.client_address ca
			where	ca.client_code	= cm.code
					and ca.is_legal = '1'
		) ca
				--left join dbo.client_doc cd on (
				--								   cd.client_code									= cm.code
				--								   and cd.doc_type_code								= 'TAXID'
				--							   )
				outer apply
		(
			select	top 1
					cd.document_no
			from	dbo.client_doc cd
			where	cd.client_code		 = cm.code
					and cd.doc_type_code = 'TAXID'
		) cd
				left join dbo.master_facility mf on (mf.code										= ap.facility_code)
				left join dbo.master_workflow mw on (mw.code										= ap.level_status)
				left join dbo.application_information ai on (ai.application_no						= ap.application_no)
				left join dbo.master_application_flow_detail mafd on (
																		 mafd.application_flow_code = ai.application_flow_code
																		 and   mafd.workflow_code	= ap.level_status
																	 )
				--left join dbo.application_asset aa on (aa.application_no							= ap.application_no)
				left join dbo.application_extention aex on (aex.application_no						= ap.application_no)
		where	ap.application_no = @p_application_no ;
	end ;
end ;
