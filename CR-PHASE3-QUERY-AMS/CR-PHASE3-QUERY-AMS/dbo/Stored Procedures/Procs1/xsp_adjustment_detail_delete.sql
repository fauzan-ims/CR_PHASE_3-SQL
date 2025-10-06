CREATE PROCEDURE dbo.xsp_adjustment_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg					   nvarchar(max)
			,@adjustment_code		   nvarchar(50)
			,@amount				   decimal(18, 2)
			,@total_adjustment		   decimal(18, 2)
			,@new_netbook_value_fiscal decimal(18, 2)
			,@new_netbook_value_comm   decimal(18, 2) ;

	begin try
		select	@adjustment_code = adjustment_code
				,@amount		 = amount
		from	dbo.adjustment_detail
		where	id = @p_id ;

		select	@total_adjustment		   = total_adjustment
				,@new_netbook_value_fiscal = new_netbook_value_fiscal
				,@new_netbook_value_comm   = new_netbook_value_comm
		from	dbo.adjustment
		where	code = @adjustment_code ;

		update	dbo.adjustment
		set		total_adjustment			= @total_adjustment - @amount
				,new_netbook_value_fiscal	= @new_netbook_value_fiscal - @amount
				,new_netbook_value_comm		= @new_netbook_value_comm - @amount
		where	code = @adjustment_code ;

		delete dbo.adjustment_detail
		where	id = @p_id ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
