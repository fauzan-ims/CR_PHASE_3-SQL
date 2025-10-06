CREATE PROCEDURE dbo.xsp_client_blacklist_insert
(
	@p_code							   nvarchar(50) output
	--,@p_status						   nvarchar(10)
	,@p_source						   nvarchar(250)
	,@p_client_type					   nvarchar(10)
	,@p_blacklist_type				   nvarchar(10)
	,@p_personal_nationality_type_code nvarchar(3)
	,@p_personal_doc_type_code		   nvarchar(50)
	,@p_personal_id_no				   nvarchar(50)
	,@p_personal_name				   nvarchar(250)
	,@p_personal_alias_name			   nvarchar(250)
	,@p_personal_mother_maiden_name	   nvarchar(250)
	,@p_personal_dob				   datetime
	,@p_corporate_name				   nvarchar(250)
	,@p_corporate_tax_file_no		   nvarchar(50)
	,@p_corporate_est_date			   datetime
	,@p_entry_date					   datetime
	,@p_entry_remarks				   nvarchar(4000)
	,@p_exit_date					   datetime
	,@p_exit_remarks				   nvarchar(4000)
	,@p_is_active					   nvarchar(1)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'CB'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_BLACKLIST'
												,@p_run_number_length = 8
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		insert into client_blacklist
		(
			code
			--,status
			,source
			,client_type
			,blacklist_type
			,personal_nationality_type_code
			,personal_doc_type_code
			,personal_id_no
			,personal_name
			,personal_alias_name
			,personal_mother_maiden_name
			,personal_dob
			,corporate_name
			,corporate_tax_file_no
			,corporate_est_date
			,entry_date
			,entry_remarks
			,exit_date
			,exit_remarks
			,is_active
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			--,@p_status
			,@p_source
			,@p_client_type
			,@p_blacklist_type
			,@p_personal_nationality_type_code
			,@p_personal_doc_type_code
			,@p_personal_id_no
			,upper(@p_personal_name)
			,upper(@p_personal_alias_name)
			,upper(@p_personal_mother_maiden_name)
			,@p_personal_dob
			,@p_corporate_name
			,@p_corporate_tax_file_no
			,@p_corporate_est_date
			,@p_entry_date
			,@p_entry_remarks
			,@p_exit_date
			,@p_exit_remarks
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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

 
