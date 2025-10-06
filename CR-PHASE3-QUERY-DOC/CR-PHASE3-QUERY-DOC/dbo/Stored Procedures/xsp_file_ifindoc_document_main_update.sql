CREATE PROCEDURE dbo.xsp_file_ifindoc_document_main_update
(
	@p_id				bigint
	,@p_module			nvarchar(15)
	,@p_doc_type		nvarchar(250)
	,@p_doc_no 			nvarchar(50)
	,@p_doc_name		nvarchar(250)
	,@p_doc_file		varchar(max) 
	,@p_doc_date		datetime
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	file_ifindoc_document_main
		set		module			=		@p_module	
				,doc_type		=		@p_doc_type
				,doc_no 		=		@p_doc_no 	
				,doc_name		=		@p_doc_name
				,doc_file		=		@p_doc_file
				,doc_date		=		@p_doc_date

				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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
