CREATE PROCEDURE dbo.xsp_client_personal_info_insert
(
	@p_code					 nvarchar(50) output
	,@p_full_name			 nvarchar(250)
	,@p_mother_maiden_name	 nvarchar(250)
	,@p_id_no				 nvarchar(50)
	,@p_place_of_birth		 nvarchar(250)
	,@p_date_of_birth		 datetime
	,@p_document_type		 nvarchar(10)
	,@p_client_group_code    nvarchar(50)  = null
	,@p_client_group_name    nvarchar(250) = null
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@client_code	nvarchar(50)
			,@client_no		nvarchar(50) ;

	--if exists
	--(
	--	select	1
	--	from	dbo.client_doc 
	--	where	document_no = @p_id_no
	--)
	--begin
	--	set	@msg = 'KTP No Already Exists.'
	--	raiserror(@msg, 16, -1)
	--end

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'OPLCP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_PERSONAL_INFO'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_no output
												,@p_branch_code = ''
												,@p_sys_document_code = 'OPLCP'
												,@p_custom_prefix = ''
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
												,@p_specified_column = 'CLIENT_NO' ;


	begin try
		if (@p_date_of_birth > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date of Birth must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 

		exec dbo.xsp_client_main_insert @p_code							= @client_code
										,@p_client_no					= @client_no
										,@p_client_type					= 'PERSONAL' 
										,@p_client_name					= @p_full_name
										,@p_is_validate					= 'F'
										,@p_status_slik_checking		= ''
										,@p_status_dukcapil_checking	= ''
										,@p_client_group_code			= @p_client_group_code
									    ,@p_client_group_name			= @p_client_group_name	
										,@p_cre_date					= @p_cre_date
										,@p_cre_by						= @p_cre_by
										,@p_cre_ip_address				= @p_cre_ip_address
										,@p_mod_date					= @p_mod_date
										,@p_mod_by						= @p_mod_by
										,@p_mod_ip_address				= @p_mod_ip_address
	
		insert into client_personal_info
		(
			client_code
			,full_name
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,dependent_count
			,nationality_type_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,UPPER(@p_full_name)
			,upper(@p_mother_maiden_name)
			,upper(@p_place_of_birth)
			,@p_date_of_birth
			,0
			,'WNI'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ; 
		
		exec dbo.sys_client_doc_generate_default_document @p_client_code		= @client_code
														  ,@p_client_type		= 'PERSONAL' 
														  ,@p_cre_date			= @p_cre_date
														  ,@p_cre_by			= @p_cre_by
														  ,@p_cre_ip_address	= @p_cre_ip_address
														  ,@p_mod_date			= @p_mod_date
														  ,@p_mod_by			= @p_mod_by
														  ,@p_mod_ip_address	= @p_mod_ip_address
		-- set npwp no
		update	dbo.client_doc
		set		document_no		  = @p_id_no
		where	client_code		  = @client_code
				and doc_type_code = @p_document_type ;

		set @p_code = @client_code
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





