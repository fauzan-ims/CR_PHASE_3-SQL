CREATE PROCEDURE dbo.xsp_rpt_somasi_penyelesaian_kewajiban
(
	@p_user_id		   nvarchar(max)
	,@p_agreement_no	nvarchar(50)
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
	delete	dbo.rpt_somasi_penyelesaian_kewajiban
	where	user_id = @p_user_id ;

	--(untuk looping)
	delete	dbo.rpt_somasi_penyelesaian_kewajiban_i
	where	user_id = @p_user_id ;

	--(untuk looping data lampiran)
	delete	dbo.rpt_somasi_penyelesaian_kewajiban_ii
	where	user_id = @p_user_id ;

	--(untuk looping data lampiran)
	delete	dbo.rpt_somasi_penyelesaian_kewajiban_iii
	where	user_id = @p_user_id ;

	declare @msg				  nvarchar(max)
			,@report_company	  nvarchar(250)
			,@report_image		  nvarchar(250)
			,@report_title		  nvarchar(250)
			,@kota				  nvarchar(50)
			,@tanggal			  datetime
			,@no_surat			  nvarchar(50)
			,@nama_client		  nvarchar(250)
			,@alamat_client		  nvarchar(4000)
			,@up_name1			  nvarchar(250)
			,@up_name2			  nvarchar(250)
			,@tanggal_tunggakan	  datetime
			,@total_object_sewa	  nvarchar(50)
			,@tunggakan			  decimal(18, 2)
			,@denda				  decimal(18, 2)
			,@total_tagihan		  decimal(18, 2)
			,@nama_bank			  nvarchar(50)
			,@no_rek			  nvarchar(50)
			,@rek_atas_nama		  nvarchar(50)
			,@employee_name		  nvarchar(50)
			,@employee_position	  nvarchar(50)
			,@agreement_no		  nvarchar(50)
			,@agreement_date	  nvarchar(50)
			,@company_name		  nvarchar(50)
			,@branch_code		  nvarchar(50)
			,@asset_no			  nvarchar(50)
			,@nominal_sewa		  decimal(18, 2)
			,@periode_sewa		  nvarchar(50)
			,@invoice_no		  nvarchar(50)
			,@nominal_invoice	  decimal(18, 2)
			,@tanggal_jatuh_tempo datetime
			,@ovd_days			  int
			,@denda_sewa		  decimal(18, 2)
			,@client_name		  nvarchar(50)
			,@type_name			  nvarchar(50)
			,@merk_name			  nvarchar(50)
			,@chassis_no		  nvarchar(50)
			,@plat_no			  nvarchar(50)
			,@engine_no			  nvarchar(50)
			,@asset_year		  int 
			,@agreement_code	  nvarchar(50)
			,@add_days			  int
			,@depthead			  nvarchar(50)
			,@jabatan			  nvarchar(250);

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @report_title = N'Somasi Penyelesaian Kewajiban' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@nama_bank = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@rek_atas_nama = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		select	@no_rek = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@add_days = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'DKPAS' ;

		select	@branch_code = branch_code
		from	dbo.agreement_main
		where	agreement_no = @p_agreement_no ;

		select	@kota = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;
		
		select	@depthead = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		insert into dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN
		(
			USER_ID
			,DELIVERY_CODE
			,REPORT_COMPANY
			,REPORT_TITLE
			,REPORT_IMAGE
			,KOTA
			,TANGGAL
			,NO_SURAT
			,NAMA_CLIENT
			,ALAMAT_CLIENT
			,UP_NAME1
			,UP_NAME2
			,TANGGAL_TUNGGAKAN
			,TOTAL_OBJECT_SEWA
			,TUNGGAKAN
			,DENDA
			,TOTAL_TAGIHAN
			,NAMA_BANK
			,NO_REK
			,REK_ATAS_NAMA
			,EMPLOYEE_NAME
			,EMPLOYEE_POSITION
			,AGREEMENT_NO
			,AGREEMENT_DATE
			,COMPANY_NAME
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	@p_user_id
				,'' --tidak dipakai
				,@report_company
				,@report_title
				,@report_image
				,@kota
				,dbo.xfn_get_system_date()
				,sb.code
				,am.client_name
				,ca.address
				,isnull(cci.contact_person_name,am.client_name)
				,''
				,dateadd(day,@add_days,dbo.xfn_get_system_date())
				,0
				,0
				,0
				,0
				,@nama_bank
				,@no_rek
				,@rek_atas_nama
				,@depthead
				,@jabatan
				,am.agreement_external_no
				,am.agreement_date
				,@report_company
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main							 am
				left join dbo.client_main					 cm on cm.client_no = am.client_no
				left join dbo.agreement_information			 ai on ai.agreement_no = am.agreement_no
				left join dbo.client_address				 ca on ca.client_code = cm.code and ca.is_mailing='1'
				left join dbo.agreement_asset				 aa on aa.agreement_no = am.agreement_no
				left join dbo.client_corporate_info			 cci on (cci.client_code = am.client_no)
				left join dbo.stop_billing					 sb on sb.agreement_no = am.agreement_no and status='APPROVE' 
		where	am.agreement_no = @p_agreement_no ;

		insert into dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_I
		(
			user_id
			,surat_no
			,no_perjanjian
			,tanggal_perjanjian
			,tipe_kendaraan
			,tahun_kendaraan
			,no_rangka
			,no_mesin
			,no_polisi
			,merk
			,perjanjian_pelaksanaan
		)
		select	@p_user_id
				,sb.code
				,isnull(ama.agreement_external_no,'-')
				,ama.agreement_date
				,isnull(mht.description,'-')
				,aast.asset_year
				,isnull(aast.fa_reff_no_02,'-')
				,isnull(aast.fa_reff_no_03,'-')
				,isnull(aast.fa_reff_no_01,'-')
				,isnull(mmr.description,'-')
				,isnull(aex.main_contract_no,'-')
		from	dbo.agreement_main ama
				left join dbo.stop_billing sb on sb.agreement_no			  = ama.agreement_no
													and   status				  = 'APPROVE'
				left join dbo.agreement_asset aast on aast.agreement_no		  = ama.agreement_no
				left join dbo.agreement_asset_vehicle aav on aav.asset_no	  = aast.ASSET_NO				
				left join dbo.master_vehicle_type mht on mht.code			  = aav.vehicle_type_code
				left join dbo.master_vehicle_model mvm on mvm.code			  = aav.vehicle_model_code
				left join dbo.master_vehicle_merk mmr on mmr.code			  = aav.vehicle_merk_code
				left join dbo.application_extention aex on aex.application_no = ama.application_no
		where	ama.agreement_no = @p_agreement_no ;

		insert into dbo.rpt_somasi_penyelesaian_kewajiban_ii
		(
			user_id
			,surat_no
			,no_perjanjian
			,nominal_sewa
			,periode_sewa
			,no_invoice
			,nominal_invoice
			,tanggal_jt
		)
		select	@p_user_id
				,sb.code
				,ama.agreement_external_no
				,isnull(ide.billing_amount,0)
				,isnull(convert(varchar(30), tabdue.from_date, 103)+' - '+convert(varchar(30), tabdue.to_date, 103),'-')
				,isnull(ide.invoice_no,'-')
				,isnull(ide.billing_amount,0) - isnull(ide.discount_amount,0) + isnull(ide.ppn_amount,0)
				,inc.invoice_due_date
		from	dbo.agreement_main ama
				left join dbo.stop_billing sb on sb.agreement_no		   = ama.agreement_no
												 and   status			   = 'APPROVE'
				left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
				left join dbo.invoice inc on inc.invoice_no				   = ide.invoice_no
				left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
				outer apply (
						select isnull(aaa.due_date,asat.handover_bast_date) 'from_date',aaa2.due_date'to_date',aaa.invoice_no,aaa2.billing_no
						from dbo.agreement_asset_amortization aaa 
						inner join dbo.agreement_asset asat on asat.asset_no = aaa.asset_no
						left join dbo.agreement_asset_amortization aaa2 on aaa2.agreement_no=aaa.agreement_no and aaa2.asset_no=aaa.asset_no and aaa2.billing_no-1 = aaa.billing_no --anggapan in arear
						where aaa.invoice_no=inc.invoice_no and aaa.asset_no=ide.asset_no and aaa.billing_no=ide.billing_no
				)tabdue
		where	ama.agreement_no = @p_agreement_no ;

		insert into dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_III
		(
			user_id
			,surat_no
			,no_perjanjian
			,nominal_sewa
			,total_hari_keterlambatan
			,denda_sewa
		)
		select	@p_user_id
				,sb.code
				,isnull(ama.agreement_external_no,'-')
				,isnull(ide.billing_amount,0)
				,isnull(aob.obligation_day,0)
				,0.25*isnull(ide.billing_amount,0)*isnull(aob.obligation_day,0)
		from	dbo.agreement_main ama
				left join dbo.stop_billing sb on sb.agreement_no		   = ama.agreement_no
												 and   status			   = 'APPROVE'
				left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
				left join dbo.invoice inc on inc.invoice_no				   = ide.invoice_no
				left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
		where	ama.agreement_no = @p_agreement_no ;
		
		select	@tunggakan = sum(nominal_invoice)
		from	dbo.rpt_somasi_penyelesaian_kewajiban_ii
		where	user_id = @p_user_id ;

		select	@denda = sum(denda_sewa)
		from	dbo.rpt_somasi_penyelesaian_kewajiban_iii
		where	user_id = @p_user_id ;

		update	dbo.rpt_somasi_penyelesaian_kewajiban
		set		tunggakan = @tunggakan
				,denda = @denda
		where	user_id = @p_user_id ;

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
