/*
	ALTERd : Louis, 20 May 2020
*/
/*
	ALTERd : Louis, 20 May 2020
*/
CREATE PROCEDURE dbo.xsp_client_survey_request_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@client_code			nvarchar(50)
			,@survey_status			nvarchar(10)
			,@survey_date			datetime
			,@survey_remarks		nvarchar(4000)
			,@survey_result_date	datetime
			,@survey_result_value	nvarchar(250)
			,@survey_result_remarks nvarchar(4000)
			,@process_date			datetime
			,@process_reff_no		nvarchar(50)
			,@process_reff_name		nvarchar(250)
			,@currency_code			nvarchar(3)
			,@request_id			bigint
			,@survey_fee_amount	    decimal(18, 2) ;

	begin try
		select @client_code = client_code from dbo.client_survey_request where code = @p_code;

		exec [dbo].[xsp_client_update_invalid] @p_client_code		= @client_code  
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address

		if exists
		(
			select	1
			from	dbo.client_survey_request
			where	code			  = @p_code
					and survey_status = 'HOLD'
		)
		begin
			select	@client_code				= client_code
					,@survey_status				= survey_status
					,@survey_date				= survey_date
					,@survey_remarks			= survey_remarks
					,@survey_result_remarks		= survey_result_remarks
					,@currency_code			= currency_code
					,@survey_fee_amount		= survey_fee_amount
			from	client_survey_request
			where	code						= @p_code ;

			update	dbo.client_survey_request
			set		survey_status	= 'REQUEST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
			
			if exists (	select 1 from dbo.master_survey
						where is_active = '1'
						and		reff_survey_category_code = 'QTYPESVY'
						and		code = 'APPLICATION_SURVEY'
					)
			begin
				exec dbo.xsp_los_interface_survey_request_insert @p_id							= @request_id output
																  ,@p_code						= ''
																  ,@p_branch_code				= ''
																  ,@p_branch_name				= ''
																  ,@p_reff_code					= @p_code
																  ,@p_reff_name					= N'CLIENT SURVEY'  
																  ,@p_reff_remarks				= @survey_remarks
																  ,@p_status					= N'HOLD'  
																  ,@p_date						= @survey_date
																  ,@p_survey_result_date		= null
																  ,@p_survey_result_value		= null
																  ,@p_survey_result_remarks		= null
																  ,@p_process_date				= null
																  ,@p_process_reff_no			= null
																  ,@p_process_reff_name			= null
																  ,@p_survey_fee_amount			= @survey_fee_amount
																  ,@p_currency_code				= @currency_code
																  ,@p_cre_date					= @p_mod_date		
																  ,@p_cre_by					= @p_mod_by			
																  ,@p_cre_ip_address			= @p_mod_ip_address
																  ,@p_mod_date					= @p_mod_date		
																  ,@p_mod_by					= @p_mod_by			
																  ,@p_mod_ip_address			= @p_mod_ip_address

				exec dbo.xsp_los_interface_request_detail	@p_type					= N'SURVEY'            
															,@p_master_reff_type	= N'QTYPESVY'         
															,@p_reff_code			= @client_code       
															,@p_reff_table			= N'CLIENT_MAIN'
															,@p_request_id			= @request_id                  
															,@p_master_code			= 'APPLICATION_SURVEY'
															,@p_mod_date			= @p_mod_date
															,@p_mod_by				= @p_mod_by
															,@p_mod_ip_address		= @p_mod_ip_address ;
			end
		end ;
		else
		begin
			set @msg = 'Data already proceed';
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

