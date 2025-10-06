create PROCEDURE dbo.xsp_master_approval_update
(
	@p_code							nvarchar(50)
	,@p_approval_name				nvarchar(250)
	,@p_reff_approval_category_code nvarchar(50)
	,@p_reff_approval_category_name nvarchar(250)
	,@p_is_active					nvarchar(1)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		update	master_approval
		set		approval_name = @p_approval_name
				,reff_approval_category_code = @p_reff_approval_category_code
				,reff_approval_category_name = @p_reff_approval_category_name
				,is_active = @p_is_active
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
