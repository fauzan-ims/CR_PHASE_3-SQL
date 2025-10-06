CREATE PROCEDURE dbo.xsp_application_asset_scoring_request_update
(
	@p_code					   nvarchar(50)
	,@p_asset_no			   nvarchar(50)
	,@p_scoring_status		   nvarchar(10)
	,@p_scoring_date		   datetime
	,@p_scoring_remarks		   nvarchar(4000)
	,@p_scoring_result_date	   datetime		 = null
	,@p_scoring_result_value   nvarchar(250) = null
	,@p_scoring_result_grade   nvarchar(50)  = null
	,@p_scoring_result_remarks nvarchar(4000)= null
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_scoring_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 
		update	application_asset_scoring_request
		set		asset_no				= @p_asset_no
				,scoring_status			= @p_scoring_status
				,scoring_date			= @p_scoring_date
				,scoring_remarks		= @p_scoring_remarks
				,scoring_result_date	= @p_scoring_result_date
				,scoring_result_value	= @p_scoring_result_value
				,scoring_result_grade	= ''
				,scoring_result_remarks = @p_scoring_result_remarks
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
		
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

