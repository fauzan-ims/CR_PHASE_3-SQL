CREATE PROCEDURE dbo.xsp_application_refund_update
(
	@p_code				 nvarchar(50)
	,@p_application_no	 nvarchar(50)
	,@p_refund_code		 nvarchar(50)
	,@p_fee_code		 nvarchar(50)
	,@p_refund_rate		 decimal(9, 6)
	,@p_refund_amount	 decimal(18, 2)
	,@p_is_auto_generate nvarchar(1)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_auto_generate = 'T'
		set @p_is_auto_generate = '1' ;
	else
		set @p_is_auto_generate = '0' ;

	begin try
		update	application_refund
		set		application_no		= @p_application_no
				,refund_code		= @p_refund_code
				,fee_code			= @p_fee_code
				,refund_rate		= @p_refund_rate
				,refund_amount		= @p_refund_amount
				,is_auto_generate	= @p_is_auto_generate
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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

