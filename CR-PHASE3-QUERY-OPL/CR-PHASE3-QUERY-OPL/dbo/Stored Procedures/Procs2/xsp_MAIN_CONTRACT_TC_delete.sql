-- Louis Selasa, 30 April 2024 18.54.05 --
CREATE PROCEDURE [dbo].[xsp_MAIN_CONTRACT_TC_delete]
(
	@p_main_contract_no	nvarchar(50)
	,@p_id				bigint
)
AS
BEGIN
	declare	@msg	nvarchar(max)
	begin try
		delete dbo.MAIN_CONTRACT_TC
		where	main_contract_no = @p_main_contract_no
				and id		   = @p_id ;

		update	dbo.application_extention
		set		is_valid					= '0' 
		where	main_contract_no			= @p_main_contract_no
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
