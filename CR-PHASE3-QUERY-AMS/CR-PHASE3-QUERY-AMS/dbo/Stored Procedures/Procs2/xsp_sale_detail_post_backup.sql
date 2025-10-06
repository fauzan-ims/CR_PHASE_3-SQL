CREATE PROCEDURE dbo.xsp_sale_detail_post_backup
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
			,@gain_loss						decimal(18,2)
			,@purchase_price				decimal(18,2)
			,@is_sold						nvarchar(1)
			,@remark						nvarchar(4000)
			,@sale_date						datetime
			,@code_handover					nvarchar(50)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@code_document					nvarchar(50)
			,@sell_type						nvarchar(50)
			,@transaction_code				nvarchar(50)

	begin try
		select	@code				= sale_code
				,@branch_code		= sl.branch_code
				,@branch_name		= sl.branch_name
				,@fee_amount		= sd.total_fee_amount
				,@ppn_amount		= sd.total_ppn_amount
				,@pph_amount		= sd.total_pph_amount
				,@asset_code		= sd.asset_code
				,@item_name			= ass.item_name
				,@sale_value		= sd.sold_amount
				,@nbv				= sd.net_book_value
				,@gain_loss			= sd.gain_loss
				,@purchase_price	= ass.purchase_price
				,@is_sold			= sd.is_sold
				,@sale_date			= sd.sale_date
				,@sell_type			= sl.sell_type
		from dbo.sale_detail sd
		left join dbo.sale sl on (sl.code = sd.sale_code)
		left join dbo.asset ass on (ass.code = sd.asset_code)
		where id = @p_id
		
		if exists (select 1 from dbo.sale_detail where id = @p_id and sale_detail_status = 'ON PROCESS')
		begin 
			if(@is_sold = '1')
			begin
				--Kondisi Jika Untung
				--if(@gain_loss > 0)
				BEGIN
                
					--Push ke Finance
					set @receive_amount = @sale_value - (@fee_amount - @pph_amount + @ppn_amount)
					set @receive_remarks = 'SALE ASSET FOR ' + @code + ' - ' + @asset_code + ' ' + @item_name
					exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
																		,@p_code					= @interface_code output
																		,@p_company_code			= 'DSF'
																		,@p_branch_code				= @branch_code
																		,@p_branch_name				= @branch_name
																		,@p_received_source			= 'REALIZATION SELL ASSET'
																		,@p_received_request_date	= @p_mod_date
																		,@p_received_source_no		= @code
																		,@p_received_status			= 'HOLD'
																		,@p_received_currency_code	= 'IDR'
																		,@p_received_amount			= @receive_amount
																		,@p_received_remarks		= @receive_remarks
																		,@p_process_date			= null
																		,@p_process_reff_no			= null
																		,@p_process_reff_name		= null
																		,@p_settle_date				= @p_mod_date
																		,@p_job_status				= null
																		,@p_failed_remarks			= null
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address

					declare curr_payment_sell cursor fast_forward read_only for
					
					select  mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mt.transaction_name
							,mtp.transaction_code
					from	dbo.master_transaction_parameter mtp 
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
					where	mtp.process_code = 'SDSTL'	
					order by mtp.order_key

					open curr_payment_sell
					
					fetch next from curr_payment_sell 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
						,@transaction_code
					
					while @@fetch_status = 0
					begin
						-- nilainya exec dari master_transaction.sp_name
						exec @return_value = @sp_name @p_id ; -- sp ini mereturn value angka
				
						-- logic kusus untuk gainloss
						if (@transaction_code = 'GINLS') -- gain loss sold
						begin
							set @orig_amount_db = @return_value * -1 -- fungsi mereturn (+) artinya untung
						end
						else if (@transaction_code = 'SLDRLDD') -- SOLD RL DEDUCT * jika untung di kredit
						begin
							set @orig_amount_db = @return_value * -1 -- fungsi mereturn (+) artinya untung
						end
						else if (@transaction_code = 'SLDRLNDD') -- SOLD RL NON DEDUCT * jika untung di debit
						begin
							set @orig_amount_db = @return_value   -- fungsi mereturn (+) artinya untung
						end
						else
						begin
							if (@debet_or_credit = 'DEBIT')
							begin
								set @orig_amount_db = @return_value
							end
							else
							begin
								set @orig_amount_db = @return_value * -1
							end
						end

						set @remarks = @transaction_name + isnull(@code,'') + ' For Asset ' + isnull(@asset_code,'') + ' ' + isnull(@item_name,'') ;
						exec dbo.xsp_efam_interface_received_request_detail_insert @p_id						= 0
																				   ,@p_received_request_code	= @interface_code
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code
																				   ,@p_branch_name				= @branch_name
																				   ,@p_gl_link_code				= @gl_link_code
																				   ,@p_agreement_no				= null
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
																				   ,@p_remarks					= @remarks
																				   ,@p_cre_date					= @p_mod_date
																				   ,@p_cre_by					= @p_mod_by
																				   ,@p_cre_ip_address			= @p_mod_ip_address
																				   ,@p_mod_date					= @p_mod_date
																				   ,@p_mod_by					= @p_mod_by
																				   ,@p_mod_ip_address			= @p_mod_ip_address
				    
					    fetch next from curr_payment_sell 
						into @sp_name
							,@debet_or_credit
							,@gl_link_code
							,@transaction_name
							,@transaction_code
					end
					
					close curr_payment_sell
					deallocate curr_payment_sell

					--bentuk journal
					exec dbo.xsp_efam_journal_sale_register @p_sale_code		= @code
															,@p_process_code	= 'SELL'
															,@p_company_code	= 'DSF'
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address
				end
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
				    
				--		set @remarks = @transaction_name + isnull(@code,'') + ' For Asset ' + isnull(@item_name,'') ;
						 
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

				update	dbo.asset
				set		status			= 'SOLD'
						,fisical_status = 'SOLD'
						,process_status = @sell_type
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code = @asset_code

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

				set @remark = 'Asset ' + @asset_code + ' - ' + @item_name + ' Sold.'
				insert into dbo.handover_request
				(
					code
					,branch_code
					,branch_name
					,type
					,status
					,date
					,handover_from
					,handover_to
					,handover_address
					,handover_phone_area
					,handover_phone_no
					,eta_date
					,fa_code
					,remark
					,reff_code
					,reff_name
					,handover_code
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(
					@code_handover
					,@branch_code
					,@branch_name
					,'SELL OUT'
					,'HOLD'
					,@p_mod_date
					,'Warehouse'
					,'SOLD'
					,''
					,''
					,''
					,@sale_date
					,@asset_code
					,@remarks
					,@code
					,'SELL SETTLEMENT'
					,null
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				)


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


