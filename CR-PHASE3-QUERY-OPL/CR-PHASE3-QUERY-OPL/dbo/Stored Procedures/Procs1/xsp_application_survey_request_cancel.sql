/*
	ALTERd : Louis, 20 May 2020
*/
CREATE PROCEDURE dbo.xsp_application_survey_request_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@application_no	nvarchar(50)
			,@total_survey  decimal(18, 2)
			,@survey_remark nvarchar(250) ;

	begin try
			select	@application_no			= application_no
			from	application_survey_request 
			where	code					= @p_code ;
		if exists
		(
			select	1
			from	dbo.application_survey_request
			where	code			  = @p_code
					and survey_status = 'HOLD'
					or	survey_status = 'REQUEST'
		)
		begin
			update	dbo.application_survey_request
			set		survey_status	= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ; 
			
			exec dbo.xsp_application_survey_fee_update  @p_application_no	= @application_no
														,@p_mod_date		= @p_mod_date	  
														,@p_mod_by			= @p_mod_by		  
														,@p_mod_ip_address	= @p_mod_ip_address
			
		end ;
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
		end ;
	end try
	Begin catch
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

