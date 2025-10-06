CREATE PROCEDURE [dbo].[xsp_audit_trail_print]
(
	@p_table_name nvarchar(100)
)
as
begin
	declare @msg	nvarchar(max)
			,@query	nvarchar(4000);

	begin try

		set @query = 'SELECT * FROM Z_AUDIT_' + @p_table_name
		
		--print @query

		EXECUTE sp_executesql @query

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
