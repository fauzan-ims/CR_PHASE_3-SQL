create PROCEDURE dbo.xsp_ifinproc_interface_document_pending_detail_insert
(
	@p_document_pending_code nvarchar(50)
	,@p_document_name		 nvarchar(250)
	,@p_document_description nvarchar(4000)
	,@p_file_name			 nvarchar(250)
	,@p_paths				 nvarchar(250)
	,@p_expired_date		 datetime
	,@p_is_temporary		 nvarchar(1)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		insert into dbo.ifinproc_interface_document_pending_detail
		(
			document_pending_code
			,document_name
			,document_description
			,file_name
			,paths
			,expired_date
			,is_temporary
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_document_pending_code
			,@p_document_name
			,@p_document_description
			,@p_file_name
			,@p_paths
			,@p_expired_date
			,@p_is_temporary
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	Begin catch
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
