CREATE PROCEDURE [dbo].[xsp_deposit_move_detail_update]
(
	@p_id				bigint
	,@p_to_deposit_type nvarchar(15)
	,@p_to_amount		decimal(18, 2)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
	,@deposit_move_code nvarchar(50)
	,@total_to_deposit_amount decimal(18,2)

	begin try
		select	@deposit_move_code = deposit_move_code
		from	dbo.deposit_move_detail
		where	id = @p_id ;

		update	dbo.deposit_move_detail
		set		to_deposit_type_code	= @p_to_deposit_type
				,to_amount				= isnull(@p_to_amount, 0)
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id = @p_id ;
		 
		select	@total_to_deposit_amount = isnull(sum(isnull(to_amount, 0)), 0)
		from	dbo.deposit_move_detail
		where	DEPOSIT_MOVE_CODE = @deposit_move_code ; 

		update dbo.deposit_move 
		set		total_to_amount = @total_to_deposit_amount
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where code = @deposit_move_code
	end try
	begin catch
		declare @error int = @@error ;

		if @error = 2627
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;

		if len(@msg) <> 0
			set @msg = N'V;' + @msg ;
		else if error_message() like '%V;%'
				or	error_message() like '%E;%'
			set @msg = error_message() ;
		else
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
