create PROCEDURE dbo.xsp_ifinproc_interface_payment_request_cancel 
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@payment_source		nvarchar(50)

	begin try

		select  @payment_source			= payment_source
		from    dbo.pbs_interface_payment_request
        where	code = @p_code
	
		if (@payment_source = 'PROCUREMENT INVOICE PAYMENT')
		begin 
			update dbo.ap_payment_request
			set    status = 'HOLD'
				   --
				   ,mod_date		 = @p_mod_date		
				   ,mod_by			 = @p_mod_by			
				   ,mod_ip_address	 = @p_mod_ip_address	
			where  code = @p_code		
		end

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
