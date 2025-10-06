CREATE procedure dbo.xsp_asset_other_upload_delete
(
	@p_fa_upload_id bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete asset_other_upload
		where	fa_upload_id = @p_fa_upload_id ;
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
			set @msg = 'v' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'e;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 	
end ;
