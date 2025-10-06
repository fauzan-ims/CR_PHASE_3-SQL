CREATE PROCEDURE dbo.xsp_ap_payment_request_detail_insert
(
	@p_id						bigint = 0 output
	,@p_company_code			nvarchar(50)
	,@p_payment_request_code	nvarchar(50)
	,@p_invoice_register_code	nvarchar(50)
	,@p_payment_amount			decimal(18, 2)
	,@p_is_paid					nvarchar(1)
	,@p_ppn						decimal(18, 2)
	,@p_pph						decimal(18, 2)
	,@p_fee						decimal(18, 2)
	,@p_discount				decimal(18,2)
	,@p_unit_price				decimal(18,2)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	begin try
		insert into ap_payment_request_detail
		(
			payment_request_code
			,company_code
			,invoice_register_code
			,payment_amount
			,is_paid
			,ppn
			,pph
			,fee
			,discount
			,unit_price
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_payment_request_code
			,@p_company_code
			,@p_invoice_register_code
			,@p_payment_amount
			,@p_is_paid
			,@p_ppn
			,@p_pph
			,@p_fee
			,@p_discount
			,@p_unit_price
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
