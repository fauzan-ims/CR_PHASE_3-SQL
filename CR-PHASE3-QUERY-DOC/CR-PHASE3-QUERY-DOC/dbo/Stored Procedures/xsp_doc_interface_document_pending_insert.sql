CREATE procedure [dbo].[xsp_doc_interface_document_pending_insert]
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
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

	insert into doc_interface_document_pending
	(
		code
		,request_branch_code
		,request_branch_name
		,general_document_code
		,document_status
		,document_expired_date
		,file_name
		,paths
		,agreement_no
		,collateral_no
		,asset_no
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
		,@p_general_document_code
		,@p_document_status
		,@p_document_expired_date
		,@p_file_name
		,@p_paths
		,@p_agreement_no
		,@p_collateral_no
		,@p_asset_no
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
end
