-- Louis Kamis, 27 April 2023 14.04.27 --
CREATE procedure dbo.xsp_opl_interface_agreement_update_out_insert
(
	@p_agreement_no	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		begin
			insert into dbo.opl_interface_agreement_update_out
			(
				agreement_no
				,agreement_status
				,agreement_sub_status
				,termination_date
				,termination_status
				,client_no
				,client_name
				,next_due_date
				,last_paid_period
				,last_installment_due_date
				,overdue_period
				,overdue_days
				,outstanding_deposit_amount
				,tenor
				,overdue_penalty_amount
				,overdue_installment_amount
				,outstanding_installment_amount
				,is_wo
				,os_principal_amount
				,os_interest_amount
				,os_tenor
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	am.agreement_no
					,agreement_status
					,agreement_sub_status
					,termination_date
					,termination_status
					,client_no
					,client_name
					,ai.next_due_date
					,isnull(ai.last_paid_period, 0)
					,ai.last_payment_installment_date
					,isnull(ai.ovd_period, 0)
					,isnull(ai.ovd_days, 0)
					,isnull(ai.os_deposit_installment_amount, 0)
					,am.periode
					,isnull(ai.ovd_penalty_amount, 0)
					,isnull(ai.ovd_rental_amount, 0)
					,isnull(ai.os_rental_amount, 0)
					,case am.agreement_sub_status
						 when 'WO' then '1'
						 else '0'
					 end
					,isnull(ai.os_rental_amount, 0)
					,0
					,ai.os_period
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.agreement_main am
					left join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
			where	am.agreement_no = @p_agreement_no ;
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
