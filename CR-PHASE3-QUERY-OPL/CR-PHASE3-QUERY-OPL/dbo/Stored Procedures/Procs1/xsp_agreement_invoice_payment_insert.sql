CREATE procedure dbo.xsp_agreement_invoice_payment_insert
(
	@p_id					   bigint output
	,@p_agreement_invoice_code nvarchar(50)
	,@p_invoice_no			   nvarchar(50)
	,@p_agreement_no		   nvarchar(50)
	,@p_asset_no			   nvarchar(50)
	,@p_transaction_no		   nvarchar(50)
	,@p_transaction_type	   nvarchar(50)
	,@p_payment_date		   datetime
	,@p_payment_amount		   decimal(18, 2)
	,@p_voucher_no			   nvarchar(50)
	,@p_description			   nvarchar(4000)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.agreement_invoice_payment
		(
			agreement_invoice_code
			,invoice_no
			,agreement_no
			,asset_no
			,transaction_no
			,transaction_type
			,payment_date
			,payment_amount
			,voucher_no
			,description
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_agreement_invoice_code
			,@p_invoice_no
			,@p_agreement_no
			,@p_asset_no
			,@p_transaction_no
			,@p_transaction_type
			,@p_payment_date
			,@p_payment_amount
			,@p_voucher_no
			,@p_description
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
