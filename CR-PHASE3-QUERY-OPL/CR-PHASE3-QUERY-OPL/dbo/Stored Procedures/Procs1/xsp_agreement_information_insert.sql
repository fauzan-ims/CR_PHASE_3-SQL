create PROCEDURE dbo.xsp_agreement_information_insert
(
	@p_agreement_no						nvarchar(50)	
	,@p_deskcoll_staff_code				nvarchar(50)	
	,@p_deskcoll_staff_name				nvarchar(250)	
	,@p_installment_amount				decimal(18, 2)	
	,@p_installment_due_date			datetime	
	,@p_next_due_date					datetime	
	,@p_last_paid_period				int	
	,@p_ovd_period						int	
	,@p_ovd_days						int	
	,@p_ovd_rental_amount				decimal(18, 2)	
	,@p_ovd_penalty_amount				decimal(18, 2)	
	,@p_os_rental_amount				decimal(18, 2)	
	,@p_os_deposit_installment_amount	decimal(18, 2)	
	,@p_os_period						int	
	,@p_last_payment_installment_date	datetime	
	,@p_last_payment_obligation_date	datetime	
	,@p_payment_promise_date			datetime	
	,@p_cre_date						datetime	
	,@p_cre_by							nvarchar(15)	
	,@p_cre_ip_address					nvarchar(15)	
	,@p_mod_date						datetime	
	,@p_mod_by							nvarchar(15)	
	,@p_mod_ip_address					nvarchar(15)	
			
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.agreement_information
		(
			agreement_no
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
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_agreement_no						
			,@p_deskcoll_staff_code				
			,@p_deskcoll_staff_name				
			,@p_installment_amount				
			,@p_installment_due_date			
			,@p_next_due_date					
			,@p_last_paid_period				
			,@p_ovd_period						
			,@p_ovd_days						
			,@p_ovd_rental_amount				
			,@p_ovd_penalty_amount				
			,@p_os_rental_amount				
			,@p_os_deposit_installment_amount	
			,@p_os_period						
			,@p_last_payment_installment_date	
			,@p_last_payment_obligation_date	
			,@p_payment_promise_date			
			,@p_cre_date						
			,@p_cre_by							
			,@p_cre_ip_address					
			,@p_mod_date						
			,@p_mod_by							
			,@p_mod_ip_address					
		);
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
