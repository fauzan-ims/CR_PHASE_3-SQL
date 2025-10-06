create procedure [dbo].[xsp_application_asset_primary_budget_delete]
(
	@p_asset_no	  nvarchar(50)
	,@p_cost_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete	application_asset_budget
		where	asset_no	  = @p_asset_no
				and cost_code = @p_cost_code ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
