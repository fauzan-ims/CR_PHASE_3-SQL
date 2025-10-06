CREATE PROCEDURE dbo.xsp_cashier_receipt_allocated_update
(
	@p_id					 bigint
	,@p_cashier_code		 nvarchar(50)
	,@p_receipt_code		 nvarchar(50)
	,@p_receipt_status		 nvarchar(50)
	,@p_receipt_use_date	 datetime
	,@p_receipt_use_trx_code nvarchar(50)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	cashier_receipt_allocated
		set		cashier_code			= @p_cashier_code
				,receipt_code			= @p_receipt_code
				,receipt_status			= @p_receipt_status
				,receipt_use_date		= @p_receipt_use_date
				,receipt_use_trx_code	= @p_receipt_use_trx_code
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;  
	end catch;
end ;
