CREATE PROCEDURE dbo.xsp_deskcoll_customer_info_update
(
	@p_deskcoll_id			bigint 
	,@p_customer_client_no  nvarchar(50)
	,@p_invoice_no			nvarchar(50)
	,@p_transaction_amount	decimal(18, 2)
	,@p_os_invoice_amount	decimal(18, 2)
	,@p_invoice_due_date	datetime
	
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 

	begin try

		update	dbo.deskcoll_customer_info
		set		customer_client_no		= @p_customer_client_no
				,invoice_no				= @p_invoice_no
				,transaction_amount		= @p_transaction_amount
				,os_invoice_amount		= @p_os_invoice_amount
				,invoice_due_date		= @p_invoice_due_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	deskcoll_id				= @p_deskcoll_id ;

		
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
