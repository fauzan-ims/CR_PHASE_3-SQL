	/*
	 exec dbo.xsp_agreement_information_update @p_agreement_no = N'' -- nvarchar(50)
 											  ,@p_mod_date = '2023-02-27 15:18:53' -- datetime
 											  ,@p_mod_by = N'' -- nvarchar(15)
 											  ,@p_mod_ip_address = N'' -- nvarchar(15)
	 */
 
	 -- Louis Handry 27/02/2023 22:16:31 -- 
	 CREATE PROCEDURE [dbo].[xsp_agreement_information_update]
	 (
 		@p_agreement_no	   nvarchar(50)
 		--
 		,@p_mod_date	   datetime
 		,@p_mod_by		   nvarchar(15)
 		,@p_mod_ip_address nvarchar(15)
	 )
	 as
	 begin
 		declare @msg							nvarchar(max) 
 				,@last_paid_period				int
 				,@last_payment_installment_date datetime
 				,@next_due_date					datetime
 				,@os_rental_amount				decimal(18, 2)
 				,@os_deposit_installment_amount decimal(18, 2)
 				,@os_period						int
 				,@installment_due_date			datetime
 				,@ovd_period					int
 				,@ovd_days						int
 				,@ovd_rental_amount				decimal(18, 2)
 				,@ovd_penalty_amount			decimal(18, 2)
 				,@last_payment_obligation_date	datetime 
				,@current_installment_no		int = 0
 				,@lra_days						int
 				,@lra_penalty_amount			decimal(18, 2)
 
 		begin try 
 			-- ambil overdue 
 			set @ovd_period = dbo.xfn_agreement_get_ovd_periode(@p_agreement_no) ;
 			set @ovd_days = dbo.xfn_agreement_get_ovd_days(@p_agreement_no) ;
 			set @ovd_rental_amount = dbo.xfn_agreement_get_ovd_rental_amount(@p_agreement_no, null) ;
		
			set @lra_days = dbo.xfn_agreement_get_lra_days(@p_agreement_no)
			set @lra_penalty_amount = dbo.xfn_agreement_get_lra_penalty_amount(@p_agreement_no)
  
 			-- ambil last_payment_installment_date & max_billing_no
 			select	@last_payment_installment_date = max(aip.payment_date)
 					,@last_paid_period = max(ivd.billing_no)
 					,@current_installment_no = max(ai.billing_no)
 			from	 dbo.agreement_invoice ai
					left join dbo.agreement_invoice_payment aip on (aip.agreement_invoice_code = ai.code)
 					inner join dbo.invoice_detail ivd on (
 															 ivd.agreement_no	  = ai.agreement_no
 															 and   ivd.invoice_no = ai.invoice_no
 															 and   ivd.asset_no	  = ai.asset_no
 														 )
 			where	ai.agreement_no = @p_agreement_no;
 		 
 			-- ambil  next_due_date, total_billing_amount & total_billing_no 
 			select	top 1 @next_due_date = min(due_date)
 					,@os_rental_amount = sum(billing_amount)
 					,@os_period = count(distinct billing_no)
 			from	agreement_asset_amortization aaa
					left join dbo.invoice inv on inv.invoice_no = aaa.invoice_no
 			where	agreement_no = @p_agreement_no
 			and		(isnull(aaa.invoice_no, '') = '' or isnull(inv.invoice_status,'') <> 'PAID')
 
 			-- ambil installment_due_date
 			set @installment_due_date = dbo.xfn_agreement_get_installment_due_date(@p_agreement_no) ;
 
 			-- ambil nilai deposit
 			select	@os_deposit_installment_amount = deposit_amount
 			from	agreement_deposit_main
 			where	deposit_type	 = 'INSTALLMENT'
 					and agreement_no = @p_agreement_no ;
 
 			--  ambil nilai obligation 
 			select	@ovd_penalty_amount = isnull(sum(ao.obligation_amount), 0) - sum(isnull(aop.payment_amount, 0))
 			from	agreement_obligation ao
 					outer apply
 			(
 				select	sum(payment_amount) 'payment_amount'
 				from	agreement_obligation_payment aop
 				where	aop.agreement_no   = ao.agreement_no
 						and aop.invoice_no = ao.invoice_no
 						and aop.asset_no   = ao.asset_no
 			) aop
 			where	agreement_no = @p_agreement_no ;
			 
 			select	@last_payment_obligation_date = max(payment_date)
 			from	dbo.agreement_obligation_payment
 			where	agreement_no = @p_agreement_no 
					and payment_source_type <> 'INVOICE CANCEL'
 
 			update	agreement_information
 			set		ovd_period						= isnull(@ovd_period, 0)
 					,ovd_days						= isnull(@ovd_days, 0)
 					,max_ovd_days					= case
 												  		 when isnull(max_ovd_days, 0) < @ovd_days then @ovd_days
 												  		 else isnull(max_ovd_days, 0)
 													  end 
 					,ovd_rental_amount				= isnull(@ovd_rental_amount, 0)
 					,last_payment_installment_date	= @last_payment_installment_date
 					,last_paid_period				= isnull(@last_paid_period, 0)
 					,next_due_date					= @next_due_date
 					,os_rental_amount				= isnull(@os_rental_amount, 0)
 					,installment_due_date			= @installment_due_date
 					,os_deposit_installment_amount	= isnull(@os_deposit_installment_amount, 0)
 					,os_period						= @os_period
 					,ovd_penalty_amount				= isnull(@ovd_penalty_amount, 0)
 					,last_payment_obligation_date	= @last_payment_obligation_date
					,current_installment_no			= @current_installment_no
					,lra_days						= @lra_days
					,lra_penalty_amount				= @lra_penalty_amount
 					--
 					,mod_date						= @p_mod_date
 					,mod_by							= @p_mod_by
 					,mod_ip_address					= @p_mod_ip_address
 			where	agreement_no					= @p_agreement_no ;  
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
 
 
 
 
