CREATE PROCEDURE dbo.xsp_fin_interface_agreement_amortization_payment_update
(
	@p_id					bigint
	,@p_agreement_no		nvarchar(50)
	,@p_installment_no		int
	,@p_payment_date		datetime
	,@p_value_date			datetime
	,@p_payment_source_type nvarchar(3)
	,@p_payment_source_no	nvarchar(50)
	,@p_payment_amount		decimal(18, 2)
	,@p_principal_amount	decimal(18, 2)
	,@p_interest_amount		decimal(18, 2)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	fin_interface_agreement_amortization_payment
		set		agreement_no			= @p_agreement_no
				,installment_no			= @p_installment_no
				,payment_date			= @p_payment_date
				,value_date				= @p_value_date
				,payment_source_type	= @p_payment_source_type
				,payment_source_no		= @p_payment_source_no
				,payment_amount			= @p_payment_amount
				,principal_amount		= @p_principal_amount
				,interest_amount		= @p_interest_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
