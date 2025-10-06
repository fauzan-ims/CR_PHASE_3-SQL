CREATE PROCEDURE dbo.xsp_ext_client_main_insert
(
	@p_code						 nvarchar(50) output
	,@p_CustId					 nvarchar(50)  = ''
	,@p_CustNo					 nvarchar(50)  = ''
	,@p_CustName				 nvarchar(250) = ''
	,@p_MrCustTypeCode			 nvarchar(50)  = ''
	,@p_MrIdTypeCode			 nvarchar(50)  = ''
	,@p_IdNo					 nvarchar(50)  = ''
	,@p_TaxIdNo					 nvarchar(50)  = ''
	,@p_IdExpiredDt				 datetime	   = null
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@year						nvarchar(2)
			,@month						nvarchar(2)
			,@client_code				nvarchar(50)  ; 

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
	if (@p_MrCustTypeCode = 'CORPORATE')
	begin
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
													,@p_branch_code = ''
													,@p_sys_document_code = ''
													,@p_custom_prefix = 'OPLCC'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'CLIENT_MAIN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;
	end
	else
	begin
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
													,@p_branch_code = ''
													,@p_sys_document_code = ''
													,@p_custom_prefix = 'OPLCP'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'CLIENT_MAIN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;
	end

	begin try
	
		insert into client_main
		(
			code
			,client_no
			,client_type
			,client_name
			,watchlist_status
			,is_validate
			,status_slik_checking
			,status_dukcapil_checking
			,is_existing_client
			,client_group_code
			,client_group_name
			,client_id
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
			,@p_CustNo
			,@p_MrCustTypeCode
			,upper(@p_CustName)
			,'CLEAR'
			,'1'
			,''
			,''
			,'1'
			,null
			,null
			,@p_CustId
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;		

		insert into dbo.client_doc
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
		(
			@client_code
			,case
				 when @p_MrIdTypeCode = 'NPWP' then 'TAXID'
				 when @p_MrIdTypeCode = 'EKTP' then 'KTP'
				 else @p_MrIdTypeCode
			 end
			,isnull(@p_IdNo, @p_TaxIdNo)
			,N'EXIST'
			,dbo.xfn_get_system_date()
			,isnull(@p_IdExpiredDt,dbo.xfn_get_system_date())
			,N'1'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		exec dbo.xsp_client_log_insert @p_id				= 0 
									   ,@p_client_code		= @client_code
									   ,@p_log_date			= @p_cre_date
									   ,@p_log_remarks		= N'ENTRY'
									   ,@p_cre_date			= @p_cre_date
									   ,@p_cre_by			= @p_cre_by
									   ,@p_cre_ip_address	= @p_cre_ip_address
									   ,@p_mod_date			= @p_mod_date
									   ,@p_mod_by			= @p_mod_by
									   ,@p_mod_ip_address	= @p_mod_ip_address
		
		set @p_code = @client_code
	end try
	begin catch
		--declare @error int ;

		--set @error = @@error ;

		--if (@error = 2627)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		--end ;

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
