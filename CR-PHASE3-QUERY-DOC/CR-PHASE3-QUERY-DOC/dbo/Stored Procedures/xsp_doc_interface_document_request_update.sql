CREATE PROCEDURE dbo.xsp_doc_interface_document_request_update
(
	@p_code					nvarchar(50)
	,@p_request_branch_code nvarchar(50)
	,@p_request_branch_name nvarchar(250)
	,@p_request_type		nvarchar(20)
	,@p_request_location	nvarchar(20)
	,@p_request_from		nvarchar(50)
	,@p_request_to			nvarchar(50)
	,@p_request_by			nvarchar(250)
	,@p_request_status		nvarchar(50)
	,@p_request_date		datetime
	,@p_remarks				nvarchar(4000)
	,@p_process_date		datetime
	,@p_process_reff_no		nvarchar(50)
	,@p_process_reff_name	nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	doc_interface_document_request
		set		request_branch_code = @p_request_branch_code
				,request_branch_name = @p_request_branch_name
				,request_type = @p_request_type
				,request_location = @p_request_location
				,request_from = @p_request_from
				,request_to = @p_request_to
				,request_by = @p_request_by
				,request_status = @p_request_status
				,request_date = @p_request_date
				,remarks = @p_remarks
				,process_date = @p_process_date
				,process_reff_no = @p_process_reff_no
				,process_reff_name = @p_process_reff_name
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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
