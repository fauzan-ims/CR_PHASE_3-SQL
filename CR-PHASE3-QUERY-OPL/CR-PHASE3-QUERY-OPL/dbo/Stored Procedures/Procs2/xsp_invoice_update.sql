CREATE PROCEDURE dbo.xsp_invoice_update
(
	@p_invoice_no					nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_invoice_type				nvarchar(10)
	,@p_invoice_date				datetime
	,@p_invoice_due_date			datetime
	,@p_invoice_name				nvarchar(250)
	,@p_invoice_status				nvarchar(10)
	,@p_client_no					nvarchar(50)
	,@p_client_name					nvarchar(250)
	,@p_client_address				nvarchar(4000)
	,@p_client_province_name		nvarchar(250)
	,@p_client_city_name			nvarchar(250)
	,@p_client_zip_code				nvarchar(50)
	,@p_client_village				nvarchar(250)
	,@p_client_rt					nvarchar(5)
	,@p_client_rw					nvarchar(5)
	,@p_client_area_phone_no		nvarchar(4)
	,@p_client_phone_no				nvarchar(15)
	,@p_client_npwp					nvarchar(50)
	,@p_currency_code				nvarchar(3)
	,@p_total_billing_amount		decimal(18, 2)
	,@p_total_discount_amount		decimal(18, 2)
	,@p_total_ppn_amount			int
	,@p_total_pph_amount			int
	,@p_total_amount				decimal(18, 2)
	,@p_faktur_no					nvarchar(50)
	,@p_generate_code				nvarchar(50)
	,@p_scheme_code					nvarchar(50)
	,@p_received_reff_no			nvarchar(50)
	,@p_received_reff_date			nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		update	invoice
		set		branch_code				= @p_branch_code			
				,branch_name			= @p_branch_name			
				,invoice_type			= @p_invoice_type
				,invoice_date			= @p_invoice_date
				,invoice_due_date		= @p_invoice_due_date
				,invoice_name			= @p_invoice_name
				,invoice_status			= @p_invoice_status
				,client_no				= @p_client_no
				,client_name			= @p_client_name
				,client_address			= @p_client_address
				,client_area_phone_no	= @p_client_area_phone_no
				,client_phone_no		= @p_client_phone_no
				,client_npwp			= @p_client_npwp
				,currency_code			= @p_currency_code
				,total_billing_amount	= @p_total_billing_amount
				,total_discount_amount	= @p_total_discount_amount
				,total_ppn_amount		= @p_total_ppn_amount
				,total_pph_amount		= @p_total_pph_amount
				,total_amount			= @p_total_amount
				,faktur_no				= @p_faktur_no
				,generate_code			= @p_generate_code
				,scheme_code			= @p_scheme_code
				,received_reff_no		= @p_received_reff_no
				,received_reff_date		= @p_received_reff_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	invoice_no				= @p_invoice_no ;

	end try
	Begin catch
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
