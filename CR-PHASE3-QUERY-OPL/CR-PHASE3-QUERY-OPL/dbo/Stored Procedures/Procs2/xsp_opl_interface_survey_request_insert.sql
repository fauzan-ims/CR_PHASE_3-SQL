CREATE PROCEDURE dbo.xsp_opl_interface_survey_request_insert

(
	@p_id							 bigint			= 0 output
	,@p_code						 nvarchar(50)
	,@p_branch_code					 nvarchar(50)
	,@p_branch_name					 nvarchar(250)
	,@p_reff_code					 nvarchar(50)
	,@p_reff_name					 nvarchar(50)
	,@p_reff_remarks				 nvarchar(4000)
	,@p_status						 nvarchar(10)
	,@p_date						 datetime
	,@p_survey_result_date			 datetime
	,@p_survey_result_value			 nvarchar(250)
	,@p_survey_result_remarks		 nvarchar(4000)
	,@p_process_date				 datetime
	,@p_process_reff_no				 nvarchar(50)
	,@p_process_reff_name			 nvarchar(250)
	,@p_currency_code				 nvarchar(3)
	,@p_survey_fee_amount			 decimal(18, 2)
	,@p_reff_object					 nvarchar(4000)
	--
	,@p_application_no				 nvarchar(50)	= ''
	,@p_contact_person_name			 nvarchar(250)	= ''
	,@p_contact_person_area_phone_no nvarchar(4)	= ''
	,@p_contact_person_phone_no		 nvarchar(15)	= ''
	,@p_address						 nvarchar(4000) = ''
	--
	,@p_cre_date					 datetime
	,@p_cre_by						 nvarchar(15)
	,@p_cre_ip_address				 nvarchar(15)
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@code	nvarchar(50)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'OPLSVR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'OPL_INTERFACE_SURVEY_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		insert into dbo.opl_interface_survey_request
		(
			code
			,branch_code
			,branch_name
			,reff_code
			,reff_name
			,reff_remarks
			,status
			,date
			,survey_result_date
			,survey_result_value
			,survey_result_remarks
			,process_date
			,process_reff_no
			,process_reff_name
			,survey_fee_amount
			,currency_code
			,reff_object
			--
			,application_no
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
			,address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,@p_reff_code
			,@p_reff_name
			,@p_reff_remarks
			,@p_status
			,@p_date
			,@p_survey_result_date
			,@p_survey_result_value
			,@p_survey_result_remarks
			,@p_process_date
			,@p_process_reff_no
			,@p_process_reff_name
			,@p_survey_fee_amount
			,@p_currency_code
			,@p_reff_object
			--
			,@p_application_no
			,@p_contact_person_name
			,@p_contact_person_area_phone_no
			,@p_contact_person_phone_no
			,@p_address
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

