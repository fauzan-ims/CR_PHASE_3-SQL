CREATE PROCEDURE dbo.xsp_agreement_invoice_ledger_main_insert_auto_allocate
(
	@p_id								 bigint = 0
	,@p_cashier_orig_amount				 decimal(18, 2)
	,@p_cashier_transaction_code		 nvarchar(50)
	,@p_asset_no						 nvarchar(50)   
	,@p_customer_name					 nvarchar(250)  
	,@p_invoice_no						 nvarchar(50)   
	,@p_invoice_date					 datetime	    
	,@p_invoice_due_date				 datetime       
	,@p_invoice_net_amount				 decimal(18, 2) 
	,@p_invoice_balance_amount			 decimal(18, 2) 
	,@p_allocation_amount				 decimal(18, 2) 
	--
	,@p_cre_date						 datetime
	,@p_cre_by							 nvarchar(15)
	,@p_cre_ip_address					 nvarchar(15)
	,@p_mod_date						 datetime
	,@p_mod_by							 nvarchar(15)
	,@p_mod_ip_address					 nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max);

	begin try
		
		if ((select isnull(sum(allocation_amount),0) + @p_invoice_balance_amount 
				   from dbo.cashier_transaction_invoice where cashier_transaction_code = @p_cashier_transaction_code
				   ) > @p_cashier_orig_amount)
		begin
			set @p_allocation_amount = @p_cashier_orig_amount - (select isnull(sum(allocation_amount),0) 
				   from dbo.cashier_transaction_invoice where cashier_transaction_code = @p_cashier_transaction_code)  
		end
		else
		begin
			set @p_allocation_amount = @p_invoice_balance_amount
		end

		if @p_allocation_amount > 0
		begin
			insert into dbo.cashier_transaction_invoice
			(
				cashier_transaction_code
				,asset_no
				,customer_name			
				,invoice_no				
				,invoice_date			
				,invoice_due_date		
				,invoice_net_amount		
				,invoice_balance_amount	
				,allocation_amount	
				
				,cre_date		
				,cre_by			
				,cre_ip_address	
				,mod_date		
				,mod_by			
				,mod_ip_address	
			)
			values
			(	@p_cashier_transaction_code
				,@p_asset_no
				,@p_customer_name			
				,@p_invoice_no				
				,@p_invoice_date			
				,@p_invoice_due_date		
				,@p_invoice_net_amount		
				,@p_invoice_balance_amount	
				,@p_allocation_amount		
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end
		

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
