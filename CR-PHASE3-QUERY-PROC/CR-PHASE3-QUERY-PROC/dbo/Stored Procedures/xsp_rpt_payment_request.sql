--created by, Bilal at 04/07/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_payment_request]
(
	@p_user_id		   nvarchar(max)
	,@p_payment_code   nvarchar(50)
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
	delete	dbo.rpt_payment_request
	where	user_id = @p_user_id ;

	--(Untuk Data looping)
	delete	dbo.rpt_payment_request_detail
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_image	 nvarchar(250)
			,@report_title	 nvarchar(250)
			,@nama_kepada	 nvarchar(250)
			,@nama_dari		 nvarchar(250)
			,@nama_cc		 nvarchar(250)
			,@tanggal		 datetime
			,@no_memo		 nvarchar(50)
			,@perihal		 nvarchar(250)
			,@customer_name	 nvarchar(250)
			,@supplier_name	 nvarchar(250)
			,@no_kontrak	 nvarchar(50)
			,@rek_atas_nama	 nvarchar(50)
			,@no_account	 nvarchar(50)
			,@nama_bank		 nvarchar(50)
			,@nominal		 decimal(18, 2)
			,@year			 nvarchar(4)
			,@month			 nvarchar(2)
			,@code			 nvarchar(50)
			,@branch_code	 nvarchar(50)
			,@nama			 nvarchar(50)
			,@jabatan		 nvarchar(50)
			,@nama_pembuat   nvarchar(50)
			,@disetujui_i	 nvarchar(50)
			,@disetujui_ii	 nvarchar(50);

	begin try
		delete	dbo.rpt_payment_request
		where	user_id = @p_user_id ;
		
		delete	dbo.rpt_payment_request_detail -- Hari - 22.Aug.2023 04:10 PM --	
		where	user_id = @p_user_id ;

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @report_title = N'Report Payment Request' ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = 'DSF'
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'OPL'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'AP_PAYMENT_REQUEST'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		update	dbo.ap_payment_request
		set		memo_code = @code
		where	code = @p_payment_code ;

		select	@branch_code = branch_code
		from	dbo.ap_payment_request
		where	CODE = @p_payment_code ;

		select	@nama_pembuat = sem.name
		from	ifinsys.dbo.sys_employee_main sem
		where	code = @p_cre_by ;

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		select	@disetujui_i = sbs.signer_name
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'DIREK'
				and sbs.branch_code = @branch_code ;

		select	@disetujui_i = sem.name
		from	ifinapv.dbo.master_approval_level mal
				inner join ifinapv.dbo.master_approval_level_position mall on mall.approval_level_code = mal.code
				inner join ifinsys.dbo.sys_employee_position sep on sep.position_code				   = mall.position_code
																	and sep.base_position			   = '1'
				inner join ifinsys.dbo.sys_position spo on spo.code									   = sep.position_code
				inner join ifinsys.dbo.sys_employee_main sem on sem.code							   = sep.emp_code
		where	mal.approval_code				   = 'APV.2308.000005'
				and mal.approval_level_from_amount > 5000000000 ;

		insert into dbo.rpt_payment_request
		(
			user_id
			,payment_code
			,report_company
			,report_title
			,report_image
			,nama_kepada
			,nama_dari
			,nama_cc
			,tanggal
			,no_memo
			,perihal
			--,customer_name
			,supplier_name
			--,no_kontrak
			,rek_atas_nama
			,no_account
			,nama_bank
			,nominal
			,PAYMENT_REMARK
			,DISIAPKAN_OLEH
			,DICEK_OLEH
			,DIKETAHUI_OLEH_I
			,DIKETAHUI_OLEH_II
			,DISETUJUI_OLEH_I
			,DISETUJUI_OLEH_II
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,@p_payment_code
				,@report_company
				,@report_title
				,@report_image
				,'Direksi PT. Dipo Star Finance'
				,'OPL Department'
				,'Treasury Dept'
				,dbo.xfn_get_system_date()
				,apr.memo_code
				,stuff((
						select	distinct ', ' + isnull(replace(pod1.po_code, '&', ' DAN '), '')
						from	dbo.ap_payment_request apr1
								left join dbo.ap_payment_request_detail aprd1 on (aprd1.payment_request_code	 = apr1.code)
								left join dbo.ap_invoice_registration_detail ird1 on (ird1.invoice_register_code = aprd1.invoice_register_code)
								left join dbo.purchase_order_detail pod1 on pod1.id								 = ird1.purchase_order_id
						where	apr1.code = apr.code
						for xml path('')
					   ), 1, 1, ''
					  )
				--,case
				--	 when apm.CLIENT_NAME is not null then 'Permohonan Pembayaran Unit OPL ' + isnull(apm.client_name, '')
				--	 else apr.remark collate SQL_Latin1_General_CP1_CI_AS
				-- end
				--,isnull(apm.client_name, '-')
				,apr.supplier_name
				--,isnull(apm.application_external_no, '-')
				,apr.to_bank_account_name
				,apr.to_bank_account_no
				,apr.to_bank_name
				,apr.invoice_amount
				,apr.REMARK
				,@nama_pembuat
				,'HERNI. H'
				,'RYANTHO'
				,@nama
				,@disetujui_i
				,@disetujui_ii
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.ap_payment_request						 apr
				left join dbo.ap_payment_request_detail		 aprd on (aprd.payment_request_code			 = apr.code)
				left join dbo.ap_invoice_registration_detail ird on (ird.invoice_register_code			 = aprd.invoice_register_code)
				left join dbo.good_receipt_note_detail		 grnd on (grnd.good_receipt_note_code		 = ird.grn_code)
				left join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.good_receipt_note_detail_id = grnd.id)
				left join ifinopl.dbo.application_asset		 ass on (ass.asset_no						 = fgrnd.reff_no)
				left join ifinopl.dbo.application_main		 apm on (apm.application_no					 = ass.application_no)
				--left join dbo.purchase_order_detail pod on pod.id = ird.purchase_order_id
		where	apr.code = @p_payment_code ;

		insert into dbo.rpt_payment_request_detail
		(
			user_id
			,customer_name
			,no_kontrak
			,nama_unit
			,no_rangka
			,no_mesin
			,nopol
			,harga_exc_vat
			,vat
			,harga_inc_vat
		)
		select	@p_user_id
				,apm.client_name
				,apm.agreement_external_no
				,aird.item_name
				,isnull(podo.chassis_no, '-')
				,isnull(podo.engine_no, '-')
				,isnull(podo.plat_no, '-')
				,(aird.purchase_amount) - aird.discount
				,aird.ppn
				,(((aird.purchase_amount) - aird.discount) + aird.ppn - aird.pph)
		from	dbo.ap_payment_request_detail					aprd
				inner join dbo.ap_invoice_registration_detail	aird on (aird.invoice_register_code		  = aprd.invoice_register_code)
				inner join dbo.good_receipt_note_detail			grnd on (
																			grnd.good_receipt_note_code	  = aird.grn_code
																			and grnd.item_code			  = aird.item_code collate latin1_general_ci_as
																		)
				inner join dbo.purchase_order_detail			pod on grnd.purchase_order_detail_id	  = pod.id
				left join dbo.purchase_order_detail_object_info podo on (podo.good_receipt_note_detail_id = grnd.id)
				left join dbo.final_good_receipt_note_detail fgrnd on (fgrnd.good_receipt_note_detail_id = grnd.id)
				left join ifinopl.dbo.application_asset		 ass on (ass.asset_no						 = fgrnd.reff_no)
				left join ifinopl.dbo.application_main		 apm on (apm.application_no					 = ass.application_no)
		where	aprd.payment_request_code = @p_payment_code ;

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
