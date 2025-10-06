CREATE PROCEDURE dbo.xsp_client_blacklist_update
(
	@p_code							nvarchar(50)
	--,@p_status						nvarchar(10)
	,@p_source						nvarchar(250)
	,@p_client_type					nvarchar(10)
	,@p_blacklist_type				nvarchar(10)
	,@p_nationality_type_code		nvarchar(3)
	,@p_personal_doc_type_code		nvarchar(50)
	,@p_personal_id_no				nvarchar(50)
	,@p_personal_name				nvarchar(250)
	,@p_personal_alias_name			nvarchar(250)
	,@p_personal_mother_maiden_name nvarchar(250)
	,@p_personal_dob				datetime
	,@p_corporate_name				nvarchar(250)
	,@p_corporate_tax_file_no		nvarchar(50)
	,@p_corporate_est_date			datetime
	,@p_entry_date					datetime
	,@p_entry_remarks				nvarchar(4000)
	,@p_exit_date					datetime
	,@p_exit_remarks				nvarchar(4000)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	client_blacklist
		set		source							= @p_source
				,client_type					= @p_client_type
				,blacklist_type					= @p_blacklist_type
				,personal_nationality_type_code	= @p_nationality_type_code
				,personal_doc_type_code			= @p_personal_doc_type_code
				,personal_id_no					= @p_personal_id_no
				,personal_name					= @p_personal_name
				,personal_alias_name			= @p_personal_alias_name
				,personal_mother_maiden_name	= @p_personal_mother_maiden_name
				,personal_dob					= @p_personal_dob
				,corporate_name					= @p_corporate_name
				,corporate_tax_file_no			= @p_corporate_tax_file_no
				,corporate_est_date				= @p_corporate_est_date
				,entry_date						= @p_entry_date
				,entry_remarks					= @p_entry_remarks
				,exit_date						= @p_exit_date
				,exit_remarks					= @p_exit_remarks
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	code							= @p_code ;
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

