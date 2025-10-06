CREATE PROCEDURE dbo.xsp_application_scoring_request_insert
(
	@p_code					   nvarchar(50)	  output
	,@p_application_no		   nvarchar(50)
	,@p_scoring_status		   nvarchar(10)
	,@p_scoring_date		   datetime
	,@p_scoring_remarks		   nvarchar(4000)
	,@p_scoring_result_date	   datetime		  = null
	,@p_scoring_result_value   nvarchar(250)  = ''
	,@p_scoring_result_grade   nvarchar(50)	  = ''
	,@p_scoring_result_remarks nvarchar(4000) = ''
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@year			 nvarchar(2)
			,@month			 nvarchar(2)
			,@code			 nvarchar(50)
			,@branch_code	 nvarchar(50)
			,@scoring_object nvarchar(max) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	select	@branch_code = branch_code
	from	dbo.application_main
	where	application_no = @p_application_no ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLASC'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_SCORING_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		exec @scoring_object = dbo.xfn_get_object_description @p_application_no
															  ,'APPLICATION'
															  ,'SCORING' ;

		insert into application_scoring_request
		(
			code
			,application_no
			,scoring_status
			,scoring_date
			,scoring_remarks
			,scoring_result_date
			,scoring_result_value
			,scoring_result_grade
			,scoring_result_remarks
			,scoring_object
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
			,@p_application_no
			,@p_scoring_status
			,@p_scoring_date
			,@p_scoring_remarks
			,@p_scoring_result_date
			,@p_scoring_result_value
			,''
			,@p_scoring_result_remarks
			,@scoring_object
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
