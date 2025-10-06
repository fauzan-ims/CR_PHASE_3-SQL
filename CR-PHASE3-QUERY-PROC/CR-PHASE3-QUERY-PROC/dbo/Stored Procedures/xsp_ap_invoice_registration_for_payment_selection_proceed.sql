CREATE PROCEDURE dbo.xsp_ap_invoice_registration_for_payment_selection_proceed
(
	@p_code			   nvarchar(50)
	,@p_date_flag	   datetime	 = null
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@code					nvarchar(50)
			,@company_code			nvarchar(50)
			,@id_detail				bigint
			,@payment_amount		decimal(18, 2)
			,@ppn_detail			decimal(18, 2)
			,@pph_detail			decimal(18, 2)
			,@shipping_fee_detail	decimal(18, 2)
			,@invoice_date			datetime
			,@currency_code			nvarchar(50)
			,@supplier_code			nvarchar(50)
			,@invoice_amount		decimal(18, 2)
			,@is_another_invoice	nvarchar(1)
			,@file_invoice_no		nvarchar(250)
			,@ppn					decimal(18, 2)
			,@pph					decimal(18, 2)
			,@shipping_fee			decimal(18, 2)
			,@bill_type				nvarchar(25)
			,@discount				decimal(18, 2)
			,@due_date				datetime
			,@purchase_order_code	nvarchar(50)
			,@tax_invoice_date		datetime
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(250)
			,@department_code		nvarchar(50)
			,@department_name		nvarchar(250)
			,@sub_department_code	nvarchar(50)
			,@sub_department_name	nvarchar(250)
			,@unit_code				nvarchar(50)
			,@unit_name				nvarchar(250)
			,@to_bank_code			nvarchar(50)
			,@to_bank_account_name	nvarchar(250)
			,@to_bank_name			nvarchar(250)
			,@to_bank_account_no	nvarchar(250)
			,@payment_by			nvarchar(25)
			,@count_validate		int
			,@supplier_name			nvarchar(250)
			,@purchase_amount		decimal(18,2)
			,@discount_detail		decimal(18,2)
			,@code_payment			nvarchar(50)
			,@sum_ppn				decimal(18,2)
			,@sum_pph				decimal(18,2)
			,@sum_discount			decimal(18,2)
			,@sum_payment			decimal(18,2)
			,@code_invoice_reg		nvarchar(50)
			,@date					datetime = dbo.xfn_get_system_date()

	begin try

		

		select @supplier_code			= supplier_code
				,@to_bank_code			= to_bank_code
				,@to_bank_name			= to_bank_name
				,@to_bank_account_no	= to_bank_account_no
				,@to_bank_account_name	= to_bank_account_name
				,@company_code			= company_code
				,@invoice_date			= invoice_date
				,@currency_code			= currency_code
				,@supplier_name			= isnull(supplier_name,'')
				,@invoice_amount		= invoice_amount
				,@ppn					= ppn
				,@pph					= pph
				,@discount				= discount
				,@due_date				= due_date
				,@purchase_order_code	= purchase_order_code
				,@tax_invoice_date		= tax_invoice_date
				,@payment_by			= payment_by
		from dbo.ap_invoice_registration
		where code = @p_code

		select @branch_code		= value
				,@branch_name	= description
		from dbo.sys_global_param
		where code = 'HO'

		--cek apakah sudah ada data dengan supplier dan bank yang sama di payment request
		if not exists (select 1 from dbo.ap_payment_request where supplier_code =  @supplier_code and to_bank_code = @to_bank_code and to_bank_name = @to_bank_name 
		and to_bank_account_no = @to_bank_account_no and to_bank_account_name = @to_bank_account_name and date_flag = @p_date_flag)
		begin
			exec dbo.xsp_ap_payment_request_insert @p_code						= @code output
													,@p_company_code			= @company_code
													,@p_invoice_date			= @date
													,@p_currency_code			= 'IDR'
													,@p_supplier_code			= @supplier_code
													,@p_supplier_name			= @supplier_name
													,@p_invoice_amount			= 0
													,@p_ppn						= 0
													,@p_pph						= 0
													,@p_fee						= 0
													,@p_discount				= 0 
													,@p_due_date				= @due_date
													,@p_purchase_order_code		= @purchase_order_code
													,@p_tax_invoice_date		= @tax_invoice_date
													,@p_branch_code				= @branch_code
													,@p_branch_name				= @branch_name
													,@p_to_bank_code			= @to_bank_code
													,@p_to_bank_account_name	= @to_bank_account_name
													,@p_to_bank_account_no		= @to_bank_account_no
													,@p_to_bank_name			= @to_bank_name
													,@p_payment_by				= @payment_by
													,@p_status					= 'HOLD'
													,@p_remark					= ''
													,@p_date_flag				= @p_date_flag
													,@p_cre_date				= @p_mod_date
													,@p_cre_by					= @p_mod_by
													,@p_cre_ip_address			= @p_mod_ip_address
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address ;
		end
		else
		begin
			select @code = code 
			from dbo.ap_payment_request
			where supplier_code			= @supplier_code
			and to_bank_code			= @to_bank_code
			and to_bank_name			= @to_bank_name
			and to_bank_account_no		= @to_bank_account_no
			and to_bank_account_name	= @to_bank_account_name
			and date_flag				= @p_date_flag
		end

		declare curr_invoice_payment_detail cursor fast_forward read_only for
			select	sum(((purchase_amount - discount) * quantity) + ppn - pph)
					,sum(ppn)
					,sum(pph)
					,sum(shipping_fee)
					,sum(purchase_amount)
					,sum(discount)
			from	dbo.ap_invoice_registration_detail
			where	invoice_register_code = @p_code 
	 
		open curr_invoice_payment_detail
		
		fetch next from curr_invoice_payment_detail 
		into @payment_amount
			,@ppn_detail
			,@pph_detail
			,@shipping_fee_detail
			,@purchase_amount
			,@discount_detail
		
		while @@fetch_status = 0
		begin
		    exec dbo.xsp_ap_payment_request_detail_insert @p_id							= 0
														,@p_company_code				= @company_code
														,@p_payment_request_code		= @code
														,@p_invoice_register_code		= @p_code
														,@p_payment_amount				= @payment_amount
														,@p_is_paid						= '0'
														,@p_ppn							= @ppn_detail
														,@p_pph							= @pph_detail
														,@p_fee							= @shipping_fee_detail
														,@p_discount					= @discount_detail
														,@p_unit_price					= @purchase_amount
														,@p_cre_date					= @p_mod_date
														,@p_cre_by						= @p_mod_by
														,@p_cre_ip_address				= @p_mod_ip_address
														,@p_mod_date					= @p_mod_date
														,@p_mod_by						= @p_mod_by
														,@p_mod_ip_address				= @p_mod_ip_address ;
		
		    fetch next from curr_invoice_payment_detail 
			into @payment_amount
				,@ppn_detail
				,@pph_detail
				,@shipping_fee_detail
				,@purchase_amount
				,@discount_detail
		end
		
		close curr_invoice_payment_detail
		deallocate curr_invoice_payment_detail

		select @sum_ppn			= sum(ppn)
				,@sum_pph		= sum(pph)
				,@sum_payment	= sum(payment_amount)
				,@sum_discount	= sum(discount)
		from dbo.ap_payment_request_detail
		where payment_request_code = @code

		select @code_invoice_reg =	stuff((
				  select	distinct ',' + invoice_register_code
				  from		dbo.ap_payment_request_detail
				  where		payment_request_code = @code
				  for xml path('')
			  ), 1, 1, ''
			 ) ;


		--update payment invoice header
		update dbo.ap_payment_request
		set		invoice_amount = @sum_payment
				,ppn			= @sum_ppn
				,pph			= @sum_pph
				,discount		= @sum_discount
				,remark			= 'Payment for ' + @code_invoice_reg
		where code = @code

		--declare c_payment_selection_proceed cursor for
		--select	code
		--		,company_code
		--		,invoice_date
		--		,currency_code
		--		,supplier_code
		--		,isnull(supplier_name,'')
		--		,invoice_amount
		--		--,is_another_invoice
		--		,file_invoice_no
		--		,ppn
		--		,pph
		--		--,shipping_fee
		--		,bill_type
		--		,discount
		--		,due_date
		--		,purchase_order_code
		--		,tax_invoice_date
		--		,branch_code
		--		,branch_name
		--		,division_code
		--		,division_name
		--		,department_code
		--		,department_name
		--		,to_bank_code
		--		,to_bank_account_name
		--		,to_bank_account_no
		--		,to_bank_name
		--		,payment_by
		--from	dbo.ap_invoice_registration
		--where	code = @p_code ;

		--open c_payment_selection_proceed ;

		--fetch c_payment_selection_proceed
		--into @code
		--	 ,@company_code
		--	 ,@invoice_date
		--	 ,@currency_code
		--	 ,@supplier_code
		--	 ,@supplier_name
		--	 ,@invoice_amount
		--	-- ,@is_another_invoice
		--	 ,@file_invoice_no
		--	 ,@ppn
		--	 ,@pph
		--	-- ,@shipping_fee
		--	 ,@bill_type
		--	 ,@discount
		--	 ,@due_date
		--	 ,@purchase_order_code
		--	 ,@tax_invoice_date
		--	 ,@branch_code
		--	 ,@branch_name
		--	 ,@division_code
		--	 ,@division_name
		--	 ,@department_code
		--	 ,@department_name
		--	 ,@to_bank_code
		--	 ,@to_bank_account_name
		--	 ,@to_bank_account_no
		--	 ,@to_bank_name
		--	 ,@payment_by ;

		--while @@fetch_status = 0
		--begin

		--	--select	@count_validate			= count(invoice_register_code)
		--	--from	dbo.ap_payment_request_detail
		--	--where	invoice_register_code	= @p_code ;

		--	--if (@count_validate > 0)
		--	--begin
		--	--	set @msg = 'Payment Order already exist, please select another Payment Selection' ;

		--	--	raiserror(@msg, 16, -1) ;
		--	--end ;

		--	exec dbo.xsp_ap_payment_request_insert @p_code					= @code output
		--										   ,@p_company_code			= @company_code
		--										   ,@p_invoice_date			= @invoice_date
		--										   ,@p_currency_code		= @currency_code
		--										   ,@p_supplier_code		= @supplier_code
		--										   ,@p_supplier_name		= @supplier_name
		--										   ,@p_invoice_amount		= @invoice_amount
		--										  -- ,@p_is_another_invoice	= '' 
		--										   ,@p_ppn					= @ppn
		--										   ,@p_pph					= @pph
		--										   ,@p_fee					= 0
		--										   --,@p_bill_type			= @bill_type
		--										   ,@p_discount				= @discount 
		--										   ,@p_due_date				= @due_date
		--										   ,@p_purchase_order_code	= @purchase_order_code
		--										   ,@p_tax_invoice_date		= @tax_invoice_date
		--										   ,@p_branch_code			= @branch_code
		--										   ,@p_branch_name			= @branch_name
		--										   ,@p_to_bank_code			= @to_bank_code
		--										   ,@p_to_bank_account_name = @to_bank_account_name
		--										   ,@p_to_bank_account_no	= @to_bank_account_no
		--										   ,@p_to_bank_name			= @to_bank_name
		--										   ,@p_payment_by			= @payment_by
		--										   ,@p_status				= 'HOLD'
		--										   ,@p_remark				= ''
		--										   ,@p_cre_date				= @p_mod_date
		--										   ,@p_cre_by				= @p_mod_by
		--										   ,@p_cre_ip_address		= @p_mod_ip_address
		--										   ,@p_mod_date				= @p_mod_date
		--										   ,@p_mod_by				= @p_mod_by
		--										   ,@p_mod_ip_address		= @p_mod_ip_address ;


		--	declare c_payment_request_detail cursor for
		--	select	(((purchase_amount - discount) * quantity) + ppn - pph )
		--			,id
		--			,ppn
		--			,pph
		--			,shipping_fee
		--			,purchase_amount
		--			,discount
		--	from	dbo.ap_invoice_registration_detail
		--	where	invoice_register_code = @p_code ;

		--	open c_payment_request_detail ;

		--	fetch c_payment_request_detail
		--	into @payment_amount
		--		 ,@id_detail
		--		 ,@ppn_detail
		--		 ,@pph_detail
		--		 ,@shipping_fee_detail
		--		 ,@purchase_amount
		--		 ,@discount_detail

		--	while @@fetch_status = 0
		--	begin
		--		exec dbo.xsp_ap_payment_request_detail_insert @p_id							= 0
		--													  ,@p_company_code				= @company_code
		--													  ,@p_payment_request_code		= @code
		--													  ,@p_invoice_register_code		= @p_code
		--													  ,@p_payment_amount			= @payment_amount
		--													  ,@p_is_paid					= '0'
		--													  ,@p_ppn						= @ppn_detail
		--													  ,@p_pph						= @pph_detail
		--													  ,@p_fee						= @shipping_fee_detail
		--													  ,@p_discount					= @discount_detail
		--													  ,@p_unit_price				= @purchase_amount
		--													  ,@p_cre_date					= @p_mod_date
		--													  ,@p_cre_by					= @p_mod_by
		--													  ,@p_cre_ip_address			= @p_mod_ip_address
		--													  ,@p_mod_date					= @p_mod_date
		--													  ,@p_mod_by					= @p_mod_by
		--													  ,@p_mod_ip_address			= @p_mod_ip_address ;				

		--		fetch c_payment_request_detail
		--		into @payment_amount
		--			,@id_detail
		--			,@ppn_detail
		--			,@pph_detail
		--			,@shipping_fee_detail
		--			,@purchase_amount
		--			,@discount_detail
		--	end ;

		--	close c_payment_request_detail ;
		--	deallocate c_payment_request_detail ;

		--	fetch c_payment_selection_proceed
		--	into @code
		--		 ,@company_code
		--		 ,@invoice_date
		--		 ,@currency_code
		--		 ,@supplier_code
		--		 ,@supplier_name
		--		 ,@invoice_amount
		--		-- ,@is_another_invoice
		--		 ,@file_invoice_no
		--		 ,@ppn
		--		 ,@pph
		--		-- ,@shipping_fee
		--		 ,@bill_type
		--		 ,@discount
		--		 ,@due_date
		--		 ,@purchase_order_code
		--		 ,@tax_invoice_date
		--		 ,@branch_code
		--		 ,@branch_name
		--		 ,@division_code
		--		 ,@division_name
		--		 ,@department_code
		--		 ,@department_name
		--		 ,@to_bank_code
		--		 ,@to_bank_account_name
		--		 ,@to_bank_account_no
		--		 ,@to_bank_name
		--		 ,@payment_by ;
		--end ;

		--close c_payment_selection_proceed ;
		--deallocate c_payment_selection_proceed ;

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
