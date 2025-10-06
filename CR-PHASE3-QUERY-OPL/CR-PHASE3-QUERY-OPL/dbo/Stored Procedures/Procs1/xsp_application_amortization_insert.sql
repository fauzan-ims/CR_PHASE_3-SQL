CREATE PROCEDURE dbo.xsp_application_amortization_insert
(
	@p_application_no				 nvarchar(50)
	,@p_installment_no				 int
	,@p_due_date					 datetime
	,@p_principal_amount			 decimal(18, 2)
	,@p_installment_amount			 decimal(18, 2)
	,@p_installment_principal_amount decimal(18, 2)
	,@p_installment_interest_amount	 decimal(18, 2)
	,@p_os_principal_amount			 decimal(18, 2)
	--
	,@p_cre_date					 datetime
	,@p_cre_by						 nvarchar(15)
	,@p_cre_ip_address				 nvarchar(15)
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_amortization
		(
			application_no
			,installment_no
			,due_date
			--,principal_amount
			--,installment_amount
			--,installment_principal_amount
			--,installment_interest_amount
			--,os_principal_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_installment_no
			,@p_due_date
			--,@p_principal_amount
			--,@p_installment_amount
			--,@p_installment_principal_amount
			--,@p_installment_interest_amount
			--,@p_os_principal_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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


