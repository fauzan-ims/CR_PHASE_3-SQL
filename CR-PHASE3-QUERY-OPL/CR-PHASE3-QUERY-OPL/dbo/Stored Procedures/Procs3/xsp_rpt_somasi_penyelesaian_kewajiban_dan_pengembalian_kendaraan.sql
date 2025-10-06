CREATE PROCEDURE dbo.xsp_rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan
(
	@p_user_id		   nvarchar(max)
	,@p_agreement_no   nvarchar(50)
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
	delete	dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN
	where	user_id = @p_user_id ;

	--(untuk looping)
	delete	dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_TUNGGAKAN
	where	user_id = @p_user_id ;

	--(untuk looping data lampiran)
	delete	dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_DENDA_PEMBATALAN
	where	user_id = @p_user_id ;

	--(untuk looping data lampiran)
	delete	dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_DENDA_KETERLAMBATAN
	where	user_id = @p_user_id ;

	--(untuk looping data lampiran)
	delete	dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_KEKURANGAN_PEMBAYARAN
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
			,@merk				  nvarchar(50)
			,@chassis_no		  nvarchar(50)
			,@engine_no			  nvarchar(50)
			,@warna				  nvarchar(50)
			,@tahun_asset		  int
			,@depthead			  nvarchar(50)
			,@branch_code_dept	  nvarchar(50)
			,@invoice_date		  datetime 
			,@agreement_code	  nvarchar(50)
			,@add_days			  int			
			,@penalty_charge	  decimal(9, 6)

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @report_title = N'SOMASI PENYELESAIAN KEWAJIBAN DAN PENGEMBALIAN KENDARAAN' ;

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

		select	@penalty_charge = charges_rate
		from	dbo.agreement_charges
		where	agreement_no	 = @p_agreement_no
				and charges_code = 'CETP' ;

		select	@branch_code = branch_code
		from	dbo.agreement_main
		where	agreement_no = @p_agreement_no ;

		select	@kota = scy.description
		from	ifinsys.dbo.sys_branch sbh
				inner join ifinsys.dbo.sys_city scy on scy.code = sbh.city_code
		where	sbh.code = @branch_code ;
		
		select	@depthead = sbs.signer_name
		from	ifinsys.dbo.sys_branch_signer sbs
		where	branch_code			 = @branch_code
				and signer_type_code = 'HEADOPR' ;

		insert into dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN
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
			,UP_NAME
			,TANGGAL_TUNGGAKAN
			,AGREEMENT_NO
			,AGREEMENT_DATE
			,COMPANY_NAME
			,NAMA_BANK
			,NO_REK
			,REK_ATAS_NAMA
			,EMPLOYEE_NAME
			,MERK
			,CHASSIS_NO
			,ENGINE_NO
			,WARNA
			,TAHUN
			,ADD_DAYS
			,PERJANJIAN_INDUK		--main_contract_no db aplication_extention
			,PERJANJIAN_PELAKSANA	--agreement_no
			,TANGGAL_PERJANJIAN		-- agreementdate
			,JENIS_KENDARAAN		--
			,NO_SERI --
			,NO_POLISI --
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	DISTINCT 
				@p_user_id
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
				,dateadd(day,@add_days,dbo.xfn_get_system_date())
				,am.agreement_external_no
				,am.agreement_date
				,am.client_name
				,@nama_bank
				,@no_rek
				,@rek_atas_nama
				,@depthead
				,mmr.description
				,isnull(aa.fa_reff_no_02,'')
				,isnull(aa.fa_reff_no_03,'')
				,aav.colour
				,aa.asset_year
				,@add_days
				,aext.MAIN_CONTRACT_NO
				,am.agreement_external_no
				,am.AGREEMENT_DATE
				--,mmr.DESCRIPTION
				,aa.asset_name -- (+) Ari 2023-10-30 ket : nama asset sesuai tampilan screen
				,isnull(aa.replacement_fa_reff_no_02, aa.fa_reff_no_02)
				,isnull(aa.replacement_fa_reff_no_01, aa.fa_reff_no_01)
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
				left join dbo.agreement_asset_vehicle		 aav on aav.asset_no = aa.asset_no
				left join dbo.application_extention aext on (aext.application_no = am.application_no)
				left join dbo.master_vehicle_type mht on mht.code			  = aav.vehicle_type_code
				left join dbo.master_vehicle_model mvm on mvm.code			  = aav.vehicle_model_code
				left join dbo.master_vehicle_merk mmr on mmr.code			  = aav.vehicle_merk_code
				left join dbo.client_corporate_info			 cci on (cci.client_code = am.client_no)
				left join dbo.stop_billing					 sb on sb.agreement_no = am.agreement_no and status='APPROVE' 
		where	am.agreement_no = @p_agreement_no ;


		insert into dbo.RPT_SOMASI_PENYELESAIAN_KEWAJIBAN_DAN_PENGEMBALIAN_KENDARAAN_TUNGGAKAN
		(
			user_id
			,agreement_no
			,periode_pemakaian
			,nilai_sewa
			,tanggal_jatuh_tempo
			,perjanjian_induk
		)
			select @p_user_id,
				   ama.agreement_external_no,
				   isnull(
							 convert(varchar(30), tabdue.period_date, 103) + ' - ' + convert(varchar(30), tabdue.period_due_date, 103),
							 '-'
						 ),
				   isnull(inc.total_billing_amount, 0) + isnull(inc.total_ppn_amount, 0),
				   inc.invoice_due_date,
				   aext.main_contract_no
			from dbo.invoice inc
				outer apply
							(
								select top 1
									   agreement_no,
									   idd.asset_no,
									   idd.billing_no
								from dbo.invoice_detail idd
								where idd.invoice_no = inc.invoice_no
									  and agreement_no = @p_agreement_no
							) ide
				left join dbo.agreement_main ama	on ama.agreement_no = ide.agreement_no 
				outer apply
							(	select	--period_date,
										--period_due_date
										-- (+) Ari 2023-10-23 ket : jika arrear period + 1, jika adv period_due - 1
										case ama.first_payment_type
											when 'ARR'
											then period_date + 1
											else period_date
										end		'period_date'
										,case ama.FIRST_PAYMENT_TYPE
											when 'ADV'
											then period_due_date - 1
											else period_due_date
										end		'period_due_date'
										-- (+) Ari 2023-10-23
							from dbo.xfn_due_date_period((ide.asset_no), (ide.billing_no))
						) tabdue
				LEFT join dbo.application_extention aext	on (aext.application_no = ama.application_no)

	--left join dbo.stop_billing sb on sb.agreement_no		   = ama.agreement_no
	--								 and   status			   = 'approve'
	--left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
	--left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
	--outer apply (
	--		select isnull(aaa.due_date,asat.handover_bast_date) 'from_date',aaa2.due_date'to_date',aaa.invoice_no,aaa2.billing_no
	--		from dbo.agreement_asset_amortization aaa 
	--		inner join dbo.agreement_asset asat on asat.asset_no = aaa.asset_no
	--		left join dbo.agreement_asset_amortization aaa2 on aaa2.agreement_no=aaa.agreement_no and aaa2.asset_no=aaa.asset_no and aaa2.billing_no-1 = aaa.billing_no --anggapan in arear
	--		where aaa.invoice_no=inc.invoice_no and aaa.asset_no=ide.asset_no and aaa.billing_no=ide.billing_no
	--)tabdue

	where ide.agreement_no = @p_agreement_no --and tabdue.period_date <> '' ;
		  and inc.invoice_status = 'POST'
		  and inc.invoice_type = 'RENTAL'
		  and inc.invoice_due_date <= dbo.xfn_get_system_date();
	 
		declare @tempTable table
		(
			user_id							nvarchar(max)
			,agreement_no					nvarchar(50)
			,nilai_sewa						decimal(18,2)
			,total_hari_keterlambatan		int
			,nilai_denda_keterlambatan		decimal(18,2)
			,perjanjian_induk				nvarchar(50)
			,row_count						int
		) ;

		insert into @tempTable
		(
		    user_id,
		    agreement_no,
		    nilai_sewa,
		    total_hari_keterlambatan,
		    nilai_denda_keterlambatan,
		    perjanjian_induk
		)
		select	distinct @p_user_id
				,isnull(ama.agreement_external_no,'-')
				,isnull(asset.rental,0)
				,isnull(xinvoice.ovd_day,0)
				,isnull(obli.os_obligasi, 0)
				,aext.main_contract_no
		from	dbo.agreement_main ama
				left join dbo.application_extention aext on (aext.application_no = ama.application_no)
				--left join dbo.stop_billing sb on sb.agreement_no		   = ama.agreement_no
				--								 and   status			   = 'APPROVE'
				--left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
				--inner join dbo.invoice inc on	inc.invoice_no			   = ide.invoice_no
				--								and inc.invoice_status	   = 'POST'
				--								and inc.invoice_type	   = 'RENTAL'
				--								and inc.invoice_due_date   <= dbo.xfn_get_system_date()
				--left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no

				outer apply
				( select sum(lease_rounded_amount) 'rental'
					from dbo.agreement_asset aas
					where agreement_no = @p_agreement_no
				) asset
				outer apply(
					select  sum( datediff(day,inc.invoice_due_date, dbo.xfn_get_system_date())) ovd_day 
					from dbo.invoice inc
					outer apply
								(
									select top 1
											agreement_no
									from dbo.invoice_detail idd
									where idd.invoice_no = inc.invoice_no
											and agreement_no = @p_agreement_no
								) ide
								where inc.invoice_due_date < dbo.xfn_get_system_date() and inc.INVOICE_STATUS = 'POST' AND inc.INVOICE_TYPE='RENTAL'
													and ide.agreement_no = @p_agreement_no
								) xinvoice
				outer apply
				( select sum(ao.obligation_amount - obligate.payment) 'os_obligasi'
					from dbo.agreement_obligation ao
					outer apply
						( select isnull(sum(aop.payment_amount),0)'payment'
						from dbo.agreement_obligation_payment aop
						where aop.obligation_code = ao.code
						) obligate
						where  ao.agreement_no = @p_agreement_no
					and ao.obligation_amount - obligate.payment > 0
				)obli
				
		where	ama.agreement_no = @p_agreement_no ;

		insert into dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_denda_keterlambatan
		(
			user_id
			,agreement_no
			,nilai_sewa
			,total_hari_keterlambatan
			,nilai_denda_keterlambatan
			,perjanjian_induk
		)
		select		user_id
					,agreement_no
					,nilai_sewa
					,total_hari_keterlambatan
					,nilai_denda_keterlambatan
					,perjanjian_induk
		from		@tempTable
		GROUP BY	 user_id
					,agreement_no 
					,nilai_sewa 
					,perjanjian_induk
					,total_hari_keterlambatan
					,nilai_denda_keterlambatan
					

		--insert into dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_denda_keterlambatan
		--(
		--	user_id
		--	,agreement_no
		--	,nilai_sewa
		--	,total_hari_keterlambatan
		--	,nilai_denda_keterlambatan
		--	,perjanjian_induk
		--)
		--select	distinct @p_user_id
		--		,isnull(ama.agreement_external_no,'-')
		--		,isnull(ide.billing_amount,0)
		--		,isnull(aob.obligation_day,0)
		--		,0.1*isnull(ide.billing_amount,0)*isnull(aob.obligation_day,0)
		--		,aext.MAIN_CONTRACT_NO
		--from	dbo.agreement_main ama
		--		left join dbo.application_extention aext on (aext.application_no = ama.application_no)
		--		left join dbo.stop_billing sb on sb.agreement_no		   = ama.agreement_no
		--										 and   status			   = 'APPROVE'
		--		left join dbo.invoice_detail ide on ide.agreement_no	   = ama.agreement_no
		--		inner join dbo.invoice inc on	inc.invoice_no			   = ide.invoice_no
		--										and inc.invoice_status	   = 'POST'
		--										and inc.invoice_type	   = 'RENTAL'
		--										and inc.invoice_due_date   <= dbo.xfn_get_system_date()
		--		left join dbo.agreement_obligation aob on aob.agreement_no = ama.agreement_no
		--where	ama.agreement_no = @p_agreement_no;
				
		insert into dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_denda_pembatalan
		(
			user_id
			,agreement_no
			,nilai_sewa
			,sisa_periode_sewa
			,denda_pembatalan
			,perjanjian_induk
		)
		select 
				@p_user_id
				,ama.agreement_external_no
				,asset.rental
				,aif.os_period
				,isnull(aif.installment_amount,0) * isnull(aif.os_period,0) * (@penalty_charge / 100)
				,aext.main_contract_no
		from	dbo.agreement_information aif
				inner join agreement_main ama on ama.agreement_no = aif.agreement_no
					outer apply
					( select sum(lease_rounded_amount) 'rental'
						from dbo.agreement_asset aas
						where agreement_no = @p_agreement_no
					) asset
				left join dbo.application_extention aext on (aext.application_no = ama.application_no)
				--left join dbo.agreement_asset aa on aa.agreement_no = aif.agreement_no
				--left join ifinams.dbo.asset a on a.rental_reff_no	= aa.asset_no
		where	ama.agreement_no = @p_agreement_no ;

		insert into dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_kekurangan_pembayaran
		(
			user_id
			,agreement_no
			,invoice_no
			,nominal_invoice
			,nominal_pembayaran
			,tanggal_pembayaran
			,kekurangan_pembayaran
			,perjanjian_induk
		)
		select	distinct
				@p_user_id
				,ama.agreement_external_no
				,i.invoice_external_no
				,i.total_billing_amount + i.total_ppn_amount
				,i.total_amount
				,xpayment.paid_date
				,i.total_pph_amount
				,aext.main_contract_no
			--dbo.agreement_invoice ai
		from	dbo.invoice i 
				INNER JOIN invoice_pph iph ON iph.INVOICE_NO = i.INVOICE_NO
				outer apply
							(
								select top 1
										agreement_no
								from dbo.invoice_detail idd
								where idd.invoice_no = i.invoice_no
										and agreement_no = @p_agreement_no
							) ide
				OUTER APPLY
				(	
						SELECT TOP 1 aip.PAYMENT_DATE 'paid_date' FROM dbo.AGREEMENT_INVOICE_PAYMENT aip 
						WHERE aip.INVOICE_NO = i.INVOICE_NO
				) xpayment
				inner join agreement_main ama on ama.agreement_no   = ide.agreement_no
				left join dbo.application_extention aext on (aext.application_no = ama.application_no)
				--left join dbo.invoice_detail id on id.agreement_no = ai.agreement_no
				--inner join 
				--left join ifinams.dbo.asset a on a.rental_reff_no  = id.asset_no
		where	ide.agreement_no = @p_agreement_no 
				and i.invoice_status	   = 'POST'
				and i.invoice_type			= 'RENTAL'
				and i.invoice_due_date		<= dbo.xfn_get_system_date()
				AND iph.SETTLEMENT_STATUS <> 'POST'

		update	dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan
		set		jumlah_a =
				(
					select	isnull(sum(nilai_sewa),0)
					from	dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_tunggakan
					where	user_id = @p_user_id
				)
				,jumlah_b =
				 (
					 select isnull(sum(nilai_denda_keterlambatan),0)
					 from	dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_denda_keterlambatan
					 where	user_id = @p_user_id
				 )
				,jumlah_c =
				 (
					 select isnull(sum(denda_pembatalan),0)
					 from	dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_denda_pembatalan
					 where	user_id = @p_user_id
				 )
				,jumlah_d =
				 (
					 select isnull(sum(kekurangan_pembayaran),0)
					 from	dbo.rpt_somasi_penyelesaian_kewajiban_dan_pengembalian_kendaraan_kekurangan_pembayaran
					 where	user_id = @p_user_id
				 )
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
