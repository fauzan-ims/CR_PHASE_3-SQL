CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_detail_upload_data_from_excel
(
	@p_blacklist_transaction_code	   nvarchar(50)
	,@p_client_type					   nvarchar(10)
	,@p_blacklist_type				   nvarchar(10)
	,@p_client_blacklist_code		   nvarchar(50)	 = null
	,@p_personal_name				   nvarchar(4000)
	,@p_corporate_name				   nvarchar(250)
	,@p_personal_id_no				   nvarchar(50)
	,@p_personal_nationality_type_code nvarchar(3)
	,@p_personal_doc_type_code		   nvarchar(50)
	,@p_corporate_tax_file_no		   nvarchar(50)
	,@p_personal_alias_name			   nvarchar(250)
	,@p_personal_mother_maiden_name	   nvarchar(250)
	,@p_personal_dob				   datetime
	,@p_corporate_est_date			   datetime
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
	declare @msg			   nvarchar(max)
			,@transaction_type nvarchar(10) ;

	select	@transaction_type = transaction_type
	from	dbo.client_blacklist_transaction
	where	code = @p_blacklist_transaction_code ;
	
	begin try
		if @transaction_type = 'REGISTER'
		begin
			set @p_client_blacklist_code = null ;
			if (@p_client_type = 'CORPORATE')
			begin
				set @p_personal_name					= null ;
				set @p_personal_id_no					= null ;
				set @p_personal_nationality_type_code	= null ;
				set @p_personal_doc_type_code			= null ;
				set @p_personal_alias_name				= null ;
				set @p_personal_mother_maiden_name		= null ;
				set @p_personal_dob						= null ;
			end ;
			else
			begin
				set @p_corporate_name		 = null ;
				set @p_corporate_tax_file_no = null ;
				set @p_corporate_est_date	 = null ;
			end ;
		end
		else
		begin
			if not exists (select 1 from dbo.client_blacklist where code = @p_client_blacklist_code)
			begin
				set @msg = 'This Blacklist Code ' + @p_client_blacklist_code + ' is not exist in Client Blacklist.'
				raiserror (@msg, 16, 1)
			end
			else
			begin
				select @p_client_type						 = client_type						
					   ,@p_blacklist_type					 = blacklist_type					
					   ,@p_personal_name					 = personal_name
					   ,@p_personal_id_no					 = personal_id_no		
					   ,@p_personal_nationality_type_code	 = personal_nationality_type_code				
					   ,@p_personal_doc_type_code			 = personal_doc_type_code		
					   ,@p_personal_alias_name				 = personal_alias_name				
					   ,@p_personal_mother_maiden_name		 = personal_mother_maiden_name		
					   ,@p_personal_dob						 = personal_dob						
					   ,@p_corporate_name					 = corporate_name					
					   ,@p_corporate_tax_file_no			 = corporate_tax_file_no			
					   ,@p_corporate_est_date				 = corporate_est_date				
					   from dbo.client_blacklist
					   where code							 = @p_client_blacklist_code
			end
		end


		insert into client_blacklist_transaction_detail
		(
			blacklist_transaction_code
			,client_type
			,blacklist_type
			,client_blacklist_code
			,personal_nationality_type_code
			,personal_doc_type_code
			,personal_alias_name
			,personal_mother_maiden_name
			,personal_dob
			,personal_name
			,corporate_name
			,personal_id_no
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
			,@p_personal_nationality_type_code
			,@p_personal_doc_type_code
			,@p_personal_alias_name
			,@p_personal_mother_maiden_name
			,@p_personal_dob
			,@p_personal_name
			,@p_corporate_name
			,@p_personal_id_no
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


