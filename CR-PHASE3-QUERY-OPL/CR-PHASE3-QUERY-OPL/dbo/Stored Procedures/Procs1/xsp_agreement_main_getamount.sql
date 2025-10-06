CREATE PROCEDURE [dbo].[xsp_agreement_main_getamount]
(
	@p_agreement_no		   nvarchar(50)
	,@p_reff_no			   nvarchar(50)
	,@p_transaction_type   nvarchar(10)
	,@p_transaction_code   nvarchar(50)
	,@p_date			   datetime
	,@p_transaction_amount decimal(18, 2) output
)
as
begin
	declare @result_amount decimal(18, 2)
			,@msg		   nvarchar(max) ;
			
	begin try
		if (@p_transaction_type = 'ET')
		begin
			if (@p_transaction_code = 'ETOLAR')
			begin
				exec @result_amount = dbo.xfn_et_get_invoice_ar_amount @p_reff_no = @p_reff_no
																	   ,@p_agreement_no = @p_agreement_no
																	   ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'CETA')
			begin
				exec @result_amount = dbo.xfn_agreement_get_et_admin @p_reff_no = @p_reff_no
																	 ,@p_agreement_no = @p_agreement_no
																	 ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'CETP')
			begin
				exec @result_amount = dbo.xfn_agreement_get_et_penalty @p_reff_no = @p_reff_no
																	   ,@p_agreement_no = @p_agreement_no
																	   ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETDPS_INST')
			begin
				exec @result_amount = dbo.xfn_agreement_get_deposit_installment @p_agreement_no
																				,@p_date ;
			end ;
			else if (@p_transaction_code = 'ETOLINV')
			begin
				exec @result_amount = dbo.xfn_et_get_invoice_amount @p_reff_no = @p_reff_no
																	,@p_agreement_no = @p_agreement_no
																	,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOLIVIC')
			begin
				exec @result_amount = dbo.xfn_et_get_total_billing_amount @p_reff_no = @p_reff_no
																		  ,@p_agreement_no = @p_agreement_no
																		  ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOLPPH')
			begin
				exec @result_amount = dbo.xfn_et_get_ol_pph @p_reff_no = @p_reff_no
															,@p_agreement_no = @p_agreement_no
															,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOS_DEFF')
			begin
				exec @result_amount = dbo.xfn_et_get_os_interest @p_reff_no = @p_reff_no
																 ,@p_agreement_no = @p_agreement_no
																 ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOS_INTER')
			begin
				exec @result_amount = dbo.xfn_et_get_os_interest @p_reff_no = @p_reff_no
																 ,@p_agreement_no = @p_agreement_no
																 ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOS_INST')
			begin
				exec @result_amount = dbo.xfn_et_get_os_installment @p_reff_no = @p_reff_no
																	,@p_agreement_no = @p_agreement_no
																	,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ETOVD_PNLTY')
			begin
				exec @result_amount = dbo.xfn_et_get_ovd_penalty @p_reff_no = @p_reff_no
																 ,@p_agreement_no = @p_agreement_no
																 ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ET_RV')
			begin
				exec @result_amount = dbo.xfn_et_get_rv_amount @p_reff_no = @p_reff_no
															   ,@p_agreement_no = @p_agreement_no
															   ,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ET_ASWVAT')
			begin
				exec @result_amount = dbo.xfn_et_get_asset_with_vat @p_reff_no = @p_reff_no
																	,@p_agreement_no = @p_agreement_no
																	,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'ET_INTERIM')
			begin
				exec @result_amount = dbo.xfn_et_get_interim_rental @p_reff_no = @p_reff_no
																	,@p_agreement_no = @p_agreement_no
																	,@p_date = @p_date ;
			end ;
			else if (@p_transaction_code = 'CETPP')
			begin
				exec @result_amount = dbo.xfn_agreement_get_et_penalty_progressive @p_reff_no = @p_reff_no
																	,@p_agreement_no = @p_agreement_no
																	,@p_date = @p_date ;
			end ;
		end ;
		else
		begin
			if (@p_transaction_code = 'OLAR')
			begin
				exec @result_amount = dbo.xfn_agreement_get_ol_ar @p_agreement_no
																  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OS_INST')
			begin
				exec @result_amount = dbo.xfn_agreement_get_invoice_ar_amount @p_agreement_no
																			  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OS_PRINC')
			begin
				exec @result_amount = dbo.xfn_agreement_get_os_principal @p_agreement_no
																		 ,@p_date ;
			end ;
			else if (@p_transaction_code = 'DPS_INST')
			begin
				exec @result_amount = dbo.xfn_agreement_get_deposit_installment @p_agreement_no
																				,@p_date ;
			end ;
			else if (@p_transaction_code = 'DPS_OTHR')
			begin
				exec @result_amount = dbo.xfn_agreement_get_deposit_other @p_agreement_no
																		  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OVD_PNLTY')
			begin
				exec @result_amount = dbo.xfn_agreement_get_ovd_penalty @p_agreement_no
																		,@p_date ;
			end ;
			else if (@p_transaction_code = 'WOAMT')
			begin
				exec @result_amount = dbo.xfn_agreement_get_wo_amount @p_agreement_no
																	  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLPPH')
			begin
				exec @result_amount = dbo.xfn_agreement_get_ol_pph @p_agreement_no
																   ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLPH')
			begin
				exec @result_amount = dbo.xfn_agreement_get_total_billing_amount @p_agreement_no
																				 ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLIVIC')
			begin
				exec @result_amount = dbo.xfn_agreement_get_total_billing_amount @p_agreement_no
																				 ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLIVICA')
			begin
				exec @result_amount = dbo.xfn_agreement_get_total_billing_amount @p_agreement_no
																				 ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLWOA')
			begin
				exec @result_amount = dbo.xfn_agreement_get_wo_amount @p_agreement_no
																	  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'AROLWOA')
			begin
				exec @result_amount = dbo.xfn_agreement_get_wo_amount @p_agreement_no
																	  ,@p_date ;
			end ;
			else if (@p_transaction_code = 'OS_INTER')
			begin
				exec @result_amount = dbo.xfn_agreement_get_os_interest @p_agreement_no
																		,@p_date ;
			end ;
			else if (@p_transaction_code = 'OS_DEFF')
			begin
				exec @result_amount = dbo.xfn_agreement_get_os_interest @p_agreement_no
																		,@p_date ;
			end ;
			else if (@p_transaction_code = 'OLINV')
			begin
				exec @result_amount = dbo.xfn_agreement_get_invoice_amount @p_agreement_no
																		   ,@p_date ;
			end ;
		end ;

		set @p_transaction_amount = isnull(@result_amount, 0) ;
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
