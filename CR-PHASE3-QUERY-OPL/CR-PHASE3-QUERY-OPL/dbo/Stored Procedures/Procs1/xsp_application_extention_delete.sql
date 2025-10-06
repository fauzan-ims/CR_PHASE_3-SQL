--created by, Rian at 22/05/2023 

CREATE PROCEDURE xsp_application_extention_delete
(
	@p_application_no	nvarchar(50)
	,@p_id				bigint
)
AS
BEGIN
	declare	@msg	nvarchar(max)
	begin try
		delete dbo.application_extention
		where	application_no = @p_application_no
				and id		   = @p_id ;
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
END
