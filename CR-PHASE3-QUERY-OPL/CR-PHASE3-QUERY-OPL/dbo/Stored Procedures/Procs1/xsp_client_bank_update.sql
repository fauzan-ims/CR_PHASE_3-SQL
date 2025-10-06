CREATE PROCEDURE [dbo].[xsp_client_bank_update]
(
	@p_code				   nvarchar(50)
	,@p_client_code		   nvarchar(50)
	,@p_currency_code	   nvarchar(3)
	,@p_bank_code		   nvarchar(50)
	,@p_bank_name		   nvarchar(250)
	,@p_bank_branch		   nvarchar(250)
	,@p_bank_account_no	   nvarchar(50)
	,@p_bank_account_name  nvarchar(250)
	,@p_is_default		   nvarchar(1) = 'F'
	,@p_is_auto_debet_bank nvarchar(1) = 'F'
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	if @p_is_auto_debet_bank = 'T'
		set @p_is_auto_debet_bank = '1' ;
	else
		set @p_is_auto_debet_bank = '0' ;

	begin try
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
		update	client_bank
		set		client_code			= @p_client_code
				,currency_code		= @p_currency_code
				,bank_code			= @p_bank_code
				,bank_name			= @p_bank_name
				,bank_branch		= upper(@p_bank_branch)
				,bank_account_no	= @p_bank_account_no
				,bank_account_name	= upper(@p_bank_account_name)
				,is_default			= @p_is_default
				,is_auto_debet_bank = @p_is_auto_debet_bank
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

		if @p_is_default = '1'
		begin
			update	dbo.client_bank
			set		is_default = '0'
			where	client_code = @p_client_code
					and code	<> @p_code ;
		end ;

		if @p_is_auto_debet_bank = '1'
		begin
			update	dbo.client_bank
			set		is_auto_debet_bank = '0'
			where	client_code = @p_client_code
					and code	<> @p_code ;
		end ;
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;

