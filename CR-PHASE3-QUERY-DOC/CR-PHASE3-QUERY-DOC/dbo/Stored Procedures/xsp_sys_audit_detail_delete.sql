CREATE PROCEDURE dbo.xsp_sys_audit_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg   nvarchar(max)
			,@date datetime ;

	begin try
		select	@date = date
		from	dbo.sys_audit_detail
		where	id = @p_id ;

		if (cast(@date as date) = cast(dbo.xfn_get_system_date() as date))
		begin
			delete sys_audit_detail
			where	id = @p_id ;
		end ;
		else
		begin
			set @msg = 'Date must be equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--if (cast(@date as date) > cast(dbo.xfn_get_system_date() as date))
		--begin
		--	set @msg = 'Date must be less then or equal then System Date' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else
		--begin
		--	delete sys_audit_detail
		--	where	id = @p_id ;
		--end
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
