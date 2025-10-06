--created by, Bilal at 05/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_surat_tagih_write_off
(
	@p_user_id				nvarchar(max)
	,@p_wo_no				nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare	@msg						nvarchar(max)
			,@report_company_name		nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_company_city		nvarchar(4000)
			,@letter_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@client_address			nvarchar(4000)
			,@total_object_sewa			int
			,@tunggakan					decimal(18,2)
			,@denda						decimal(18,2)
			,@bank_name					nvarchar(250)
			,@bank_account_name			nvarchar(250)
			,@bank_account_no			nvarchar(50)
			,@petugas					nvarchar(250)
			,@nomor_perjanjian			nvarchar(50)
			,@tanggal_perjajian			datetime
			,@tipe_kendaraan			nvarchar(250)
			,@tahun_kendaraan			nvarchar(4)
			,@nomor_rangka				nvarchar(50)
			,@nomor_mesin				nvarchar(50)
			,@nomor_polisi				nvarchar(50)
			,@nominal_sewa				decimal(18,2)
			,@periode_sewa				nvarchar(250)
			,@nomor_invoice				nvarchar(50)
			,@nominal_invoice			decimal(18,2)
			,@tanggal_jatuh_tempo		datetime
			,@total_hari_keterlambatan	int
			,@denda_sewa				decimal(18,2)
			,@agreement_no				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@nama_bank					nvarchar(250)
			,@rek_atas_nama				nvarchar(250)
			,@no_rek					nvarchar(50)
			,@add_days					int
			,@depthead					nvarchar(250)
			,@jabatan					nvarchar(250)
			,@perihal					nvarchar(250) ; 

	begin try

		delete dbo.rpt_surat_tagih_write_off
		where	user_id = @p_user_id;

		delete dbo.rpt_surat_tagih_write_off_lampiran_i
		where	user_id = @p_user_id;

		delete dbo.rpt_surat_tagih_write_off_lampiran_ii
		where	user_id = @p_user_id;

		delete dbo.rpt_surat_tagih_write_off_lampiran_iii
		where	user_id = @p_user_id;

		select	@report_company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;
		
		select	@agreement_no = agreement_no
		from	dbo.write_off_main 
		where	code = @p_wo_no ;

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
		where	agreement_no = @agreement_no ;

		select	@report_company_city = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;

		set	@report_title = 'surat_tagih_write_off Penyelesaian Kewajiban Kendaraan' ;

		set @perihal = 'Somasi Penyelesaian Kewajiban Kendaraan' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@depthead = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		insert into dbo.rpt_surat_tagih_write_off
		(
			user_id
			,wo_code
			,report_company
			,report_title
			,report_image
			,kota
			,tanggal
			,no_surat
			,perihal
			,nama_client
			,alamat_client
			,up_name1
			,up_name2
			,tanggal_tunggakan
			,total_object_sewa
			,tunggakan
			,denda
			,total_tagihan
			,nama_bank
			,no_rek
			,rek_atas_nama
			,employee_name
			,employee_position
			,no_perjanjian_induk -- (+) Ari 2023-10-18
			,tanggal_perjanjian_induk -- (+) Ari 2023-10-18
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
				,wom.code
				,@report_company_name
				,@report_title
				,@report_image
				--,@report_company_city
				,'Jakarta'
				,dbo.xfn_get_system_date()
				,wom.code
				,@perihal
				,am.client_name
				,ca.address
				,isnull(cci.contact_person_name, am.client_name)
				,''
				,dateadd(day, @add_days, dbo.xfn_get_system_date())
				,0
				,0
				,0
				,0
				,@nama_bank
				,@no_rek
				,@rek_atas_nama
				,@depthead
				,@jabatan
				,induk.main_contract_no -- (+) Ari 2023-10-18
				,induk.main_contract_date -- (+) Ari 2023-10-18
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am
				left join dbo.write_off_main wom on wom.agreement_no = am.agreement_no
				left join dbo.client_main cm on cm.client_no = am.client_no
				left join dbo.agreement_information ai on ai.agreement_no = am.agreement_no
				outer apply
				(
					select	top 1
							ca.address
					from	dbo.client_address ca
					where	ca.client_code	  = cm.code
							and ca.is_mailing = '1'
				) ca
				--left join dbo.client_address				 ca on ca.client_code = cm.code and ca.is_mailing='1'
				left join dbo.agreement_asset aa on aa.agreement_no			= am.agreement_no
				left join dbo.client_corporate_info cci on (cci.client_code = am.client_no)
				-- (+) Ari 2023-10-18 ket : get application induk
				outer apply (
								select	ae.main_contract_no
										,ae.main_contract_date 
								from	dbo.application_extention ae
								inner	join dbo.application_main ap on (ae.application_no = ap.application_no)
								where	ap.application_no = am.application_no
							)induk
				-- (+) Ari 2023-10-18
		where	am.agreement_no = @agreement_no
				and wom.code	= @p_wo_no ;

		insert into dbo.RPT_SURAT_TAGIH_WRITE_OFF_LAMPIRAN_I
		(
			USER_ID
			,SURAT_NO
			,NO_PERJANJIAN
			,TANGGAL_PERJANJIAN
			,TIPE_KENDARAAN
			,TAHUN_KENDARAAN
			,NO_RANGKA
			,NO_MESIN
			,NO_POLISI
		)
		select	distinct @p_user_id
				,@p_wo_no
				,isnull(ama.agreement_external_no,'-')
				,ama.agreement_date
				,isnull(mht.description,'-')
				,aast.asset_year
				,isnull(aast.fa_reff_no_02,'-')
				,isnull(aast.fa_reff_no_03,'-')
				,isnull(aast.fa_reff_no_01,'-')
		from	dbo.agreement_main ama
				left join dbo.write_off_main				 wom on wom.agreement_no = ama.agreement_no
				left join dbo.agreement_asset aast on aast.agreement_no		  = ama.agreement_no
				left join dbo.agreement_asset_vehicle aav on aav.asset_no	  = aast.ASSET_NO				
				left join dbo.master_vehicle_type mht on mht.code			  = aav.vehicle_type_code
				left join dbo.master_vehicle_model mvm on mvm.code			  = aav.vehicle_model_code
				left join dbo.master_vehicle_merk mmr on mmr.code			  = aav.vehicle_merk_code
				left join dbo.application_extention aex on aex.application_no = ama.application_no
		where	ama.agreement_no = @agreement_no and wom.code = @p_wo_no;


		insert into dbo.rpt_surat_tagih_write_off_lampiran_ii
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
		select		@p_user_id
					,@p_wo_no
					,ama.agreement_external_no
					,isnull(xasset.rental, 0)
					,isnull(convert(varchar(30), tabdue.period_date, 103) + ' - ' + convert(varchar(30), tabdue.period_due_date, 103), '-')
					,isnull(inc.invoice_external_no, '-')
					--,inc.total_billing_amount + inc.total_ppn_amount
					,amount.payment
					,inc.invoice_due_date
		from		dbo.invoice_detail ide
					inner join dbo.invoice inc on inc.invoice_no = ide.invoice_no
					inner join dbo.agreement_main ama on ama.agreement_no = ide.agreement_no
					outer apply
						(
							select	sum(LEASE_ROUNDED_AMOUNT) 'rental'
							from	dbo.AGREEMENT_ASSET
							where	AGREEMENT_NO = ama.AGREEMENT_NO
						) xasset
					outer apply
						(
							select	period_date
									,period_due_date
							from	dbo.xfn_due_date_period((ide.asset_no), (ide.billing_no))
						) tabdue
					outer apply
						(
							select	sum(isnull(aa.ar_amount, 0)) 'payment' -- isnull(aap.payment_amount, 0))'payment'
							from	dbo.agreement_invoice aa --with (nolock)
							--outer apply
							--			(
							--				select	sum(aap.payment_amount) as 'payment_amount'
							--				from	dbo.agreement_invoice_payment aap with (nolock)
							--				where	(aap.agreement_invoice_code = aa.code)
							--			) aap
							where	aa.agreement_no = @agreement_no
							and		aa.invoice_no = inc.invoice_no -- (+) Ari 2023-10-19 ket : per invoice
						) amount
		where		ide.agreement_no	   = @agreement_no
					and inc.invoice_status IN ('POST','WO')
		group by	inc.invoice_external_no
					,ama.agreement_external_no
					,xasset.rental
					,inc.invoice_external_no
					,inc.invoice_due_date
					,isnull(convert(varchar(30), tabdue.period_date, 103) + ' - ' + convert(varchar(30), tabdue.period_due_date, 103), '-') 
					,inc.total_billing_amount + inc.total_ppn_amount
					,amount.payment;

		insert into dbo.RPT_SURAT_TAGIH_WRITE_OFF_LAMPIRAN_III
		(
			USER_ID
			,SURAT_NO
			,NO_PERJANJIAN
			,NOMINAL_SEWA
			,TOTAL_HARI_KETERLAMBATAN
			,DENDA_SEWA
		)
		SELECT	distinct 
				@p_user_id
				,@p_wo_no
				,isnull(ama.agreement_external_no, '-')
				,isnull(ide.billing_amount, 0)
				--,isnull(xinvoice.ovd_day,0)
				,isnull(ovd.overdue,0)
				,isnull(obli.os_obligasi, 0)
				--,ISNULL(aob.obligation_day, 0)
				--,isnull(aob.obligation_amount,0) - isnull(jumlah_payment_amt.jumlah,0)
		from	dbo.agreement_main ama
				left join dbo.write_off_main wom on wom.agreement_no = ama.agreement_no
				left join dbo.invoice_detail ide on ide.agreement_no = ama.agreement_no
				inner join dbo.invoice inc on inc.invoice_no = ide.invoice_no and inc.invoice_status IN ('POST','WO')
				left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
														  and  aob.asset_no = ide.asset_no
														  and  aob.installment_no = ide.billing_no
				--outer apply
				--(
				--	select	sum(payment_amount) 'jumlah'
				--	from	dbo.agreement_obligation_payment
				--	where	obligation_code = aob.code
				--) jumlah_payment_amt

				--outer apply(
				--	select  sum( datediff(day,inc.invoice_due_date, dbo.xfn_get_system_date())) ovd_day 
				--	from dbo.invoice inc
				--	outer apply
				--				(
				--					select top 1
				--							agreement_no
				--					from dbo.invoice_detail idd
				--					where idd.invoice_no = inc.invoice_no
				--							and agreement_no = @agreement_no
				--				) ide
				--				where inc.invoice_due_date < dbo.xfn_get_system_date() and inc.INVOICE_STATUS = 'POST' AND inc.INVOICE_TYPE='RENTAL'
				--									and ide.agreement_no = @agreement_no
				--				) xinvoice

				-- (+) Ari 2023-10-13 ket : get overdue yg belum terbayar
				outer apply
				(
					--select	sum(ao.obligation_day) 'overdue'
					--from	dbo.agreement_obligation ao
					--where	ao.agreement_no = ama.agreement_no
					--and		ao.installment_no not in (select aop.installment_no from dbo.agreement_obligation_payment aop where aop.agreement_no = ama.agreement_no)
					----and		ao.asset_no in (select top 1 asset_no from dbo.agreement_asset where agreement_no = ama.agreement_no)

					select	sum(due.overdue) 'overdue'
					from	 
							(
								select	max(ao.obligation_day) 'overdue'
								from	dbo.agreement_obligation ao
								outer	apply (
												select	isnull(sum(aop.payment_amount),0)'payment'
												from	dbo.agreement_obligation_payment aop
												where	aop.obligation_code = ao.code
											  ) obp
								where	ao.agreement_no = ama.agreement_no
								--and		ao.installment_no not in (select aop.installment_no from dbo.agreement_obligation_payment aop where aop.agreement_no = ama.agreement_no)
								and		ao.obligation_amount - obp.payment > 0
								group	by ao.installment_no
							) due
				) ovd
				-- (+) Ari 2023-10-13
				outer apply
				( 
				SELECT sum(ao.obligation_amount - obligate.payment) "os_obligasi"
					from dbo.agreement_obligation ao
					outer apply
						( 
						SELECT isnull(sum(aop.payment_amount),0)"payment"
						from dbo.agreement_obligation_payment aop
						where aop.obligation_code = ao.code
						) obligate
						where  ao.agreement_no = @agreement_no
					and ao.obligation_amount - obligate.payment > 0
				)obli
		where	ama.agreement_no = @agreement_no and wom.code = @p_wo_no ;
		
		if not exists(select * from dbo.rpt_surat_tagih_write_off_lampiran_ii where user_id=@p_user_id)
		begin
			insert into dbo.rpt_surat_tagih_write_off_lampiran_ii
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
		select		@p_user_id
					,@p_wo_no
					,ama.agreement_external_no
					,null--isnull(xasset.rental, 0)
					,null--isnull(convert(varchar(30), tabdue.period_date, 103) + ' - ' + convert(varchar(30), tabdue.period_due_date, 103), '-')
					,null--isnull(inc.invoice_external_no, '-')
					,null--sum(inc.total_billing_amount - inc.total_discount_amount + inc.total_ppn_amount)
					,null--inc.invoice_due_date
		from		dbo.invoice_detail ide
					inner join dbo.invoice inc on inc.invoice_no = ide.invoice_no
					inner join dbo.agreement_main ama on ama.agreement_no = ide.agreement_no
					outer apply
						(
							select	sum(lease_rounded_amount) 'rental'
							from	dbo.AGREEMENT_ASSET
							where	AGREEMENT_NO = ama.AGREEMENT_NO
						) xasset
					outer apply
						(
							select	period_date
									,period_due_date
							from	dbo.xfn_due_date_period((ide.asset_no), (ide.billing_no))
						) tabdue
		where		ide.agreement_no	   = @agreement_no
					
		group by	inc.invoice_external_no
					,ama.agreement_external_no
					,xasset.rental
					,inc.invoice_external_no
					,inc.invoice_due_date
					,isnull(convert(varchar(30), tabdue.period_date, 103) + ' - ' + convert(varchar(30), tabdue.period_due_date, 103), '-') ;
		end;

		if not exists(select * from dbo.rpt_surat_tagih_write_off_lampiran_iii where user_id=@p_user_id)
		begin
			insert into dbo.rpt_surat_tagih_write_off_lampiran_iii
			(
				user_id
				,surat_no
				,no_perjanjian
				,nominal_sewa
				,total_hari_keterlambatan
				,denda_sewa
			)
			select	distinct @p_user_id
					,@p_wo_no
					,isnull(ama.agreement_external_no, '-')
					,0
					,0
					,0
			from	dbo.agreement_main ama
					left join dbo.write_off_main wom on wom.agreement_no = ama.agreement_no
			where	ama.agreement_no = @agreement_no and wom.code = @p_wo_no ;
		end;

		select	@tunggakan = SUM(nominal_invoice)
		from	dbo.RPT_surat_tagih_write_off_LAMPIRAN_II
		where	user_id = @p_user_id ;

		select	@denda = sum(denda_sewa)
		from	dbo.RPT_surat_tagih_write_off_LAMPIRAN_III
		where	user_id = @p_user_id ;

		update	dbo.rpt_surat_tagih_write_off
		set		tunggakan = @tunggakan
				,denda = @denda
		where	user_id = @p_user_id ;

		update	dbo.warning_letter					
		set		last_print_by							= @p_user_id
				,print_count							= print_count +1
				--
				,mod_by									= @p_user_id
				,mod_date								= @p_mod_date
				,mod_ip_address							= @p_mod_ip_address
		where	letter_no								= @p_wo_no ;


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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
END
