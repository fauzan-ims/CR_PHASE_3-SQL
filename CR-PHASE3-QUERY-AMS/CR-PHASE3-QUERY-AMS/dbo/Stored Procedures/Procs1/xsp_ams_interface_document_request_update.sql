
create procedure xsp_ams_interface_document_request_update
(
	@p_id						   bigint
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
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	ams_interface_document_request
		set		code = @p_code
				,request_branch_code = @p_request_branch_code
				,request_branch_name = @p_request_branch_name
				,request_type = @p_request_type
				,request_location = @p_request_location
				,request_from = @p_request_from
				,request_to = @p_request_to
				,request_to_branch_code = @p_request_to_branch_code
				,request_to_branch_name = @p_request_to_branch_name
				,request_to_agreement_no = @p_request_to_agreement_no
				,request_to_client_name = @p_request_to_client_name
				,request_from_dept_code = @p_request_from_dept_code
				,request_from_dept_name = @p_request_from_dept_name
				,request_to_dept_code = @p_request_to_dept_code
				,request_to_dept_name = @p_request_to_dept_name
				,request_to_thirdparty_type = @p_request_to_thirdparty_type
				,agreement_no = @p_agreement_no
				,collateral_no = @p_collateral_no
				,asset_no = @p_asset_no
				,request_by = @p_request_by
				,request_status = @p_request_status
				,request_date = @p_request_date
				,remarks = @p_remarks
				,document_code = @p_document_code
				,process_date = @p_process_date
				,process_reff_no = @p_process_reff_no
				,process_reff_name = @p_process_reff_name
				,job_status = @p_job_status
				,failed_remark = @p_failed_remark
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
