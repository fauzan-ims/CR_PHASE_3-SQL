CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_detail_insert
(
	@p_id							   bigint = 0 output
	,@p_blacklist_transaction_code	   nvarchar(50)	 = null
	,@p_client_type					   nvarchar(10)	 = null
	,@p_blacklist_type				   nvarchar(10)	 = null
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
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from client_blacklist_transaction_detail where personal_id_no = @p_personal_id_no  and blacklist_transaction_code = @p_blacklist_transaction_code and client_type = 'PERSONAL')
		begin
			set @msg = 'ID No already exist';
			raiserror(@msg, 16, -1) ;
		end 
		else if exists (select 1 from client_blacklist_transaction_detail where corporate_tax_file_no = @p_corporate_tax_file_no and blacklist_transaction_code = @p_blacklist_transaction_code and client_type = 'CORPORATE')
		begin
			set @msg = 'TAX File No already exist';
			raiserror(@msg, 16, -1) ;
		end 

		insert into client_blacklist_transaction_detail
		(
			blacklist_transaction_code
			,client_type
			,blacklist_type
			,client_blacklist_code
			,personal_id_no
			,personal_nationality_type_code
			,personal_doc_type_code
			,personal_name
			,personal_alias_name
			,personal_mother_maiden_name
			,personal_dob
			,corporate_name
			,corporate_tax_file_no
			,corporate_est_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_blacklist_transaction_code
			,@p_client_type
			,@p_blacklist_type
			,@p_client_blacklist_code
			,@p_personal_id_no
			,@p_personal_nationality_type_code
			,@p_personal_doc_type_code
			,upper(@p_personal_name		  )
			,upper(@p_personal_alias_name )
			,upper(@p_personal_mother_maiden_name)
			,@p_personal_dob
			,upper(@p_corporate_name)
			,@p_corporate_tax_file_no
			,@p_corporate_est_date
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

 

