CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_insert]
(
	@p_code					 nvarchar(50)  output
	,@p_company_code		 nvarchar(50)
	,@p_invoice_date		 datetime
	,@p_currency_code		 nvarchar(50)		= ''
	,@p_supplier_code		 nvarchar(50) 
	,@p_supplier_name		 nvarchar(250)
	,@p_invoice_amount		 decimal(18, 2)		= 0
	,@p_file_invoice_no		 nvarchar(250)		= ''
	,@p_ppn					 decimal(18, 2)		= 0
	,@p_pph					 decimal(18, 2)		= 0
	,@p_bill_type			 nvarchar(25)
	,@p_discount			 decimal(18, 2)
	,@p_due_date			 datetime
	,@p_purchase_order_code	 nvarchar(50)		= ''
	,@p_tax_invoice_date	 datetime
	,@p_branch_code			 nvarchar(50)		= ''
	,@p_branch_name			 nvarchar(250)		= ''
	,@p_division_code		 nvarchar(50)		= ''
	,@p_division_name		 nvarchar(250)		= ''
	,@p_department_code		 nvarchar(50)		= ''
	,@p_department_name		 nvarchar(250)		= ''
	,@p_to_bank_code		 nvarchar(50) 
	,@p_to_bank_name		 nvarchar(250)		= ''
	,@p_to_bank_account_name nvarchar(250) 
	,@p_to_bank_account_no	 nvarchar(250) 
	,@p_payment_by			 nvarchar(25)		= ''
	,@p_status				 nvarchar(25)
	,@p_remark				 nvarchar(4000)
	,@p_file_name			 nvarchar(250)		= ''
	,@p_file_paths			 nvarchar(205)		= ''
	,@p_unit_price			 decimal(18,2)		= 0
	,@p_date_flag			 datetime			= null
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg	 nvarchar(max)
			,@year	 nvarchar(2)
			,@month	 nvarchar(2)
			,@code	 nvarchar(50)
			,@value	 int
			,@value2 int ;

	begin try
		select	@value = value
		from	dbo.sys_global_param
		where	CODE = 'APINVBCM' ;

		if @p_invoice_date > dbo.xfn_get_system_date()
		begin
	
			set @msg = 'Invoice Received Date must less than system date.';
	
			raiserror(@msg, 16, -1) ;
	
		end     

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

		if @p_due_date < dbo.xfn_get_system_date()
		begin
	
			set @msg = 'Due date must be greater or equal than system date.';
	
			raiserror(@msg, 16, -1) ;
	
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


		if @p_tax_invoice_date > dbo.xfn_get_system_date()
		begin
	
			set @msg = 'Tax invoice date must be less or equal than system date.';
	
			raiserror(@msg, 16, -1) ;
	
		end  

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_company_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'INR'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'AP_INVOICE_REGISTRATION'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into ap_invoice_registration
		(
			code
			,company_code
			,invoice_date
			,currency_code
			,supplier_code
			,supplier_name
			,invoice_amount
			,file_invoice_no
			,ppn
			,pph
			,bill_type
			,discount
			,due_date
			,purchase_order_code
			,tax_invoice_date
			,branch_code
			,branch_name
			,division_code
			,division_name
			,department_code
			,department_name
			,to_bank_code
			,to_bank_name
			,to_bank_account_name
			,to_bank_account_no
			,payment_by
			,status
			,remark
			,file_name
			,paths
			,unit_price
			,date_flag
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_company_code
			,@p_invoice_date
			,@p_currency_code
			,@p_supplier_code
			,@p_supplier_name
			,@p_invoice_amount
			,@p_file_invoice_no
			,@p_ppn
			,@p_pph
			,@p_bill_type
			,@p_discount
			,@p_due_date
			,@p_purchase_order_code
			,@p_tax_invoice_date
			,@p_branch_code
			,@p_branch_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_to_bank_code
			,@p_to_bank_name
			,@p_to_bank_account_name
			,@p_to_bank_account_no
			,@p_payment_by
			,@p_status
			,@p_remark
			,@p_file_name
			,@p_file_paths
			,@p_unit_price
			,@p_date_flag
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

			--declare @purchase_order_id bigint
			--		,@item_code		   nvarchar(50)
			--		,@item_name		   nvarchar(250)
			--		,@ppn			   decimal(18, 2)
			--		,@pph			   decimal(18, 2)
			--		,@purchase_amount  decimal(18, 2)
			--		,@tax_code		   nvarchar(50) ;

			--declare c_invoice_register_detail cursor for
			--select	id
			--		,item_code
			--		,item_name
			--		,ppn_amount
			--		,pph_amount
			--		,price_amount
			--		,tax_code
			--from	dbo.purchase_order_detail
			--where	po_code = @p_purchase_order_code ;

			--open c_invoice_register_detail ;

			--fetch c_invoice_register_detail
			--into @purchase_order_id
			--	 ,@item_code
			--	 ,@item_name
			--	 ,@ppn
			--	 ,@pph
			--	 ,@purchase_amount
			--	 ,@tax_code ;

			--while @@fetch_status = 0
			--begin
			--	declare @p_id bigint ;

			--	EXEC dbo.xsp_ap_invoice_registration_detail_insert @p_id						= @p_id OUTPUT                
			--	                                                  ,@p_invoice_register_code		= @code    
			--	                                                  ,@p_grn_code					= ''                   
			--	                                                  ,@p_currency_code				= @p_currency_code               
			--	                                                  ,@p_item_code                 = @item_code 
			--	                                                  ,@p_purchase_amount           = @purchase_amount
			--	                                                  ,@p_total_amount              = 0
			--	                                                  ,@p_tax_code                  = @tax_code 
			--	                                                  ,@p_ppn                      	= @ppn
			--	                                                  ,@p_pph                       = @pph
			--	                                                  ,@p_shipping_fee              = 0
			--	                                                  ,@p_discount                  = 0
			--	                                                  ,@p_branch_code               = @p_branch_code  
			--	                                                  ,@p_branch_name               = @p_branch_name 
			--	                                                  ,@p_division_code             = @p_division_code 
			--	                                                  ,@p_division_name             = @p_division_name 
			--	                                                  ,@p_department_code           = @p_department_code 
			--	                                                  ,@p_department_name           = @p_department_name 
			--	                                                  ,@p_sub_department_code       = @p_sub_department_code 
			--	                                                  ,@p_sub_department_name       = @p_sub_department_name 
			--	                                                  ,@p_unit_code                 = @p_unit_code 
			--	                                                  ,@p_unit_name                 = @p_unit_name 
			--	                                                  ,@p_purchase_order_id			= @purchase_order_id       
			--	                                                  ,@p_cre_date					= @p_mod_date		
			--	                                                  ,@p_cre_by					= @p_mod_by			
			--	                                                  ,@p_cre_ip_address			= @p_mod_ip_address
			--	                                                  ,@p_mod_date					= @p_mod_date		
			--	                                                  ,@p_mod_by					= @p_mod_by			
			--	                                                  ,@p_mod_ip_address			= @p_mod_ip_address ;
			--	fetch c_invoice_register_detail
			--	into @purchase_order_id
			--		 ,@item_code
			--		 ,@item_name
			--		 ,@ppn
			--		 ,@pph
			--		 ,@purchase_amount
			--		 ,@tax_code ;
			--end ;

			--close c_invoice_register_detail ;
			--deallocate c_invoice_register_detail ;
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_ap_invoice_registration_insert] TO [ims-raffyanda]
    AS [dbo];

