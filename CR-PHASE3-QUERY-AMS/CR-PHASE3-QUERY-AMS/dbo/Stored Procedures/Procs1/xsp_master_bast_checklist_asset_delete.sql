--Created, Rian at 28/12/2022

CREATE PROCEDURE dbo.xsp_master_bast_checklist_asset_delete
(
	@p_code				nvarchar(50)
	,@p_asset_type_code	nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete	dbo.master_bast_checklist_asset
		where	code			= @p_code
		and		asset_type_code	= @p_asset_type_code;
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
