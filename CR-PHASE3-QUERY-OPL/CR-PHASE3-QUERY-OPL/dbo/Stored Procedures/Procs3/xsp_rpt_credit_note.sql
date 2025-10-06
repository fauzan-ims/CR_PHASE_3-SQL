CREATE PROCEDURE dbo.xsp_rpt_credit_note
(
	@p_user_id		   nvarchar(50)
	,@p_credit_no	   nvarchar(50)
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
	delete dbo.RPT_CREDIT_NOTE
	where	user_id = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			,@tanggal				datetime
			,@star_periode			datetime
			,@end_periode			datetime
			,@jatuh_tempo			datetime
			,@no_perjanjian			nvarchar(50)
			,@client_name			nvarchar(50)
			,@alamat_client			nvarchar(4000)
			,@npwp_no				nvarchar(50)
			,@jenis					nvarchar(50)
			,@type					nvarchar(50)
			,@uraian				nvarchar(50)
			,@unit					int
			,@jumlah				int
			,@harga_perunit			decimal(18, 2)
			,@jumlah_harga			decimal(18, 2)
			,@sub_total				decimal(18, 2)
			,@ppn					decimal(18, 2)
			,@ppn_pct				decimal(9, 6)
			,@total					decimal(18, 2)
			,@sejumlah				nvarchar(250)
			,@nama_bank				nvarchar(50)
			,@rek_atas_nama			nvarchar(50)
			,@no_rek				nvarchar(50)
			,@employee_name			nvarchar(50)
			,@employee_position		nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@periode_star			datetime
			,@periode_end			datetime
			,@contract_star			datetime
			,@contract_end			datetime
			,@sum_agreement			decimal(18, 2)
			,@sum_jenis_or_type		decimal(18, 2)
			,@sum_unit				decimal(18, 2)
			,@npwp_company			nvarchar(50)
			,@invoice_date			datetime
			,@invoice_due_date		datetime
			,@address				nvarchar(250)
			,@client_npwp			nvarchar(50)
			,@item_name				nvarchar(50)
			,@quantity				int
			,@total_amount			decimal(18, 2)
			,@total_ppn_amount		int
			,@bank_name				nvarchar(50)
			,@total_amount2			decimal(18, 2)
			,@bank_account_name		nvarchar(50)
			,@bank_account_no		nvarchar(50)
			,@billing_amount		decimal(18, 2)
			,@invoice_type			nvarchar(20)
			,@periode_denda_from	datetime
			,@periode_denda_to		datetime
			,@total_jumlah_harga	decimal(18, 2)
			,@jumlah_agreement		int
			,@jumlah_item			int
			,@jumlah_quantity		int
			,@jumlah_harga1			decimal(18, 2)
			,@total_jumlah_harga1	decimal(18, 2)
			,@plat_no				nvarchar(50)
			,@agreement_external_no nvarchar(50)
			,@branch_code			nvarchar(50)
			,@agreement_date		datetime
			,@invoice_external_no	nvarchar(50)
			,@inv_name				nvarchar(250) 
			,@periode_sewa_asset	nvarchar(4000)
			,@count_agreement_no	int
            ,@multiplier			int
			,@min_invoice_date		datetime
			,@max_invoice_date		datetime 
			,@remarks				nvarchar(4000)
			,@nama					nvarchar(250)
			,@report_address		nvarchar(250)
			,@ho_branch_code		nvarchar(50)
			,@company_fax_area		nvarchar(5)
			,@company_fax_phone		nvarchar(50)
			,@company_telp_area	 	nvarchar(50)
			,@company_telp_area1	nvarchar(50)
			,@company_telp	 		nvarchar(50)
			,@company_fax	 		nvarchar(50)
			,@branch_name			nvarchar(250);

	begin try
		
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@npwp_company = value
		from	dbo.sys_global_param
		where	code = 'INVNPWP' ;

		select	@ho_branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

		select	@employee_name = sem.name
		from	ifinsys.dbo.sys_employee_main sem
		where	sem.code = @p_user_id ;

		select	@branch_code = branch_code
		from	dbo.credit_note
		where	code = @p_credit_no ;

		select	@ppn_pct = value
		from	dbo.sys_global_param
		where	code = 'RTAXPPN' ;

		select	@bank_name = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@bank_account_no = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@bank_account_name = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		select	@employee_name = sbs.signer_name 
				,@employee_position = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		select	@report_address = address
				,@company_telp_area = area_phone_no
				,@company_telp_area1 = phone_no
				,@company_fax_area = area_fax_no
				,@company_fax_phone = fax_no
				,@branch_name = name
		from	ifinsys.dbo.sys_branch
		where	code = @branch_code;

		set @report_title='CREDIT NOTE';

		begin
			insert into dbo.RPT_CREDIT_NOTE
			(
				USER_ID
				,NO_CREDIT_NOTE
				,REPORT_COMPANY
				,REPORT_TITLE
				,REPORT_ADDRESS
				,REPORT_PHONE_NO
				,REPORT_FAX_NO
				,REPORT_IMAGE
				,TANGGAL
				,NPWP_COMPANY
				,STAR_PERIODE
				,END_PERIODE
				,NO_PERJANJIAN
				,CLIENT_NAME
				,ALAMAT_CLIENT
				,NPWP_NO
				,JENIS
				,TYPE
				,URAIAN
				,EMPLOYEE_NAME
				,EMPLOYEE_POSITION
				,AMOUNT
				,VAT_PCT
				,VAT_AMOUNT
				,TOTAL_AMOUNT
				,NOTE
				,CRE_DATE
				,CRE_BY
				,CRE_IP_ADDRESS
				,MOD_DATE
				,MOD_BY
				,MOD_IP_ADDRESS
			)
			select	distinct @p_user_id
					,@p_credit_no
					,@report_company
					,@report_title
					,@report_address
					,'('+isnull(@company_telp_area,'')+')-('+isnull(@company_telp_area1,'')+')'
					,'('+isnull(@company_fax_area,'')+')-('+isnull(@company_fax_phone,'')+')'
					,@report_image
					,dbo.xfn_bulan_indonesia(cn.date)
					,@npwp_company
					,dbo.xfn_bulan_indonesia(period.period_date)--dbo.xfn_bulan_indonesia(isnull(inc.new_invoice_date,inc.invoice_date))
					,dbo.xfn_bulan_indonesia(period.period_due_date)--dbo.xfn_bulan_indonesia(inc.invoice_due_date)
					,agreement_main.agreement_external_no
					,inc.client_name
					,inc.client_address
					,inc.client_npwp
					,null
					,null
					,null
					,@employee_name
					,@employee_position
					,cn.credit_amount
					,cn.PPN_PCT
					,(cn.PPN_AMOUNT-cn.NEW_PPN_AMOUNT)
					,cn.CREDIT_AMOUNT+((cn.PPN_AMOUNT-cn.NEW_PPN_AMOUNT))
					,cn.REMARK
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.credit_note cn
					inner join dbo.credit_note_detail cnd on cnd.credit_note_code = cn.code 
					inner join dbo.invoice_detail ivd on (ivd.invoice_no = cnd.invoice_no and cnd.invoice_detail_id = ivd.id)
					inner join dbo.invoice inc on (inc.INVOICE_NO = cn.INVOICE_NO)
					left join dbo.application_asset aast on (aast.ASSET_NO = ivd.ASSET_NO)
					inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
					outer apply (
						select	top 1
								ama.agreement_external_no
						from	dbo.invoice_detail ind
								inner join agreement_main ama on ama.agreement_no = ind.agreement_no
						where	ind.invoice_no = cnd.invoice_no
								and ind.agreement_no is not null
					)agreement_main
					outer apply(
						select	*
						from	dbo.xfn_due_date_period(ivd.ASSET_NO, ivd.BILLING_NO) 
					)period
			where	cn.code = @p_credit_no ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
