-- Louis Senin, 07 Juli 2025 17.57.18 --
create PROCEDURE [dbo].[xsp_application_asset_update_asset_status]
(
	@p_application_no		 nvarchar(50)
	,@p_status				nvarchar(250) = ''
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.application_asset
		set		asset_status = @p_status
		where	application_no = @p_application_no ;
	end try
	begin catch 
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
