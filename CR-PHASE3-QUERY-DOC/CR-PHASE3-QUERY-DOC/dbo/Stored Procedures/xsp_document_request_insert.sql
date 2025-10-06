CREATE PROCEDURE dbo.xsp_document_request_insert
(
	@p_code						 nvarchar(50) 
	,@p_branch_code				 nvarchar(20)
	,@p_branch_name				 nvarchar(250)
	,@p_request_type			 nvarchar(20)
	,@p_request_location		 nvarchar(20)
	,@p_request_from			 nvarchar(50)
	,@p_request_to				 nvarchar(50)
	,@p_request_to_client_name	 nvarchar(250)
	,@p_request_to_branch_code	 nvarchar(50)
	,@p_request_to_branch_name	 nvarchar(250)
	,@p_request_from_dept_code	 nvarchar(50)
	,@p_request_from_dept_name	 nvarchar(250)
	,@p_request_to_dept_code	 nvarchar(50)
	,@p_request_to_dept_name	 nvarchar(250)
	,@p_request_by				 nvarchar(250)
	,@p_request_status			 nvarchar(50)
	,@p_request_date			 datetime
	,@p_remarks					 nvarchar(4000)
	,@p_document_code			 nvarchar(50)
	,@p_agreement_no			 nvarchar(50)
	,@p_collateral_no			 nvarchar(50)
	,@p_asset_no				 nvarchar(50)
	,@p_request_to_thirdparty_type	NVARCHAR(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@date	nvarchar(2);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;


	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'DR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'DOCUMENT_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
	begin try
		insert into DOCUMENT_REQUEST
		(
		    code,
		    branch_code,
		    branch_name,
		    request_type,
		    request_location,
		    request_from,
		    request_to,
		    request_to_client_name,
		    request_to_branch_code,
		    request_to_branch_name,
		    request_from_dept_code,
		    request_from_dept_name,
		    request_to_dept_code,
		    request_to_dept_name,
		    request_by,
		    request_status,
		    request_date,
		    remarks,
		    document_code,
		    agreement_no,
		    collateral_no,
		    asset_no,
			request_to_thirdparty_type,
			--
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_request_type
			,@p_request_location
			,@p_request_from
			,@p_request_to
			,@p_request_to_client_name	
			,@p_request_to_branch_code	
			,@p_request_to_branch_name	
			,@p_request_from_dept_code	
			,@p_request_from_dept_name	
			,@p_request_to_dept_code	
			,@p_request_to_dept_name	
			,@p_request_by
			,@p_request_status
			,@p_request_date
			,@p_remarks
			,@p_document_code
			,@p_agreement_no
			,@p_collateral_no
			,@p_asset_no
			,@p_request_to_thirdparty_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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


