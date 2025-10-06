CREATE PROCEDURE dbo.xsp_client_main_update
(
	@p_code						 nvarchar(50)
	,@p_client_type				 nvarchar(10)
	,@p_client_name				 nvarchar(250)
	,@p_client_group_code		 nvarchar(50) = null
	,@p_client_group_name		 nvarchar(250) = null
	,@p_watchlist_status		 nvarchar(10)
	,@p_is_validate				 nvarchar(1)
	,@p_status_slik_checking	 nvarchar(1)
	,@p_status_dukcapil_checking nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_validate = 'T'
		set @p_is_validate = '1' ;
	else
		set @p_is_validate = '0' ;

	begin try
		update	client_main
		set		client_type					= @p_client_type
				,client_name				= @p_client_name
				,client_group_code			= @p_client_group_code
				,client_group_name			= @p_client_group_name
				,watchlist_status			= @p_watchlist_status
				,is_validate				= @p_is_validate
				,status_slik_checking		= @p_status_slik_checking
				,status_dukcapil_checking	= @p_status_dukcapil_checking
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

