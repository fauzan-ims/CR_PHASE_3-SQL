CREATE procedure dbo.xsp_master_custom_report_column_order_up
	@p_id				   bigint
	,@p_custom_report_code nvarchar(50)
as
begin
	declare @order_tamp int
			,@msg		nvarchar(max) ;

	begin try
		select	@order_tamp = order_key
		from	dbo.master_custom_report_column
		where	id = @p_id ;

		if (@order_tamp > 1)
		begin
			update	dbo.master_custom_report_column
			set		order_key = @order_tamp
			where	order_key			   = @order_tamp - 1
					and custom_report_code = @p_custom_report_code ;

			update	dbo.master_custom_report_column
			set		order_key = @order_tamp - 1
			where	id = @p_id ;
		end ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
