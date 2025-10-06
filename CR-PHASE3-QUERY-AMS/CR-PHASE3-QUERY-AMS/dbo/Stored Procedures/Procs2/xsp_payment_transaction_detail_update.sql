CREATE procedure xsp_payment_transaction_detail_update
(
	@p_id							bigint	
	,@p_payment_transaction_code	nvarchar(50)
	,@p_payment_request_code		nvarchar(50)
	,@p_orig_curr_code				nvarchar(3)
	,@p_orig_amount					decimal(18,2)
	,@p_exch_rate					decimal(9,6)
	,@p_base_amount					decimal(18,2)
	,@p_tax_amount					decimal(18,2)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		
		update	payment_transaction_detail
		set		payment_transaction_code	= @p_payment_transaction_code
				,payment_request_code		= @p_payment_request_code	
				,orig_curr_code				= @p_orig_curr_code			
				,orig_amount				= @p_orig_amount				
				,exch_rate					= @p_exch_rate				
				,base_amount				= @p_base_amount				
				,tax_amount					= @p_tax_amount							
				,mod_date					= @p_mod_date		
				,mod_by						= @p_mod_by			
				,mod_ip_address 			= @p_mod_ip_address
		where	id							= @p_id
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
