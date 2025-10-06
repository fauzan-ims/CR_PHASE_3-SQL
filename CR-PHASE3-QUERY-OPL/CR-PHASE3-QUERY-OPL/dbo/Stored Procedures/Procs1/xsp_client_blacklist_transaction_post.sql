CREATE PROCEDURE dbo.xsp_client_blacklist_transaction_post
(
	@p_code				nvarchar(50)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@transaction_type					nvarchar(10)
			,@register_source					nvarchar(250)
			,@transaction_date					datetime
			,@transaction_remarks				nvarchar(4000)
			,@id								bigint 
			,@history_remark					nvarchar(4000) 
			,@client_type						nvarchar(10)
			,@blacklist_type					nvarchar(10)
			,@personal_id_no					nvarchar(50)
			,@personal_nationality_type_code	nvarchar(50)
			,@personal_doc_type_code			nvarchar(50)
			,@personal_name						nvarchar(250)
			,@personal_alias_name				nvarchar(250)
			,@personal_mother_maiden_name		nvarchar(250)
			,@personal_dob						datetime
			,@corporate_name					nvarchar(250)
			,@corporate_tax_file_no				nvarchar(50)
			,@corporate_est_date				datetime 
			,@client_blacklist_code				nvarchar(50);

	
	begin try			
		if exists (select 1 from dbo.client_blacklist_transaction where transaction_status <> 'HOLD' and code = @p_code)
		begin
			set @msg = 'Data already proceed';
			raiserror (@msg, 16, 1);
		end	
		else if not exists (select 1 from dbo.client_blacklist_transaction_detail where blacklist_transaction_code = @p_code)
		begin
			set @msg = 'Please add at least 1 client';
			raiserror (@msg, 16, 1);
		end
		
		
		update	dbo.client_blacklist_transaction
		set		transaction_status	= 'POST'
				,transaction_date	= dbo.xfn_get_system_date()
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code

		select	@transaction_type		= transaction_type
				,@transaction_date		= transaction_date
				,@transaction_remarks	= transaction_remarks
				,@register_source		= register_source
		from	dbo.client_blacklist_transaction
		where	code					= @p_code
		
		if (@transaction_type = 'REGISTER')
		begin
		    declare los_cur	cursor local fast_forward for
			select client_type
				   ,blacklist_type
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
			from	dbo.client_blacklist_transaction_detail
			where	blacklist_transaction_code		 = @p_code
									
			open los_cur
			fetch next from los_cur  
			into	@client_type					
					,@blacklist_type					 
					,@personal_id_no					 
					,@personal_nationality_type_code  
					,@personal_doc_type_code			 
					,@personal_name					 
					,@personal_alias_name			 
					,@personal_mother_maiden_name	 
					,@personal_dob					 
					,@corporate_name					 
					,@corporate_tax_file_no			 
					,@corporate_est_date				 
			while @@fetch_status = 0
			begin
				
				set @history_remark = 'REGISTER ' + @transaction_remarks ;

				if (@client_type = 'PERSONAL')
				begin
					if exists(select 1 from dbo.client_blacklist  where personal_id_no = @personal_id_no and is_active = '1')
					begin
						set @msg = 'ID No ' + @personal_id_no + ' already registed';
						raiserror (@msg, 16, 1);
					end
					
					exec dbo.xsp_client_blacklist_insert @p_code							= @client_blacklist_code output 
														 ,@p_source							= @register_source
														 ,@p_client_type					= @client_type					 
														 ,@p_blacklist_type					= @blacklist_type					 
														 ,@p_personal_nationality_type_code = @personal_nationality_type_code			 
														 ,@p_personal_doc_type_code			= @personal_doc_type_code  
														 ,@p_personal_id_no					= @personal_id_no			 
														 ,@p_personal_name					= @personal_name					 
														 ,@p_personal_alias_name			= @personal_alias_name			 
														 ,@p_personal_mother_maiden_name	= @personal_mother_maiden_name	 
														 ,@p_personal_dob					= @personal_dob					 
														 ,@p_corporate_name					= null			 
														 ,@p_corporate_tax_file_no			= null			 
														 ,@p_corporate_est_date				= null			 
														 ,@p_entry_date						= @transaction_date	
														 ,@p_entry_remarks					= @transaction_remarks
														 ,@p_exit_date						= null
														 ,@p_exit_remarks					= null
														 ,@p_is_active						= 'T'
														 ,@p_cre_date						= @p_cre_date		
														 ,@p_cre_by							= @p_cre_by			
														 ,@p_cre_ip_address					= @p_cre_ip_address	
														 ,@p_mod_date						= @p_mod_date		
														 ,@p_mod_by							= @p_mod_by			
														 ,@p_mod_ip_address					= @p_mod_ip_address	
					
					exec dbo.xsp_client_blacklist_history_insert @p_id						= @id output
																 ,@p_client_blacklist_code	= @client_blacklist_code
																 ,@p_history_date			= @transaction_date
																 ,@p_history_remarks		= @history_remark
																 ,@p_cre_date				= @p_cre_date		
																 ,@p_cre_by					= @p_cre_by			
																 ,@p_cre_ip_address			= @p_cre_ip_address	
																 ,@p_mod_date				= @p_mod_date		
																 ,@p_mod_by					= @p_mod_by			
																 ,@p_mod_ip_address			= @p_mod_ip_address	
				end
				else
				begin
					if exists(select 1 from dbo.client_blacklist  where corporate_tax_file_no = @corporate_tax_file_no and is_active = '1')
					begin
						set @msg = 'Tax File No ' + @corporate_tax_file_no + ' already registed';
						raiserror (@msg, 16, 1);
					end
					
					exec dbo.xsp_client_blacklist_insert @p_code							= @client_blacklist_code output 
														 ,@p_source							= @register_source
														 ,@p_client_type					= @client_type					 
														 ,@p_blacklist_type					= @blacklist_type					 
														 ,@p_personal_nationality_type_code = null		 
														 ,@p_personal_doc_type_code			= null
														 ,@p_personal_id_no					= null
														 ,@p_personal_name					= null 
														 ,@p_personal_alias_name			= null
														 ,@p_personal_mother_maiden_name	= null
														 ,@p_personal_dob					= null
														 ,@p_corporate_name					= @corporate_name				 
														 ,@p_corporate_tax_file_no			= @corporate_tax_file_no		 
														 ,@p_corporate_est_date				= @corporate_est_date			 
														 ,@p_entry_date						= @transaction_date	
														 ,@p_entry_remarks					= @transaction_remarks
														 ,@p_exit_date						= null
														 ,@p_exit_remarks					= null
														 ,@p_is_active						= 'T'
														 ,@p_cre_date						= @p_cre_date		
														 ,@p_cre_by							= @p_cre_by			
														 ,@p_cre_ip_address					= @p_cre_ip_address	
														 ,@p_mod_date						= @p_mod_date		
														 ,@p_mod_by							= @p_mod_by			
														 ,@p_mod_ip_address					= @p_mod_ip_address	
														 
					exec dbo.xsp_client_blacklist_history_insert @p_id						= @id output
																 ,@p_client_blacklist_code	= @client_blacklist_code
																 ,@p_history_date			= @transaction_date
																 ,@p_history_remarks		= @history_remark
																 ,@p_cre_date				= @p_cre_date		
																 ,@p_cre_by					= @p_cre_by			
																 ,@p_cre_ip_address			= @p_cre_ip_address	
																 ,@p_mod_date				= @p_mod_date		
																 ,@p_mod_by					= @p_mod_by			
																 ,@p_mod_ip_address			= @p_mod_ip_address	

				end

				fetch next from los_cur  
				into	@client_type					
						,@blacklist_type					 
						,@personal_id_no					 
						,@personal_nationality_type_code  
						,@personal_doc_type_code			 
						,@personal_name					 
						,@personal_alias_name			 
						,@personal_mother_maiden_name	 
						,@personal_dob					 
						,@corporate_name					 
						,@corporate_tax_file_no			 
						,@corporate_est_date	

			end
			close los_cur
			deallocate los_cur
		end
		else if (@transaction_type = 'RELEASE')
		begin
		    declare los_curs	cursor local fast_forward for
			select client_blacklist_code
				   ,client_type
				   ,personal_id_no
				   ,corporate_tax_file_no
			from	dbo.client_blacklist_transaction_detail
			where	blacklist_transaction_code		 = @p_code
									
			open los_curs
			fetch next from los_curs  
			into	@client_blacklist_code
					,@client_type					
					,@personal_id_no								 
					,@corporate_tax_file_no			 
			while @@fetch_status = 0
			begin
				
				set @history_remark = 'RELEASE ' + @transaction_remarks ;

				if (@client_type = 'PERSONAL')
				begin
					if exists(select 1 from dbo.client_blacklist  where personal_id_no = @personal_id_no and is_active = '0')
					begin
						set @msg = 'ID ' + @personal_id_no + ' already release';
						raiserror (@msg, 16, 1);
					end
					else if not exists(select 1 from dbo.client_blacklist  where personal_id_no = @personal_id_no and is_active = '1')
					begin
						set @msg = 'ID ' + @personal_id_no + ' not exist in Client Blacklist';
						raiserror (@msg, 16, 1);
					end
					if (isnull(@client_blacklist_code ,'') <> '')
					begin
						update client_blacklist
						set	   exit_date    = @transaction_date
							   ,exit_remarks = @transaction_remarks
							   ,is_active	= '0'
						where  code			= @client_blacklist_code
					end
					else
					begin

						select @client_blacklist_code = code  from  dbo.client_blacklist where personal_id_no = @personal_id_no and is_active = '1'

						update client_blacklist
						set	   exit_date      = @transaction_date
							   ,exit_remarks  = @transaction_remarks
							   ,is_active	  = '0'
						where  personal_id_no = @personal_id_no
					end

					exec dbo.xsp_client_blacklist_history_insert @p_id						= @id output
																 ,@p_client_blacklist_code	= @client_blacklist_code
																 ,@p_history_date			= @transaction_date
																 ,@p_history_remarks		= @history_remark
																 ,@p_cre_date				= @p_cre_date		
																 ,@p_cre_by					= @p_cre_by			
																 ,@p_cre_ip_address			= @p_cre_ip_address	
																 ,@p_mod_date				= @p_mod_date		
																 ,@p_mod_by					= @p_mod_by			
																 ,@p_mod_ip_address			= @p_mod_ip_address	
				end
				else
				begin
					if not exists(select 1 from dbo.client_blacklist  where corporate_tax_file_no = @corporate_tax_file_no and is_active = '1')
					begin
						set @msg = 'Tax File No ' + @corporate_tax_file_no + ' not exist in  Client Blacklist';
						raiserror (@msg, 16, 1);
					end
					
					if (isnull(@client_blacklist_code ,'') <> '')
					begin
						update client_blacklist
						set	   exit_date    = @transaction_date
							   ,exit_remarks = @transaction_remarks
							   ,is_active	= '0'
						where  code			= @client_blacklist_code
					end
					else
					begin
					
						select @client_blacklist_code = code  from  dbo.client_blacklist where corporate_tax_file_no = @corporate_tax_file_no and is_active = '1'

						update client_blacklist
						set	   exit_date			 = @transaction_date
							   ,exit_remarks		 = @transaction_remarks
							   ,is_active			 = '0'
						where  corporate_tax_file_no = @corporate_tax_file_no
					end

					exec dbo.xsp_client_blacklist_history_insert @p_id						= @id output
																 ,@p_client_blacklist_code	= @client_blacklist_code
																 ,@p_history_date			= @transaction_date
																 ,@p_history_remarks		= @history_remark
																 ,@p_cre_date				= @p_cre_date		
																 ,@p_cre_by					= @p_cre_by			
																 ,@p_cre_ip_address			= @p_cre_ip_address	
																 ,@p_mod_date				= @p_mod_date		
																 ,@p_mod_by					= @p_mod_by			
																 ,@p_mod_ip_address			= @p_mod_ip_address	

				end

				fetch next from los_curs  
				into	@client_blacklist_code
						,@client_type					
						,@personal_id_no							 
						,@corporate_tax_file_no			 

			end
			close los_curs
			deallocate los_curs
		    
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

