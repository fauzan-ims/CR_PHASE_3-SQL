CREATE PROCEDURE dbo.xsp_opl_interface_client_main_insert
(
	@p_id						 bigint = 0 output
	,@p_code					 nvarchar(50)
	,@p_client_type				 nvarchar(10)
	,@p_client_no				 nvarchar(50)
	,@p_client_name				 nvarchar(250)
	,@p_is_validate				 nvarchar(1)
	,@p_is_red_flag				 nvarchar(1)
	,@p_watchlist_status		 nvarchar(10)
	,@p_status_slik_checking	 nvarchar(10)
	,@p_status_dukcapil_checking nvarchar(10)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_validate = 'T'
		set @p_is_validate = '1' ;

	if @p_is_validate = 'F'
		set @p_is_validate = '0' ;

	if @p_is_red_flag = 'T'
		set @p_is_red_flag = '1' ;

	if @p_is_red_flag = 'F'
		set @p_is_red_flag = '0' ;

	begin try
		insert into opl_interface_client_main
		(
			code
			,client_type
			,client_no
			,client_name
			,is_validate
			,is_red_flag
			,watchlist_status
			,status_slik_checking
			,status_dukcapil_checking
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_client_type
			,@p_client_no
			,@p_client_name
			,@p_is_validate
			,@p_is_red_flag
			,@p_watchlist_status
			,@p_status_slik_checking
			,@p_status_dukcapil_checking
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

