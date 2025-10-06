CREATE PROCEDURE dbo.xsp_master_transaction_get_agreement
as
begin
	declare	@msg			nvarchar(max)
			,@module_name	nvarchar(250)

	begin try
	
			select 	module_name
			from	dbo.master_transaction mt
					inner join journal_gl_link jgl on (jgl.code = mt.gl_link_code)
			where   gl_link_code = 'AGRE'
					and mt.is_active = '1'
							
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

end


