
create procedure [dbo].[xsp_transaction_lock_history_update]
(
	@p_id			   bigint
	,@p_user_id		   nvarchar(50)
	,@p_user_name	   nvarchar(250)
	,@p_reff_name	   nvarchar(250)
	,@p_reff_code	   nvarchar(50)
	,@p_access_date	   datetime
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		update	transaction_lock_history
		set		user_id = @p_user_id
				,user_name = @p_user_name
				,reff_name = @p_reff_name
				,reff_code = @p_reff_code
				,access_date = @p_access_date
				,is_active = @p_is_active
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
