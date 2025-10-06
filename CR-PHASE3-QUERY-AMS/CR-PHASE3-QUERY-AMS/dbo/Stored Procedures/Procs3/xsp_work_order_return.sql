CREATE PROCEDURE [dbo].[xsp_work_order_return]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@journal_code			nvarchar(50)
			,@journal_date			datetime		= dbo.xfn_get_system_date()
			,@journal_remark		nvarchar(4000)
			,@source_name			nvarchar(250)
			,@faktur_jurnal			nvarchar(50)
			,@branch_code_asset		nvarchar(50)
			,@branch_name_asset		nvarchar(250)
			,@plat_no				nvarchar(50)
			,@sp_name				nvarchar(250)
			,@debet_or_credit		nvarchar(10)
			,@gl_link_code			nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@transaction_code		nvarchar(50)
			,@orig_amount_cr		decimal(18, 2)
			,@orig_amount_db		decimal(18, 2)
			,@amount				decimal(18, 2)
			,@return_value			decimal(18, 2)
			,@id_detail				int
			,@faktur_no				nvarchar(50)
			,@total_amount			decimal(18, 2)
			,@faktur_no_invoice		nvarchar(50)
			,@ppn_pct				decimal(9, 6)
			,@pph_pct				decimal(9, 6)
			,@vendor_code			nvarchar(50)
			,@vendor_name			nvarchar(250)
			,@vendor_npwp			nvarchar(50)
			,@adress				nvarchar(4000)
			,@pph_type				nvarchar(50)
			,@income_type			nvarchar(50)
			,@income_bruto_amount	decimal(18, 2)
			,@tax_rate				decimal(9, 6)
			,@ppn_pph_amount		decimal(18, 2)
			,@faktur_date_source	nvarchar(50)
			,@remarks_tax			nvarchar(4000)
			,@faktur_date			datetime
			,@agreement_external_no nvarchar(50)
			,@exch_rate				decimal(9, 6)
			,@agreement_no			nvarchar(50)
			,@asset_code			nvarchar(50)
			,@reimburse				nvarchar(1)
			,@payment_status		nvarchar(50)
			,@invoice_status		nvarchar(50)
			,@invoice_date			datetime

	begin try
		select	@status				= wo.status
				,@branch_code_asset = ass.branch_code
				,@branch_name_asset = ass.branch_name
				,@plat_no			= avh.plat_no
				,@faktur_date		= wo.faktur_date
				,@faktur_no			= wo.faktur_no
				,@agreement_no		= ass.agreement_external_no
				,@asset_code		= ass.code
				,@reimburse			= mnt.is_reimburse
				,@invoice_date		= wo.invoice_date
		from	dbo.work_order				 wo
				inner join dbo.maintenance	 mnt on mnt.code	   = wo.maintenance_code
				inner join dbo.asset		 ass on ass.code	   = mnt.asset_code
				inner join dbo.asset_vehicle avh on avh.ASSET_CODE = ass.CODE
		where	wo.code = @p_code ;

		--select		top 1
		--			@payment_status = payment_status
		--from		dbo.payment_request
		--where		payment_source_no = @p_code
		--order by	cre_date desc ;

		select		top 1
					@invoice_status = status
		from		ifinopl.dbo.additional_invoice_request
		where		reff_code = @p_code
		order by	cre_date desc ;

		if (@status = 'POST')
		begin
			if(@reimburse = '1')
			begin
				if(@invoice_status <> 'CANCEL')
				begin
					set @msg = N'Please cancel in additional invoice first.' ;

					raiserror(@msg, 16, -1) ;
				end
			end


			if exists (select 1 from dbo.efam_interface_journal_gl_link_transaction where transaction_name = 'MAINTENANCE ASSET' and reff_source_no = @p_code)
			begin

				if exists
				(
					select	1
					from	dbo.payment_request
					where	payment_source_no  = @p_code
							and payment_status = 'HOLD'
				)
				begin
				set @agreement_external_no = isnull(@agreement_no, @asset_code)
				set @source_name = N'Reverse Work Order for ' + @plat_no + N' - ' + @p_code ;

				exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																			   ,@p_company_code				= 'DSF'
																			   ,@p_branch_code				= @branch_code_asset
																			   ,@p_branch_name				= @branch_name_asset
																			   ,@p_transaction_status		= 'HOLD'
																			   ,@p_transaction_date			= @journal_date
																			   ,@p_transaction_value_date	= @invoice_date --@journal_date
																			   ,@p_transaction_code			= @p_code
																			   ,@p_transaction_name			= 'REVERSE MAINTENANCE ASSET'
																			   ,@p_reff_module_code			= 'IFINAMS'
																			   ,@p_reff_source_no			= @p_code
																			   ,@p_reff_source_name			= @source_name
																			   ,@p_is_journal_reversal		= '0'
																			   ,@p_transaction_type			= ''
																			   ,@p_cre_date					= @p_mod_date
																			   ,@p_cre_by					= @p_mod_by
																			   ,@p_cre_ip_address			= @p_mod_ip_address
																			   ,@p_mod_date					= @p_mod_date
																			   ,@p_mod_by					= @p_mod_by
																			   ,@p_mod_ip_address			= @p_mod_ip_address ;

				declare curr_journal cursor fast_forward read_only for
				select	mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
						,mtp.transaction_code
						,wod.id
						,wod.total_amount
						,wod.ppn_pct
						,wod.pph_pct
						,isnull(mnt.vendor_code, mv.code)
						,isnull(mnt.vendor_name, mv.npwp_name)
						,isnull(mnt.vendor_address, mv.npwp_address)
						,isnull(mnt.vendor_npwp, mv.npwp)
				from	dbo.master_transaction_parameter	mtp
						inner join dbo.master_transaction	mt on mt.code				= mtp.transaction_code
																  and mt.company_code	= mtp.company_code
						inner join dbo.work_order			wo on (wo.code				= @p_code)
						inner join dbo.work_order_detail	wod on (wod.work_order_code = wo.code)
						inner join dbo.maintenance			mnt on mnt.code				= wo.maintenance_code
						left join ifinbam.dbo.master_vendor mv on mv.code				= mnt.vendor_code
				where	mtp.process_code = 'WOFA' ;

				open curr_journal ;

				fetch next from curr_journal
				into @sp_name
					 ,@debet_or_credit
					 ,@gl_link_code
					 ,@transaction_name
					 ,@transaction_code
					 ,@id_detail
					 ,@total_amount
					 ,@ppn_pct
					 ,@pph_pct
					 ,@vendor_code
					 ,@vendor_name
					 ,@adress
					 ,@vendor_npwp ;

				while @@fetch_status = 0
				begin
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @id_detail ;

					-- sp ini mereturn value angka 

					--if(isnull(@return_value,0) <> 0 )
					begin
						if (@debet_or_credit = 'DEBIT')
						begin
							--set @orig_amount_cr = 0 ;
							--set @orig_amount_db = @return_value ;
							set @orig_amount_cr = @return_value ;
							set @orig_amount_db = 0 ;
						end ;
						else
						begin
							--set @orig_amount_cr = abs(@return_value) ;
							--set @orig_amount_db = 0 ;
							set @orig_amount_cr = 0 ;
							set @orig_amount_db = abs(@return_value) ;
						end ;
					end ;

					--(+) Ari 2023-12-18 ket : req pak hary jika faktur kosong, pakai invoice
					if (@transaction_code in
					(
						'MNTPPN', 'MNTPPH', 'MNTPPHP'
					)
					   )
					begin
						if (@faktur_no = '0000000000000000') -- hari 12 jan 2024 -- jika faktur default maka ambil invoice no
						begin
							set @faktur_no = @faktur_no_invoice ;
						end ;

					--set @faktur_no = isnull(@faktur_no,@faktur_no_invoice)
					end ;

					-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
					select	@vendor_name = mv.npwp_name
							,@adress	 = mv.npwp_address
					from	ifinbam.dbo.master_vendor mv
					where	mv.code = @vendor_code ;

					if (@transaction_code = 'MNTPPN')
					begin
						if (@return_value > 0)
						begin
							set @pph_type = N'PPN MASUKAN' ;
							set @income_type = N'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + N'%' ;
							set @income_bruto_amount = @total_amount ;
							set @tax_rate = @ppn_pct ;
							set @ppn_pph_amount = @return_value ;
							set @faktur_jurnal = @faktur_no ;
						end ;
					end ;
					else if (@transaction_code = 'MNTPPH')
					begin
						if (@return_value > 0)
						begin
							set @pph_type = N'PPH PASAL 23' ;
							set @income_type = N'Jasa Perawatan Kendaraan' ;
							set @income_bruto_amount = @total_amount ;
							set @tax_rate = @pph_pct ;
							set @ppn_pph_amount = @return_value ;
							set @faktur_date = @faktur_date_source ;
							set @faktur_jurnal = @faktur_no ;
						end ;
					end ;
					else if (@transaction_code = 'MNTPPHP')
					begin
						if (@return_value > 0)
						begin
							set @pph_type = N'PPH PASAL 21' ;
							set @income_type = N'Jasa Teknik' ;
							set @income_bruto_amount = @total_amount ;
							set @tax_rate = @pph_pct ;
							set @ppn_pph_amount = @return_value ;
							set @vendor_code = @vendor_code ;
							set @vendor_name = @vendor_name ;
							set @vendor_npwp = @vendor_npwp ;
							set @adress = @adress ;
							set @faktur_date = @faktur_date_source ;
							set @faktur_jurnal = @faktur_no ;
						end ;
					end ;
					else
					begin
						set @income_type = N'' ;
						set @pph_type = N'' ;
						set @vendor_code = N'' ;
						set @vendor_name = N'' ;
						set @vendor_npwp = N'' ;
						set @adress = N'' ;
						set @income_bruto_amount = 0 ;
						set @tax_rate = 0 ;
						set @ppn_pph_amount = 0 ;
						set @remarks_tax = N'' ;
						set @faktur_jurnal = N'' ;
						set @faktur_date = null ;
					end ;

					set @journal_remark = N'Work Order ' + @transaction_name + N'. For ' + @plat_no ;
					set @remarks_tax = @journal_remark ;

					if(@transaction_code = 'ACPS')
					begin
						if not exists(select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @journal_code and gl_link_code = @gl_link_code)
						begin
							exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_code
																								  ,@p_company_code					= 'DSF'
																								  ,@p_branch_code					= @branch_code_asset
																								  ,@p_branch_name					= @branch_name_asset
																								  ,@p_cost_center_code				= null
																								  ,@p_cost_center_name				= null
																								  ,@p_gl_link_code					= @gl_link_code
																								  ,@p_agreement_no					= @agreement_external_no
																								  ,@p_facility_code					= ''
																								  ,@p_facility_name					= ''
																								  ,@p_purpose_loan_code				= ''
																								  ,@p_purpose_loan_name				= ''
																								  ,@p_purpose_loan_detail_code		= ''
																								  ,@p_purpose_loan_detail_name		= ''
																								  ,@p_orig_currency_code			= 'IDR'
																								  ,@p_orig_amount_db				= @orig_amount_db
																								  ,@p_orig_amount_cr				= @orig_amount_cr
																								  ,@p_exch_rate						= 0
																								  ,@p_base_amount_db				= @orig_amount_db
																								  ,@p_base_amount_cr				= @orig_amount_cr
																								  ,@p_division_code					= ''
																								  ,@p_division_name					= ''
																								  ,@p_department_code				= ''
																								  ,@p_department_name				= ''
																								  ,@p_remarks						= @journal_remark
																								  ,@p_ext_pph_type					= @pph_type
																								  ,@p_ext_vendor_code				= @vendor_code
																								  ,@p_ext_vendor_name				= @vendor_name
																								  ,@p_ext_vendor_npwp				= @vendor_npwp
																								  ,@p_ext_vendor_address			= @adress
																								  ,@p_ext_income_type				= @income_type
																								  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																								  ,@p_ext_tax_rate_pct				= @exch_rate
																								  ,@p_ext_pph_amount				= @ppn_pph_amount
																								  ,@p_ext_description				= @remarks_tax
																								  ,@p_ext_tax_number				= @faktur_jurnal
																								  ,@p_ext_tax_date					= @faktur_date
																								  ,@p_ext_sale_type					= ''
																								  ,@p_cre_date						= @p_mod_date
																								  ,@p_cre_by						= @p_mod_by
																								  ,@p_cre_ip_address				= @p_mod_ip_address
																								  ,@p_mod_date						= @p_mod_date
																								  ,@p_mod_by						= @p_mod_by
																								  ,@p_mod_ip_address				= @p_mod_ip_address ;
						end
						else
						begin
							update	dbo.efam_interface_journal_gl_link_transaction_detail
							set		orig_amount_db = orig_amount_db + @orig_amount_db
									,orig_amount_cr = orig_amount_cr + @orig_amount_cr
									,base_amount_db = base_amount_db + @orig_amount_db
									,base_amount_cr = base_amount_cr + @orig_amount_cr
							where	gl_link_code				 = @gl_link_code
									and gl_link_transaction_code = @journal_code ;
						end
					end
					else
					begin
						exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_code
																							  ,@p_company_code					= 'DSF'
																							  ,@p_branch_code					= @branch_code_asset
																							  ,@p_branch_name					= @branch_name_asset
																							  ,@p_cost_center_code				= null
																							  ,@p_cost_center_name				= null
																							  ,@p_gl_link_code					= @gl_link_code
																							  ,@p_agreement_no					= @agreement_external_no
																							  ,@p_facility_code					= ''
																							  ,@p_facility_name					= ''
																							  ,@p_purpose_loan_code				= ''
																							  ,@p_purpose_loan_name				= ''
																							  ,@p_purpose_loan_detail_code		= ''
																							  ,@p_purpose_loan_detail_name		= ''
																							  ,@p_orig_currency_code			= 'IDR'
																							  ,@p_orig_amount_db				= @orig_amount_db
																							  ,@p_orig_amount_cr				= @orig_amount_cr
																							  ,@p_exch_rate						= 0
																							  ,@p_base_amount_db				= @orig_amount_db
																							  ,@p_base_amount_cr				= @orig_amount_cr
																							  ,@p_division_code					= ''
																							  ,@p_division_name					= ''
																							  ,@p_department_code				= ''
																							  ,@p_department_name				= ''
																							  ,@p_remarks						= @journal_remark
																							  ,@p_ext_pph_type					= @pph_type
																							  ,@p_ext_vendor_code				= @vendor_code
																							  ,@p_ext_vendor_name				= @vendor_name
																							  ,@p_ext_vendor_npwp				= @vendor_npwp
																							  ,@p_ext_vendor_address			= @adress
																							  ,@p_ext_income_type				= @income_type
																							  ,@p_ext_income_bruto_amount		= @income_bruto_amount
																							  ,@p_ext_tax_rate_pct				= @exch_rate
																							  ,@p_ext_pph_amount				= @ppn_pph_amount
																							  ,@p_ext_description				= @remarks_tax
																							  ,@p_ext_tax_number				= @faktur_jurnal
																							  ,@p_ext_tax_date					= @faktur_date
																							  ,@p_ext_sale_type					= ''
																							  ,@p_cre_date						= @p_mod_date
																							  ,@p_cre_by						= @p_mod_by
																							  ,@p_cre_ip_address				= @p_mod_ip_address
																							  ,@p_mod_date						= @p_mod_date
																							  ,@p_mod_by						= @p_mod_by
																							  ,@p_mod_ip_address				= @p_mod_ip_address ;
					end

					fetch next from curr_journal
					into @sp_name
						 ,@debet_or_credit
						 ,@gl_link_code
						 ,@transaction_name
						 ,@transaction_code
						 ,@id_detail
						 ,@total_amount
						 ,@ppn_pct
						 ,@pph_pct
						 ,@vendor_code
						 ,@vendor_name
						 ,@adress
						 ,@vendor_npwp ;
				end ;

				close curr_journal ;
				deallocate curr_journal ;

				-- balancing
				begin
					if ((
							select	sum(orig_amount_db) - sum(orig_amount_cr)
							from	dbo.efam_interface_journal_gl_link_transaction_detail
							where	gl_link_transaction_code = @journal_code
						) <> 0
					   )
					begin
						set @msg = N'Journal is not balance.' ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;

			end ;
				else
				begin
					set @msg = N'Data already proceed.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end

			update	dbo.payment_request
			set		payment_status = 'CANCEL'
					--
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	payment_source_no = @p_code ;

			update	dbo.work_order
			set		status				= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = N'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
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
