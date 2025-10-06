CREATE PROCEDURE dbo.xsp_doc_interface_document_request_insert
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
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		insert into doc_interface_document_request
		(
			code
			,request_branch_code
			,request_branch_name
			,request_type
			,request_location
			,request_from
			,request_to
			,request_by
			,request_status
			,request_date
			,remarks
			,process_date
			,process_reff_no
			,process_reff_name
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
			,@p_request_by
			,@p_request_status
			,@p_request_date
			,@p_remarks
			,@p_process_date
			,@p_process_reff_no
			,@p_process_reff_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

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
end
