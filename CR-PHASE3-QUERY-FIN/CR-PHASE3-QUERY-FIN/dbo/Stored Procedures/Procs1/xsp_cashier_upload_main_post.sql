CREATE PROCEDURE dbo.xsp_cashier_upload_main_post
	@p_code nvarchar(50)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.cashier_upload_detail
			where	cashier_upload_code = @p_code
		)
		begin
			update	dbo.cashier_upload_main
			set		status = 'POST'
			where	code	= @p_code ;
		end ;
		else
		begin
			set @msg = 'Error data already Post' ;

			raiserror(@msg, 16, 1) ;
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
