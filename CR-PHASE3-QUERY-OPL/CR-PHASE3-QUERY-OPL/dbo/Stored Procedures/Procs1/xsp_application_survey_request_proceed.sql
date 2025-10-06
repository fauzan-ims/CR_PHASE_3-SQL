/*
	ALTERd : Louis, 20 May 2020
*/
CREATE PROCEDURE dbo.xsp_application_survey_request_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@application_no					nvarchar(50)
			,@survey_status						nvarchar(10)
			,@survey_date						datetime
			,@survey_remarks					nvarchar(4000)
			,@survey_result_date				datetime
			,@survey_result_value				nvarchar(250)
			,@survey_result_remarks				nvarchar(4000)
			,@process_date						datetime
			,@process_reff_no					nvarchar(50)
			,@process_reff_name					nvarchar(250) 
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(50)
			,@currency_code						nvarchar(3)
			,@survey_fee_amount					decimal(18, 2)
			,@request_id						bigint
			,@reff_object						nvarchar(4000) 
			--(+) Saparudin : 02-08-2021
			,@contact_person_name				nvarchar(250)
			,@contact_person_area_phone_no		NVARCHAR(4)
			,@contact_person_phone_no			nvarchar(15)
			,@address							nvarchar(4000)
			,@applicatin_external_no			nvarchar(50);

	begin try
		if exists
		(
			select	1
			from	dbo.application_survey_request
			where	code			  = @p_code
					and survey_status = 'HOLD'
		)
		begin
			if not exists
			(
				select	1
				from	dbo.master_survey
				where	is_active					  = '1'
						and reff_survey_category_code = 'QTYPESVY'
						and code					  = 'APPLICATION_SURVEY'
			)
			begin
				set @msg = 'Please setting master survey for APPLICATION_SURVEY' ;

				raiserror(@msg, 16, 1) ; 
			end ;

			select	@application_no					= application_no
					,@survey_status					= survey_status
					,@survey_date					= survey_date
					,@survey_remarks				= survey_remarks
					,@survey_result_date			= survey_result_date
					,@survey_result_value			= survey_result_value
					,@survey_result_remarks			= survey_result_remarks
					,@currency_code					= currency_code
					,@survey_fee_amount				= survey_fee_amount
					,@reff_object					= survey_object
					--(+) Saparudin : 02-08-2021
					,@contact_person_name			= contact_person_name
					,@contact_person_area_phone_no	= contact_person_area_phone_no
					,@contact_person_phone_no		= contact_person_phone_no
					,@address						= address
					,@applicatin_external_no		= application_external_no
			from	application_survey_request 
			where	code					= @p_code ;

			select	@branch_code = branch_code
					,@branch_name = branch_name
			from	dbo.application_main
			where	application_no = @application_no ;			
			
			update	dbo.application_survey_request
			set		survey_status	= 'REQUEST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ; 
			
						
			exec dbo.xsp_application_survey_fee_update	@p_application_no	= @application_no
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address

			if exists (	select 1 from dbo.master_survey
						where is_active = '1'
						and		reff_survey_category_code = 'QTYPESVY'
						and		code = 'APPLICATION_SURVEY'
					)
			begin

				exec dbo.xsp_opl_interface_survey_request_insert @p_id								= @request_id output
																  ,@p_code							= ''
																  ,@p_branch_code					= @branch_code
																  ,@p_branch_name					= @branch_name
																  ,@p_reff_code						= @p_code
																  ,@p_reff_name						= N'APPLICATION SURVEY'  
																  ,@p_reff_remarks					= @survey_remarks
																  ,@p_status						= N'HOLD'  
																  ,@p_date							= @survey_date
																  ,@p_survey_result_date			= null
																  ,@p_survey_result_value			= null
																  ,@p_survey_result_remarks			= null
																  ,@p_process_date					= null
																  ,@p_process_reff_no				= null
																  ,@p_process_reff_name				= null
																  ,@p_survey_fee_amount				= @survey_fee_amount
																  ,@p_currency_code					= @currency_code
																  ,@p_reff_object					= @reff_object
																  ,@p_application_no				= @applicatin_external_no
																  --(+) Saparudin : 02-08-2021
																  ,@p_contact_person_name			= @contact_person_name
																  ,@p_contact_person_area_phone_no	= @contact_person_area_phone_no
				                                                  ,@p_contact_person_phone_no		= @contact_person_phone_no
				                                                  ,@p_address						= @address
																  --
																  ,@p_cre_date						= @p_mod_date		
																  ,@p_cre_by						= @p_mod_by			
																  ,@p_cre_ip_address				= @p_mod_ip_address
																  ,@p_mod_date						= @p_mod_date		
																  ,@p_mod_by						= @p_mod_by			
																  ,@p_mod_ip_address				= @p_mod_ip_address

				exec dbo.xsp_opl_interface_request_detail	@p_type					= N'SURVEY'            
															,@p_master_reff_type	= N'QTYPESVY'         
															,@p_reff_code			= @application_no       
															,@p_reff_table			= N'APPLICATION_MAIN'
															,@p_request_code		= @p_code                  
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

