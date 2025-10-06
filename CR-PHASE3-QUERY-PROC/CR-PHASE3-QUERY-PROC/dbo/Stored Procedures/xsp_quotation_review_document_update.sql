CREATE PROCEDURE dbo.xsp_quotation_review_document_update
(
	 @p_id						bigint
	,@p_quotation_review_code	nvarchar(50)
	,@p_document_code			nvarchar(50) = ''
	--,@p_file_path				nvarchar(250)
	--,@p_file_name				nvarchar(250)
	,@p_remark_detail			nvarchar(4000)  = ''
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	 update quotation_review_document
	set
			 quotation_review_code	= @p_quotation_review_code
			,document_code			= @p_document_code
			--,file_path				= @p_file_path
			--,file_name				= @p_file_name
			,remark					= @p_remark_detail
				--
			,mod_date				= @p_mod_date
			,mod_by					= @p_mod_by
			,mod_ip_address			= @p_mod_ip_address
	where		id	= @p_id

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
