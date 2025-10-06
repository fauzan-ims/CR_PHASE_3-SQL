CREATE PROCEDURE dbo.xsp_termination_detail_asset_update
(
	@p_id					   bigint
	,@p_refund_amount		   decimal(18, 2)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@code_termination	nvarchar(50)
			,@sum_refund_amount	decimal(18,2)

	begin try
		select @code_termination = termination_code 
		from dbo.termination_detail_asset
		where id = @p_id

		update	termination_detail_asset
		set		refund_amount				= @p_refund_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;

		select @sum_refund_amount = sum(refund_amount) 
		from dbo.termination_detail_asset
		where termination_code = @code_termination

		update	dbo.termination_main
		set		termination_approved_amount	= @sum_refund_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @code_termination ;

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
