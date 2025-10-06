/*
	ALTERd : louis, 20 may 2020
*/
CREATE PROCEDURE dbo.xsp_application_asset_scoring_request_post
(
	@p_code					   nvarchar(50)
	,@p_scoring_result_value   nvarchar(250)  = ''
	,@p_scoring_result_remarks nvarchar(4000) = ''
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg	   nvarchar(max) 
			,@asset_no nvarchar(50) ;

	begin try
		select	@asset_no = asset_no
		from	application_asset_scoring_request 
		where	code = @p_code ;
		if exists
		(
			select	1
			from	dbo.application_asset_scoring_request
			where	code			   = @p_code
					and scoring_status = 'REQUEST'
		)
		begin
			update	dbo.application_asset_scoring_request
			set		scoring_status			= 'POST'
					,scoring_result_date	= @p_mod_date
					,scoring_result_value	= @p_scoring_result_value
					,scoring_result_remarks	= @p_scoring_result_remarks
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
			 
			update dbo.opl_interface_scoring_request
			set		status					= 'POST'
					,scoring_result_date	= @p_mod_date
					,scoring_result_value	= @p_scoring_result_value
					,scoring_result_remarks	= @p_scoring_result_remarks
					,process_date			= @p_mod_date
					,process_reff_no		= ''
					,process_reff_name		= ''
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	reff_code				= @p_code
		end ;
		else
		begin
			set @msg = 'Data already post or document file not uploaded';
			raiserror(@msg, 16, 1) ;
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

