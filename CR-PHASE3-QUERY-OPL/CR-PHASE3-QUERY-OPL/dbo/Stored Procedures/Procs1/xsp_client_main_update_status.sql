CREATE PROCEDURE dbo.xsp_client_main_update_status
(
	@p_reff_no				  nvarchar(50)
	,@p_is_red_flag			  nvarchar(1)
	,@p_watchlist_status	  nvarchar(15)
	,@p_group_limit_amount	  decimal(18, 2) = 0
	,@p_os_expousure_amount	  decimal(18, 2) = 0
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@client_code nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no = @p_reff_no
		)
		begin
			select	@client_code = client_code
			from	dbo.application_main
			where	application_no = @p_reff_no ;

			update	dbo.client_main
			set		is_red_flag = @p_is_red_flag
					,watchlist_status = @p_watchlist_status
			where	code = @client_code ;

			update	application_information
			set		os_exposure_amount = @p_os_expousure_amount
					,group_limit_amount = @p_group_limit_amount
			where	application_no = @p_reff_no ;
		end ;
		else if exists
		(
			select	1
			from	dbo.drawdown_main
			where	drawdown_no = @p_reff_no
		)
		begin
			select	@client_code = client_code
			from	dbo.drawdown_main
			where	drawdown_no = @p_reff_no ;

			update	dbo.client_main
			set		is_red_flag = @p_is_red_flag
					,watchlist_status = @p_watchlist_status
			where	code = @client_code ;

			update	drawdown_information
			set		os_exposure_amount = @p_os_expousure_amount
					,group_limit_amount = @p_group_limit_amount
			where	drawdown_code = @p_reff_no ;
		end ;
		else if exists
		(
			select	1
			from	dbo.plafond_main
			where	code = @p_reff_no
		)
		begin
			select	@client_code = client_code
			from	dbo.plafond_main
			where	code = @p_reff_no ;

			update	dbo.client_main
			set		is_red_flag = @p_is_red_flag
					,watchlist_status = @p_watchlist_status
			where	code = @client_code ;
		end ;
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

