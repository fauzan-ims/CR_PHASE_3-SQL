CREATE PROCEDURE dbo.xsp_client_doc_insert_from_cms
(
	@p_id			   bigint
	,@p_client_code	   nvarchar(50) = null
	,@p_doc_type_code  nvarchar(50) = null
	,@p_document_no	   nvarchar(50) = null
	,@p_doc_status	   nvarchar(10) = null
	,@p_eff_date	   datetime	    = null
	,@p_exp_date	   datetime	    = null
	,@p_is_default	   nvarchar(1)  = null
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into client_doc
		(
			client_code
			,doc_type_code
			,document_no
			,doc_status
			,eff_date
			,exp_date
			,is_default
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_client_code
			,@p_doc_type_code
			,upper(@p_document_no)
			,@p_doc_status
			,@p_eff_date
			,@p_exp_date
			,@p_is_default
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

