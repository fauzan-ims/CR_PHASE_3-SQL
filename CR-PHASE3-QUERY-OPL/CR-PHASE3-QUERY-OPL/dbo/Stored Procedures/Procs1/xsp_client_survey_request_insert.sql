CREATE PROCEDURE dbo.xsp_client_survey_request_insert
(
	@p_code					  nvarchar(50)	 output
	,@p_client_code			  nvarchar(50)
	,@p_survey_status		  nvarchar(10)
	,@p_survey_date			  datetime
	,@p_survey_fee_amount	  decimal(18, 2)
	,@p_survey_remarks		  nvarchar(4000)
	,@p_survey_result_date	  datetime		 = null
	,@p_survey_result_value	  nvarchar(250)	 = ''
	,@p_survey_result_remarks nvarchar(4000) = ''
	,@p_currency_code		  nvarchar(3)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50) 
			,@branch_code	nvarchar(50)
			,@survey_object nvarchar(max) = '' ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ASR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'client_SURVEY_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if (@p_survey_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 
		
		exec @survey_object = dbo.xfn_get_object_description @p_client_code,'CLIENT','SURVEY'
		insert into client_survey_request
		(
			code
			,client_code
			,survey_status
			,survey_date
			,survey_fee_amount
			,survey_remarks
			,survey_result_date
			,survey_result_remarks
			,survey_object
			,currency_code
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
			,@p_client_code
			,@p_survey_status
			,@p_survey_date
			,@p_survey_fee_amount
			,@p_survey_remarks
			,@p_survey_result_date
			,@p_survey_result_remarks
			,@survey_object
			,@p_currency_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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

