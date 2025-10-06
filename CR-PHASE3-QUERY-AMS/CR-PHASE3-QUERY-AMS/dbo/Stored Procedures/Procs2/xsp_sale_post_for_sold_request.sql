CREATE PROCEDURE dbo.xsp_sale_post_for_sold_request
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@asset_code		nvarchar(50)
			,@req_amount		decimal(18,2)
			,@code_interface	nvarchar(50)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@reff_source_name	nvarchar(4000)
			,@sp_name			nvarchar(250)
			,@debit_credit		nvarchar(10)
			,@gl_link_code		nvarchar(50)
			,@transaction_name	nvarchar(250)
			,@orig_amount_cr	decimal(18,2)
			,@orig_amount_db	decimal(18,2)
			,@return_value		decimal(18,2)
			,@detail_remark		nvarchar(4000)
			,@id_detail			int
			,@is_permit_to_sell	nvarchar(1)
			,@asset_no_detail	nvarchar(50)
			,@id_monitoring_gps	bigint
            ,@remark			nvarchar(4000)

	begin try		
		if exists(select 1 from dbo.sale where status = 'ON PROCESS' and code = @p_code)
		begin
				update	dbo.sale
				set		status				= 'APPROVE'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @p_code ;

				-- cursor branch asset
				declare curr_branch cursor fast_forward read_only for
				select	ass.branch_code
						,ass.branch_name
				from	dbo.sale_detail		 sd
						inner join dbo.asset ass on (ass.code = sd.asset_code)
				where	sd.sale_code = @p_code
				and		isnull(ass.is_permit_to_sell,'0') = '0'
				group by ass.branch_code
						,ass.branch_name
				
				open curr_branch
				
				fetch next from curr_branch 
				into @branch_code
					,@branch_name
				
				while @@fetch_status = 0
				begin
					--insert journal header per cabang
					set @reff_source_name = 'Sell Request for ' + @p_code
					exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @code_interface output
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code
																				   ,@p_branch_name				= @branch_name
																				   ,@p_transaction_status		= 'HOLD'
																				   ,@p_transaction_date			= @p_mod_date
																				   ,@p_transaction_value_date	= @p_mod_date
																				   ,@p_transaction_code			= @p_code
																				   ,@p_transaction_name			= 'SELL REQUEST'
																				   ,@p_reff_module_code			= 'IFINAMS'
																				   ,@p_reff_source_no			= @p_code
																				   ,@p_reff_source_name			= @reff_source_name
																				   ,@p_is_journal_reversal		= '0'
																				   ,@p_transaction_type			= ''
																				   ,@p_cre_date					= @p_mod_date
																				   ,@p_cre_by					= @p_mod_by
																				   ,@p_cre_ip_address			= @p_mod_ip_address
																				   ,@p_mod_date					= @p_mod_date
																				   ,@p_mod_by					= @p_mod_by
																				   ,@p_mod_ip_address			= @p_mod_ip_address
					--cursor permit to sell asset
					declare curr_journal cursor fast_forward read_only for 
					select	sd.id
							,sd.asset_code
					from dbo.sale_detail sd
					inner join dbo.asset ass on (ass.code = sd.asset_code)
					where	sd.sale_code = @p_code
					and ass.branch_code = @branch_code
					and		isnull(ass.is_permit_to_sell,'0') = '0'
				
					open curr_journal
				
					fetch next from curr_journal 
					into @id_detail
						,@asset_no_detail
				
					while @@fetch_status = 0
					begin
						--cursor journal detail
						declare cursor_name cursor fast_forward read_only for
						select	mt.sp_name
								,mtp.debet_or_credit
								,mtp.gl_link_code
								,mt.transaction_name
						from	dbo.master_transaction_parameter mtp
								inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
								inner join dbo.sale_detail sd on (sd.id = @id_detail)
						where	mtp.process_code = 'FASR'

						open cursor_name
					
						fetch next from cursor_name 
						into @sp_name
							,@debit_credit
							,@gl_link_code
							,@transaction_name
					
						while @@fetch_status = 0
						begin
							-- nilainya exec dari MASTER_TRANSACTION.sp_name
							exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 

							if(@return_value <> 0 )
							begin
								if (@debit_credit ='DEBIT')
								begin
									set @orig_amount_cr = 0
									set @orig_amount_db = @return_value
								END
								else
								begin
									set @orig_amount_cr = abs(@return_value)
									set @orig_amount_db = 0
								end		
							end

							set @detail_remark  = @transaction_name + ' - Branch ' + @branch_name + '. For ' + @asset_no_detail;
                            
							if(@is_permit_to_sell is null or @is_permit_to_sell = '0')
							begin
								if(@return_value > 0)
								begin
									exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @code_interface
																										  ,@p_company_code					= 'DSF'
																										  ,@p_branch_code					= @branch_code
																										  ,@p_branch_name					= @branch_name
																										  ,@p_cost_center_code				= null
																										  ,@p_cost_center_name				= null
																										  ,@p_gl_link_code					= @gl_link_code
																										  ,@p_agreement_no					= @asset_no_detail
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
																										  ,@p_remarks						= @detail_remark
																										  ,@p_cre_date						= @p_mod_date
																										  ,@p_cre_by						= @p_mod_by
																										  ,@p_cre_ip_address				= @p_mod_ip_address
																										  ,@p_mod_date						= @p_mod_date
																										  ,@p_mod_by						= @p_mod_by
																										  ,@p_mod_ip_address				= @p_mod_ip_address
								end
							end
								
						
							fetch next from cursor_name 
							into @sp_name
								,@debit_credit
								,@gl_link_code
								,@transaction_name
						end
					
						close cursor_name
						deallocate cursor_name
					
						select	@orig_amount_db		= sum(orig_amount_db) 
								,@orig_amount_cr	= sum(orig_amount_cr) 
						from  dbo.efam_interface_journal_gl_link_transaction_detail
						where gl_link_transaction_code = @code_interface

						--+ validasi : total detail =  payment_amount yang di header
						if (@orig_amount_db <> @orig_amount_cr)
						begin
							set @msg = 'Journal does not balance';
							raiserror(@msg, 16, -1) ;
						end


					    fetch next from curr_journal 
						into @id_detail
							,@asset_no_detail
					end
					
					close curr_journal
					deallocate curr_journal	
					    fetch next from curr_branch 
						into @branch_code
							,@branch_name
					end
				
				close curr_branch
				deallocate curr_branch

				--declare curr_journal cursor fast_forward read_only for 
				--select	ass.is_permit_to_sell
				--		,sd.id
				--		,ass.branch_code
				--		,ass.branch_name
				--from dbo.sale_detail sd
				--inner join dbo.asset ass on (ass.code = sd.asset_code)
				--where sd.sale_code = @p_code
				
				--open curr_journal
				
				--fetch next from curr_journal 
				--into @is_permit_to_sell
				--	,@id_detail
				--	,@branch_code
				--	,@branch_name
				
				--while @@fetch_status = 0
				--begin
				--	if(@is_permit_to_sell is null or @is_permit_to_sell = '0')
				--	begin
				--		set @reff_source_name = 'Sell Request for ' + @p_code
				--		exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @code_interface output
				--																	   ,@p_company_code				= 'DSF'
				--																	   ,@p_branch_code				= @branch_code
				--																	   ,@p_branch_name				= @branch_name
				--																	   ,@p_transaction_status		= 'HOLD'
				--																	   ,@p_transaction_date			= @p_mod_date
				--																	   ,@p_transaction_value_date	= @p_mod_date
				--																	   ,@p_transaction_code			= @p_code
				--																	   ,@p_transaction_name			= 'SELL REQUEST'
				--																	   ,@p_reff_module_code			= 'IFINAMS'
				--																	   ,@p_reff_source_no			= @p_code
				--																	   ,@p_reff_source_name			= @reff_source_name
				--																	   ,@p_is_journal_reversal		= '0'
				--																	   ,@p_transaction_type			= ''
				--																	   ,@p_cre_date					= @p_mod_date
				--																	   ,@p_cre_by					= @p_mod_by
				--																	   ,@p_cre_ip_address			= @p_mod_ip_address
				--																	   ,@p_mod_date					= @p_mod_date
				--																	   ,@p_mod_by					= @p_mod_by
				--																	   ,@p_mod_ip_address			= @p_mod_ip_address
				--	end

				--	declare cursor_name cursor fast_forward read_only for
				--	select	mt.sp_name
				--			,mtp.debet_or_credit
				--			,mtp.gl_link_code
				--			,mt.transaction_name
				--			--,sd.id
				--	from	dbo.master_transaction_parameter mtp
				--			inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
				--			inner join dbo.sale_detail sd on (sd.id = @id_detail)
				--	where	mtp.process_code = 'FASR'

				--	open cursor_name
				
				--	fetch next from cursor_name 
				--	into @sp_name
				--		,@debit_credit
				--		,@gl_link_code
				--		,@transaction_name
				--		--,@id_detail
				
				--	while @@fetch_status = 0
				--	begin
				--		-- nilainya exec dari MASTER_TRANSACTION.sp_name
				--		exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 

				--		if(@return_value <> 0 )
				--		begin
				--			if (@debit_credit ='DEBIT')
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

				--		set @detail_remark  = @transaction_name + ' - Branch ' + @branch_name ;

				--		if(@is_permit_to_sell is null or @is_permit_to_sell = '0')
				--		begin
				--			if(@return_value > 0)
				--			begin
				--				exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @code_interface
				--																					  ,@p_company_code					= 'DSF'
				--																					  ,@p_branch_code					= @branch_code
				--																					  ,@p_branch_name					= @branch_name
				--																					  ,@p_cost_center_code				= null
				--																					  ,@p_cost_center_name				= null
				--																					  ,@p_gl_link_code					= @gl_link_code
				--																					  ,@p_agreement_no					= ''
				--																					  ,@p_facility_code					= ''
				--																					  ,@p_facility_name					= ''
				--																					  ,@p_purpose_loan_code				= ''
				--																					  ,@p_purpose_loan_name				= ''
				--																					  ,@p_purpose_loan_detail_code		= ''
				--																					  ,@p_purpose_loan_detail_name		= ''
				--																					  ,@p_orig_currency_code			= 'IDR'
				--																					  ,@p_orig_amount_db				= @orig_amount_db
				--																					  ,@p_orig_amount_cr				= @orig_amount_cr
				--																					  ,@p_exch_rate						= 0
				--																					  ,@p_base_amount_db				= @orig_amount_db
				--																					  ,@p_base_amount_cr				= @orig_amount_cr
				--																					  ,@p_division_code					= ''
				--																					  ,@p_division_name					= ''
				--																					  ,@p_department_code				= ''
				--																					  ,@p_department_name				= ''
				--																					  ,@p_remarks						= @detail_remark
				--																					  ,@p_cre_date						= @p_mod_date
				--																					  ,@p_cre_by						= @p_mod_by
				--																					  ,@p_cre_ip_address				= @p_mod_ip_address
				--																					  ,@p_mod_date						= @p_mod_date
				--																					  ,@p_mod_by						= @p_mod_by
				--																					  ,@p_mod_ip_address				= @p_mod_ip_address
				--			end
				--		end
							
					
				--			fetch next from cursor_name 
				--			into @sp_name
				--				,@debit_credit
				--				,@gl_link_code
				--				,@transaction_name
				--				--,@id_detail
				--	end
				
				--	close cursor_name
				--	deallocate cursor_name
				
				--	select	@orig_amount_db		= sum(orig_amount_db) 
				--			,@orig_amount_cr	= sum(orig_amount_cr) 
				--	from  dbo.efam_interface_journal_gl_link_transaction_detail
				--	where gl_link_transaction_code = @code_interface

				--	--+ validasi : total detail =  payment_amount yang di header
				--	if (@orig_amount_db <> @orig_amount_cr)
				--	begin
				--		set @msg = 'Journal does not balance';
				--		raiserror(@msg, 16, -1) ;
				--	end


				--    fetch next from curr_journal 
				--	into @is_permit_to_sell
				--		,@id_detail
				--		,@branch_code
				--		,@branch_name
				--end
				
				--close curr_journal
				--deallocate curr_journal

				--set @reff_source_name = 'Sell Request for ' + @p_code
				--exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @code_interface output
				--															   ,@p_company_code				= 'DSF'
				--															   ,@p_branch_code				= @branch_code
				--															   ,@p_branch_name				= @branch_name
				--															   ,@p_transaction_status		= 'HOLD'
				--															   ,@p_transaction_date			= @p_mod_date
				--															   ,@p_transaction_value_date	= @p_mod_date
				--															   ,@p_transaction_code			= @p_code
				--															   ,@p_transaction_name			= 'SELL REQUEST'
				--															   ,@p_reff_module_code			= 'IFINAMS'
				--															   ,@p_reff_source_no			= @p_code
				--															   ,@p_reff_source_name			= @reff_source_name
				--															   ,@p_is_journal_reversal		= '0'
				--															   ,@p_transaction_type			= ''
				--															   ,@p_cre_date					= @p_mod_date
				--															   ,@p_cre_by					= @p_mod_by
				--															   ,@p_cre_ip_address			= @p_mod_ip_address
				--															   ,@p_mod_date					= @p_mod_date
				--															   ,@p_mod_by					= @p_mod_by
				--															   ,@p_mod_ip_address			= @p_mod_ip_address

				
				--declare cursor_name cursor fast_forward read_only for
				--select	mt.sp_name
				--		,mtp.debet_or_credit
				--		,mtp.gl_link_code
				--		,mt.transaction_name
				--		,sd.id
				--from	dbo.master_transaction_parameter mtp
				--		inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
				--		inner join dbo.sale_detail sd on (sd.sale_code = @p_code)
				--where	mtp.process_code = 'FASR'

				--open cursor_name
				
				--fetch next from cursor_name 
				--into @sp_name
				--	,@debit_credit
				--	,@gl_link_code
				--	,@transaction_name
				--	,@id_detail
				
				--while @@fetch_status = 0
				--begin
				--	-- nilainya exec dari MASTER_TRANSACTION.sp_name
				--	exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 

				--	if(@return_value <> 0 )
				--	begin
				--		if (@debit_credit ='DEBIT')
				--		begin
				--			set @orig_amount_cr = 0
				--			set @orig_amount_db = @return_value
				--		end
				--		else
				--		begin
				--			set @orig_amount_cr = abs(@return_value)
				--			set @orig_amount_db = 0
				--		end		
				--	end

				--	set @detail_remark  = @transaction_name + ' - Branch ' + @branch_name ;

				--	if(@return_value > 0)
				--	begin
				--		exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @code_interface
				--																			  ,@p_company_code					= 'DSF'
				--																			  ,@p_branch_code					= @branch_code
				--																			  ,@p_branch_name					= @branch_name
				--																			  ,@p_cost_center_code				= null
				--																			  ,@p_cost_center_name				= null
				--																			  ,@p_gl_link_code					= @gl_link_code
				--																			  ,@p_agreement_no					= ''
				--																			  ,@p_facility_code					= ''
				--																			  ,@p_facility_name					= ''
				--																			  ,@p_purpose_loan_code				= ''
				--																			  ,@p_purpose_loan_name				= ''
				--																			  ,@p_purpose_loan_detail_code		= ''
				--																			  ,@p_purpose_loan_detail_name		= ''
				--																			  ,@p_orig_currency_code			= 'IDR'
				--																			  ,@p_orig_amount_db				= @orig_amount_db
				--																			  ,@p_orig_amount_cr				= @orig_amount_cr
				--																			  ,@p_exch_rate						= 0
				--																			  ,@p_base_amount_db				= @orig_amount_db
				--																			  ,@p_base_amount_cr				= @orig_amount_cr
				--																			  ,@p_division_code					= ''
				--																			  ,@p_division_name					= ''
				--																			  ,@p_department_code				= ''
				--																			  ,@p_department_name				= ''
				--																			  ,@p_remarks						= @detail_remark
				--																			  ,@p_cre_date						= @p_mod_date
				--																			  ,@p_cre_by						= @p_mod_by
				--																			  ,@p_cre_ip_address				= @p_mod_ip_address
				--																			  ,@p_mod_date						= @p_mod_date
				--																			  ,@p_mod_by						= @p_mod_by
				--																			  ,@p_mod_ip_address				= @p_mod_ip_address
				--	end
						
				
				--    fetch next from cursor_name 
				--	into @sp_name
				--		,@debit_credit
				--		,@gl_link_code
				--		,@transaction_name
				--		,@id_detail
				--end
				
				--close cursor_name
				--deallocate cursor_name
				
				--select	@orig_amount_db		= sum(orig_amount_db) 
				--		,@orig_amount_cr	= sum(orig_amount_cr) 
				--from  dbo.efam_interface_journal_gl_link_transaction_detail
				--where gl_link_transaction_code = @code_interface

				----+ validasi : total detail =  payment_amount yang di header
				--if (@orig_amount_db <> @orig_amount_cr)
				--begin
				--	set @msg = 'Journal does not balance';
				--	raiserror(@msg, 16, -1) ;
				--end

				declare curr_sale_update cursor fast_forward read_only for
				select sld.asset_code
						,sld.sell_request_amount
						,sl.remark
				from dbo.sale sl
				inner join dbo.sale_detail sld on (sl.code = sld.sale_code)
				where sl.code = @p_code
				
				open curr_sale_update
				
				fetch next from curr_sale_update 
				into @asset_code
					,@req_amount
					,@remark
				
				while @@fetch_status = 0
				begin
				    update dbo.asset
					set		is_permit_to_sell		= '1'
							,sell_request_amount	= @req_amount
							,permit_sell_date		= @p_mod_date
							--
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code = @asset_code

					if exists (
						select	1
						from	dbo.asset 
						where	code = @asset_code 
						and		is_gps = '1'
						and		gps_status = 'SUBSCRIBE'
					)
					begin
						
						select	@id_monitoring_gps = id
						from	dbo.monitoring_gps
						where	fa_code = @asset_code
								and status = 'SUBSCRIBE'
						
						declare @p_request_no nvarchar(50);
						exec dbo.xsp_gps_unsubcribe_request_insert @p_request_no		= @p_request_no output, 
						                                           @p_id				= @id_monitoring_gps,   
						                                           @p_source_reff_name	= N'SELL REQUEST',      
						                                           @p_cre_date			= @p_mod_date,			
						                                           @p_cre_by			= @p_mod_by,            
						                                           @p_cre_ip_address	= @p_mod_ip_address,    
						                                           @p_mod_date			= @p_mod_date,			
						                                           @p_mod_by			= @p_mod_by,            
						                                           @p_mod_ip_address	= @p_mod_ip_address,
																   @p_source_reff_no	= @p_code 
																   ,@p_remarks			= @remark
						
					
					end
					
					FETCH next from curr_sale_update 
					into @asset_code
						,@req_amount
						,@remark
				end
				
				close curr_sale_update
				deallocate curr_sale_update
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
