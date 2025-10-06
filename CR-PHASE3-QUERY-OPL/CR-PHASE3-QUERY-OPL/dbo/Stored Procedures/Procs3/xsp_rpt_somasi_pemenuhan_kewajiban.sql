--created by, bilal at 05/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_somasi_pemenuhan_kewajiban
(
	@p_user_id		   nvarchar(max)
	,@p_delivery_no	   nvarchar(50)
	,@p_letter_no	   nvarchar(50)
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
	delete	dbo.rpt_somasi_pemenuhan_kewajiban
	where	user_id = @p_user_id ;

	--(untuk data looping)
	delete	dbo.rpt_somasi_pemenuhan_kewajiban_detail
	where	user_id = @p_user_id ;

	--(untuk data lampiran)
	delete	dbo.rpt_somasi_pemenuhan_kewajiban_lampiran
	where	user_id = @p_user_id ;

	declare @msg				   nvarchar(max)
			,@report_company	   nvarchar(250)
			,@report_image		   nvarchar(250)
			,@report_title		   nvarchar(250)
			,@kota				   nvarchar(50)
			,@tanggal			   datetime
			,@no_surat			   nvarchar(50)
			,@nama_lessee		   nvarchar(250)
			,@alamat_lessee		   nvarchar(4000)
			,@nama_direktur_lessee nvarchar(250)
			,@agreement_no		   nvarchar(50)
			,@agreement_date	   datetime
			,@no_sp1			   nvarchar(50)
			,@tanggal_sp1		   datetime
			,@no_sp2			   nvarchar(50)
			,@tanggal_sp2		   datetime
			,@tanggal_somasi	   datetime
			,@no_rek			   nvarchar(50)
			,@bank_name			   nvarchar(50)
			,@atas_nama			   nvarchar(50)
			,@jumlah_unit		   int
			,@nama_object_lease	   nvarchar(50)
			,@tahun_object_lease   nvarchar(4)
			,@nama_dept_head	   nvarchar(50)
			,@nama_penasihat	   nvarchar(50)
			,@branch_code		   nvarchar(50)
			,@invoice_no		   nvarchar(50)
			,@periode_pemakaian	   nvarchar(4000)
			,@nilai_sewa		   decimal(18, 2)
			,@ovd_amount		   decimal(18, 2)
			,@jatuh_tempo		   datetime
			,@asset_name		   nvarchar(250)
			,@asset_year		   int
			,@no_somasi			   nvarchar(50)
			,@no_rangka			   nvarchar(50)
			,@no_seri			   nvarchar(50)
			,@no_mesin			   nvarchar(50)
			,@merk				   nvarchar(50)
			,@no_period			   int
			,@nama				   nvarchar(250)
			,@jabatan			   nvarchar(250)
			,@agreement_no_sp	   nvarchar(50)
			,@sp				   int

	begin try
		delete	from dbo.rpt_somasi_pemenuhan_kewajiban
		where	user_id = @p_user_id ;

		delete	from dbo.rpt_somasi_pemenuhan_kewajiban_detail
		where	user_id = @p_user_id ;

		delete	from dbo.rpt_somasi_pemenuhan_kewajiban_lampiran
		where	user_id = @p_user_id ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @report_title = N'' ;

		select	@branch_code = branch_code
		from	dbo.warning_letter_delivery
		where	code = @p_delivery_no ;

		select	@kota		= isnull(sc.description, '-')
				,@bank_name = isnull(sbk.description, '-')
				,@atas_nama = isnull(sbb.bank_account_name, '-')
				,@no_rek	= isnull(sbb.bank_account_no, '-')
		from	ifinsys.dbo.sys_branch				   sb with (nolock)
				inner join ifinsys.dbo.sys_city		   sc with (nolock) on (sc.code					 = sb.city_code)
				left join ifinsys.dbo.sys_branch_bank sbb with (nolock) on (
																				sbb.branch_code		 = sb.code
																				and sbb.default_flag = '1'
																			)
				left join ifinsys.dbo.sys_bank		   sbk with (nolock) on (sbk.code				 = sbb.master_bank_code)
		where	sb.code = @branch_code ;

		select	@bank_name = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@atas_nama = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		select	@no_rek = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@nama_penasihat = value
		from	dbo.sys_global_param
		where	code = 'PNSHTHKM' ;

		select		@agreement_no_sp = agreement_no
		from		dbo.warning_letter
		where		delivery_code = @p_delivery_no 
					and letter_no = @p_letter_no;;

		select		top 1	@no_sp1		  = letter_no
							,@tanggal_sp1 = letter_date
		from		warning_letter
		where		agreement_no	  = @agreement_no_sp
					and letter_status <> 'CANCEL'
					and letter_status <> 'HOLD'
					and letter_type = 'SP1'
		order by	cre_date desc ;

		select		top 1	@no_sp2		  = isnull(letter_no,'-')
							,@tanggal_sp2 = letter_date
		from		warning_letter
		where		agreement_no	  = @agreement_no_sp
					and letter_status <> 'CANCEL'
					and letter_status <> 'HOLD'
					and letter_type = 'SP2'
		order by	cre_date desc ;

		--select	@no_sp1		  = wl.letter_no
		--		,@tanggal_sp1 = wl.letter_date
		--from	dbo.warning_letter							  wl
		--		inner join dbo.warning_letter_delivery_detail wld on wl.letter_no = wld.letter_code
		--where	wld.delivery_code  = @p_delivery_no
		--		and wl.letter_type = 'SP1' ;

		--select	@no_sp2		  = wl.letter_no
		--		,@tanggal_sp2 = wl.letter_date
		--from	dbo.warning_letter							  wl
		--		inner join dbo.warning_letter_delivery_detail wld on wl.letter_no = wld.letter_code
		--where	wld.delivery_code  = @p_delivery_no
		--		and wl.letter_type = 'SP2' ;

		select	@no_somasi		 = wl.letter_no
				,@tanggal_somasi = wl.letter_date
				,@no_surat		 = wl.letter_no
		from	dbo.warning_letter							  wl
				inner join dbo.warning_letter_delivery_detail wld on wl.letter_no = wld.letter_code
		where	wld.delivery_code  = @p_delivery_no
				and wl.letter_type = 'SOMASI' ;

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		
		-- (+) Ari 2023-12-28 ket : get from global param, infonya pakai yg somasi
		select	@sp = value 
		from	dbo.sys_global_param
		where	code = 'DKPAS'

		insert into dbo.rpt_somasi_pemenuhan_kewajiban
		(
			user_id								
			,delivery_no
			,report_company
			,report_title
			,report_image
			,kota
			,tanggal
			,no_surat
			,nama_lessee
			,alamat_lessee
			,nama_direktur_lessee
			,agreement_no
			,agreement_date
			,no_sp1
			,tanggal_sp1
			,no_sp2
			,tanggal_sp2
			,tanggal_somasi
			,no_rek
			,nama_bank
			,atas_nama
			,jumlah_unit
			,nama_object_lease
			,tahun_object_lease
			,nama_dept_head
			,jabatan
			,nama_penasihat
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select distinct
				@p_user_id
				,@p_delivery_no
				,@report_company
				,@report_title
				,@report_image
				,@kota
				,@tanggal_somasi
				,wldd.letter_code
				,am.client_name
				,agas.billing_to_address--cad.ADDRESS
				,''--cci.full_name
				,am.agreement_external_no
				,am.agreement_date
				,@no_sp1
				,@tanggal_sp1
				,@no_sp2
				,@tanggal_sp2
				--,@tanggal_somasi
				,dateadd(day,@sp,@tanggal_somasi) -- (+) Ari 2023-12-27 ket : disamain dengan pengambilan sp 1 dan 2
				,@no_rek
				,@bank_name
				,@atas_nama
				,agast.jumlah_asset
				,agas.asset_name
				,agas.asset_year
				,@nama
				,@jabatan
				,@nama_penasihat
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no = wldd.letter_code)
				left join dbo.invoice_detail invd on (invd.agreement_no = wl.agreement_no)
				inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no and inv.invoice_status='POST' and inv.invoice_due_date <= dbo.xfn_get_system_date() and inv.invoice_type='RENTAL')
				left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
				left join dbo.application_main apa on (apa.application_no = am.application_no)
				left join dbo.client_address cad on (cad.client_code = apa.client_code and cad.is_legal='1' and isnull(cad.address,'')<>'')
				left join dbo.client_relation cci on (
														 cci.client_code = am.client_no
														 and   cci.relation_type = 'SHAREHOLDER'
													 )
				outer apply
		(
			select	aas.asset_name
					,aas.asset_year
					,aas.billing_to_address
			from	dbo.agreement_asset aas
			where	aas.agreement_no = wl.agreement_no
		) agas
				outer apply
		(
			select	count(aas.asset_no) 'jumlah_asset'
			from	dbo.agreement_asset aas
			where	aas.agreement_no = wl.agreement_no
		) agast
		where	wldd.letter_code = @p_letter_no 

		--select	@agreement_date		 = am.agreement_date
		--		,@invoice_no		 = isnull(i.invoice_external_no, ai.invoice_no)
		--		,@periode_pemakaian	 = aaa.description
		--		,@no_period			 = aaa.billing_no
		--		,@nilai_sewa		 = isnull(i.total_billing_amount + i.total_ppn_amount,aaa.billing_amount)
		--		,@ovd_amount		 = wl.overdue_penalty_amount
		--		,@jatuh_tempo		 = i.invoice_due_date
		--		,@asset_name		 = aa.asset_name
		--		,@asset_year		 = aa.asset_year
		--		,@agreement_no		 = am.agreement_external_no
		--		,@no_rangka			 = aa.fa_reff_no_02
		--		,@no_seri			 = aa.fa_reff_no_01
		--		,@no_mesin			 = aa.fa_reff_no_03
		--		,@merk				 = aa.fa_name
		--		,@nama_object_lease	 = aa.fa_name
		--		,@jumlah_unit		 = agast.jumlah_asset
		--		,@nama_object_lease	 = agas.asset_name
		--		,@tahun_object_lease = agas.asset_year
		--from	dbo.agreement_main							 am
		--		left join dbo.client_corporate_info			 cci on cci.client_code = am.client_no
		--		left join dbo.client_address				 ca on ca.client_code = am.client_no
		--		left join dbo.agreement_invoice				 ai on ai.agreement_no = am.agreement_no
		--		left join dbo.invoice						 i on i.invoice_no = ai.invoice_no
		--		left join dbo.warning_letter				 wl on wl.agreement_no = am.agreement_no
		--		left join dbo.agreement_asset_amortization aaa on (aaa.agreement_no = wl.agreement_no)
		--		left join dbo.warning_letter_delivery_detail wldd on wl.letter_no = wldd.letter_code
		--		left join dbo.agreement_asset				 aa on aa.agreement_no = am.agreement_no
		--		outer apply
		--		(
		--			select	aas.asset_name
		--					,aas.asset_year
		--			from	dbo.agreement_asset aas
		--			where	aas.agreement_no = wl.agreement_no
		--		) agas
		--		outer apply
		--		(
		--			select	count(aas.asset_no) 'jumlah_asset'
		--			from	dbo.agreement_asset aas
		--			where	aas.agreement_no = wl.agreement_no
		--		) agast
		--		outer apply
		--		(
		--			select	payment_date
		--			from	dbo.agreement_invoice_payment aip
		--			where	aip.agreement_no   = ai.agreement_no
		--					and aip.invoice_no = ai.invoice_no
		--					and aip.asset_no   = ai.asset_no
		--		) aip
		--where	wldd.letter_code = @p_letter_no
		--		and aip.payment_date is null ;
		--select @nama_direktur_lessee
		--select @nama_lessee
		--insert into dbo.rpt_somasi_pemenuhan_kewajiban
		--(
		--	user_id
		--	,delivery_no
		--	,report_company
		--	,report_title
		--	,report_image
		--	,kota
		--	,tanggal
		--	,no_surat
		--	,nama_lessee
		--	,alamat_lessee
		--	,nama_direktur_lessee
		--	,agreement_no
		--	,agreement_date
		--	,no_sp1
		--	,tanggal_sp1
		--	,no_sp2
		--	,tanggal_sp2
		--	,tanggal_somasi
		--	,no_rek
		--	,nama_bank
		--	,atas_nama
		--	,jumlah_unit
		--	,nama_object_lease
		--	,tahun_object_lease
		--	,nama_dept_head
		--	,nama_penasihat
		--	--
		--	,cre_date
		--	,cre_by
		--	,cre_ip_address
		--	,mod_date
		--	,mod_by
		--	,mod_ip_address
		--)
		--values
		--(
		--	@p_user_id
		--	,@p_delivery_no
		--	,@report_company
		--	,@report_title
		--	,@report_image
		--	,@kota
		--	,@tanggal
		--	,@no_surat
		--	,@nama_lessee
		--	,@alamat_lessee
		--	,@nama_direktur_lessee
		--	,@agreement_no
		--	,@agreement_date
		--	,@no_sp1
		--	,@tanggal_sp1
		--	,@no_sp2
		--	,@tanggal_sp2
		--	,@tanggal_somasi
		--	,@no_rek
		--	,@bank_name
		--	,@atas_nama
		--	,@jumlah_unit
		--	,@nama_object_lease
		--	,@tahun_object_lease
		--	,@nama_dept_head
		--	,@nama_penasihat
		--	--
		--	,@p_cre_date
		--	,@p_cre_by
		--	,@p_cre_ip_address
		--	,@p_mod_date
		--	,@p_mod_by
		--	,@p_mod_ip_address
		--) ;

		insert into dbo.rpt_somasi_pemenuhan_kewajiban_detail
		(
			user_id
			,agreement_no
			,no_invoice
			,periode_pemakaian
			,nilai_sewa
			,denda
			,tanggal_jt
		)
		select	distinct @p_user_id
				,am.agreement_external_no
				,isnull(i.invoice_external_no, ai.invoice_no)
				,'Billing ke ' + cast(period.billing_no as nvarchar(15)) + N' dari Periode '
                            + convert(varchar(30), period.period_date, 103) + N' Sampai dengan '
                            + convert(varchar(30), period.period_due_date, 103)
				,isnull(i.total_billing_amount + i.total_ppn_amount,aaa.billing_amount)
				,wl.overdue_penalty_amount
				,i.invoice_due_date
		from	dbo.agreement_main							 am
				left join dbo.client_corporate_info			 cci on cci.client_code = am.client_no
				left join dbo.client_address				 ca on ca.client_code = am.client_no
				left join dbo.agreement_invoice				 ai on ai.agreement_no = am.agreement_no
				left join dbo.invoice						 i on i.invoice_no = ai.invoice_no
				left join dbo.invoice_detail				 invd on invd.invoice_no = i.invoice_no and invd.agreement_no = am.agreement_no
				left join dbo.warning_letter				 wl on wl.agreement_no = am.agreement_no
				--left join dbo.agreement_asset_amortization aaa on (aaa.agreement_no = wl.agreement_no)
				left join dbo.warning_letter_delivery_detail wldd on wl.letter_no = wldd.letter_code
				left join dbo.agreement_asset				 aa on aa.agreement_no = am.agreement_no
				outer apply 
				(
					select	top 1 billing_amount
					from	dbo.agreement_asset_amortization
					where	agreement_no = wl.agreement_no
				)aaa
				outer apply
				(
					select	aas.asset_name
							,aas.asset_year
					from	dbo.agreement_asset aas
					where	aas.agreement_no = wl.agreement_no
				) agas
				outer apply
				(
					select	count(aas.asset_no) 'jumlah_asset'
					from	dbo.agreement_asset aas
					where	aas.agreement_no = wl.agreement_no
				) agast
				outer apply
				(
					select	payment_date
					from	dbo.agreement_invoice_payment aip
					where	aip.agreement_no   = ai.agreement_no
							and aip.invoice_no = ai.invoice_no
							and aip.asset_no   = ai.asset_no
				) aip
				outer apply
					(
						select	asset_no
								,billing_no
								,period_date
								,period_due_date
						from	dbo.xfn_due_date_period(invd.asset_no,invd.billing_no) aa
						where	aa.billing_no = invd.billing_no
						and		aa.asset_no = invd.asset_no
					)period
		where	wldd.letter_code = @p_letter_no
				and aip.payment_date is null 
				and isnull(i.invoice_external_no, ai.invoice_no) is not null
				and i.invoice_due_date <= dbo.xfn_get_system_date()
				and i.INVOICE_TYPE ='RENTAL';
		--values
		--(
		--	@p_user_id			-- user_id - nvarchar(50)
		--	,@agreement_no		-- agreement_no - nvarchar(50)
		--	,@invoice_no		-- no_invoice - nvarchar(50)
		--	,@periode_pemakaian -- periode_pemakaian - datetime
		--	,@nilai_sewa		-- nilai_sewa - decimal(18, 2)
		--	,@ovd_amount		-- denda - decimal(18, 2)
		--	,@jatuh_tempo		-- tanggal_jt - datetime
		--) ;

		insert into dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN_LAMPIRAN
		(
			USER_ID
			,NO_SURAT_SOMASI
			,TANGGAL_SOMASI
			,MAIN_CONTRACT_NO
			,AGREEMENT_NO
			,AGREEMENT_DATE
			,ASSET_NAME
			,VEHICLE_TYPE
			,BRAND
			,YEAR
			,CHASSIS_NO
			,ENGINE_NO
			,PLAT_NO
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	distinct
				@p_user_id
				,wldd.letter_code
				,wl.letter_date
				,aext.main_contract_no
				,am.agreement_external_no
				,am.agreement_date
				,aas.asset_name
				,aas.asset_name--mvu.class_type_name
				,mvm.description
				,aas.asset_year
				,isnull(aas.replacement_fa_reff_no_02, aas.fa_reff_no_02)
				,isnull(aas.replacement_fa_reff_no_03, aas.fa_reff_no_03)
				,isnull(aas.replacement_fa_reff_no_01, aas.fa_reff_no_01)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.warning_letter_delivery_detail wldd
				left join dbo.warning_letter wl on (wl.letter_no			 = wldd.letter_code)
				left join dbo.invoice_detail invd on (invd.agreement_no = wl.agreement_no)
				left join dbo.invoice inv on (inv.invoice_no = invd.invoice_no and inv.invoice_type='RENTAL')
				left join dbo.agreement_asset aas on (aas.agreement_no		 = wl.agreement_no)
				left join dbo.agreement_main am on (am.agreement_no			 = wl.agreement_no)
				left join dbo.agreement_asset_vehicle aav on (aav.asset_no	 = aas.asset_no)
				left join dbo.application_extention aext on (aext.application_no = am.application_no)
				left join dbo.master_vehicle_merk mvm on (mvm.code			 = aav.vehicle_merk_code)
				left join dbo.master_vehicle_unit mvu on (mvu.code			 = aav.vehicle_unit_code)
		where	wldd.letter_code = @p_letter_no ;

		if not exists(SELECT * FROM dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN_LAMPIRAN where user_id=@p_user_id)
		begin
				insert into dbo.RPT_SOMASI_PEMENUHAN_KEWAJIBAN_LAMPIRAN
				(
					USER_ID
					,NO_SURAT_SOMASI
					,TANGGAL_SOMASI
					,MAIN_CONTRACT_NO
					,AGREEMENT_NO
					,AGREEMENT_DATE
					,ASSET_NAME
					,VEHICLE_TYPE
					,BRAND
					,YEAR
					,CHASSIS_NO
					,ENGINE_NO
					,PLAT_NO
					,CRE_DATE
					,CRE_BY
					,CRE_IP_ADDRESS
					,MOD_DATE
					,MOD_BY
					,MOD_IP_ADDRESS
				)
				select	distinct
						@p_user_id
						,wldd.letter_code
						,wl.letter_date
						,null--aext.main_contract_no
						,null--am.agreement_external_no
						,null--am.agreement_date
						,null--aas.asset_name
						,null--aas.asset_name--mvu.class_type_name
						,null--mvm.description
						,null--aas.asset_year
						,null--isnull(aas.replacement_fa_reff_no_02, aas.fa_reff_no_02)
						,null--isnull(aas.replacement_fa_reff_no_03, aas.fa_reff_no_03)
						,null--isnull(aas.replacement_fa_reff_no_01, aas.fa_reff_no_01)
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.warning_letter_delivery_detail wldd
						left join dbo.warning_letter wl on (wl.letter_no			 = wldd.letter_code)
				where	wldd.letter_code = @p_letter_no ;
		end;

		update	dbo.warning_letter					
		set		last_print_by		= @p_user_id
				,print_count		= print_count +1
				--
				,mod_by				= @p_user_id
				,mod_date			= @p_mod_date
				,mod_ip_address		= @p_mod_ip_address
		where	letter_no			= @p_letter_no 
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
			set @msg = N'v' + N';' + @msg ;
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
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

