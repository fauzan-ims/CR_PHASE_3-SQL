CREATE procedure [dbo].[xsp_ap_invoice_registration_update]
(
	@p_code					 nvarchar(50)
	,@p_company_code		 nvarchar(50)
	,@p_invoice_date		 datetime
	,@p_currency_code		 nvarchar(50)	= ''
	,@p_supplier_code		 nvarchar(50)	= ''
	,@p_supplier_name		 nvarchar(250)	= ''
	,@p_invoice_amount		 decimal(18, 2) = 0
	,@p_file_invoice_no		 nvarchar(250)
	,@p_ppn					 decimal(18, 2) = 0
	,@p_pph					 decimal(18, 2) = 0
	,@p_bill_type			 nvarchar(25)
	,@p_discount			 decimal(18, 2)
	,@p_due_date			 datetime
	,@p_purchase_order_code	 nvarchar(50)	= ''
	,@p_tax_invoice_date	 datetime
	,@p_branch_code			 nvarchar(50)	= ''
	,@p_branch_name			 nvarchar(250)	= ''
	,@p_division_code		 nvarchar(50)	= ''
	,@p_division_name		 nvarchar(250)	= ''
	,@p_department_code		 nvarchar(50)	= ''
	,@p_department_name		 nvarchar(250)	= ''
	,@p_to_bank_code		 nvarchar(50)	= ''
	,@p_to_bank_name		 nvarchar(250)	= ''
	,@p_to_bank_account_name nvarchar(250)	= ''
	,@p_to_bank_account_no	 nvarchar(250)	= ''
	,@p_payment_by			 nvarchar(25)	= ''
	,@p_status				 nvarchar(25)
	,@p_remark				 nvarchar(4000)
	,@p_faktur_no			 nvarchar(50)	= null
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@value		int
			,@value2	int

	begin try
		
		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'APINVBCM' ;

		if(@p_invoice_date < dateadd(month, -@value, dbo.xfn_get_system_date()))
		begin
			if(@value <> 0)
			begin
				set @msg = N'Invoice receive date cannot be back dated for more than ' + convert(varchar(1), @value) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if(@value = 0)
			begin
				set @msg = N'Invoice receive date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'APTXBCM' ;

		if(@p_tax_invoice_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			if(@value2 <> 0)
			begin
				set @msg = N'Invoice tax date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value2 = 0)
			begin
				set @msg = N'Invoice tax date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if @p_invoice_date > dbo.xfn_get_system_date()
		begin

			set @msg = 'Invoice receive date must be less or equal than system date.';

			raiserror(@msg, 16, -1) ;

		end   

		if @p_due_date < dbo.xfn_get_system_date()
		begin
			set @msg = N'Due date must be greater or equal than system date.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if @p_tax_invoice_date > dbo.xfn_get_system_date()
		begin

			set @msg = 'Tax invoice date must be less or equal than system date.';

			raiserror(@msg, 16, -1) ;

		end  

		-- jika purchase code diubah, detailnya di delete
		--if exists (select 1 from ap_invoice_registration where code = @p_code and purchase_order_code <> @p_purchase_order_code)
		--begin
		--	delete dbo.ap_invoice_registration_detail
		--	where invoice_register_code = @p_code

		--end
		if (len(@p_faktur_no) != 16)
		begin
			set @msg = N'Faktur Number Must be 16 Digits' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	ap_invoice_registration
		set		invoice_date			= @p_invoice_date
				,currency_code			= @p_currency_code
				,supplier_code			= @p_supplier_code
				,supplier_name			= @p_supplier_name
				,invoice_amount			= @p_invoice_amount
				,file_invoice_no		= @p_file_invoice_no
				,ppn					= @p_ppn
				,pph					= @p_pph
				,bill_type				= @p_bill_type
				,discount				= @p_discount
				,due_date				= @p_due_date
				,purchase_order_code	= @p_purchase_order_code
				,tax_invoice_date		= @p_tax_invoice_date
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,division_code			= @p_division_code
				,division_name			= @p_division_name
				,department_code		= @p_department_code
				,department_name		= @p_department_name
				,to_bank_code			= @p_to_bank_code
				,to_bank_name			= @p_to_bank_name
				,to_bank_account_name	= @p_to_bank_account_name
				,to_bank_account_no		= @p_to_bank_account_no
				,payment_by				= @p_payment_by
				,status					= @p_status
				,remark					= @p_remark
				,faktur_no				= @p_faktur_no
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
