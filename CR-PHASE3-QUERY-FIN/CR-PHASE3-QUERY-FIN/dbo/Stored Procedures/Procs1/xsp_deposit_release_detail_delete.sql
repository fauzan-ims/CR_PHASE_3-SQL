CREATE PROCEDURE dbo.xsp_deposit_release_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg						nvarchar(max) 
			,@deposit_release_code		nvarchar(50)
			,@deposit_code				nvarchar(50)
			,@sum_amount				decimal(18, 2) ;

	begin try
		select	@deposit_release_code	= deposit_release_code
				,@deposit_code			= deposit_code
		from	dbo.deposit_release_detail
		where	id = @p_id ;

		delete deposit_release_detail
		where	id = @p_id ;

		select	@sum_amount		= sum(release_amount)
		from	dbo.deposit_release_detail
		where	deposit_release_code = @deposit_release_code

		update	dbo.deposit_release
		set		release_amount	= isnull(@sum_amount,0)
		where	code			= @deposit_release_code
		
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
