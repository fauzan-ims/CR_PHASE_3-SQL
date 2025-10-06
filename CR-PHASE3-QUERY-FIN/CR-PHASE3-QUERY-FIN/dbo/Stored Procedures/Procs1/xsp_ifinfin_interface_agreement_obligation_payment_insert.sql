CREATE PROCEDURE dbo.xsp_ifinfin_interface_agreement_obligation_payment_insert
(
	@p_id					bigint = 0 output
	,@p_obligation_code		nvarchar(50)
	,@p_agreement_no		nvarchar(50)
	,@p_installment_no		int
	,@p_payment_date		datetime
	,@p_value_date			datetime
	,@p_payment_source_type nvarchar(10)
	,@p_payment_source_no	nvarchar(50)
	,@p_payment_amount		decimal(18, 2)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into ifinfin_interface_agreement_obligation_payment
		(
			obligation_code
			,agreement_no
			,installment_no
			,payment_date
			,value_date
			,payment_source_type
			,payment_source_no
			,payment_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_obligation_code
			,@p_agreement_no
			,@p_installment_no
			,@p_payment_date
			,@p_value_date
			,@p_payment_source_type
			,@p_payment_source_no
			,@p_payment_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
