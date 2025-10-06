CREATE PROCEDURE dbo.xsp_order_main_cancel
(
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
    
	declare @msg			nvarchar(max)
			,@order_status	nvarchar(20)

	begin try
	
		select	@order_status	= order_status
		from	dbo.order_main
		where	code = @p_code
		
		if @order_status <> 'HOLD'
		begin
			set @msg = 'Data already proceed.'
			raiserror(@msg ,16,-1)
		end

		update	dbo.order_main
		set		order_status	= 'CANCEL'
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code = @p_code
		
		update	dbo.register_main
		set		order_status		= null
				,order_code			= null
				,register_status	= 'PAID'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code in (select register_code from dbo.order_detail where order_code = @p_code)
	
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

end
