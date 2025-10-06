CREATE PROCEDURE [dbo].[xsp_et_main_paid]
(
	@p_code			   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_value_date	   datetime
	,@p_payment_date   datetime
	,@p_exch_rate	   decimal(18, 6) = 1
	,@p_invoice_type   nvarchar(10)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@no						int = 1
			,@count_asset				int
			,@billing_no				int
			,@discount_amount			decimal(18, 2)
			,@discount_per_asset_amount decimal(18, 2)
			,@asset_no					nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@obligation_type			nvarchar(50)
			,@currency					nvarchar(3)
			,@penalty_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@total_deposit_amount		decimal(18, 2) = 0
			,@obligation_paid_amount	decimal(18, 2) = 0
			,@et_amount					decimal(18, 2)
			,@et_remarks				nvarchar(4000) ;

	begin try
		begin  
			select	@branch_code	= branch_code
					,@branch_name	= branch_name 
					,@et_amount		= et_amount
			from	dbo.et_main 
			where	code = @p_code

			-- settlement obligation
			begin 
				if (@p_invoice_type = 'PENALTY')
				begin 
					
					select	@discount_amount = disc_amount
					from	dbo.et_transaction
					where	et_code				 = @p_code
							and transaction_code = 'CETP' ;

					select	@count_asset = count(1)
					from	dbo.et_detail
					where	et_code			 = @p_code
							and is_terminate = '1' ;
							
					if (@count_asset > 1)
					begin
						set @discount_per_asset_amount = floor(@discount_amount / @count_asset)
					end
					else
					begin
						set @discount_per_asset_amount = @discount_amount
					end
									
					declare curretdetail cursor fast_forward read_only for
					select	asset_no
					from	dbo.et_detail
					where	et_code			 = @p_code
							and is_terminate = '1' ;

					open curretdetail ;

					fetch next from curretdetail
					into @asset_no ;

					while @@fetch_status = 0
					begin 
					
						set @billing_no = dbo.xfn_asset_get_installment_no(@asset_no)

						-- jika asset terakhir discount per asset diisi dengan sisa discount yang belum terpakai
						if (@no = @count_asset)
						begin
							set @discount_per_asset_amount = @discount_amount - (@discount_per_asset_amount * (@count_asset - 1))
						end ; 
						 
						set @penalty_amount = dbo.xfn_agreement_get_et_penalty_by_asset(@asset_no, @p_agreement_no, @p_value_date) - @discount_per_asset_amount ;
						
						if (@penalty_amount > 0)
						begin 
							exec dbo.xsp_agreement_obligation_insert @p_code					= 0
																		,@p_agreement_no		= @p_agreement_no
																		,@p_asset_no		    = @asset_no	
																		,@p_invoice_no		    = ''
																		,@p_installment_no		= @billing_no
																		,@p_obligation_day		= 0
																		,@p_obligation_date		= @p_value_date
																		,@p_obligation_type		= 'CETP'
																		,@p_obligation_name		= 'ET PENALTY CHARGES'
																		,@p_obligation_reff_no	= 'EOD'
																		,@p_obligation_amount	= @penalty_amount
																		,@p_remarks				= N'ET PENALTY'
																		,@p_cre_date			= @p_mod_date	   
																		,@p_cre_by				= @p_mod_by		   
																		,@p_cre_ip_address		= @p_mod_ip_address 
																		,@p_mod_date			= @p_mod_date
																		,@p_mod_by				= @p_mod_by
																		,@p_mod_ip_address		= @p_mod_ip_address
						end
					
						set @penalty_amount = 0 
						set @billing_no = 0

						set @no = @no + 1

						fetch next from curretdetail
						into @asset_no ;
					end ;

					close curretdetail ;
					deallocate curretdetail ; 
				end
			end ;

			--update agreement & asset
			begin 
				 
				if not exists(select 1 from dbo.et_detail where et_code = @p_code and is_terminate = '0')
				begin 
					update	dbo.agreement_main
					set		termination_date	  = @p_value_date
							,termination_status   = 'ET'
							,agreement_status	  = 'TERMINATE'
							,agreement_sub_status = 'INCOMPLETE'
							--
							,mod_date			  = @p_mod_date
							,mod_by				  = @p_mod_by
							,mod_ip_address		  = @p_mod_ip_address
					where	agreement_no		  = @p_agreement_no ;

					exec dbo.xsp_agreement_main_update_terminate_status @p_agreement_no			= @p_agreement_no
																		,@p_termination_date	= @p_value_date
																		,@p_mod_date			= @p_mod_date
																		,@p_mod_by				= @p_mod_by
																		,@p_mod_ip_address		= @p_mod_ip_address
					
					
					set @et_remarks = 'EARLY TERMINATION FULL'
				end ;
				else
				begin
					set @et_remarks = 'EARLY TERMINATION PARTIAL'
				end

				update	dbo.agreement_asset
				set		asset_status	= 'TERMINATE'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	asset_no in
						(
							select	asset_no
							from	dbo.et_detail
							where	et_code			 = @p_code
									and is_terminate = '1'
						) ;

				 -- Louis Rabu, 18 Januari 2023 10.07.21 --
				-- insert to handover with Status : TAKING UP
				exec dbo.xsp_et_main_to_handover_asset_insert @p_code				= @p_code
															  ,@p_agreement_no		= @p_agreement_no
															  ,@p_et_date			= @p_value_date
															  --
															  ,@p_cre_date			= @p_mod_date
															  ,@p_cre_by			= @p_mod_by
															  ,@p_cre_ip_address	= @p_mod_ip_address
															  ,@p_mod_date			= @p_mod_date
															  ,@p_mod_by			= @p_mod_by
															  ,@p_mod_ip_address	= @p_mod_ip_address
				
				
			end

			--- insert penggunaan deposit
			if exists
			(
				select	1
				from	dbo.et_transaction et
				where	et_code					= @p_code
						and et.transaction_code = 'DPS_INST'
						and et.total_amount		< 0
			)
			begin
				select	@total_deposit_amount = isnull(et.total_amount, 0)
				from	dbo.et_transaction et
				where	et_code					= @p_code
						and et.transaction_code = 'DPS_INST' ;
	
				
				select	@branch_code = am.branch_code
						,@branch_name = am.branch_name
						,@currency = am.currency_code
				from	dbo.et_main em
						inner join dbo.agreement_main am on (am.agreement_no = em.agreement_no)
				where	code = @p_code ;

				set @p_exch_rate = 1 ;
				set @base_amount = @total_deposit_amount * @p_exch_rate ;
				
				exec dbo.xsp_agreement_deposit_allocation @p_branch_code		 = @branch_code		 
														  ,@p_branch_name		 = @branch_name		 
														  ,@p_agreement_no		 = @p_agreement_no		 
														  ,@p_deposit_type		 = @obligation_type		 
														  ,@p_transaction_date	 = @p_value_date	 
														  ,@p_orig_amount		 = @total_deposit_amount		 
														  ,@p_currency			 = @currency			 
														  ,@p_exch_rate			 = @p_exch_rate			 
														  ,@p_base_amount		 = @base_amount		 
														  ,@p_deposit_amount	 = @total_deposit_amount	 
														  ,@p_source_reff_module = N'IFINOPL'
														  ,@p_source_reff_code	 = @p_code
														  ,@p_source_reff_name	 = 'EARLY TERMINATION'
														  --
														  ,@p_cre_date			 = @p_mod_date		
														  ,@p_cre_by			 = @p_mod_by			
														  ,@p_cre_ip_address	 = @p_mod_ip_address
														  ,@p_mod_date			 = @p_mod_date		
														  ,@p_mod_by			 = @p_mod_by			
														  ,@p_mod_ip_address	 = @p_mod_ip_address
			end ;

			--if (@et_amount <= 0) --melakukan function ini jika deposit > dari nilai et
			--begin
			--	exec dbo.xsp_et_main_journal @p_reff_name		= 'EARLY TERMINATION'
			--								 ,@p_reff_code		= @p_code
			--								 ,@p_value_date		= @p_value_date
			--								 ,@p_trx_date		= @p_payment_date
			--								 ,@p_mod_date		= @p_mod_date
			--								 ,@p_mod_by			= @p_mod_by
			--								 ,@p_mod_ip_address = @p_mod_ip_address ;
			--end ;

			--update	dbo.et_main
			--set		et_status		= 'PAID'
			--		--
			--		,mod_date		= @p_mod_date
			--		,mod_by			= @p_mod_by
			--		,mod_ip_address = @p_mod_ip_address
			--where	code			= @p_code ; 

			exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @p_agreement_no
																   ,@p_mod_date			= @p_mod_date
																   ,@p_mod_by			= @p_mod_by
																   ,@p_mod_ip_address	= @p_mod_ip_address 
			
			 
			exec dbo.xsp_agreement_log_insert @p_agreement_no		= @p_agreement_no
											  ,@p_asset_no			= null
											  ,@p_log_source_no		= @p_code
											  ,@p_log_date			= @p_value_date
											  ,@p_log_remarks		= @et_remarks
											  ,@p_cre_date			= @p_mod_date
											  ,@p_cre_by			= @p_mod_by
											  ,@p_cre_ip_address	= @p_mod_ip_address
											  ,@p_mod_date			= @p_mod_date
											  ,@p_mod_by			= @p_mod_by
											  ,@p_mod_ip_address	= @p_mod_ip_address 
		end ;
	end try
	Begin catch
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





