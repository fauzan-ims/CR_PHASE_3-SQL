CREATE PROCEDURE dbo.xsp_client_survey_request_update
(
	@p_code					  nvarchar(50)
	,@p_client_code			  nvarchar(50)
	,@p_survey_status		  nvarchar(10)
	,@p_survey_date			  datetime
	,@p_survey_fee_amount	  decimal(18, 2) = 0
	,@p_survey_remarks		  nvarchar(4000)
	,@p_survey_result_date	  datetime		 = null
	,@p_survey_result_remarks nvarchar(4000) = null
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_survey_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 
		
		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @p_client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		update	client_survey_request
		set		client_code				= @p_client_code
				,survey_status			= @p_survey_status
				,survey_date			= @p_survey_date
				,survey_fee_amount		= @p_survey_fee_amount
				,survey_remarks			= @p_survey_remarks
				,survey_result_date		= @p_survey_result_date
				,survey_result_remarks	= @p_survey_result_remarks
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

