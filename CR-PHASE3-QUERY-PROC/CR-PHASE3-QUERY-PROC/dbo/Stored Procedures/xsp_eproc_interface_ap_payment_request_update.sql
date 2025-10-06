CREATE PROCEDURE dbo.xsp_eproc_interface_ap_payment_request_update
(
	@p_id					 bigint
	,@p_code				 nvarchar(50)
	,@p_invoice_date		 datetime
	,@p_currency_code		 nvarchar(50)
	,@p_supplier_code		 nvarchar(50)
	,@p_invoice_amount		 decimal(18, 2)
	,@p_is_another_invoice	 nvarchar(1)
	,@p_file_invoice_no		 nvarchar(250)
	,@p_ppn					 decimal(18, 2)
	,@p_pph					 decimal(18, 2)
	,@p_fee					 decimal(18, 2)
	,@p_bill_type			 nvarchar(25)
	,@p_discount			 decimal(18, 2)
	,@p_due_date			 datetime
	,@p_tax_invoice_date	 datetime
	,@p_purchase_order_code	 nvarchar(50)
	,@p_branch_code			 nvarchar(50)
	,@p_branch_name			 nvarchar(250)
	,@p_to_bank_code		 nvarchar(50)
	,@p_to_bank_account_name nvarchar(250)
	,@p_to_bank_account_no	 nvarchar(250)
	,@p_payment_by			 nvarchar(25)
	,@p_status				 nvarchar(25)
	,@p_remark				 nvarchar(4000)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_another_invoice = 'T'
		set @p_is_another_invoice = '1' ;
	else
		set @p_is_another_invoice = '0' ;

	begin try
		update	eproc_interface_ap_payment_request
		set		code = @p_code
				,invoice_date = @p_invoice_date
				,currency_code = @p_currency_code
				,supplier_code = @p_supplier_code
				,invoice_amount = @p_invoice_amount
				,is_another_invoice = @p_is_another_invoice
				,file_invoice_no = @p_file_invoice_no
				,ppn = @p_ppn
				,pph = @p_pph
				,fee = @p_fee
				,bill_type = @p_bill_type
				,discount = @p_discount
				,due_date = @p_due_date
				,tax_invoice_date = @p_tax_invoice_date
				,purchase_order_code = @p_purchase_order_code
				,branch_code = @p_branch_code
				,branch_name = @p_branch_name
				,to_bank_code = @p_to_bank_code
				,to_bank_account_name = @p_to_bank_account_name
				,to_bank_account_no = @p_to_bank_account_no
				,payment_by = @p_payment_by
				,status = @p_status
				,remark = @p_remark
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
