CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_detail_update
(
	@p_id							   bigint
	,@p_blacklist_transaction_code	   nvarchar(50)	 = null
	,@p_client_blacklist_code		   nvarchar(50)	 = null
	,@p_personal_id_no				   nvarchar(50)	 = null
	,@p_personal_nationality_type_code nvarchar(3)	 = null
	,@p_personal_doc_type_code		   nvarchar(50)	 = null
	,@p_personal_name				   nvarchar(250) = null
	,@p_personal_alias_name			   nvarchar(250) = null
	,@p_personal_mother_maiden_name	   nvarchar(250) = null
	,@p_personal_dob				   datetime		 = null
	,@p_corporate_name				   nvarchar(250) = null
	,@p_corporate_tax_file_no		   nvarchar(50)	 = null
	,@p_corporate_est_date			   datetime		 = null
	--
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from client_blacklist_transaction_detail where personal_id_no = @p_personal_id_no and id <> @p_id and blacklist_transaction_code = @p_blacklist_transaction_code and client_type = 'PERSONAL')
		begin
			set @msg = 'ID No already exist';
			raiserror(@msg, 16, -1) ;
		end 
		else if exists (select 1 from client_blacklist_transaction_detail where corporate_tax_file_no = @p_corporate_tax_file_no and id <> @p_id and blacklist_transaction_code = @p_blacklist_transaction_code and client_type = 'CORPORATE')
		begin
			set @msg = 'TAX File No already exist';
			raiserror(@msg, 16, -1) ;
		end 
		update	client_blacklist_transaction_detail
		set		client_blacklist_code			= @p_client_blacklist_code
				,personal_id_no					= @p_personal_id_no
				,personal_nationality_type_code = @p_personal_nationality_type_code
				,personal_doc_type_code			= @p_personal_doc_type_code
				,personal_name					= @p_personal_name
				,personal_alias_name			= @p_personal_alias_name
				,personal_mother_maiden_name	= @p_personal_mother_maiden_name
				,personal_dob					= @p_personal_dob
				,corporate_name					= @p_corporate_name
				,corporate_tax_file_no			= @p_corporate_tax_file_no
				,corporate_est_date				= @p_corporate_est_date
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;
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

