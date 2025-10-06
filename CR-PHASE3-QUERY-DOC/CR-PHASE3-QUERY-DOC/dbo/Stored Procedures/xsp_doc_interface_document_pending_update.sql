CREATE procedure [dbo].[xsp_doc_interface_document_pending_update]
(
	@p_code					  nvarchar(50)
	,@p_request_branch_code	  nvarchar(50)
	,@p_request_branch_name	  nvarchar(250)
	,@p_general_document_code nvarchar(50)
	,@p_document_status		  nvarchar(10)
	,@p_document_expired_date datetime
	,@p_file_name			  nvarchar(250)
	,@p_paths				  nvarchar(250)
	,@p_agreement_no		  nvarchar(50)
	,@p_collateral_no		  nvarchar(50)
	,@p_asset_no			  nvarchar(50)
	,@p_process_date		  datetime
	,@p_process_reff_no		  nvarchar(50)
	,@p_process_reff_name	  nvarchar(250)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	doc_interface_document_pending
		set		request_branch_code = @p_request_branch_code
				,request_branch_name = @p_request_branch_name
				,general_document_code = @p_general_document_code
				,document_status = @p_document_status
				,document_expired_date = @p_document_expired_date
				,file_name = @p_file_name
				,paths = @p_paths
				,agreement_no = @p_agreement_no
				,collateral_no = @p_collateral_no
				,asset_no = @p_asset_no
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
		declare  @error int
		set  @error = @@error
		 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;
	
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;
	
		raiserror(@msg, 16, -1) ;
	
		return ; 
	end catch ;
end ;
