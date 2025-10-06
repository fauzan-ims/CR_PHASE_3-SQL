CREATE PROCEDURE dbo.xsp_application_asset_component_delete
(
	@p_id bigint
)
as
begin
	declare @msg		nvarchar(max) 
			,@asset_no	nvarchar(50) ; 

	begin try
		select	@asset_no = asset_no
		from	application_asset_component 
		where	id = @p_id ; 

		delete application_asset_component
		where	id = @p_id ;
	end try
	Begin catch
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

