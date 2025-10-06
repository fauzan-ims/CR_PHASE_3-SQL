CREATE PROCEDURE dbo.xsp_additional_invoice_update
(
	@p_code							nvarchar(50)
	,@p_invoice_type				nvarchar(10)
	,@p_invoice_date				datetime
	,@p_invoice_due_date			datetime
	,@p_invoice_name				nvarchar(250)
	,@p_invoice_status				nvarchar(10)
	,@p_client_no					nvarchar(50)
	,@p_client_name					nvarchar(250)	= ''
	,@p_client_address				nvarchar(4000)  = ''
	,@p_client_area_phone_no		nvarchar(4)	    = ''
	,@p_client_phone_no				nvarchar(15)    = ''
	,@p_client_npwp					nvarchar(50)	= ''
	,@p_currency_code				nvarchar(3)		= ''
	,@p_total_billing_amount		decimal(18, 2)	= 0
	,@p_total_discount_amount		decimal(18, 2)	= 0
	,@p_total_ppn_amount			int	= 0
	,@p_total_pph_amount			int	= 0
	,@p_total_amount				decimal(18, 2)	= 0
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		--ditutup sementara untuk backdate 
		--begin
			--validasi jika tanggal date lebih kecil dari sistem date
			--if (@p_invoice_date < dbo.xfn_get_system_date())
			--begin
			--	set	@msg = 'Date must be greater than System Date'
			--	raiserror(@msg, 16, -1)
			--end

			----validasi jika tanggal due date lebih kecil dari sistem date
			--if (@p_invoice_due_date < dbo.xfn_get_system_date())
			--begin
			--	set	@msg = 'Due Date must be greater than System Date'
			--	raiserror(@msg, 16, -1)
			--end
		--end
        

		update	additional_invoice
		set		invoice_type				= @p_invoice_type
				,invoice_date				= @p_invoice_date
				,invoice_due_date			= @p_invoice_due_date
				,invoice_name				= @p_invoice_name
				,invoice_status				= @p_invoice_status
				,client_no					= @p_client_no
				,client_name				= @p_client_name
				,client_address				= @p_client_address
				,client_area_phone_no		= @p_client_area_phone_no
				,client_phone_no			= @p_client_phone_no
				,client_npwp				= @p_client_npwp
				,currency_code				= @p_currency_code
				,total_billing_amount		= @p_total_billing_amount
				,total_discount_amount		= @p_total_discount_amount
				,total_ppn_amount			= @p_total_ppn_amount
				,total_pph_amount			= @p_total_pph_amount
				,total_amount				= @p_total_amount
				,branch_name				= @p_branch_name
				,branch_code				= @p_branch_code
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
