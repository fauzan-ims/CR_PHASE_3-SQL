

CREATE PROCEDURE dbo.xsp_sale_detail_post
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@code							nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@interface_code				nvarchar(50)
			,@fee_amount					decimal(18,2)
			,@ppn_amount					decimal(18,2)
			,@pph_amount					decimal(18,2)
			,@sp_name						nvarchar(250)
			,@gl_link_code					nvarchar(50)
			,@transaction_name				nvarchar(250)
			,@transaction_code				nvarchar(250)
			,@debet_or_credit				nvarchar(10)
			,@remarks						nvarchar(4000)
			,@asset_code					nvarchar(50)
			,@item_name						nvarchar(250)
			,@sale_value					decimal(18,2)
			,@nbv							decimal(18,2)
			,@receive_amount				decimal(18,2)
			,@receive_remarks				nvarchar(4000)
			,@return_value					decimal(18, 2)
			,@orig_amount_db				decimal(18, 2)
			,@amount						decimal(18,2)
			,@gain_loss						BIGINT
			,@purchase_price				decimal(18,2)
			,@is_sold						nvarchar(1)
			,@remark						nvarchar(4000)
			,@sale_date						datetime
			,@code_handover					nvarchar(50)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@code_document					nvarchar(50)
			,@sell_type						nvarchar(50)
			,@reff_remark					nvarchar(4000)
			,@agreement_no					nvarchar(50)
			,@client_name					nvarchar(250)
			,@buyer_address					nvarchar(4000)
			,@buyer_name					nvarchar(250)
			,@buyer_area_phone_no			nvarchar(4)
			,@buyer_phone_no				nvarchar(15)
			,@nbv_asset						decimal(18,2)
			,@status_asset					nvarchar(50)
			,@ppn_pct						decimal(9,6)
			,@pph_pct						decimal(9,6)
			,@vendor_type					nvarchar(25)
			,@pph_type						nvarchar(20)
			,@total_amount					decimal(18,2)
			,@remarks_tax					nvarchar(4000)
			,@income_type					nvarchar(250)
			,@income_bruto_amount			decimal(18,2)
			,@tax_rate						decimal(5,2)
			,@ppn_pph_amount				decimal(18,2)
			,@vendor_code					nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@vendor_npwp					nvarchar(20)
			,@faktur_no						nvarchar(50)
			,@adress						nvarchar(4000)
			,@buyer_type					nvarchar(20)
			,@ktp_no						nvarchar(20)
			,@npwp_no						nvarchar(20)
			,@auction_code					nvarchar(50)
			,@auction_name					nvarchar(250)
			,@auction_npwp					nvarchar(20)
			,@auction_address				nvarchar(4000)
			,@branch_code_asset				nvarchar(50)
			,@branch_name_asset				nvarchar(250)
			,@faktur_date					DATETIME
            ,@auction_nitku					NVARCHAR(50)
			,@auction_npwp_ho				NVARCHAR(50)

	begin try
		select	@code					= sale_code
				,@branch_code			= sl.branch_code
				,@branch_name			= sl.branch_name
				,@fee_amount			= sd.total_fee_amount
				,@ppn_amount			= sd.total_ppn_amount
				,@pph_amount			= sd.total_pph_amount
				,@asset_code			= sd.asset_code
				,@item_name				= ass.item_name
				,@sale_value			= sd.sold_amount
				,@nbv					= sd.net_book_value
				,@gain_loss				= sd.gain_loss
				,@purchase_price		= ass.purchase_price
				,@is_sold				= sd.is_sold
				,@sale_date				= sd.sale_date
				,@sell_type				= sl.sell_type
				,@receive_amount		= sd.net_receive
				,@agreement_no			= ass.agreement_no
				,@client_name			= ass.client_name
				,@buyer_address			= sd.buyer_address
				,@buyer_name			= sd.buyer_name
				,@buyer_area_phone_no	= sd.buyer_area_phone
				,@buyer_phone_no		= sd.buyer_area_phone_no
				,@nbv_asset				= ass.net_book_value_comm
				,@status_asset			= ass.status
				,@auction_code			= auction.code
				,@auction_name			= auction.auction_name
				,@auction_npwp			= auction.tax_file_no
				,@auction_address		= auction_address.address
				,@branch_code_asset		= ass.branch_code
				,@branch_name_asset		= ass.branch_name
				,@auction_nitku			= auction.nitku
				,@auction_npwp_ho		= auction.npwp_ho
		from dbo.sale_detail sd			
		inner join dbo.sale sl on (sl.code = sd.sale_code)
		inner join dbo.asset ass on (ass.code = sd.asset_code)
		outer apply(select mc.code, mc.auction_name, mc.tax_file_no, mc.nitku, mc.npwp_ho from dbo.master_auction mc where sl.auction_code = mc.code) auction
		outer apply(select address from dbo.master_auction_address mad where mad.auction_code = auction.code) auction_address
		where id = @p_id

		set @gain_loss = round(@gain_loss,0)

		if @nbv_asset <> @nbv
		begin
			set @msg = 'Please save first.';
			raiserror(@msg ,16,-1);
		end
		
		if exists (select 1 from dbo.sale_detail where id = @p_id and sale_detail_status = 'ON PROCESS')
		begin 
			if(@is_sold = '1')
			begin
				----Kondisi Jika Untung
				--if(@gain_loss > 0)
				BEGIN
                
					--Push ke Finance
					set @receive_remarks = 'SALE ASSET FOR ' + @code + ' - ' + @asset_code + ' ' + @item_name
					exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
																		,@p_code					= @interface_code output
																		,@p_company_code			= 'DSF'
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_received_source			= 'REALIZATION SELL ASSET'
																		,@p_received_request_date	= @p_mod_date
																		,@p_received_source_no		= @asset_code--@code
																		,@p_received_status			= 'HOLD'
																		,@p_received_currency_code	= 'IDR'
																		,@p_received_amount			= @receive_amount
																		,@p_received_remarks		= @receive_remarks
																		,@p_process_date			= null
																		,@p_process_reff_no			= null
																		,@p_process_reff_name		= null
																		,@p_settle_date				= null
																		,@p_job_status				= 'HOLD'
																		,@p_failed_remarks			= null
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address

					declare curr_payment_sell cursor fast_forward read_only for
					
					select mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mt.transaction_name
							,mtp.transaction_code
							,sd.buyer_type
							,sd.ktp_no
							,sd.buyer_npwp
							,sd.buyer_name
							,sd.buyer_address
							,sd.total_fee_amount - isnull(sd.total_ppn_amount,0) + isnull(sd.total_pph_amount,0)
							,sd.faktur_no
							,sd.faktur_date
					from	dbo.master_transaction_parameter mtp 
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
							inner join dbo.sale_detail sd on (sd.id = @p_id)
					where	mtp.process_code = 'SDSTL'	
					order by mtp.order_key

					open curr_payment_sell
					
					fetch next from curr_payment_sell 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
						,@transaction_code
						,@buyer_type
						,@ktp_no
						,@npwp_no
						,@buyer_name
						,@buyer_address
						,@total_amount
						,@faktur_no
						,@faktur_date
					
					while @@fetch_status = 0
					begin
						-- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @p_id ; -- sp ini mereturn value angka
						
						if (@transaction_code = 'GINLS') OR (@transaction_code = 'GINLSC')-- logic khusus gain loss
						begin
							if @return_value > 0
								set @orig_amount_db = @return_value * -1 -- journal untung deault nya kredit
							else
								set @orig_amount_db = abs(@return_value )

						end 
						else
						begin
							if (@debet_or_credit = 'DEBIT')
							begin
								set @orig_amount_db = @return_value ;
							end ;
							else
							begin
								set @orig_amount_db = @return_value * -1 ;
							end ;
						end ;

						if (@sell_type = 'CLAIM') -- (+) Raffyanda 28/05/2024 Penambahan Logic jika claim tidak ada gain loss
						begin 
							if @transaction_code = 'GINLS'
							begin
								set @orig_amount_db = 0
							end
						end

						set @remarks = @transaction_name + isnull(@code,'') + ' For Asset ' + isnull(@asset_code,'') + ' ' + isnull(@item_name,'') ;
						set @remarks_tax = @remarks

						if(@transaction_code = 'APPNSTL') --PPN OUT FEE ASSET SOLD
						begin
							if(@return_value <> 0)
							begin
								if(@sell_type = 'AUCTION')
								BEGIN
									set @vendor_code		= @auction_code
									set @vendor_name		= @auction_name
									set @vendor_npwp		= @auction_npwp
									set @adress				= @auction_address
								end
								else if (@sell_type = 'MOCIL')
								begin
									set @vendor_code		= 'MOCIL'
									set @vendor_name		= 'MOCIL'
									set @vendor_npwp		= @npwp_no
									set @adress				= @buyer_address
								end
								--set @adress					= @buyer_address
								--set @vendor_npwp			= isnull(@npwp_no,@ktp_no)
								set @pph_type				= 'PPN KELUARAN'
								set @income_type			= 'PPN KELUARAN ' + '11%'
								set @income_bruto_amount	= @total_amount
								set @tax_rate				= 11
								set @ppn_pph_amount			= @return_value
								
							end
						END
                        
						ELSE IF(@transaction_code = 'PPNSTL') --PPN IN FEE ASSET SOLD
						begin
							if(@return_value <> 0)
							BEGIN
								if(@sell_type = 'AUCTION')
								begin
                                
								select	@auction_nitku		= nitku
										,@auction_npwp_ho	= npwp_ho
								from	dbo.master_auction
								where code = @auction_code

									set @vendor_code		= @auction_code
									set @vendor_name		= @auction_name
									set @vendor_npwp		= @auction_npwp
									set @adress				= @auction_address
								end
								else if (@sell_type = 'MOCIL')
								begin
									set @vendor_code		= 'MOCIL'
									set @vendor_name		= 'MOCIL'
									set @vendor_npwp		= @npwp_no
									set @adress				= @buyer_address
								end
								--set @adress					= @buyer_address
								--set @vendor_npwp			= isnull(@npwp_no,@ktp_no)
								set @pph_type				= 'PPN MASUKAN'
								set @income_type			= 'PPN MASUKAN ' + '11%'
								set @income_bruto_amount	= @total_amount
								set @tax_rate				= 11
								set @ppn_pph_amount			= @return_value
							end
						end
						else if(@transaction_code = 'PPHSTL') --PPH FEE ASSET SOLD
						begin
							if(@return_value > 0)
							begin
								--if (@buyer_type = 'PERSONAL')
								--begin
								--	set @pph_type		= 'PPH PASAL 21'
								--	set @income_type	= 'PERANTARA'
								--end
								--else -- CORPORATE

								-- Fee penjualan hanya ada di case Auction dan Mocil
								begin
									set @pph_type		= 'PPH PASAL 23'
									set @income_type	= 'JASA PERANTARA/AGEN'
									
								end
								
								if(@sell_type = 'AUCTION')
								begin
                                
								select	@auction_nitku		= nitku
										,@auction_npwp_ho	= npwp_ho
								from	dbo.master_auction
								where code = @auction_code

									set @vendor_code		= @auction_code
									set @vendor_name		= @auction_name
									set @vendor_npwp		= @auction_npwp
									set @adress				= @auction_address
								end
								else if (@sell_type = 'MOCIL')
								begin
									set @vendor_code		= 'MOCIL'
									set @vendor_name		= 'MOCIL'
									set @vendor_npwp		= @npwp_no
									set @adress				= @buyer_address
								end
								--set @adress					= @buyer_address
								--set @vendor_npwp			= isnull(@npwp_no,@ktp_no)
								--set @income_type			= 'JASA PERANTARA/AGEN'
								set @income_bruto_amount	= @total_amount
								set @tax_rate				= 2
								set @ppn_pph_amount			= @return_value
							end
						end

						else
						begin
							set @income_type			= ''
							set @pph_type				= ''
							set @vendor_code			= ''
							set @vendor_name			= ''
							set @vendor_npwp			= ''
							set @adress					= ''
							set @income_bruto_amount	= 0
							set @tax_rate				= 0
							set @ppn_pph_amount			= 0
							set @remarks_tax			= ''
							set @faktur_no				= ''
							set @faktur_date			= null
							set @buyer_type				= ''
							SET @auction_nitku			= ''
							SET	@auction_npwp_ho		= ''
						end
				    
						if @orig_amount_db <> 0
						begin
							exec dbo.xsp_efam_interface_received_request_detail_insert @p_id						= 0
																					   ,@p_received_request_code	= @interface_code
																					   ,@p_company_code				= 'DSF'
																					   ,@p_branch_code				= @branch_code_asset
																					   ,@p_branch_name				= @branch_name_asset
																					   ,@p_gl_link_code				= @gl_link_code
																					   ,@p_agreement_no				= @asset_code--null
																					   ,@p_facility_code			= null
																					   ,@p_facility_name			= null
																					   ,@p_purpose_loan_code		= null
																					   ,@p_purpose_loan_name		= null
																					   ,@p_purpose_loan_detail_code = null
																					   ,@p_purpose_loan_detail_name = null
																					   ,@p_orig_currency_code		= 'IDR'
																					   ,@p_orig_amount				= @orig_amount_db
																					   ,@p_division_code			= null
																					   ,@p_division_name			= null
																					   ,@p_department_code			= null
																					   ,@p_department_name			= null
																					   ,@p_ext_pph_type				= @pph_type
																					   ,@p_ext_vendor_code			= @vendor_code
																					   ,@p_ext_vendor_name			= @vendor_name
																					   ,@p_ext_vendor_npwp			= @vendor_npwp
																					   ,@p_ext_vendor_address		= @adress
																					   ,@p_ext_vendor_type			= @buyer_type
																					   ,@p_ext_income_type			= @income_type
																					   ,@p_ext_income_bruto_amount	= @income_bruto_amount
																					   ,@p_ext_tax_rate_pct			= @tax_rate
																					   ,@p_ext_pph_amount			= @ppn_pph_amount
																					   ,@p_ext_description			= @remarks_tax
																					   ,@p_ext_tax_number			= @faktur_no
																					   ,@p_ext_tax_date				= @faktur_date
																					   ,@p_ext_sale_type			= ''
																					   ,@p_ext_nitku				= @auction_nitku
																					   ,@p_ext_npwp_ho				= @auction_npwp_ho
																					   ,@p_remarks					= @remarks
																					   ,@p_cre_date					= @p_mod_date
																					   ,@p_cre_by					= @p_mod_by
																					   ,@p_cre_ip_address			= @p_mod_ip_address
																					   ,@p_mod_date					= @p_mod_date
																					   ,@p_mod_by					= @p_mod_by
																					   ,@p_mod_ip_address			= @p_mod_ip_address
						end
				    
					    fetch next from curr_payment_sell 
						into @sp_name
							,@debet_or_credit
							,@gl_link_code
							,@transaction_name
							,@transaction_code
							,@buyer_type
							,@ktp_no
							,@npwp_no
							,@buyer_name
							,@buyer_address
							,@total_amount
							,@faktur_no
							,@faktur_date
					end
					
					close curr_payment_sell
					deallocate curr_payment_sell

				END
				SELECT * FROM dbo.EFAM_INTERFACE_RECEIVED_REQUEST WHERE RECEIVED_SOURCE_NO = @asset_code
				SELECT * FROM dbo.EFAM_INTERFACE_RECEIVED_REQUEST_DETAIL WHERE RECEIVED_REQUEST_CODE = @interface_code
				--jika rugi
				--else
				--begin
				--	--push ke finance					
				--	set @receive_amount = @sale_value - (@fee_amount - @pph_amount + @ppn_amount)
				--	set @receive_remarks = 'REALIZATION SALE ASSET FOR ' + @code

				--	exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
				--														,@p_code					= @interface_code output
				--														,@p_company_code			= 'DSF'
				--														,@p_branch_code				= @branch_code
				--														,@p_branch_name				= @branch_name
				--														,@p_received_source			= 'REALIZATION SELL ASSET'
				--														,@p_received_request_date	= @p_mod_date
				--														,@p_received_source_no		= @p_id
				--														,@p_received_status			= 'HOLD'
				--														,@p_received_currency_code	= 'IDR'
				--														,@p_received_amount			= @receive_amount
				--														,@p_received_remarks		= @receive_remarks
				--														,@p_process_date			= null
				--														,@p_process_reff_no			= null
				--														,@p_process_reff_name		= null
				--														,@p_settle_date				= @p_mod_date
				--														,@p_job_status				= null
				--														,@p_failed_remarks			= null
				--														,@p_cre_date				= @p_mod_date
				--														,@p_cre_by					= @p_mod_by
				--														,@p_cre_ip_address			= @p_mod_ip_address
				--														,@p_mod_date				= @p_mod_date
				--														,@p_mod_by					= @p_mod_by
				--														,@p_mod_ip_address			= @p_mod_ip_address

				--	declare curr_payment_sell cursor fast_forward read_only for

				--	select  mt.sp_name
				--			,mtp.debet_or_credit
				--			,mtp.gl_link_code
				--			,mt.transaction_name
				--	from	dbo.master_transaction_parameter mtp 
				--			left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
				--			left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				--	where	mtp.process_code = 'SDSTLL'	
					
				--	open curr_payment_sell
					
				--	fetch next from curr_payment_sell 
				--	into @sp_name
				--		,@debet_or_credit
				--		,@gl_link_code
				--		,@transaction_name
					
				--	while @@fetch_status = 0
				--	begin
				--		-- nilainya exec dari MASTER_TRANSACTION.sp_name
				--		exec @return_value = @sp_name @p_id ; -- sp ini mereturn value angka
				
				--		if (@debet_or_credit ='DEBIT')
				--			begin
				--				set @orig_amount_db = @return_value

				--			end
				--		else
				--		begin
				--				set @orig_amount_db = @return_value * -1
				--		end
				    
				--		set @remarks = 'Sell payment ' + isnull(@code,'') + ' For Asset ' + isnull(@item_name,'') ;
						 
				--		exec dbo.xsp_efam_interface_received_request_detail_insert @p_id						= 0
				--																   ,@p_received_request_code	= @interface_code
				--																   ,@p_company_code				= 'DSF'
				--																   ,@p_branch_code				= @branch_code
				--																   ,@p_branch_name				= @branch_name
				--																   ,@p_gl_link_code				= @gl_link_code
				--																   ,@p_agreement_no				= null
				--																   ,@p_facility_code			= null
				--																   ,@p_facility_name			= null
				--																   ,@p_purpose_loan_code		= null
				--																   ,@p_purpose_loan_name		= null
				--																   ,@p_purpose_loan_detail_code = null
				--																   ,@p_purpose_loan_detail_name = null
				--																   ,@p_orig_currency_code		= 'IDR'
				--																   ,@p_orig_amount				= @orig_amount_db
				--																   ,@p_division_code			= null
				--																   ,@p_division_name			= null
				--																   ,@p_department_code			= null
				--																   ,@p_department_name			= null
				--																   ,@p_remarks					= @remarks
				--																   ,@p_cre_date					= @p_mod_date
				--																   ,@p_cre_by					= @p_mod_by
				--																   ,@p_cre_ip_address			= @p_mod_ip_address
				--																   ,@p_mod_date					= @p_mod_date
				--																   ,@p_mod_by					= @p_mod_by
				--																   ,@p_mod_ip_address			= @p_mod_ip_address
						
				--	    fetch next from curr_payment_sell 
				--		into @sp_name
				--			,@debet_or_credit
				--			,@gl_link_code
				--			,@transaction_name
				--	end
					
				--	close curr_payment_sell
				--	deallocate curr_payment_sell
					
				--	--bentuk journal
				--	exec dbo.xsp_efam_journal_sale_register @p_sale_code		= @code
				--											,@p_process_code	= 'SELLR'
				--											,@p_company_code	= 'DSF'
				--											,@p_mod_date		= @p_mod_date
				--											,@p_mod_by			= @p_mod_by
				--											,@p_mod_ip_address	= @p_mod_ip_address
				--end
					
				--validasi
				
				set @msg = dbo.xfn_finance_request_check_balance('RECEIVE',@interface_code)
				if @msg <> ''
				begin
					raiserror(@msg,16,1);
				end

				update	dbo.sale_detail
				set		sale_detail_status	= 'POST'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	id					= @p_id ;

				--update	dbo.asset
				--set		status			= 'SOLD'
				--		,fisical_status = 'SOLD'
				--		,process_status = @sell_type
				--		,sale_date		= dbo.xfn_get_system_date()
				--		,sale_amount	= @receive_amount
				--		--
				--		,mod_date			= @p_mod_date
				--		,mod_by				= @p_mod_by
				--		,mod_ip_address		= @p_mod_ip_address
				--where	code = @asset_code

				--insert into handover request
				set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
				set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

				exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code_handover output
															,@p_branch_code			 = @branch_code
															,@p_sys_document_code	 = ''
															,@p_custom_prefix		 = 'WOHR'
															,@p_year				 = @year
															,@p_month				 = @month
															,@p_table_name			 = 'HANDOVER_REQUEST'
															,@p_run_number_length	 = 5
															,@p_delimiter			 = '.'
															,@p_run_number_only		 = '0' ;

				--set @remark = 'Release sell unit ' + @asset_code + ' - ' + @item_name + ' Sold No. ' + @code + ', sold to : ' + @buyer_name ;
				--insert into dbo.handover_request
				--(
				--	code
				--	,branch_code
				--	,branch_name
				--	,type
				--	,status
				--	,date
				--	,handover_from
				--	,handover_to
				--	,handover_address
				--	,handover_phone_area
				--	,handover_phone_no
				--	,eta_date
				--	,fa_code
				--	,remark
				--	,reff_code
				--	,reff_name
				--	,handover_code
				--	,cre_date
				--	,cre_by
				--	,cre_ip_address
				--	,mod_date
				--	,mod_by
				--	,mod_ip_address
				--)
				--values
				--(
				--	@code_handover
				--	,@branch_code
				--	,@branch_name
				--	,'SELL OUT'
				--	,'HOLD'
				--	,@p_mod_date
				--	,'Warehouse'
				--	,@buyer_name
				--	,@buyer_address
				--	,@buyer_area_phone_no
				--	,@buyer_phone_no
				--	,@sale_date
				--	,@asset_code
				--	,@remark
				--	,@code
				--	,'SELL SETTLEMENT'
				--	,null
				--	,@p_mod_date
				--	,@p_mod_by
				--	,@p_mod_ip_address
				--	,@p_mod_date
				--	,@p_mod_by
				--	,@p_mod_ip_address
				--)


				--insert into document request
				set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
				set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

				exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code_document output
															,@p_branch_code			 = @branch_code
															,@p_sys_document_code	 = ''
															,@p_custom_prefix		 = 'IDR'
															,@p_year				 = @year
															,@p_month				 = @month
															,@p_table_name			 = 'AMS_INTERFACE_DOCUMENT_REQUEST'
															,@p_run_number_length	 = 5
															,@p_delimiter			= '.'
															,@p_run_number_only		 = '0' ;

				--insert into document request
				insert into dbo.ams_interface_document_request
				(
					code
					,request_branch_code
					,request_branch_name
					,request_type
					,request_location
					,request_from
					,request_to
					,request_to_branch_code
					,request_to_branch_name
					,request_to_agreement_no
					,request_to_client_name
					,request_from_dept_code
					,request_from_dept_name
					,request_to_dept_code
					,request_to_dept_name
					,request_to_thirdparty_type
					,agreement_no
					,collateral_no
					,asset_no
					,request_by
					,request_status
					,request_date
					,remarks
					,document_code
					,process_date
					,process_reff_no
					,process_reff_name
					,job_status
					,failed_remark
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(
					@code_document
					,@branch_code
					,@branch_name
					,'BORROW'
					,'THIRD PARTY'
					,'BRANCH'
					,''
					,null 
					,null 
					,null 
					,null 
					,null 
					,'' 
					,null 
					,''
					,null
					,null
					,null
					,@asset_code
					,@p_mod_by
					,'HOLD'
					,@p_mod_date
					,'Document Request Form Sell Setllement.'
					,null
					,null
					,null
					,null
					,'HOLD'
					,''
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				)

				-- update document main, is_sold, sold date nya kapan
				update ifindoc.dbo.document_main
				set is_sold				= '1'
					,sold_date			= @sale_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
				where asset_no = @asset_code

				-- insert ke income ledger
				set @reff_remark = 'Sell asset for ' + @asset_code + ' - ' + @item_name
				exec dbo.xsp_asset_income_ledger_insert @p_id				= 0
														,@p_asset_code		= @asset_code
														,@p_date			= @sale_date
														,@p_reff_code		= @code
														,@p_reff_name		= 'SELL'
														,@p_reff_remark		= @reff_remark
														,@p_income_amount	= @receive_amount
														,@p_agreement_no	= @agreement_no
														,@p_client_name		= @client_name
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address
				
			end
			else
			begin
				update	dbo.sale_detail
				set		sale_detail_status	= 'PAID'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	id					= @p_id ;
			end
		end
		else
		begin
			set @msg = 'Data already post.';
			raiserror(@msg ,16,-1);
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
end ;




