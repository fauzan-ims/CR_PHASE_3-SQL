CREATE PROCEDURE dbo.xsp_endorsement_request_insert
(
	@p_code						   nvarchar(50) OUTPUT
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_policy_code				   nvarchar(50)
	,@p_endorsement_request_status nvarchar(10)
	,@p_endorsement_request_date   datetime
	,@p_endorsement_request_type   nvarchar(10)
	,@p_endorsement_code		   nvarchar(50)
	,@p_request_reff_no			   nvarchar(50)
	,@p_request_reff_name		   nvarchar(250)
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@is_existing				nvarchar(1)
			,@policy_process_status		nvarchar(10); 

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ER'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ENDORSEMENT_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		select @policy_process_status = isnull(policy_process_status, '')
			   ,@is_existing		  = is_policy_existing
		from dbo.insurance_policy_main
		where  code = @p_policy_code

		
		if @is_existing = '1'
		begin
			set @msg = 'Please change policy, This policy existing';
			raiserror(@msg, 16, -1);
		end

		if (@policy_process_status is not null)
		begin
			set @msg = 'This policy already proceed in ' + lower(substring(@policy_process_status,0,len(@policy_process_status)));
			raiserror(@msg, 16, -1) ;
		end

		insert into endorsement_request
		(
			code
			,branch_code
			,branch_name
			,policy_code
			,endorsement_request_status
			,endorsement_request_date
			,endorsement_request_type
			,endorsement_code
			,request_reff_no
			,request_reff_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_policy_code
			,@p_endorsement_request_status
			,@p_endorsement_request_date
			,@p_endorsement_request_type
			,@p_endorsement_code
			,@p_request_reff_no
			,@p_request_reff_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		UPDATE dbo.insurance_policy_main
		SET	   policy_process_status = 'ENDORSEMENT'
		WHERE  code = @p_policy_code

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



