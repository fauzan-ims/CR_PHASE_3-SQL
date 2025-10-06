CREATE PROCEDURE dbo.xsp_rpt_invoice_kwitansi
(
	@p_user_id		   nvarchar(50)
	,@p_no_invoice	   nvarchar(50)
	,@p_group_print	   nvarchar(1) = ''
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
	if @p_group_print <> '1'
	begin
		delete	dbo.rpt_invoice_kwitansi
		where	user_id = @p_user_id ;

		delete	dbo.rpt_invoice_kwitansi_detail
		where	user_id = @p_user_id ;
	end ;

	declare @temp_tabel_detail as table
	(
		user_id			  nvarchar(50)
		,receipt_no		  nvarchar(50)
		,agreement_no	  nvarchar(50)
		,agreement_date	  datetime
		,jenis_alat		  nvarchar(250)
		,type			  nvarchar(250)
		,unit			  int
		,star_periode	  datetime
		,end_periode	  datetime
		,no_polisi		  nvarchar(50)
		,star_contract	  datetime
		,end_contract	  datetime
		,harga_perunit	  decimal(18, 2)
		,jumlah_harga	  decimal(18, 2)
		,sub_total		  decimal(18, 2)
		,ppn			  decimal(18, 2)
		,pph			  decimal(18, 2)
		,total			  decimal(18, 2)
		,sum_agreement	  int
		,sum_jeni_or_type int
		,sum_unit		  int
		,kwitansi_no	  nvarchar(50)
		,dpp_nilai_lain	  DECIMAL(18, 2)
	) ;

	-- (+) Ari 2023-10-16 ket : add table temp to get asset name
	declare @table_temp table
	(
		asset_name nvarchar(4000)
	) ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			--,@no_kwitansi			nvarchar(50)
			--,@sudah_terima			nvarchar(250)
			--,@sejumlah				nvarchar(250)
			--,@untuk_pembayaran		nvarchar(250)
			--,@star_periode			datetime
			--,@end_periode			datetime
			--,@jatuh_tempo			datetime
			--,@total					decimal(18, 2)
			,@harga_perunit			decimal(18, 2)
			--,@kota					nvarchar(50)
			--,@tanggal				datetime
			--,@nama					nvarchar(50)
			--,@jabatan				nvarchar(50)
			--,@nama_bank				nvarchar(50)
			--,@rek_atas_nama			nvarchar(50)
			--,@no_rek				nvarchar(50)
			--,@employee_name			nvarchar(50)
			--,@employee_position		nvarchar(50)
			--,@jumlah_item			int
			--,@untuk_pembayaran1		nvarchar(250)
			,@client_name			nvarchar(250)
			,@item_name				nvarchar(250)
			,@invoice_external_no	nvarchar(50)
			,@invoice_date			datetime
			--,@received_reff_no		nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@agreement_date		datetime
			,@quantity				int
			,@invoice_due_date		datetime
			,@plat_no				nvarchar(50)
			,@maturity_date			datetime
			,@unit_amount			decimal(18, 2)
			,@total_ppn_amount		decimal(18, 2)
			,@total_pph_amount		decimal(18, 2)
			--,@jumlah_harga			decimal(18, 2)
			,@sub_total				decimal(18, 2)
			,@total_jumlah_harga	decimal(18, 2)
			--,@jumlah_agreement		int
			--,@jumlah_item1			int
			--,@jumlah_quantity		int
			,@branch_code			nvarchar(50)
			,@bank_name				nvarchar(100)
			,@bank_account_name		nvarchar(250)
			,@bank_account_no		nvarchar(50)
			--,@min_invoice_date		datetime
			--,@max_invoice_date		datetime
			,@is_receipt_deduct_pph nvarchar(1)
			,@nama_signer			nvarchar(250)
			,@inv_external_no		nvarchar(50)
			,@kota					nvarchar(250)
			,@kwitansi_no			nvarchar(50)
			--,@client_npwp			nvarchar(50)
			--,@client_address		nvarchar(250)
			--,@invoice_type			nvarchar(250)
			--,@bast_date				datetime
			--,@periode_denda_to		datetime;
			,@description			nvarchar(4000)
			,@qty					int
			,@asset_name			nvarchar(250)
			,@star_date				datetime
			,@type					nvarchar(250)
			,@no_polisi				nvarchar(50)
			,@remarks				nvarchar(4000)
			,@dpp_nilai_lain		decimal(18, 2);

	begin try
		declare @temptable table
		(
			agreement_no nvarchar(50)
		) ;

		insert into @temptable
		(
			agreement_no
		)
		select		agreement_no
		from		dbo.invoice_detail
		where		invoice_no = @p_no_invoice
		group by	agreement_no ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set @report_title = N'KWITANSI' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@bank_name = value
		from	dbo.sys_global_param
		where	code = 'BANK' ;

		select	@bank_account_no = value
		from	dbo.sys_global_param
		where	code = 'BANKNO' ;

		select	@bank_account_name = value
		from	dbo.sys_global_param
		where	code = 'BANKNAME' ;

		--select	@employee_name = sem.name
		--		,@employee_position = sysp.description
		--from	ifinsys.dbo.sys_employee_main sem
		--		inner join ifinsys.dbo.sys_employee_position sep on (sem.code = sep.emp_code)
		--		--left join ifinsys.dbo.sys_position sysp on (sysp.code = sep.position_code)
		--		outer apply
		--			(
		--				select	*
		--				from	ifinsys.dbo.sys_position
		--				where	code = sep.position_code
		--			) sysp
		--where	sem.code = @p_user_id ;

		--select	@min_invoice_date	= min (bgnd.due_date)
		--select	@max_invoice_date	= max(bgnd.due_date) 
		--from	dbo.billing_generate_detail bgnd with (nolock)
		--where	bgnd.invoice_no = @p_no_invoice
		select	@invoice_external_no = invc.invoice_external_no
				,@invoice_date = invc.invoice_date
				,@branch_code = invc.branch_code
		from	dbo.invoice invc with (nolock)
		where	invc.invoice_no = @p_no_invoice ;

		select	@kota = value
		from	dbo.sys_global_param
		where	code = 'INVCITY' ;

		select	top 1
				@is_receipt_deduct_pph = aa.is_receipt_deduct_pph
		from	dbo.invoice_detail invd
				inner join dbo.agreement_asset aa on (
														 aa.asset_no		   = invd.asset_no
														 and   aa.agreement_no = invd.agreement_no
													 )
		where	invd.invoice_no = @p_no_invoice ;

		select	@sub_total = isnull(inv.total_billing_amount, 0) - isnull(inv.credit_billing_amount, 0) - inv.total_discount_amount --isnull(ind.billing_amount, 0) * isnull(ind.quantity, 0)
		from	dbo.invoice inv
		--inner join dbo.invoice_detail ind on (ind.invoice_no = inv.invoice_no)
		where	inv.invoice_no = @p_no_invoice ;

		--select		@sub_total = sum(@unit_amount)
		--from		dbo.invoice inv
		--			inner join dbo.invoice_detail ind on (ind.invoice_no = inv.invoice_no)
		--where		inv.invoice_no = @p_no_invoice
		--group by	ind.quantity
		--			,ind.billing_amount ;

		--(+) Raffyanda 16/10/2023 15.04.00 penambahan operasi pengurangan dengan credit billing amount pada total harga
		select	@total_jumlah_harga = case 
										  when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
										  when  @is_receipt_deduct_pph = '1' then (inv.total_billing_amount - inv.total_discount_amount) + case
																													 when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																													 else inv.credit_ppn_amount
																												 end - case
																														   when isnull(inv.credit_pph_amount, 0) = 0 then inv.total_pph_amount
																														   else inv.credit_pph_amount
																													   end - inv.credit_billing_amount
										  else (inv.total_billing_amount - inv.total_discount_amount) + case
																											when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																											else inv.credit_ppn_amount
																										end - inv.credit_billing_amount
									  end
		--,@invoice_type = inv.invoice_type
		from	dbo.invoice inv
		where	inv.invoice_no = @p_no_invoice ;

		select	top 1
			--@client_npwp = asat.billing_to_npwp
			--,@client_address = asat.npwp_address
			--,
				@client_name = asat.npwp_name
		from	dbo.invoice_detail invd with (nolock)
				inner join agreement_asset asat with (nolock) on asat.asset_no			 = invd.asset_no
																 and   asat.agreement_no = invd.agreement_no
		where	invd.invoice_no = @p_no_invoice ;

		--select		@jumlah_agreement = count(1)
		--from		dbo.invoice_detail with (nolock)
		--where		invoice_no = @p_no_invoice
		--group by	agreement_no ;

		--select		@jumlah_item1 = count(1)
		--			--,@jumlah_item = count(1)
		--from		dbo.invoice_detail indao with (nolock)
		--where		indao.invoice_no = @p_no_invoice
		--group by asset_no

		--select		@jumlah_quantity = count(1)
		--from		dbo.invoice_detail indao with (nolock)
		--where		indao.invoice_no = @p_no_invoice
		select	@nama_signer = signer_name
		from	ifinsys.dbo.sys_branch_signer --with (nolock)
		where	signer_type_code = 'HEADOPR'
				and branch_code	 = @branch_code ;

		--select		@invoice_type = inv.invoice_type
		--from		dbo.invoice inv
		--			inner join dbo.sys_general_subcode sc on inv.invoice_type = sc.code
		--where		inv.invoice_no = @p_no_invoice ;

		--select	@bast_date = asat.handover_bast_date
		--from	dbo.agreement_asset asat
		--where	asat.agreement_no = @agreement_no ;

		--select	@periode_denda_to = et_date
		--from	dbo.et_main
		--		inner join dbo.et_detail on (et_detail.et_code			 = et_main.code)
		--		inner join dbo.invoice_detail on (invoice_detail.asset_no = et_detail.asset_no)
		--where	et_status					= 'APPROVE'
		--		and invoice_detail.asset_no = et_detail.asset_no
		--		and invoice_no				= @p_no_invoice ;
		begin

			insert into dbo.rpt_invoice_kwitansi
			(
				user_id
				,no_invoice
				,report_company
				,report_title
				,report_image
				,no_kwitansi
				,sudah_terima
				,sejumlah
				,currency_desc
				,untuk_pembayaran
				,star_periode
				,end_periode
				,jatuh_tempo
				,total
				,kota
				,tanggal
				,nama
				,jabatan
				,nama_bank
				,rek_atas_nama
				,no_rek
				,type
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,dpp_nilai_lain

			)
			select	@p_user_id
					,inv.invoice_external_no
					,@report_company
					,@report_title
					,@report_image
					,inv.kwitansi_no
					,@client_name
					--(+) Raffyanda 16/10/2023 15.04.00 penambahan operasi pengurangan dengan credit billing amount pada total harga
					,case 
						 when inv.total_billing_amount - inv.credit_billing_amount = 0 then '0'
						 when @is_receipt_deduct_pph = '1' then dbo.Terbilang(	(inv.total_billing_amount - inv.total_discount_amount) + case
																													 when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																													 else inv.credit_ppn_amount
																												 end - case
																														   when isnull(inv.credit_pph_amount, 0) = 0 then inv.total_pph_amount
																														   else inv.credit_pph_amount
																													   end - inv.credit_billing_amount
													)
						 else dbo.Terbilang(   (inv.total_billing_amount - inv.total_discount_amount) + case
																											when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																											else inv.credit_ppn_amount
																										end - inv.credit_billing_amount
										   )
					 --when '1' then dbo.terbilang(inv.total_amount - (inv.credit_billing_amount + inv.credit_ppn_amount - inv.credit_pph_amount))
					 --else dbo.terbilang((inv.total_billing_amount + inv.total_ppn_amount) - (inv.credit_billing_amount + inv.credit_ppn_amount))
					 end
					,case inv.currency_code
						 when 'IDR' then 'Rupiah'
						 when 'USD' then 'Dollar'
						 when 'JPY' then 'Yen'
						 else ''
					 end
					--,case 
					--	when @jumlah_item = 1 then @untuk_pembayaran
					--	else @untuk_pembayaran1
					--end
					,inv.invoice_name
					,null --inv.invoice_date
					,null --inv.invoice_due_date
					,dbo.xfn_bulan_indonesia(inv.invoice_due_date) --DATEADD(day, -1, inv.invoice_due_date) as dateadd
					--(+) Raffyanda 16/10/2023 15.04.00 penambahan operasi pengurangan dengan credit billing amount pada total harga
					,case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
						 when @is_receipt_deduct_pph = '1' then (inv.total_billing_amount - inv.total_discount_amount) + case
																									when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																									else inv.credit_ppn_amount
																								end - case
																										  when isnull(inv.credit_pph_amount, 0) = 0 then inv.total_pph_amount
																										  else inv.credit_pph_amount
																									  end - inv.credit_billing_amount
						 else (inv.total_billing_amount - inv.total_discount_amount) + case
																						   when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
																						   else inv.credit_ppn_amount
																					   end - inv.credit_billing_amount
					 --when '1' then (inv.total_amount - (inv.credit_billing_amount + inv.credit_ppn_amount - inv.credit_pph_amount))
					 --else ((inv.total_billing_amount + inv.total_ppn_amount) - (inv.credit_billing_amount + inv.credit_ppn_amount))
					 end
					--,(inv.total_billing_amount - inv.total_discount_amount) + inv.total_ppn_amount - inv.total_pph_amount
					--,(inv.total_billing_amount - inv.total_discount_amount) + inv.total_ppn_amount
					,@kota --inv.branch_name
					,dbo.xfn_bulan_indonesia(isnull(inv.new_invoice_date, inv.invoice_date))
					,@nama_signer
					,'Operating Lease Head'
					,@bank_name
					,@bank_account_name
					,@bank_account_no
					,inv.invoice_type
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,inv.dpp_nilai_lain
			from	dbo.invoice inv with (nolock)
			where	inv.invoice_no = @p_no_invoice ;

			declare curr_penagihan_detail cursor fast_forward read_only for
			--inv.received_reff_no				--receipt_no
			--,
			select	am.agreement_external_no --ind.agreement_no				--agreement_no
					,am.agreement_date --agreement_date
					,aa.asset_name --isnull(ass.item_name,aa.asset_name)--jenis_alat
					,ind.quantity --unit
					,case when @p_no_invoice = '03906.INV.2034.02.2024' then '2024-01-01' else
					period.period_date end --star_periode
					,case when @p_no_invoice = '03906.INV.2034.02.2024' then '2024-01-31' else
					period.period_due_date end --end_periode
					,isnull(aa.FA_REFF_NO_01,aa.replacement_fa_reff_no_01) --isnull(asv.plat_no,isnull(aa.REPLACEMENT_FA_REFF_NO_01,aa.FA_REFF_NO_01))--no_polisi
					,aa.handover_bast_date + 1 --star_contract
					,aif.maturity_date --end_contract
					,case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
						 when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
						 else inv.credit_ppn_amount
					 end --ppn
					,case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
						 when isnull(inv.credit_pph_amount, 0) = 0 then inv.total_pph_amount
						 else inv.credit_pph_amount
					 end --pph
					,aa.lease_rounded_amount
					,inv.invoice_external_no
					,inv.kwitansi_no
					,ind.billing_amount - isnull(credit.adjustment_amount, 0) - ind.discount_amount
					,inv.dpp_nilai_lain
			from	dbo.invoice inv with (nolock)
					inner join dbo.invoice_detail ind with (nolock) on (ind.invoice_no = inv.invoice_no)
					--inner join ifinams.dbo.asset ass with (nolock) on (ass.asset_no = ind.asset_no)
					inner join dbo.agreement_asset aa with (nolock) on (aa.asset_no = ind.asset_no)
					inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ind.agreement_no)
					--left join ifinams.dbo.asset_vehicle asv on (asv.asset_code = isnull(aa.FA_CODE,aa.REPLACEMENT_FA_CODE))
					left join dbo.agreement_information aif with (nolock) on (aif.agreement_no = ind.agreement_no)
					--outer apply(
					--	select	*
					--	from	ifinams.dbo.asset_vehicle asv
					--	where	asv.asset_code = isnull(aa.fa_code, aa.replacement_fa_code)
					--)asv
					--raffyanda 30/10/2023 10:56:00 penambahan operasi pengurangan dengan credit amount pada kolom jumlah harga di invoice kwitansi
					outer apply
			(
				select	cnd.adjustment_amount
				from	dbo.credit_note_detail cnd
				INNER JOIN dbo.credit_note cn ON (cn.code = cnd.credit_note_code)
				where	ind.id = cnd.invoice_detail_id
				and		cn.status <> 'CANCEL'
			) credit
					outer apply
			(
				select	asset_no
						,billing_no
						--,period_date
						-- (+) Ari 2023-10-16 ket : arrear period_date + 1, adv period_due_date - 1
						,case am.first_payment_type
							 when 'ARR' then period_date + 1
							 else period_date
						 end 'period_date'
						,period_due_date
						--,case am.first_payment_type
						--	 when 'ADV' then period_due_date -- 1
						--	 else period_due_date
						-- end 'period_due_date'
				-- (+) Ari 2023-10-16
				from	dbo.xfn_due_date_period(ind.asset_no, cast(ind.billing_no as int)) aa
				where	ind.billing_no	 = aa.billing_no
						and ind.asset_no = aa.asset_no
			) period
			where	inv.invoice_no = @p_no_invoice 
			order	by aa.asset_no asc

			open curr_penagihan_detail ;

			fetch next from curr_penagihan_detail
			--into @received_reff_no	
			--	 ,
			into @agreement_no
				 ,@agreement_date
				 ,@item_name
				 ,@quantity
				 ,@invoice_date
				 ,@invoice_due_date
				 ,@plat_no
				 ,@star_date
				 ,@maturity_date
				 ,@total_ppn_amount
				 ,@total_pph_amount
				 ,@harga_perunit
				 ,@inv_external_no
				 ,@kwitansi_no
				 ,@unit_amount 
				 ,@dpp_nilai_lain

			while @@fetch_status = 0
			BEGIN

				INSERT into @temp_tabel_detail
				(
					user_id
					,receipt_no
					,agreement_no
					,agreement_date
					,jenis_alat
					,type
					,unit
					,star_periode
					,end_periode
					,no_polisi
					,star_contract
					,end_contract
					,harga_perunit
					,jumlah_harga
					,sub_total
					,ppn
					,pph
					,total
					,sum_agreement
					,sum_jeni_or_type
					,sum_unit
					,kwitansi_no
					,dpp_nilai_lain
				)
				values
				(
					@p_user_id
					,@inv_external_no
					,@agreement_no
					,@agreement_date
					,@item_name
					,@item_name
					,@quantity
					,@invoice_date
					,@invoice_due_date
					,@plat_no
					,@star_date
					,@maturity_date
					,@harga_perunit
					,@unit_amount
					,@sub_total
					,@total_ppn_amount
					,case @is_receipt_deduct_pph
						 when '1' then @total_pph_amount
						 else 0
					 end
					,@total_jumlah_harga
					,null --@jumlah_agreement
					,null --@jumlah_item1
					,null --@jumlah_quantity
					,@kwitansi_no
					,@dpp_nilai_lain
				) ;

				fetch next from curr_penagihan_detail
				into @agreement_no
					 ,@agreement_date
					 ,@item_name
					 ,@quantity
					 ,@invoice_date
					 ,@invoice_due_date
					 ,@plat_no
					 ,@star_date
					 ,@maturity_date
					 ,@total_ppn_amount
					 ,@total_pph_amount
					 ,@harga_perunit
					 ,@inv_external_no
					 ,@kwitansi_no
					 ,@unit_amount 
					 ,@dpp_nilai_lain
			end ;

			close curr_penagihan_detail ;
			deallocate curr_penagihan_detail ;

			insert into dbo.RPT_INVOICE_KWITANSI_DETAIL
			(
				user_id
				,receipt_no
				,agreement_no
				,agreement_date
				,jenis_alat
				,type
				,unit
				,star_periode
				,end_periode
				,no_polisi
				,star_contract
				,end_contract
				,harga_perunit
				,jumlah_harga
				,sub_total
				,ppn
				,pph
				,total
				,sum_agreement
				,sum_jeni_or_type
				,sum_unit
				,kwitansi_no
				,dpp_nilai_lain
				
			)
			select	user_id
					,receipt_no
					,agreement_no
					,agreement_date
					,jenis_alat
					,type
					,unit
					,star_periode
					,end_periode
					,no_polisi
					,star_contract
					,end_contract
					,harga_perunit
					,jumlah_harga
					,sub_total
					,ppn
					,pph
					,total
					,sum_agreement
					,sum_jeni_or_type
					,sum_unit
					,kwitansi_no
					,dpp_nilai_lain
			from	@temp_tabel_detail ;

			--update	dbo.rpt_invoice_kwitansi
			--set		star_periode =dbo.xfn_bulan_indonesia((
			--			select	min(star_periode)
			--			from	dbo.rpt_invoice_kwitansi_detail
			--			where	user_id = @p_user_id
			--		))

			--		,end_periode =dbo.xfn_bulan_indonesia((
			--			 select max(end_periode)
			--			 from	dbo.rpt_invoice_kwitansi_detail
			--			 where	user_id = @p_user_id
			--		 ))
			--where	user_id = @p_user_id ;

			--if @invoice_type='PENALTY'
			--begin
			--	update	dbo.rpt_invoice_penagihan
			--	set		star_periode = @bast_date
			--			,end_periode = case
			--								when @bast_date is null then null
			--								else @max_due_date
			--							end
			--	where	no_invoice = @invoice_external_no and user_id = @p_user_id ;
			--end
			--else 
			begin
				update	dbo.rpt_invoice_kwitansi
				set		star_periode = dbo.xfn_bulan_indonesia((
																   select	min(star_periode)
																   from		dbo.rpt_invoice_kwitansi_detail
																   where	user_id = @p_user_id and receipt_no = @invoice_external_no
															   )
															  )
						,end_periode = dbo.xfn_bulan_indonesia((
																   select	max(end_periode)
																   from		dbo.rpt_invoice_kwitansi_detail
																   where	user_id = @p_user_id and receipt_no = @invoice_external_no
															   )
															  )
				where	no_invoice	= @invoice_external_no
						and user_id = @p_user_id ;
			end ;

			-- (+) Ari 2023-10-16 ket : mod description
			begin
				insert into @table_temp
				(
					asset_name
				)
				select	distinct
						type
				from	rpt_invoice_kwitansi_detail
				where	user_id = @p_user_id and receipt_no = @invoice_external_no

				if exists
				(
					select	1
					from	@table_temp
					having	count(asset_name) = 1
				)
				begin
					select		@asset_name = aa.asset_name
								,@agreement_no = am.agreement_external_no
								,@agreement_date = am.agreement_date
					from		dbo.invoice inv with (nolock)
								inner join dbo.invoice_detail ind with (nolock) on (ind.invoice_no = inv.invoice_no)
								inner join dbo.agreement_asset aa with (nolock) on (aa.asset_no = ind.asset_no)
								inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ind.agreement_no)
								left join dbo.agreement_information aif with (nolock) on (aif.agreement_no = ind.agreement_no)
								outer apply
					(
						select	asset_no
								,billing_no
								,period_date
								,period_due_date
						from	dbo.xfn_due_date_period(ind.asset_no, cast(ind.billing_no as int)) aa
						where	ind.billing_no	 = aa.billing_no
								and ind.asset_no = aa.asset_no
					) period
					where		inv.invoice_no = @p_no_invoice
					group by	aa.asset_name
								,am.agreement_external_no
								,am.agreement_date ;
								
					if ((
							select		count(1)
							from		@temptable
						) > 1
					   )
					begin
						set @agreement_no = N'terlampir' ;
					end ;

					select	@qty = count(quantity)
					from	dbo.invoice_detail
					where	invoice_no = @p_no_invoice ;

					--(+) raffyanda 25/10/2023 penambahan deskripsi yang berbeda antara invoice dengan type rental dan mobilisasi
					select	@no_polisi = no_polisi
					from	dbo.rpt_invoice_kwitansi_detail
					where	user_id = @p_user_id and receipt_no = @invoice_external_no

					select	@remarks = description
					from	dbo.invoice_detail
					where	invoice_no = @p_no_invoice ;

					select	@type = invoice_type
					from	dbo.invoice
					where	invoice_no = @p_no_invoice ;

					if (@type = 'RENTAL')
					begin
						set @description = N'Sewa Kendaraan ' + convert(nvarchar(10), @qty) + N' kendaraan ' + @asset_name + N' untuk operasional ' + @client_name + N' sesuai dengan perjanjian Operating Lease No. ' + @agreement_no + N' tanggal ' + dbo.xfn_bulan_indonesia(convert(nvarchar(50), @agreement_date, 106)) ;
					end ;
					else
					begin
						set @description = @remarks ; --N'Biaya Pengiriman Kendaraan ' + @asset_name + N' No. Polisi ' + @no_polisi + N' dari ' + @kota;
					end ;

					update	dbo.rpt_invoice_kwitansi
					set		untuk_pembayaran = @description
					where	user_id = @p_user_id   and no_invoice = @invoice_external_no
				end ;
				else
				begin
					select		@agreement_no = am.agreement_external_no
								,@agreement_date = am.agreement_date
					from		dbo.invoice inv with (nolock)
								inner join dbo.invoice_detail ind with (nolock) on (ind.invoice_no = inv.invoice_no)
								inner join dbo.agreement_asset aa with (nolock) on (aa.asset_no = ind.asset_no)
								inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ind.agreement_no)
								left join dbo.agreement_information aif with (nolock) on (aif.agreement_no = ind.agreement_no)
								outer apply
					(
						select	asset_no
								,billing_no
								,period_date
								,period_due_date
						from	dbo.xfn_due_date_period(ind.asset_no, cast(ind.billing_no as int)) aa
						where	ind.billing_no	 = aa.billing_no
								and ind.asset_no = aa.asset_no
					) period
					where		inv.invoice_no = @p_no_invoice
					group by	am.agreement_external_no
								,am.agreement_date ;
								
					if ((
							select		count(1)
							from		@temptable
						) > 1
					   )
					begin
						set @agreement_no = N'' ;
					end ;

					select	@qty = count(quantity)
					from	dbo.invoice_detail
					where	invoice_no = @p_no_invoice ;

					set @description = N'Sewa Kendaraan ' + convert(nvarchar(10), @qty) + N' kendaraan terlampir untuk operasional ' + @client_name + N' sesuai dengan perjanjian Operating Lease No. ' + @agreement_no; --+ N' terlampir tanggal terlampir ' ;--+ convert(nvarchar(50), @agreement_date, 106) ;

					update	dbo.rpt_invoice_kwitansi
					set		untuk_pembayaran = @description
					where	user_id = @p_user_id   and no_invoice = @invoice_external_no
				end ;

				delete @table_temp ;

			-- (+) Ari 2023-10-16
			end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
