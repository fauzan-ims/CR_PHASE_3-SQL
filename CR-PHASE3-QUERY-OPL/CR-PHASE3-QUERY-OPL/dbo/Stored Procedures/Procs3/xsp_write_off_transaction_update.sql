CREATE PROCEDURE dbo.xsp_write_off_transaction_update
(
	@p_id				   bigint
	,@p_wo_code			   nvarchar(50)
	,@p_gl_link_code	   nvarchar(50)
	,@p_transaction_amount decimal(18, 2)
	,@p_is_transaction	   nvarchar(1)
	,@p_order_key		   int
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_transaction = 'T'
		set @p_is_transaction = '1' ;

	if @p_is_transaction = 'F'
		set @p_is_transaction = '0' ;

	begin try
		update	write_off_transaction
		set		wo_code				= @p_wo_code 
				,transaction_amount = @p_transaction_amount
				,is_transaction		= @p_is_transaction
				,order_key			= @p_order_key
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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

