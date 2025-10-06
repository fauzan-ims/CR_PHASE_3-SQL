
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_spaf_claim_post]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@status						nvarchar(20)
			,@date							datetime	= dbo.xfn_get_system_date()
			,@claim_amount					decimal(18,2)
			,@fa_code						nvarchar(50)
			,@item_name						nvarchar(250)
			,@claim_type					nvarchar(50)
			,@remark						nvarchar(4000)
			,@code_interface				nvarchar(50)
			,@claim_date					datetime
			,@receive_remark				nvarchar(4000)
			,@sp_name						nvarchar(250)
			,@gl_link_code					nvarchar(50)
			,@transaction_name				nvarchar(250)
			,@debet_or_credit				nvarchar(10)
			,@remarks						nvarchar(4000)
			,@receive_amount				decimal(18,2)
			,@return_value					decimal(18, 2)
			,@id							int
			,@orig_amount_db				decimal(18, 2)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@branch_code_detail			nvarchar(50)
			,@branch_name_detail			nvarchar(250)
			,@code_journal					nvarchar(50)
			,@orig_amount_cr				decimal(18,2)
			,@detail_remark					nvarchar(4000)
			,@id_detail						int
			,@claim_amount_detail			decimal(18,2)
			,@journal_date					datetime = dbo.xfn_get_system_date()
			,@ppn							decimal(18,2)
			,@pph							decimal(18,2)
			,@agreement_no					nvarchar(50)
			,@text							nvarchar(250)
			,@ppn_detail					decimal(18,2)
			,@pph_detail					decimal(18,2)

	begin try 

		if exists(select 1 from dbo.efam_interface_received_request where received_source_no  = @p_code)
		begin
			set @msg = 'Receive for this Receipt No already exist.';
			raiserror(@msg ,16,-1);
		end

		--validasi nilai total claim harus sama detail
		select @claim_amount	= total_claim_amount 
				,@ppn			= ppn_amount
				,@pph			= pph_amount
		from dbo.spaf_claim
		where code = @p_code

		select @claim_amount_detail = sum(claim_amount) + @ppn -  @pph
				,@ppn_detail		= sum(ppn_amount_detail)
				,@pph_detail		= sum(pph_amount_detail)
		from dbo.spaf_claim_detail
		where spaf_claim_code = @p_code

		if (@claim_amount <> @claim_amount_detail)
		begin
			set @msg = 'Total claim amount header must be equal with claim amount detail.';
			raiserror(@msg ,16,-1);
		end

		if (@ppn <> @ppn_detail)
		begin
			set @msg = 'PPN header must be equal with PPN detail.';
			raiserror(@msg ,16,-1);
		end

		if (@pph <> @pph_detail)
		begin
			set @msg = 'PPH header must be equal with PPH detail.';
			raiserror(@msg ,16,-1);
		end

		select	@status			= status
				,@date			= date
				,@claim_amount	= total_claim_amount
		from	dbo.spaf_claim
		where	code = @p_code ;

		update	dbo.spaf_claim
		set		status			= 'ON PROCESS'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code;


		--cursor branch asset
		DECLARE curr_branch CURSOR FAST_FORWARD READ_ONLY for
        select	ass.branch_code
				,ass.branch_name
		from	dbo.spaf_claim					 sclm
		inner join dbo.spaf_claim_detail sclmd on (sclmd.spaf_claim_code = sclm.code)
		inner join dbo.spaf_asset		 sas on (sas.code				 = sclmd.spaf_asset_code)
		inner join dbo.asset			 ass on (ass.code				 = sas.fa_code)
		where sclm.code = @p_code
		group by ass.branch_code
			 ,ass.branch_name

		OPEN curr_branch

		FETCH NEXT FROM curr_branch 
		into @branch_code
			,@branch_name

		WHILE @@FETCH_STATUS = 0
		BEGIN
		    --set @receive_remark = 'SPAF/SUBVENTION Claim for ' + @p_code
					--fauzan
		SET @receive_remark =
		(
			SELECT 'SPAF/SUBVENTION Claim for ' + SPAF_CLAIM.CODE + ' and Receipt No '
				   + STUFF(
							  (
								  SELECT DISTINCT
										 ', ' + SA.SUBVENTION_RECEIPT_NO
								  FROM dbo.SPAF_ASSET AS SA
								  WHERE SA.SUBVENTION_RECEIPT_NO = SPAF_CLAIM.RECEIPT_NO
										AND SA.SUBVENTION_RECEIPT_NO IS NOT NULL
								  FOR XML PATH(''), TYPE
							  ).value('.', 'NVARCHAR(MAX)'),
							  1,
							  2,
							  ''
						  )
			FROM dbo.SPAF_CLAIM
			WHERE SPAF_CLAIM.CODE = @p_code

		);
		--SELECT @receive_remark
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code							= @code_journal output
																		   ,@p_company_code					= 'DSF'
																		   ,@p_branch_code					= @branch_code
																		   ,@p_branch_name					= @branch_name
																		   ,@p_transaction_status			= 'HOLD'
																		   ,@p_transaction_date				= @journal_date
																		   ,@p_transaction_value_date		= @journal_date
																		   ,@p_transaction_code				= @p_code
																		   ,@p_transaction_name				= 'SPAF CLAIM'
																		   ,@p_reff_module_code				= 'IFINAMS'
																		   ,@p_reff_source_no				= @p_code
																		   ,@p_reff_source_name				= @receive_remark
																		   ,@p_is_journal_reversal			= '0'
																		   ,@p_transaction_type				= ''
																		   ,@p_cre_date						= @p_mod_date
																		   ,@p_cre_by						= @p_mod_by
																		   ,@p_cre_ip_address				= @p_mod_ip_address
																		   ,@p_mod_date						= @p_mod_date
																		   ,@p_mod_by						= @p_mod_by
																		   ,@p_mod_ip_address				= @p_mod_ip_address
			--cursor asset percabang
			DECLARE curr_spaf_detail CURSOR FAST_FORWARD READ_ONLY for
            select id 
			from dbo.spaf_claim_detail sclmd
			inner join dbo.spaf_asset		 sas on (sas.code				 = sclmd.spaf_asset_code)
			inner join dbo.asset			 ass on (ass.code				 = sas.fa_code)
			where sclmd.spaf_claim_code = @p_code
			and ass.branch_code = @branch_code

			OPEN curr_spaf_detail

			FETCH NEXT FROM curr_spaf_detail 
			into @id_detail

			WHILE @@FETCH_STATUS = 0
			BEGIN
			    --cursor insert ke journal
				declare curr_journal cursor fast_forward read_only for
				select	mt.sp_name
						,mtp.debet_or_credit
						,mtp.gl_link_code
						,mt.transaction_name
						,ass.branch_code
						,ass.branch_name
						,ass.code
						,ass.item_name
						,sclmd.id
						,ass.agreement_external_no
				from	dbo.master_transaction_parameter  mtp
						inner join dbo.master_transaction mt on mt.code					  = mtp.transaction_code
																and mt.company_code		  = mtp.company_code
						inner join dbo.spaf_claim_detail  sclmd on (sclmd.id = @id_detail)
						inner join dbo.spaf_asset		  sas on (sas.code				  = sclmd.spaf_asset_code)
						inner join dbo.asset			  ass on (ass.code				  = sas.fa_code)
				where	mtp.process_code = 'SPFJ' ;

			open curr_journal

			fetch next from curr_journal 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@branch_code_detail
				,@branch_name_detail
				,@fa_code
				,@item_name
				,@id_detail
				,@agreement_no

			while @@fetch_status = 0
			begin
			    	-- nilainya exec dari MASTER_TRANSACTION.sp_name
					exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 

					--if(isnull(@return_value,0) <> 0 )
					begin
						if (@debet_or_credit ='DEBIT')
						begin
							set @orig_amount_cr = 0
							set @orig_amount_db = @return_value
						end
						else
						begin
							set @orig_amount_cr = abs(@return_value)
							set @orig_amount_db = 0
						end		
					end

					set @gl_link_code = isnull(@gl_link_code,'')
					set @detail_remark  = 'SPAF/SUBVENTION CLAIM for '+ @transaction_name + '. Asset : ' + @fa_code + ' - ' + @item_name

					set @text = isnull(@agreement_no,@fa_code)
					exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code			= @code_journal
																						  ,@p_company_code						= 'DSF'
																						  ,@p_branch_code						= @branch_code_detail
																						  ,@p_branch_name						= @branch_name_detail
																						  ,@p_cost_center_code					= null
																						  ,@p_cost_center_name					= null
																						  ,@p_gl_link_code						= @gl_link_code
																						  ,@p_agreement_no						= @text --@fa_code
																						  ,@p_facility_code						= ''
																						  ,@p_facility_name						= ''
																						  ,@p_purpose_loan_code					= ''
																						  ,@p_purpose_loan_name					= ''
																						  ,@p_purpose_loan_detail_code			= ''
																						  ,@p_purpose_loan_detail_name			= ''
																						  ,@p_orig_currency_code				= 'IDR'
																						  ,@p_orig_amount_db					= @orig_amount_db
																						  ,@p_orig_amount_cr					= @orig_amount_cr
																						  ,@p_exch_rate							= 0
																						  ,@p_base_amount_db					= @orig_amount_db
																						  ,@p_base_amount_cr					= @orig_amount_cr
																						  ,@p_division_code						= ''
																						  ,@p_division_name						= ''
																						  ,@p_department_code					= ''
																						  ,@p_department_name					= ''
																						  ,@p_remarks							= @detail_remark
																						  ,@p_cre_date							= @p_mod_date
																						  ,@p_cre_by							= @p_mod_by
																						  ,@p_cre_ip_address					= @p_mod_ip_address
																						  ,@p_mod_date							= @p_mod_date
																						  ,@p_mod_by							= @p_mod_by
																						  ,@p_mod_ip_address					= @p_mod_ip_address


			    fetch next from curr_journal 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
					,@branch_code_detail
					,@branch_name_detail
					,@fa_code
					,@item_name
					,@id_detail
					,@agreement_no
			end

				close curr_journal
				deallocate curr_journal

				select	@orig_amount_db = sum(orig_amount_db) 
						,@orig_amount_cr = sum(orig_amount_cr) 
				from  dbo.efam_interface_journal_gl_link_transaction_detail
				where gl_link_transaction_code = @code_journal

				--+ validasi : total detail =  payment_amount yang di header
				if (@orig_amount_db <> @orig_amount_cr)
				begin
					set @msg = 'Journal does not balanceeeee';
					raiserror(@msg, 16, -1) ;
				end

			    FETCH NEXT FROM curr_spaf_detail 
				into @id_detail
			END

			CLOSE curr_spaf_detail
			DEALLOCATE curr_spaf_detail


		    FETCH NEXT FROM curr_branch 
			into @branch_code
				,@branch_name
		END

		CLOSE curr_branch
		DEALLOCATE curr_branch


		--set @receive_remark = 'SPAF Claim for ' + @p_code + '. Claim : ' + format(@claim_amount, '#,###.00', 'DE-de')
		--exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code							= @code_journal output
		--															   ,@p_company_code					= 'DSF'
		--															   ,@p_branch_code					= @branch_code
		--															   ,@p_branch_name					= @branch_name
		--															   ,@p_transaction_status			= 'HOLD'
		--															   ,@p_transaction_date				= @date
		--															   ,@p_transaction_value_date		= @date
		--															   ,@p_transaction_code				= @p_code
		--															   ,@p_transaction_name				= 'SPAF CLAIM'
		--															   ,@p_reff_module_code				= 'IFINAMS'
		--															   ,@p_reff_source_no				= @p_code
		--															   ,@p_reff_source_name				= @receive_remark
		--															   ,@p_is_journal_reversal			= '0'
		--															   ,@p_transaction_type				= ''
		--															   ,@p_cre_date						= @p_mod_date
		--															   ,@p_cre_by						= @p_mod_by
		--															   ,@p_cre_ip_address				= @p_mod_ip_address
		--															   ,@p_mod_date						= @p_mod_date
		--															   ,@p_mod_by						= @p_mod_by
		--															   ,@p_mod_ip_address				= @p_mod_ip_address


		--declare curr_journal cursor fast_forward read_only for
		--select	mt.sp_name
		--		,mtp.debet_or_credit
		--		,mtp.gl_link_code
		--		,mt.transaction_name
		--		,ass.branch_code
		--		,ass.branch_name
		--from	dbo.master_transaction_parameter  mtp
		--		inner join dbo.master_transaction mt on mt.code					  = mtp.transaction_code
		--												and mt.company_code		  = mtp.company_code
		--		inner join dbo.spaf_claim		  sclm on (sclm.code			  = @p_code)
		--		inner join dbo.spaf_claim_detail  sclmd on (sclmd.spaf_claim_code = sclm.code)
		--		inner join dbo.spaf_asset		  sas on (sas.code				  = sclmd.spaf_asset_code)
		--		inner join dbo.asset			  ass on (ass.code				  = sas.fa_code)
		--where	mtp.process_code = 'SPFJ' ;

		--open curr_journal

		--fetch next from curr_journal 
		--into @sp_name
		--	,@debet_or_credit
		--	,@gl_link_code
		--	,@transaction_name
		--	,@branch_code_detail
		--	,@branch_name_detail

		--while @@fetch_status = 0
		--begin
		--    	-- nilainya exec dari MASTER_TRANSACTION.sp_name
		--		exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 

		--		--if(@return_value <> 0 )
		--		begin
		--			if (@debet_or_credit ='DEBIT')
		--			begin
		--				set @orig_amount_cr = 0
		--				set @orig_amount_db = @return_value
		--			end
		--			else
		--			begin
		--				set @orig_amount_cr = abs(@return_value)
		--				set @orig_amount_db = 0
		--			end		
		--		end

		--		set @gl_link_code = isnull(@gl_link_code,'')
		--		set @detail_remark  = 'SPAF CLAIM for '+ @transaction_name + ' amount : ' + format(@return_value, '#,###.00', 'DE-de')

		--		exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code			= @code_journal
		--																			  ,@p_company_code						= 'DSF'
		--																			  ,@p_branch_code						= @branch_code_detail
		--																			  ,@p_branch_name						= @branch_name_detail
		--																			  ,@p_cost_center_code					= null
		--																			  ,@p_cost_center_name					= null
		--																			  ,@p_gl_link_code						= @gl_link_code
		--																			  ,@p_agreement_no						= ''
		--																			  ,@p_facility_code						= ''
		--																			  ,@p_facility_name						= ''
		--																			  ,@p_purpose_loan_code					= ''
		--																			  ,@p_purpose_loan_name					= ''
		--																			  ,@p_purpose_loan_detail_code			= ''
		--																			  ,@p_purpose_loan_detail_name			= ''
		--																			  ,@p_orig_currency_code				= 'IDR'
		--																			  ,@p_orig_amount_db					= @orig_amount_db
		--																			  ,@p_orig_amount_cr					= @orig_amount_cr
		--																			  ,@p_exch_rate							= 0
		--																			  ,@p_base_amount_db					= @orig_amount_db
		--																			  ,@p_base_amount_cr					= @orig_amount_cr
		--																			  ,@p_division_code						= ''
		--																			  ,@p_division_name						= ''
		--																			  ,@p_department_code					= ''
		--																			  ,@p_department_name					= ''
		--																			  ,@p_remarks							= @detail_remark
		--																			  ,@p_cre_date							= @p_mod_date
		--																			  ,@p_cre_by							= @p_mod_by
		--																			  ,@p_cre_ip_address					= @p_mod_ip_address
		--																			  ,@p_mod_date							= @p_mod_date
		--																			  ,@p_mod_by							= @p_mod_by
		--																			  ,@p_mod_ip_address					= @p_mod_ip_address


		--    fetch next from curr_journal 
		--	into @sp_name
		--		,@debet_or_credit
		--		,@gl_link_code
		--		,@transaction_name
		--		,@branch_code_detail
		--		,@branch_name_detail
		--end

		--close curr_journal
		--deallocate curr_journal

		--select	@orig_amount_db = sum(orig_amount_db) 
		--		,@orig_amount_cr = sum(orig_amount_cr) 
		--from  dbo.efam_interface_journal_gl_link_transaction_detail
		--where gl_link_transaction_code = @code_journal

		----+ validasi : total detail =  payment_amount yang di header
		--if (@orig_amount_db <> @orig_amount_cr)
		--begin
		--	set @msg = 'Journal does not balance';
		--	raiserror(@msg, 16, -1) ;
		--end


		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
															,@p_code					= @code_interface output
															,@p_company_code			= 'DSF'
															,@p_branch_code				= @branch_code
															,@p_branch_name				= @branch_name
															,@p_received_source			= 'SPAF CLAIM ASSET'
															,@p_received_request_date	= @journal_date
															,@p_received_source_no		= @p_code
															,@p_received_status			= 'HOLD'
															,@p_received_currency_code	= 'IDR'
															,@p_received_amount			= @claim_amount
															,@p_received_remarks		= @receive_remark
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


			declare curr_receiv_request cursor fast_forward read_only for
			select mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
					,scd.id
					,ass.branch_code
					,ass.branch_name
					,ass.code
					,ass.agreement_external_no
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
					inner join dbo.spaf_claim_detail scd on (scd.spaf_claim_code = @p_code)
					inner join dbo.spaf_asset		  sas on (sas.code				  = scd.spaf_asset_code)
					inner join dbo.asset			  ass on (ass.code				  = sas.fa_code)
			where	mtp.process_code = 'SPFC'	
			order by mtp.order_key

			open curr_receiv_request

			fetch next from curr_receiv_request 
			into @sp_name
				,@debet_or_credit
				,@gl_link_code
				,@transaction_name
				,@id
				,@branch_code_detail
				,@branch_name_detail
				,@fa_code
				,@agreement_no

			while @@fetch_status = 0
			begin
			    -- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @id ; -- sp ini mereturn value angka

				if (@debet_or_credit = 'DEBIT')
				begin
					set @orig_amount_db = @return_value ;
				end ;
				else
				begin
					set @orig_amount_db = @return_value * -1 ;
				end ;


				set @remarks = @transaction_name + '  ' + isnull(@p_code,'');
				set @text = isnull(@agreement_no, @fa_code)
				if(@return_value > 0)
				begin

					exec dbo.xsp_efam_interface_received_request_detail_insert @p_id						= 0
																			   ,@p_received_request_code	= @code_interface
																			   ,@p_company_code				= 'DSF'
																			   ,@p_branch_code				= @branch_code_detail
																			   ,@p_branch_name				= @branch_name_detail
																			   ,@p_gl_link_code				= @gl_link_code
																			   ,@p_agreement_no				= @text--@p_code
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
																			   ,@p_ext_pph_type				= null
																			   ,@p_ext_vendor_code			= null
																			   ,@p_ext_vendor_name			= null
																			   ,@p_ext_vendor_npwp			= null
																			   ,@p_ext_vendor_address		= null
																			   ,@p_ext_vendor_type			= null
																			   ,@p_ext_income_type			= null
																			   ,@p_ext_income_bruto_amount	= 0
																			   ,@p_ext_tax_rate_pct			= 0
																			   ,@p_ext_pph_amount			= 0
																			   ,@p_ext_description			= null
																			   ,@p_ext_tax_number			= null
																			   ,@p_ext_sale_type			= null
																			   ,@p_ext_tax_date				= null
																			   ,@p_cre_date					= @p_mod_date
																			   ,@p_cre_by					= @p_mod_by
																			   ,@p_cre_ip_address			= @p_mod_ip_address
																			   ,@p_mod_date					= @p_mod_date
																			   ,@p_mod_by					= @p_mod_by
																			   ,@p_mod_ip_address			= @p_mod_ip_address

				end

			    fetch next from curr_receiv_request 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
					,@id
					,@branch_code_detail
					,@branch_name_detail
					,@fa_code
					,@agreement_no
			end

			close curr_receiv_request
			deallocate curr_receiv_request

			--validasi
			set @msg = dbo.xfn_finance_request_check_balance('RECEIVE',@code_interface)
			if @msg <> ''
			begin
				raiserror(@msg,16,1);
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
