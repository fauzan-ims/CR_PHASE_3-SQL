-- Louis Senin, 25 Maret 2024 15.07.37 --
CREATE PROCEDURE dbo.xsp_rpt_invoice_denda_keterlambatan_pengembalian_asset
(
	@p_user_id		   nvarchar(max)
	,@p_agreement_no   nvarchar(50)
	,@p_invoice_no	   nvarchar(50)	= null
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
	delete dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset
	where	user_id = @p_user_id ;

	--(untuk data looping)
	delete dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset_detail
	where	user_id = @p_user_id ;

	--(untuk data lampiran)
	delete dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset_kwitansi
	where	user_id = @p_user_id ;
	
	--(untuk data lampiran)
	delete dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset_detail_info
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_image	 nvarchar(250)
			,@report_title	 nvarchar(250)
			,@no_invoice	 nvarchar(50)
			,@tanggal		 datetime
			,@npwp_no		 nvarchar(50)
			,@star_sewa		 datetime
			,@end_sewa		 datetime
			,@star_denda	 datetime
			,@end_denda		 datetime
			,@jatuh_tempo	 nvarchar(250)
			,@no_perjanjian	 nvarchar(50)
			,@lesse_desc	 nvarchar(4000)
			,@nama_bank		 nvarchar(50)
			,@rek_atas_nama	 nvarchar(50)
			,@no_rek		 nvarchar(50)
			,@nama			 nvarchar(50)
			,@jabatan		 nvarchar(50)
			,@topovdp		 int ;

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@topovdp = value
		from	dbo.sys_global_param
		where	code = 'TOPOVDP' ;

		select	@npwp_no = value
		from	dbo.sys_global_param
		where	code = 'invnpwp' ;

		select	@nama_bank = value
		from	dbo.sys_global_param
		where	code = 'bank' ;

		select	@rek_atas_nama = value
		from	dbo.sys_global_param
		where	code = 'bankname' ;

		select	@no_rek = value
		from	dbo.sys_global_param
		where	code = 'bankno' ;
		
		set @report_title = 'INVOICE DENDA KETERLAMBATAN PENGEMBALIAN KENDARAAN SEWA' ;
		
		if (isnull(@p_invoice_no, '') = '')
		begin
			set @jatuh_tempo = dbo.xfn_bulan_indonesia(dateadd(day, @topovdp, dbo.xfn_get_system_date())) ;
		end ;
		else
		begin
			select	@jatuh_tempo = dbo.xfn_bulan_indonesia(invoice_due_date)
			from	dbo.invoice
			where	invoice_no = @p_invoice_no ;
		end ;

		insert into dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset
		(
			user_id
			,agreement_no
			,report_company
			,report_title
			,report_image
			,no_invoice
			,tanggal
			,npwp_no
			,star_sewa
			,end_sewa
			,star_denda
			,end_denda
			,jatuh_tempo
			,no_perjanjian
			,client_name
			,lesse_desc
			,nama_bank
			,rek_atas_nama
			,no_rek
			,npwp_client
			,nama
			,jabatan
			,untuk_pembayaran
			,sejumlah
			,kota 
			,total
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,am.agreement_external_no
				,@report_company
				,@report_title
				,@report_image
				,right('0' + cast(month(dbo.xfn_get_system_date())as nvarchar(2)),2) + right(year(dbo.xfn_get_system_date()),2) + '/' + am.agreement_external_no -- invoice no kosong  
				,dbo.xfn_bulan_indonesia(dbo.xfn_get_system_date()) -- @tanggal kosong  
				,@npwp_no
				,dbo.xfn_bulan_indonesia(agreement_asset.handover_bast_date) --dbo.xfn_bulan_indonesia(case when am.FIRST_PAYMENT_TYPE = 'ADV' then dateadd(month,aa.multiplier,aam.start_sewa) else aam.start_sewa end)
				,dbo.xfn_bulan_indonesia(ai.maturity_date) --dbo.xfn_bulan_indonesia(case when am.FIRST_PAYMENT_TYPE = 'ADV' then dateadd(month,aa.multiplier,aam.end_sewa) else aam.end_sewa end)
				,dbo.xfn_bulan_indonesia(dateadd(day, 1, ai.maturity_date)) --dbo.xfn_bulan_indonesia(ai.maturity_date)
				,dbo.xfn_bulan_indonesia(isnull(aa.return_date,dbo.xfn_get_system_date()))
				,@jatuh_tempo
				,am.agreement_external_no
				,am.client_name
				,aa.billing_to_address
				,@nama_bank
				,@rek_atas_nama
				,@no_rek
				,aa.billing_to_npwp --npwp_client
				,sbs.signer_name
				,sp.description
				,'Denda Keterlambatan Pengembalian Kendaraan Sewa ' + cast(aas.jumlah as nvarchar(50)) + ' Kendaraan'
				,dbo.terbilang(isnull(ai.lra_penalty_amount, 0))
				,'JAKARTA'
				,ai.lra_penalty_amount
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am
				left join dbo.agreement_information ai on (
																ai.agreement_no = am.agreement_no
																--and ai.lra_penalty_amount > 0
															)
				left join ifinsys.dbo.sys_branch_signer sbs on (
																   sbs.branch_code = am.branch_code
																   --and sbs.signer_type_code = 'DEPTHEAD'
																   and sbs.signer_type_code = 'HEADOPR'
															   )
				left join ifinsys.dbo.sys_employee_position em on (
																	  em.emp_code = sbs.emp_code
																	  and  em.base_position = '1'
																  )
				left join ifinsys.dbo.sys_position sp on (sp.code = em.position_code)
				outer apply
				(
					select	min(due_date) 'start_sewa'
							,max(due_date) 'end_sewa'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aam
						outer apply
				(
					select	count(1) 'JUMLAH'
					from	dbo.agreement_asset aa
					outer apply
					(
						select	isnull(ao.obligation_amount - isnull(payment_amount, 0), 0) 'obligation_amount'
						from	dbo.agreement_obligation ao
								outer apply
								(
									select	sum(aop.payment_amount) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.obligation_code = ao.code
								) aop
						where	ao.agreement_no		   = aa.agreement_no
								and ao.asset_no		   = aa.asset_no
								and ao.obligation_type = 'LRAP'
								and ao.invoice_no		= @p_invoice_no
					) ao
					where	agreement_no = am.agreement_no
					and ao.obligation_amount > 0
				) aas
				outer apply
				(
					select	top 1
							aa.billing_to_address
							,aa.billing_to_npwp 
							,mbt.multiplier
							,aa.return_date
					from	dbo.agreement_asset aa
							inner join dbo.master_billing_type mbt on (mbt.code = aa.billing_type)
					where	aa.agreement_no = am.agreement_no
					order by aa.return_date desc
				) aa
				outer apply(
					select min(ags.handover_bast_date) 'handover_bast_date'
					from dbo.agreement_asset ags
					where ags.agreement_no = am.agreement_no
				)agreement_asset
		where	am.agreement_no = @p_agreement_no ;

		insert into dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset_detail
		(
			user_id
			,jenis
			,type
			,uraian
			,no_polisi
			,jumlah
			,jumlah_denda
			,jumlah_desc
		)
		select		@p_user_id
					,aa.asset_name
					,''
					,'Denda Keterlambatan Pengembalian Kendaraan Sewa'
					,'xxx'--aa.fa_reff_no_01
					,count(aa.asset_no)
					--,ai.lra_penalty_amount
					--,dbo.terbilang(ai.lra_penalty_amount)
					,sum(ao.obligation_amount)
					,dbo.terbilang(ai.lra_penalty_amount)
		from		dbo.agreement_asset aa
					inner join dbo.invoice_detail ide on ide.asset_no = aa.asset_no
					inner join dbo.agreement_information ai on (ai.agreement_no = aa.agreement_no)
					outer apply
					(
						select	isnull(ao.obligation_amount - isnull(payment_amount, 0), 0) 'obligation_amount'
						from	dbo.agreement_obligation ao
								outer apply
								(
									select	sum(aop.payment_amount) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.obligation_code = ao.code
								) aop
						where	ao.agreement_no		   = aa.agreement_no
								and ao.asset_no		   = aa.asset_no
								and ao.obligation_type = 'LRAP'
					) ao
		where		aa.agreement_no		= @p_agreement_no
					and ide.invoice_no	= @p_invoice_no
					--and ai.lra_penalty_amount > 0
					and ao.obligation_amount > 0
		group by	aa.asset_name
					,ai.lra_penalty_amount
					--,ao.obligation_amount
					--,aa.fa_reff_no_01 ;

		
		insert into dbo.rpt_invoice_denda_keterlambatan_pengembalian_asset_detail_info
		(
			user_id
			,jenis
			,type
			,uraian
			,no_polisi
			,jumlah
			,jumlah_denda
			,jumlah_desc
		)
		select		@p_user_id
					,aa.asset_name
					,''
					,'Denda Keterlambatan Pengembalian Kendaraan Sewa'
					,aa.fa_reff_no_01
					,1 'asset_no' --count(aa.asset_no)
					--,ai.lra_penalty_amount
					--,dbo.terbilang(ai.lra_penalty_amount)
					,sum(ao.obligation_amount)
					,dbo.terbilang(sum(ai.lra_penalty_amount))
		from		dbo.agreement_asset aa
					inner join dbo.invoice_detail ide on ide.asset_no = aa.asset_no
					inner join dbo.agreement_information ai on (ai.agreement_no = aa.agreement_no)
					outer apply
					(
						select	isnull(ao.obligation_amount - isnull(payment_amount, 0), 0) 'obligation_amount'
						from	dbo.agreement_obligation ao
								outer apply
								(
									select	sum(aop.payment_amount) 'payment_amount'
									from	dbo.agreement_obligation_payment aop
									where	aop.obligation_code = ao.code
								) aop
						where	ao.agreement_no		   = aa.agreement_no
								and ao.asset_no		   = aa.asset_no
								and ao.obligation_type = 'LRAP'
					) ao
		where		aa.agreement_no			= @p_agreement_no
					and ide.invoice_no		= @p_invoice_no
					--and ai.lra_penalty_amount > 0
					and ao.obligation_amount > 0
		group by	aa.asset_name
					--,ai.lra_penalty_amount
					--,ao.obligation_amount
					,aa.fa_reff_no_01 ;
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