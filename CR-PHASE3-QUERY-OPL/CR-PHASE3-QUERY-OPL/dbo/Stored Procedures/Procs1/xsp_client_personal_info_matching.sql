/*
	ALTERd : Yunus Muslim, 27 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_client_personal_info_matching
(
	@p_client_code		nvarchar(50)
)
as
begin
	declare @msg								nvarchar(max)
			,@client_type						nvarchar(10)
			,@personal_nationality_type_code	nvarchar(50)
			,@personal_name						nvarchar(250)
			,@personal_alias_name				nvarchar(250)
			,@personal_mother_maiden_name		nvarchar(250)
			,@personal_dob						datetime	
			,@personal_doc_type_code			nvarchar(50)
			,@personal_id_no					nvarchar(50)
			,@job_code							nvarchar(50)
			,@checking_status					nvarchar(1)					
	
	begin try
		select	@client_type	= client_type 
		from	dbo.client_main
		where	code			= @p_client_code
		
		select	@personal_nationality_type_code = nationality_type_code
				,@personal_name					= full_name
				,@personal_alias_name			= alias_name
				,@personal_mother_maiden_name	= mother_maiden_name
				,@personal_dob					= date_of_birth
		from	dbo.client_personal_info
		where	client_code						= @p_client_code
		
		select	@personal_doc_type_code	= doc_type_code
				,@personal_id_no		= document_no
		from	dbo.client_doc
		where	client_code				= @p_client_code
		
		select	@job_code	= work_type_code
		from	dbo.client_personal_work
		where	client_code = @p_client_code
		
		exec dbo.xsp_sys_client_negative_and_warning_matching @p_client_type						= @client_type
															  ,@p_personal_nationality_type_code	= @personal_nationality_type_code
															  ,@p_personal_doc_type_code			= @personal_doc_type_code
															  ,@p_personal_id_no					= @personal_id_no
															  ,@p_personal_name						= @personal_name
															  ,@p_personal_alias_name				= @personal_alias_name
															  ,@p_personal_mother_maiden_name		= @personal_mother_maiden_name
															  ,@p_personal_dob						= @personal_dob
															  ,@p_corporate_name					= ''
															  ,@p_corporate_tax_file_no				= ''
															  ,@p_corporate_est_date				= ''
															  ,@p_status							= @checking_status	output

		if @checking_status <> '0'
		begin
			set @msg = 'This person is found in negative or warning list'
			raiserror(@msg,16,-1)
		end

		set @checking_status = ''

		exec dbo.xsp_sys_job_blacklist_matching @p_job_code	= @job_code
												,@p_status	= @checking_status output
		
		if @checking_status <> '0'
		begin
			set @msg = 'This person job is found in negative list'
			raiserror(@msg,16,-1)
		end

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

