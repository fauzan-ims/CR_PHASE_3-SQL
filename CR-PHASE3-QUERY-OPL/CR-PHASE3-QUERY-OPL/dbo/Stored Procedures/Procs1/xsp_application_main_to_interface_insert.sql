CREATE PROCEDURE dbo.xsp_application_main_to_interface_insert
(
	@p_application_no  nvarchar(50)
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
	declare @msg								   nvarchar(max)
			,@agreement_no						   nvarchar(50)
			,@client_name						   nvarchar(250)
			,@system_date						   datetime
			,@document_pending_branch_code		   nvarchar(50)
			,@document_pending_branch_name		   nvarchar(250)
			,@document_pending_initial_branch_code nvarchar(50)
			,@document_pending_initial_branch_name nvarchar(250)
			,@document_pending_code				   nvarchar(50)
			,@application_doc_document_code		   nvarchar(50)
			,@application_doc_document_name		   nvarchar(250)
			,@is_temporary						   nvarchar(1)
			,@application_doc_file_name			   nvarchar(250)
			,@application_doc_paths				   nvarchar(250)
			,@application_doc_expired_date		   datetime
			,@temporary_document_value			   nvarchar(max)
			,@result							   nvarchar(1)
			,@query								   nvarchar(max)
			,@client_no							   nvarchar(50)
			,@ParmDefinition					   nvarchar(500) ;	

	begin try 
		set @system_date = dbo.xfn_get_system_date(); 

		-- insert interface_application_main
		begin
			insert into dbo.opl_interface_application_main
			(
				agreement_no
				,agreement_external_no
				,branch_code
				,branch_name
				,agreement_date
				,agreement_status
				,agreement_sub_status
				,termination_date
				,termination_status
				,client_no
				,client_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	am.main_agreement_no
					,am.main_agreement_no
					,am.branch_code
					,am.branch_name
					,am.application_date
					,'GO LIVE'
					,''
					,null
					,null
					,cm.client_no
					,cm.client_name
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_main am
					inner join dbo.client_main cm on (cm.code = am.client_code)
			where	am.application_no = @p_application_no ;
		end

		-- interface document pending
		begin 
					 
			select	@temporary_document_value = isnull(value, '')
			from	dbo.sys_global_param
			where	code = 'DOCTEMP' ;
		   
			select	@document_pending_branch_code			= branch_code
					,@document_pending_branch_name			= branch_name
					,@document_pending_initial_branch_code	= branch_code
					,@document_pending_initial_branch_name	= branch_name
					,@client_no								= cm.client_no
					,@client_name							= cm.client_name
					,@agreement_no							= pm.main_agreement_no
			from	dbo.application_main pm
					inner join dbo.client_main cm on (cm.code = pm.client_code)
			where	pm.application_no						= @p_application_no ;

		    -- insert application document to document pending header
			exec dbo.xsp_opl_interface_document_pending_insert @p_code						= @document_pending_code output
															   ,@p_branch_code				= @document_pending_branch_code
															   ,@p_branch_name				= @document_pending_branch_name
															   ,@p_initial_branch_code		= @document_pending_initial_branch_code
															   ,@p_initial_branch_name		= @document_pending_initial_branch_name
															   ,@p_document_type			= 'AGREEMENT'
															   ,@p_document_status			= 'HOLD'
															   ,@p_client_no				= @client_no
															   ,@p_client_name				= @client_name
															   ,@p_plafond_no				= null
															   ,@p_agreement_no				= @agreement_no
															   ,@p_collateral_no			= null
															   ,@p_collateral_name			= null
															   ,@p_plafond_collateral_no	= null
															   ,@p_plafond_collateral_name	= null
															   ,@p_asset_no					= null
															   ,@p_asset_name				= null
															   ,@p_entry_date				= @system_date
															   ,@p_cre_date					= @p_cre_date
															   ,@p_cre_by					= @p_cre_by
															   ,@p_cre_ip_address			= @p_cre_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ; 
															   
			-- looping application document to document pending detail  
			declare currapplicationdoc cursor fast_forward read_only for 
			select	ad.document_code
					,sgd.document_name
					,filename
					,paths
					,expired_date
			from	dbo.application_doc ad
					inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
			where	ad.application_no = @p_application_no ;
			
			open currapplicationdoc
			
			fetch next from currapplicationdoc 
			into @application_doc_document_code
				 ,@application_doc_document_name
				 ,@application_doc_file_name		
				 ,@application_doc_paths			
				 ,@application_doc_expired_date

			while @@fetch_status = 0
			begin
			
				set @query = 'select @retvalOUT = 1 from dbo.sys_global_param where code = ''DOCTEMP'' and ''' + @application_doc_document_code + ''' in (' + @temporary_document_value + ')' ;
				set @ParmDefinition = N'@retvalOUT nvarchar(1) output' ;

				exec sp_executesql @query
								   ,@ParmDefinition
								   ,@retvalOUT = @result output ;

				if (isnull(@result, '0') <> '0')
				begin
					set @is_temporary = '1' ;
				end ;
				else
				begin
					set @is_temporary = '0' ;
				end ;

				set @result  = '0';

			    exec dbo.xsp_opl_interface_document_pending_detail_insert @p_document_pending_code	= @document_pending_code
			    														  ,@p_document_name			= @application_doc_document_name
			    														  ,@p_document_description  = '' 
			    														  ,@p_file_name				= @application_doc_file_name
			    														  ,@p_paths					= @application_doc_paths
			    														  ,@p_expired_date			= @application_doc_expired_date 
																		  ,@p_is_temporary			= @is_temporary
			    														  ,@p_cre_date				= @p_cre_date	   
			    														  ,@p_cre_by				= @p_cre_by		   
			    														  ,@p_cre_ip_address		= @p_cre_ip_address 
			    														  ,@p_mod_date				= @p_mod_date	   
			    														  ,@p_mod_by				= @p_mod_by		   
			    														  ,@p_mod_ip_address		= @p_mod_ip_address 
			    
			
			    fetch next from currapplicationdoc 
				into @application_doc_document_code
					 ,@application_doc_document_name
					 ,@application_doc_file_name		
					 ,@application_doc_paths			
					 ,@application_doc_expired_date
			end
			
			close currapplicationdoc
			deallocate currapplicationdoc 

			insert into dbo.opl_interface_sys_document_upload
			(
				reff_no
				,reff_name
				,reff_trx_code
				,file_name
				,doc_file
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@agreement_no
					,reff_name
					,reff_trx_code
					,file_name
					,doc_file
					--
					,@p_cre_date	   
					,@p_cre_by		   
					,@p_cre_ip_address 
					,@p_mod_date	   
					,@p_mod_by		   
					,@p_mod_ip_address 
			from	dbo.sys_document_upload
			where	reff_no = @p_application_no ;
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




