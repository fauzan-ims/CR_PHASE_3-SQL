create procedure xsp_ams_interface_document_request_insert
(
	@p_id						   bigint = 0 output
	,@p_code					   nvarchar(50)
	,@p_request_branch_code		   nvarchar(50)
	,@p_request_branch_name		   nvarchar(250)
	,@p_request_type			   nvarchar(20)
	,@p_request_location		   nvarchar(20)
	,@p_request_from			   nvarchar(50)
	,@p_request_to				   nvarchar(50)
	,@p_request_to_branch_code	   nvarchar(50)
	,@p_request_to_branch_name	   nvarchar(250)
	,@p_request_to_agreement_no	   nvarchar(50)
	,@p_request_to_client_name	   nvarchar(250)
	,@p_request_from_dept_code	   nvarchar(50)
	,@p_request_from_dept_name	   nvarchar(250)
	,@p_request_to_dept_code	   nvarchar(50)
	,@p_request_to_dept_name	   nvarchar(250)
	,@p_request_to_thirdparty_type nvarchar(250)
	,@p_agreement_no			   nvarchar(50)
	,@p_collateral_no			   nvarchar(50)
	,@p_asset_no				   nvarchar(50)
	,@p_request_by				   nvarchar(250)
	,@p_request_status			   nvarchar(50)
	,@p_request_date			   datetime
	,@p_remarks					   nvarchar(4000)
	,@p_document_code			   nvarchar(50)
	,@p_process_date			   datetime
	,@p_process_reff_no			   nvarchar(50)
	,@p_process_reff_name		   nvarchar(250)
	,@p_job_status				   nvarchar(20)
	,@p_failed_remark			   nvarchar(4000)
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
	declare @msg nvarchar(max) ;

	begin try
		insert into ams_interface_document_request
		(
			code
			,request_branch_code
			,request_branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_to_branch_code
			,request_to_branch_name
			,request_to_agreement_no
			,request_to_client_name
			,request_from_dept_code
			,request_from_dept_name
			,request_to_dept_code
			,request_to_dept_name
			,request_to_thirdparty_type
			,agreement_no
			,collateral_no
			,asset_no
			,request_by
			,request_status
			,request_date
			,remarks
			,document_code
			,process_date
			,process_reff_no
			,process_reff_name
			,job_status
			,failed_remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_code
			,@p_request_branch_code
			,@p_request_branch_name
			,@p_request_type
			,@p_request_location
			,@p_request_from
			,@p_request_to
			,@p_request_to_branch_code
			,@p_request_to_branch_name
			,@p_request_to_agreement_no
			,@p_request_to_client_name
			,@p_request_from_dept_code
			,@p_request_from_dept_name
			,@p_request_to_dept_code
			,@p_request_to_dept_name
			,@p_request_to_thirdparty_type
			,@p_agreement_no
			,@p_collateral_no
			,@p_asset_no
			,@p_request_by
			,@p_request_status
			,@p_request_date
			,@p_remarks
			,@p_document_code
			,@p_process_date
			,@p_process_reff_no
			,@p_process_reff_name
			,@p_job_status
			,@p_failed_remark
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
