CREATE PROCEDURE dbo.xsp_master_account_payable_detail_update
(
	@p_id						bigint
	,@p_account_payable_code	nvarchar(50)
	,@p_payment_source          nvarchar(50)
	--					        
	,@p_mod_date		        datetime
	,@p_mod_by			        nvarchar(15)
	,@p_mod_ip_address	        nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) ;
    
	begin try

		update	dbo.master_account_payable_detail
		set		account_payable_code	= @p_account_payable_code
				,payment_source			= @p_payment_source		
				--
				,mod_date			   = @p_mod_date
				,mod_by				   = @p_mod_by
				,mod_ip_address		   = @p_mod_ip_address
		where	id						= @p_id ;
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
