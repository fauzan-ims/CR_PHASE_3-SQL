/*
exec xsp_job_eod_agreement_aging
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
CREATE PROCEDURE dbo.xsp_job_eod_agreement_aging
as
begin
	declare @msg			 nvarchar(max)
			,@move_date		 datetime	  = dateadd(day, -62, dbo.xfn_get_system_date())
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = 'SYSTEM' ;

	begin try
		begin
			-- move data aging yang date nya h-62 ke history
			insert into dbo.agreement_aging_history
			(
				agreement_no
				,aging_date
				,branch_code
				,branch_name
				,client_no
				,client_name
				,agreement_status
				,agreement_sub_status
				,deskcoll_staff_code
				,deskcoll_staff_name
				,installment_amount
				,installment_due_date
				,next_due_date
				,last_paid_period
				,ovd_period
				,ovd_days
				,ovd_rental_amount
				,ovd_penalty_amount
				,os_rental_amount
				,os_deposit_installment_amount
				,os_period
				,last_payment_installment_date
				,last_payment_obligation_date
				,payment_promise_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	agreement_no
					,aging_date
					,branch_code
					,branch_name
					,client_no
					,client_name
					,agreement_status
					,agreement_sub_status
					,deskcoll_staff_code
					,deskcoll_staff_name
					,installment_amount
					,installment_due_date
					,next_due_date
					,last_paid_period
					,ovd_period
					,ovd_days
					,ovd_rental_amount
					,ovd_penalty_amount
					,os_rental_amount
					,os_deposit_installment_amount
					,os_period
					,last_payment_installment_date
					,last_payment_obligation_date
					,payment_promise_date
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	agreement_aging
			where	aging_date = @move_date ;

			-- hapus data di h-62 (sepria 28-05-2025)
			delete	 agreement_aging  where	aging_date = @move_date ;

			insert into dbo.agreement_aging
			(
				agreement_no
				,aging_date
				,branch_code
				,branch_name
				,client_no
				,client_name
				,agreement_status
				,agreement_sub_status
				,deskcoll_staff_code
				,deskcoll_staff_name
				,installment_amount
				,installment_due_date
				,next_due_date
				,last_paid_period
				,ovd_period
				,ovd_days
				,ovd_rental_amount
				,ovd_penalty_amount
				,os_rental_amount
				,os_deposit_installment_amount
				,os_period
				,last_payment_installment_date
				,last_payment_obligation_date
				,payment_promise_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	am.agreement_no
					,dbo.xfn_get_system_date()
					,am.branch_code
					,am.branch_name
					,am.client_no
					,am.client_name
					,am.agreement_status
					,am.agreement_sub_status
					,ai.deskcoll_staff_code
					,ai.deskcoll_staff_name
					,ai.installment_amount
					,ai.installment_due_date
					,ai.next_due_date
					,ai.last_paid_period
					,ai.ovd_period
					,ai.ovd_days
					,ai.ovd_rental_amount
					,ai.ovd_penalty_amount
					,ai.os_rental_amount
					,ai.os_deposit_installment_amount
					,ai.os_period
					,ai.last_payment_installment_date
					,ai.last_payment_obligation_date
					,ai.payment_promise_date
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.agreement_main am
					inner join dbo.agreement_information ai on (ai.agreement_no		   = am.agreement_no)
															   and am.agreement_status = 'GO LIVE' ;
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
