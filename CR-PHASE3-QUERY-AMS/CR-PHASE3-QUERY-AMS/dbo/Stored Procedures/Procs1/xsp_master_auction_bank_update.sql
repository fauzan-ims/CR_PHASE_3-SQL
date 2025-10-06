CREATE PROCEDURE dbo.xsp_master_auction_bank_update
(
	@p_id				  bigint
	,@p_auction_code	  nvarchar(50)
	,@p_currency_code	  nvarchar(3)
	,@p_bank_code		  nvarchar(50)
	,@p_bank_name		  nvarchar(250)
	,@p_bank_branch		  nvarchar(250)
	,@p_bank_account_no	  nvarchar(50)
	,@p_bank_account_name nvarchar(250)
	,@p_is_default		  nvarchar(1)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
BEGIN

	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;

	if @p_is_default = 'F'
		set @p_is_default = '0' ;

	begin TRY
		
		if @p_is_default = '1'
		BEGIN
        
			update	dbo.master_auction_bank
			set		is_default		= 0
			where	auction_code	= @p_auction_code
			and		is_default		= 1

		end

		update	master_auction_bank
		set		auction_code		= @p_auction_code
				,currency_code		= @p_currency_code
				,bank_code			= @p_bank_code
				,bank_name			= @p_bank_name
				,bank_branch		= @p_bank_branch
				,bank_account_no	= @p_bank_account_no
				,bank_account_name	= @p_bank_account_name
				,is_default			= @p_is_default
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
		
		update	dbo.master_auction
		set		is_validate = 0
		where	code = @p_auction_code

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
