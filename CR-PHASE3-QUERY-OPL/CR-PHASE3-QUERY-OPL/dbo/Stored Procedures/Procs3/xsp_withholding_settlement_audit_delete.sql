/*
exec dbo.xsp_withholding_settlement_audit_delete @p_code = N'' -- nvarchar(50)
*/

-- Louis Jumat, 02 Juni 2023 16.07.49 -- 
CREATE PROCEDURE dbo.xsp_withholding_settlement_audit_delete
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		delete	withholding_settlement_audit
		where	code = @p_code ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 547)
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
