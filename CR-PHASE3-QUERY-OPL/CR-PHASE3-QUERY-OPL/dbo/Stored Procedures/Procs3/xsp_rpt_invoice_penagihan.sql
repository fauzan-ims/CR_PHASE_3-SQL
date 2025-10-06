CREATE PROCEDURE dbo.xsp_rpt_invoice_penagihan
(
	@p_user_id		   NVARCHAR(50)
	,@p_no_invoice	   NVARCHAR(50)
	,@p_group_print	   NVARCHAR(1) = ''
	--,@p_from_date			datetime
	--,@p_to_date				datetime
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN

	IF @p_group_print <> '1'
	BEGIN
		DELETE dbo.rpt_invoice_penagihan
		WHERE	user_id = @p_user_id ;

		DELETE dbo.rpt_invoice_penagihan_detail_asset
		WHERE	user_id = @p_user_id ;
        
		delete dbo.rpt_invoice_pembatalan_kontrak_detail
		where	user_id = @p_user_id ;

		DELETE dbo.rpt_invoice_penagihan_detail
		WHERE	user_id = @p_user_id ;
	END;
	
	exec dbo.xsp_mtn_rpt_invoice_insert @p_user_id = @p_user_id -- nvarchar(50)
											,@p_invoice_no = @p_no_invoice -- nvarchar(50)

	--if (@p_no_invoice not in ('01556.INV.2004.11.2023', '01499.INV.2004.11.2023','01500.INV.2004.11.2023'))
	BEGIN
	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			--,@tanggal				datetime
			--,@star_periode			datetime
			--,@end_periode			datetime
			--,@jatuh_tempo			datetime
			--,@no_perjanjian			nvarchar(50)
			,@client_name			nvarchar(50)
			--,@alamat_client			nvarchar(4000)
			--,@npwp_no				nvarchar(50)
			,@jenis					nvarchar(50)
			--,@type					nvarchar(50)
			--,@uraian				nvarchar(50)
			--,@unit					int
			--,@jumlah				int
			,@harga_perunit			decimal(18, 2)
			--,@jumlah_harga			decimal(18, 2)
			,@sub_total				decimal(18, 2)
			,@ppn					decimal(18, 2)
			,@ppn_pct				decimal(9, 6)
			,@total					decimal(18, 2)
			--,@sejumlah				nvarchar(250)
			--,@nama_bank				nvarchar(50)
			--,@rek_atas_nama			nvarchar(50)
			--,@no_rek				nvarchar(50)
			--,@employee_name			nvarchar(50)
			--,@employee_position		nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@periode_star			datetime
			,@periode_end			datetime
			,@contract_star			datetime
			,@contract_end			datetime
			--,@sum_agreement			decimal(18, 2)
			--,@sum_jenis_or_type		decimal(18, 2)
			--,@sum_unit				decimal(18, 2)
			,@npwp_company			nvarchar(50)
			,@invoice_date			datetime
			,@invoice_due_date		datetime
			,@address				nvarchar(4000)
			,@client_npwp			nvarchar(50)
			--,@item_name				nvarchar(50)
			,@quantity				int
			--,@total_amount			decimal(18, 2)
			,@total_ppn_amount		decimal(18, 2)
			,@bank_name				nvarchar(50)
			--,@total_amount2			decimal(18, 2)
			,@bank_account_name		nvarchar(50)
			,@bank_account_no		nvarchar(50)
			,@billing_amount		decimal(18, 2)
			,@invoice_type			nvarchar(20)
			--,@periode_denda_from	datetime
			,@periode_denda_to		datetime
			,@total_jumlah_harga	decimal(18, 2)
			--,@jumlah_agreement		int
			--,@jumlah_item			int
			--,@jumlah_quantity		int
			--,@jumlah_harga1			decimal(18, 2)
			--,@total_jumlah_harga1	decimal(18, 2)
			,@plat_no				nvarchar(50)
			,@agreement_external_no nvarchar(50)
			,@branch_code			nvarchar(50)
			--,@agreement_date		datetime
			,@invoice_external_no	nvarchar(50)
			,@inv_name				nvarchar(4000) 
			,@periode_sewa_asset	nvarchar(4000)
			,@count_agreement_no	int
            --,@multiplier			int
			,@min_invoice_date		datetime
			,@max_invoice_date		datetime 
			,@remarks				nvarchar(4000)
			,@nama					nvarchar(250)
			--,@handover_bast_date	datetime
			,@bast_date				datetime
			,@max_due_date			datetime
			,@jumlah_seluruhnya		decimal(18,2)
			,@agreement_type		nvarchar(10)
			,@agreement_date		DATETIME
            ,@no_perjanjian			NVARCHAR(50)
			,@count					int
			,@lease_rounded_amount	decimal(18, 2)
			,@jumlah_asset			int
			,@dpp_nilai_lain		decimal(18, 2)

	begin try
	
		exec dbo.xsp_rpt_invoice_kwitansi @p_user_id			= @p_user_id
										  ,@p_no_invoice		= @p_no_invoice
										  ,@p_cre_date			= @p_cre_date	   
										  ,@p_cre_by			= @p_cre_by		   
										  ,@p_cre_ip_address	= @p_cre_ip_address 
										  ,@p_mod_date			= @p_mod_date	   
										  ,@p_mod_by			= @p_mod_by		   
										  ,@p_mod_ip_address	= @p_mod_ip_address 
										  ,@p_group_print		= @p_group_print ;

		DECLARE @rpt_invoice_penagihan_detail_asset	AS TABLE(
			user_id			NVARCHAR(50)
			,jenis			NVARCHAR(250)
			,invoice_no		NVARCHAR(50)
			,invoice_ext_no	NVARCHAR(50)
			,code			NVARCHAR(50)
			,type			NVARCHAR(250)
			,uraian			NVARCHAR(4000)
			,jumlah			INT
			,harga_perunit	DECIMAL(18, 2)
			,jumlah_harga	DECIMAL(18, 2)
			,sub_total		DECIMAL(18, 2)
			,ppn			DECIMAL(18, 2)
			,ppn_rate		DECIMAL(9, 6)
			,total			DECIMAL(18, 2)
			,dpp_nilai_lain	DECIMAL(18, 2)
		);

		declare @temp_table_invoice	as table(
			user_id nvarchar(50)  ,
			jenis nvarchar(250) ,
			type nvarchar(250) ,
			uraian nvarchar(4000) ,
			no_polisi nvarchar(50) ,
			jumlah int ,
			jumlah_denda decimal(18, 2) ,
			jumlah_desc nvarchar(250) ,
			no_invoice nvarchar(50) 
		);

		--create table #rpt_invoice_pembatalan_kontrak_detail
		--(
		--	user_id		  nvarchar(50)
		--	,jenis		  nvarchar(50)
		--	,type		  nvarchar(50)
		--	,uraian		  nvarchar(250)
		--	,no_polisi	  nvarchar(50)
		--	,jumlah		  int
		--	,jumlah_denda decimal(18, 2)
		--	,jumlah_desc  nvarchar(250)
		--) ;

		select	@report_company = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'IMGDSF' ;

		select	@npwp_company = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'INVNPWP' ;

		--select	
		--from	dbo.invoice inv
		--where	inv.invoice_no = @p_no_invoice ;

		--select	@employee_name = sem.name
		--from	ifinsys.dbo.sys_employee_main sem
		--where	sem.code = @p_user_id ;

		--select		@jumlah_agreement = count(1)
		--from		dbo.invoice_detail
		--where		invoice_no = @p_no_invoice
		--group by	agreement_no ;

		--select		@jumlah_item = count(1)
		--from		dbo.invoice_detail indao
		--			--inner join ifinams.dbo.asset assao on (assao.asset_no = indao.asset_no)
		--			inner join dbo.agreement_asset asat on asat.asset_no = indao.asset_no
		--where		indao.invoice_no = @p_no_invoice
		--group by	asat.asset_no;--assao.item_code ;

		--select		@jumlah_quantity = count(1)
		--from		dbo.invoice_detail indao
		--			inner join dbo.agreement_asset asat on asat.ASSET_NO = indao.ASSET_NO
		--			--inner join ifinams.dbo.asset assao on (assao.asset_no = indao.asset_no)
		--where		indao.invoice_no = @p_no_invoice
		--group by	indao.quantity ;

		select		@count = COUNT(DISTINCT ind.agreement_no)
		from		dbo.invoice_detail ind with (nolock) 
		where		ind.invoice_no = @p_no_invoice ;

		select		@agreement_no = ind.agreement_no
		from		dbo.invoice_detail ind with (nolock) 
		where		ind.invoice_no = @p_no_invoice ;

		select		@count_agreement_no = count(distinct ind.agreement_no)
		from		dbo.invoice_detail ind with (nolock)
		where		ind.invoice_no = @p_no_invoice 
		group by	ind.agreement_no;

		select	@agreement_external_no = am.agreement_external_no
				--,@multiplier = mbt.multiplier
		from	dbo.agreement_main am with (nolock)
				inner join dbo.master_billing_type mbt with (nolock) on (mbt.code = am.billing_type)
		where	am.agreement_no = @agreement_no ;

		--select	@star_periode = aaa.billing_date
		--		,@end_periode = dateadd(month, @multiplier, aaa.billing_date)
		--from	dbo.invoice_detail ivd
		--		inner join dbo.invoice inv on inv.invoice_no = ivd.invoice_no
		--		inner join dbo.agreement_asset_amortization aaa on (
		--																aaa.asset_no	 = ivd.asset_no
		--																and aaa.agreement_no = ivd.agreement_no
		--																and aaa.billing_no	 = ivd.billing_no
		--															)
		--where	ivd.invoice_no = @p_no_invoice ;

		select	@max_due_date = max(period.period_due_date)
		from	dbo.agreement_asset asat with (nolock)
				inner join dbo.agreement_asset_amortization aaa with (nolock) on aaa.asset_no = asat.asset_no
																				 and aaa.agreement_no = asat.agreement_no
				outer apply
				(
					select	period_due_date
					from	dbo.xfn_due_date_period(asat.asset_no, aaa.billing_no)
				) period
		where	aaa.agreement_no = @agreement_no ;

		select	@bast_date = asat.handover_bast_date
		from	dbo.agreement_asset asat with (nolock)
		where	asat.agreement_no = @agreement_no ;

		select	@periode_denda_to = et_date
		from	dbo.et_main with (nolock)
				inner join dbo.et_detail with (nolock) on (et_detail.et_code			 = et_main.code)
				inner join dbo.invoice_detail with (nolock) on (invoice_detail.asset_no = et_detail.asset_no)
		where	et_status					= 'APPROVE'
				and invoice_detail.asset_no = et_detail.asset_no
				and invoice_no				= @p_no_invoice ;

		--select	@min_invoice_date	= min (bgnd.due_date)
		--		,@max_invoice_date	= max(bgnd.due_date) 
		--from	dbo.billing_generate_detail bgnd 
		--where	bgnd.invoice_no = @p_no_invoice

		select	@ppn_pct = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'RTAXPPN' ;

		select	@bank_name = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'BANK' ;

		select	@bank_account_no = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'BANKNO' ;

		select	@bank_account_name = value
		from	dbo.sys_global_param with (nolock)
		where	code = 'BANKNAME' ;

		select	@invoice_date			= isnull(inv.new_invoice_date,inv.invoice_date)
				,@invoice_due_date		= inv.invoice_due_date
				,@client_name			= inv.client_name
				--,@address				= inv.client_address
				--,@client_npwp			= inv.client_npwp
				,@invoice_type			= inv.invoice_type
				,@invoice_external_no	= inv.invoice_external_no
				,@inv_name				= sc.description
				--,@sub_total				= inv.total_billing_amount --- inv.total_discount_amount - inv.credit_billing_amount
				,@sub_total				= case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0 else inv.total_billing_amount - inv.CREDIT_BILLING_AMOUNT - inv.total_discount_amount end
				,@total_jumlah_harga	= case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0 else (inv.total_billing_amount  - inv.credit_billing_amount - inv.total_discount_amount ) + (case when inv.credit_billing_amount > 0 then inv.credit_ppn_amount else inv.total_ppn_amount end) end
				,@total_ppn_amount		= case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0 when inv.credit_billing_amount > 0 then inv.credit_ppn_amount else inv.total_ppn_amount end
				,@branch_code			= inv.branch_code
				,@dpp_nilai_lain		= inv.dpp_nilai_lain
		from	dbo.invoice inv with (nolock)
		inner join dbo.sys_general_subcode sc with (nolock) on inv.invoice_type = sc.code
		--inner join dbo.invoice_detail ind with (nolock) on ind.invoice_no = inv.invoice_no
		--inner join dbo.agreement_main am with (nolock) on am.agreement_no = ind.agreement_no
		where inv.invoice_no = @p_no_invoice

		select	@nama = signer_name 
		from	ifinsys.dbo.sys_branch_signer with (nolock)
		where	signer_type_code = 'HEADOPR'
				and branch_code = @branch_code ;

		select	top 1
				@client_npwp = asat.billing_to_npwp
				,@address = asat.npwp_address
				,@client_name = asat.npwp_name
				--,@handover_bast_date = asat.handover_bast_date
		from	dbo.invoice_detail invd with (nolock)
				inner join agreement_asset asat with (nolock) on asat.asset_no		 = invd.asset_no
																 and asat.agreement_no = invd.agreement_no
		where	invd.invoice_no = @p_no_invoice ;

		begin
			
			if (@invoice_type = 'RENTAL')
				begin
					set @report_title = 'INVOICE PENAGIHAN SEWA KENDARAAN' ;
				end            
			else
				begin
					set @report_title = 'INVOICE ' + @inv_name;
				end
				
			insert into dbo.rpt_invoice_penagihan
			(
				user_id
				,no_invoice
				,invoice_no
				,report_company
				,report_title
				,report_image
				,tanggal
				,npwp_company
				,star_periode
				,end_periode
				,jatuh_tempo
				,no_perjanjian
				,client_name
				,alamat_client
				,npwp_no
				,jenis
				,type
				,uraian
				,jumlah
				,harga_perunit
				,jumlah_harga
				,sub_total
				,ppn
				,total
				,sejumlah
				,nama_bank
				,rek_atas_nama
				,no_rek
				,employee_name
				,employee_position
				,invoice_type
				,periode_denda_from
				,periode_denda_to
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,dpp_nilai_lain
			)
			VALUES
			(	@p_user_id
				,@invoice_external_no
				,@invoice_external_no
				,@report_company
				,@report_title
				,@report_image
				,dbo.xfn_bulan_indonesia(@invoice_date)
				,@npwp_company
				,@invoice_date--,@star_periode--@min_invoice_date
				,@invoice_due_date--,@end_periode--@max_invoice_date
				,dbo.xfn_bulan_indonesia(@invoice_due_date)
				--,case when @count_agreement_no > 1 then 'LIHAT LAMPIRAN'
				--else @agreement_external_no
				--end
				,case when @count > 1 then 'TERLAMPIR'
				else  @agreement_external_no 
				end
				--,@agreement_external_no
				,@client_name
				,@address
				,@client_npwp
				,null--@item_name
				,null--@item_name
				,'SEWA KENDARAAN UNTUK OPERASIONAL'
				,@quantity
				,@sub_total
				,0
				,@sub_total
				,@total_ppn_amount
				,@total_jumlah_harga
				,dbo.terbilang(@total_jumlah_harga)
				,@bank_name
				,@bank_account_name
				,@bank_account_no
				,@nama
				,'Operating Lease Head'
				,@invoice_type
				,dbo.xfn_bulan_indonesia(@periode_denda_to)
				,dbo.xfn_bulan_indonesia(@max_due_date)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@dpp_nilai_lain
			) ;

				--SELECT @no_perjanjian = COUNT(DISTINCT no_perjanjian)
				--FROM dbo.RPT_INVOICE_PENAGIHAN
				--WHERE USER_ID = @p_user_id


				--if (@no_perjanjian = 1) 
				--	begin
				--		update dbo.rpt_invoice_penagihan
				--		set no_perjanjian = @agreement_external_no
				--		where user_id = @p_user_id
				--	end
				--ELSE
				--	begin 
				--		update dbo.rpt_invoice_penagihan
				--		set no_perjanjian = 'Terlampir'
				--		where user_id = @p_user_id 
				--	end
				
			if (@invoice_type = 'PENALTY')
			begin
				insert into @temp_table_invoice
				(
					user_id
					,no_invoice
					,jenis
					,type
					,uraian
					,no_polisi
					,jumlah
					,jumlah_denda
					,jumlah_desc
				)
				select	@p_user_id
						,@invoice_external_no
						,''
						,ags.ASSET_NAME
						,'SEWA KENDARAAN UNTUK OPERASIONAL'
						,isnull(ags.REPLACEMENT_FA_REFF_NO_01,ags.fa_reff_no_01)--isnull(avi.plat_no,ags.fa_reff_no_01)
						,ind.quantity
						,isnull(ind.total_amount,0)
						,''
				from	dbo.invoice inv with (nolock)
						inner join dbo.invoice_detail ind with (nolock) on (ind.invoice_no = inv.invoice_no)
						inner join dbo.agreement_asset ags with (nolock) on (ags.asset_no	= ind.asset_no)
						--inner join ifinams.dbo.asset_vehicle avi on (avi.asset_code = isnull(ags.replacement_fa_code,ags.fa_code))
				where	inv.invoice_no = @p_no_invoice ;

			end ;
			ELSE
			begin 
				if (
					(select	count(1)
					from
							(
								select		ind.billing_amount
											,aav.vehicle_unit_code
								from		dbo.invoice_detail ind
											--left join dbo.agreement_asset ags with (nolock) on (ags.asset_no  = ind.asset_no and ags.AGREEMENT_NO = ind.AGREEMENT_NO)
											left join dbo.agreement_asset_vehicle aav with (nolock) on (aav.asset_no = ind.asset_no)
								where		ind.invoice_no = @p_no_invoice
								group by	ind.billing_amount
											,aav.vehicle_unit_code
							) invd) > 1
					)
				begin
					select	@jumlah_asset = sum(quantity)
					from	invoice_detail
					where	invoice_no = @p_no_invoice ;

					insert into @rpt_invoice_penagihan_detail_asset
					(
						user_id
						,invoice_no
						,invoice_ext_no
						,jenis
						,code
						,type
						,uraian
						,jumlah
						,harga_perunit
						,jumlah_harga
						,sub_total
						,ppn
						,ppn_rate
						,total
						,dpp_nilai_lain
					)
					values
					(
						@p_user_id
						,@p_no_invoice
						,@invoice_external_no
						,''
						,'LIHAT LAMPIRAN'
						,'LIHAT LAMPIRAN'
						,'SEWA KENDARAAN UNTUK OPERASIONAL'
						,@jumlah_asset
						,0
						,@sub_total
						,@sub_total
						,@total_ppn_amount
						,@ppn_pct
						,@total_jumlah_harga
						,@dpp_nilai_lain
					)
				end ;
				else
				begin
                
					INSERT into @rpt_invoice_penagihan_detail_asset
					(
						user_id
						,invoice_no
						,invoice_ext_no
						,jenis
						,code
						,type
						,uraian
						,jumlah
						,harga_perunit
						,jumlah_harga
						,sub_total
						,ppn
						,ppn_rate
						,total
						,dpp_nilai_lain
					)
					SELECT	@p_user_id
							,@p_no_invoice
							,@invoice_external_no
							,''
							,ags.fa_code
							,ags.asset_name
							,CASE @invoice_type 
								WHEN 'RENTAL' THEN 'SEWA KENDARAAN UNTUK OPERASIONAL' 
								ELSE ind.description 
							 END
							,ind.quantity
							,ags.lease_rounded_amount--ind.billing_amount --- ags.discount_amount - inv.credit_billing_amount
							--,ind.quantity * ind.billing_amount --- ags.discount_amount - inv.credit_billing_amount)
							,((ind.quantity * ind.billing_amount - isnull(credit.adjustment_amount, 0))   - ind.discount_amount)-- inv.total_discount_amount)
							,@sub_total
							--,ind.ppn_amount --@total_ppn_amount
							,case when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
								 when isnull(inv.credit_ppn_amount, 0) = 0 then ind.ppn_amount
								 else credit.new_ppn_amount
							 end --ppn
							,@ppn_pct
							,@sub_total + @total_ppn_amount--(ind.quantity * ind.billing_amount) + @total_ppn_amount --@total_jumlah_harga
							,@dpp_nilai_lain
					FROM	dbo.invoice inv WITH (NOLOCK)
							INNER JOIN dbo.invoice_detail ind WITH (NOLOCK) ON (ind.invoice_no = inv.invoice_no)
							INNER JOIN dbo.agreement_asset ags WITH (NOLOCK) ON (ags.asset_no	 = ind.asset_no)
							outer apply
							(
								select	cnd.adjustment_amount, cnd.new_ppn_amount
								from	dbo.credit_note_detail cnd
								inner join dbo.credit_note cn on (cn.code = cnd.credit_note_code)
								where	ind.id = cnd.invoice_detail_id
									and cn.status <> 'CANCEL'
							) credit
					WHEre	inv.invoice_no = @p_no_invoice ;

				end ;
			end ;
			--select @sub_total + @total_ppn_amount
			--SELECT * FROM @rpt_invoice_penagihan_detail_asset 

		--	select		max(user_id)
		--			,@invoice_external_no
		--			,max(jenis)
		--			,max(code)
		--			,max(type)
		--			,max(uraian)
		--			,sum(jumlah)
		--			,harga_perunit
		--			,sum(jumlah_harga)
		--			,sum(jumlah) * harga_perunit --MAX(harga_perunit)
		--			,SUM(ppn)
		--			,max(ppn_rate)
		--			,sum(jumlah_harga) + SUM(ppn) --MAX(harga_perunit) + max(ppn)
		--from		@rpt_invoice_penagihan_detail_asset
		--where		user_id		   = @p_user_id
		--			and invoice_no = @p_no_invoice
		--group by	invoice_no
		--			,harga_perunit
		--			--,ppn
					--,jumlah_harga;
			insert into dbo.RPT_INVOICE_PEMBATALAN_KONTRAK_DETAIL
			(
				user_id
				,no_invoice
				,jenis
				,type
				,uraian
				,no_polisi
				,jumlah
				,jumlah_denda
				,jumlah_desc
			)
			select	user_id
					,no_invoice
					,jenis
					,type
					,uraian
					,no_polisi
					,jumlah
					,jumlah_denda
					,jumlah_desc
			from	@temp_table_invoice ;


			declare curr_penagihan_detail cursor fast_forward read_only for
			select	am.agreement_external_no
					,am.agreement_date
					,aa.asset_name
					,aa.handover_bast_date + 1
					,ai.maturity_date
					,case when @p_no_invoice = '03906.INV.2034.02.2024' then '01/01/2024'+ ' - ' +'31/01/2024' else
					convert(nvarchar(20),period.period_date,103)+ ' - ' +convert(nvarchar(20),period.period_due_date,103) end
					,aa.lease_rounded_amount
					,(ivd.billing_amount  - isnull(credit.adjustment_amount, 0) - ivd.discount_amount)
					,(inv.total_billing_amount - isnull(inv.credit_billing_amount, 0) - inv.total_discount_amount) --((inv.total_billing_amount - inv.total_discount_amount) + inv.total_ppn_amount)
					,case
							when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
							when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
							else inv.credit_ppn_amount
						end
					,( case
							when inv.total_billing_amount - inv.credit_billing_amount = 0 then 0
							when isnull(inv.credit_ppn_amount, 0) = 0 then inv.total_ppn_amount
							else inv.credit_ppn_amount
						end) + (inv.total_billing_amount - isnull(inv.credit_billing_amount, 0) - inv.total_discount_amount) -- inv.credit_billing_amount)--(ivd.billing_amount - ivd.discount_amount) + ((inv.total_billing_amount - inv.total_discount_amount) + inv.total_ppn_amount)
					--,inv.total_billing_amount - inv.total_discount_amount - inv.credit_billing_amount + inv.total_ppn_amount
					--,avi.PLAT_NO
					,isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
					,inv.invoice_name
					,period.period_date
					,period.period_due_date
					,inv.dpp_nilai_lain
			from	dbo.invoice_detail ivd with (nolock)
					inner join dbo.invoice inv with (nolock) on (inv.invoice_no								= ivd.invoice_no)
					inner join dbo.agreement_asset aa with (nolock) on (aa.asset_no							= ivd.asset_no)
					--inner join ifinams.dbo.asset_vehicle avi on (avi.ASSET_CODE = isnull(aa.REPLACEMENT_FA_CODE,aa.FA_CODE))
					--inner join dbo.agreement_asset_amortization aaa on (
					--													   aaa.invoice_no		= ivd.invoice_no
					--													   and aaa.asset_no		= ivd.asset_no
					--													   and aaa.agreement_no = ivd.agreement_no
					--													   and aaa.billing_no	= ivd.billing_no
					--												   )
					inner join dbo.agreement_main am with (nolock) on (am.agreement_no						= ivd.agreement_no)
					--inner join dbo.agreement_information ai on (ai.agreement_no					= ivd.agreement_no)
					outer apply
					(
						select	ai.maturity_date
						from	dbo.agreement_information ai with (nolock)
						where	ai.agreement_no = ivd.agreement_no
					)ai
					outer apply
					(
						select	cnd.adjustment_amount
						from	dbo.credit_note_detail cnd
						INNER JOIN dbo.credit_note cn ON (cn.code = cnd.credit_note_code)
						where	ivd.id = cnd.invoice_detail_id
						AND		cn.status <> 'CANCEL'
					) credit
					outer apply
					(
						select	asset_no
								,billing_no
								--,period_date
								-- (+) Ari 2023-10-16 ket : arrear period_date + 1, adv period_due_date - 1
								,case am.first_payment_type
									when 'ARR'
									then period_date + 1
									else period_date
								end 'period_date'
								,period_due_date
								--,case am.first_payment_type
								--	when 'ADV'
								--	then period_due_date - 1
								--	else period_due_date
								--end 'period_due_date'
								-- (+) Ari 2023-10-16
						from	dbo.xfn_due_date_period(ivd.asset_no,cast(ivd.billing_no as int)) aa
						where	ivd.billing_no = aa.billing_no
						and		ivd.asset_no = aa.asset_no
					)period
			where	inv.invoice_no = @p_no_invoice
			order	by aa.asset_no asc

			open curr_penagihan_detail ;

			fetch next from curr_penagihan_detail
			into @agreement_no
				 ,@agreement_date
				 ,@jenis
				 ,@contract_star
				 ,@contract_end
				 ,@periode_sewa_asset
				 ,@lease_rounded_amount
				 ,@harga_perunit
				 ,@sub_total
				 ,@ppn
				 ,@total
				 ,@plat_no
				 ,@remarks
				 ,@periode_star
				 ,@periode_end
				 ,@dpp_nilai_lain;

			while @@fetch_status = 0
			BEGIN
				
				INSERT into dbo.rpt_invoice_penagihan_detail
				(
					user_id
					,no_invoice
					,agreement_no
					,agreement_date
					,jenis
					,type
					,unit
					,police_no 
					,contract_star
					,contract_end
					,harga_perunit
					,jumlah_harga
					,sub_total
					,ppn_pct
					,ppn
					,total
					,periode_sewa
					,remarks
					,periode_star
					,periode_end
					--
					,sum_agreement
					,sum_jenis_or_type
					,sum_unit
					,dpp_nilai_lain
				)
				values
				(	@p_user_id
					,@invoice_external_no
					,@agreement_no
					,@agreement_date
					,@jenis
					,''
					,1
					,upper(@plat_no)
					,@contract_star
					,@contract_end
					,@lease_rounded_amount
					,@harga_perunit
					,@sub_total
					,@ppn_pct
					,@ppn
					,@total
					,@periode_sewa_asset
					,@remarks
					,@periode_star
					,@periode_end
					--
					,null
					,null
					,null
					,@dpp_nilai_lain
				) ;
				
				FETCH NEXT FROM curr_penagihan_detail
				INTO @agreement_no
					 ,@agreement_date
					 ,@jenis
					 ,@contract_star
					 ,@contract_end
					 ,@periode_sewa_asset
					 ,@lease_rounded_amount
					 ,@harga_perunit
					 ,@sub_total
					 ,@ppn
					 ,@total
					 ,@plat_no 
					 ,@remarks
					 ,@periode_star
					 ,@periode_end
					 ,@dpp_nilai_lain;
			END ;

			close curr_penagihan_detail ;
			DEALLOCATE curr_penagihan_detail ;
		END ;
		
		insert into rpt_invoice_penagihan_detail_asset
		(
			user_id
			,invoice_no
			,jenis
			,code
			,type
			,uraian
			,jumlah
			,harga_perunit
			,jumlah_harga
			,sub_total
			,ppn
			,ppn_rate
			,total
			,dpp_nilai_lain
		)
		select		max(user_id)
					,@invoice_external_no
					,max(jenis)
					,max(code)
					,max(type)
					,max(uraian)
					,sum(jumlah)
					,harga_perunit
					,sum(jumlah_harga)
					,sum(jumlah) * harga_perunit --MAX(harga_perunit)
					,SUM(ppn)
					,max(ppn_rate)
					,sum(jumlah_harga) + SUM(ppn) --MAX(harga_perunit) + max(ppn)
					,@dpp_nilai_lain
		from		@rpt_invoice_penagihan_detail_asset
		where		user_id		   = @p_user_id
					and invoice_no = @p_no_invoice
		group by	invoice_no
					,harga_perunit
					--,ppn
					--,jumlah_harga;



		update	dbo.rpt_invoice_penagihan_detail_asset
		set		sub_total =
				(
					select		sum(jumlah_harga)
					from		dbo.rpt_invoice_penagihan_detail_asset
					where		user_id = @p_user_id and invoice_no = @invoice_external_no
				)
				--,ppn = 
				--(
				--	select		top 1 ppn
				--	from		dbo.rpt_invoice_penagihan_detail_asset
				--	where		user_id = @p_user_id
				--)
		where	user_id = @p_user_id ;

		--update	dbo.rpt_invoice_penagihan_detail_asset
		--set		total = (
		--			select		top 1 sub_total+ppn
		--			from		dbo.rpt_invoice_penagihan_detail_asset
		--			where		user_id = @p_user_id
		--		)
		--where	user_id = @p_user_id ;
	
		select	@jumlah_seluruhnya = total
		from	rpt_invoice_penagihan_detail_asset with (nolock)
		where	user_id		   = @p_user_id
				and invoice_no = @invoice_external_no ;

		if exists
		(
			select	1
			from	rpt_invoice_penagihan_detail_asset
			where	user_id		   = @p_user_id
					and invoice_no = @invoice_external_no
		)
		begin
			update	rpt_invoice_penagihan
			set		sejumlah = dbo.terbilang(@jumlah_seluruhnya)
			where	user_id		   = @p_user_id
					and invoice_no = @invoice_external_no ;
		end ;
		
		IF NOT EXISTS (SELECT 1 FROM dbo.rpt_invoice_penagihan_detail)
		BEGIN 
			INSERT INTO dbo.rpt_invoice_penagihan_detail
		(
			user_id
			,no_invoice
			,agreement_no
			,agreement_date
			,jenis
			,type
			,unit
			,periode_star
			,periode_end
			,police_no
			,contract_star
			,contract_end
			,harga_perunit
			,jumlah_harga
			,sub_total
			,ppn_pct
			,ppn
			,total
			,sum_agreement
			,sum_jenis_or_type
			,sum_unit
			,periode_sewa
			,remarks
			,dpp_nilai_lain
		)
		VALUES
		(
			@p_user_id -- USER_ID - nvarchar(50)
			,@p_no_invoice -- NO_INVOICE - nvarchar(50)
			,@agreement_external_no -- AGREEMENT_NO - nvarchar(50)
			,NULL -- AGREEMENT_DATE - datetime
			,NULL -- JENIS - nvarchar(50)
			,NULL -- TYPE - nvarchar(50)
			,NULL -- UNIT - int
			,NULL -- PERIODE_STAR - datetime
			,NULL -- PERIODE_END - datetime
			,NULL -- POLICE_NO - nvarchar(50)
			,NULL -- CONTRACT_STAR - datetime
			,NULL -- CONTRACT_END - datetime
			,NULL -- HARGA_PERUNIT - decimal(18, 2)
			,NULL -- JUMLAH_HARGA - decimal(18, 2)
			,NULL -- SUB_TOTAL - decimal(18, 2)
			,NULL -- PPN_PCT - decimal(9, 6)
			,NULL -- PPN - decimal(18, 2)
			,NULL -- TOTAL - decimal(18, 2)
			,NULL -- SUM_AGREEMENT - int
			,NULL -- SUM_JENIS_OR_TYPE - int
			,NULL -- SUM_UNIT - int
			,NULL -- PERIODE_SEWA - nvarchar(4000)
			,NULL -- REMARKS - nvarchar(4000)
			,null
		)
		END
    
		IF @invoice_type='PENALTY'
		BEGIN
			UPDATE	dbo.rpt_invoice_penagihan
			SET		star_periode = dbo.xfn_bulan_indonesia(@bast_date)
					,end_periode = CASE
										WHEN @bast_date IS NULL THEN NULL
										ELSE dbo.xfn_bulan_indonesia(@max_due_date)
									END
			WHERE	no_invoice = @invoice_external_no AND user_id = @p_user_id ;
		END
		ELSE
		BEGIN
			UPDATE	dbo.rpt_invoice_penagihan
			SET		star_periode = dbo.xfn_bulan_indonesia((
						SELECT	MIN(periode_star)
						FROM	dbo.rpt_invoice_penagihan_detail
						WHERE	user_id		   = @p_user_id
								AND no_invoice = @invoice_external_no
					))
					,end_periode = dbo.xfn_bulan_indonesia((
						 SELECT MAX(periode_end)
						 FROM	dbo.rpt_invoice_penagihan_detail
						 WHERE	user_id		   = @p_user_id
								AND no_invoice = @invoice_external_no
					 ))
			WHERE	no_invoice = @invoice_external_no AND user_id = @p_user_id ;
		end;

        
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
		
end ;
