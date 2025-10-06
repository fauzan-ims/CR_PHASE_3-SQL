CREATE PROCEDURE dbo.xsp_sys_audit_detail_update
(
	@p_id			   bigint
	,@p_audit_code	   nvarchar(50)
	,@p_date		   datetime
	,@p_progress	   nvarchar(250)
	,@p_remark		   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (cast(@p_date as date) > cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = 'Date must be less then or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	sys_audit_detail
		set		audit_code		= @p_audit_code
				,date			= @p_date
				,progress		= @p_progress
				,remark			= @p_remark
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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
