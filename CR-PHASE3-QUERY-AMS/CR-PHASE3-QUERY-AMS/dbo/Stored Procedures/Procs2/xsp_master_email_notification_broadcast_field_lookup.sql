

CREATE procedure dbo.xsp_master_email_notification_broadcast_field_lookup
(
	@p_field			nvarchar(100)
	,@p_doc_code		nvarchar(100)
	,@p_email_profile	nvarchar(100)
	,@p_code			nvarchar(15)
	,@p_attachment_flag		int = 0
	,@p_attachment_file		nvarchar(4000) = ''	
	,@p_attachment_path		nvarchar(4000) = ''
) as
begin	
	
	declare @sql				nvarchar(2000)
			,@param				nvarchar(2000)
			,@value				nvarchar(10)
			,@table				nvarchar(100)
			,@email_subject		nvarchar(100)
			,@email_body		nvarchar(4000)
			,@reply_to			nvarchar(100)
			,@user_email		nvarchar(100)
			,@field_lookup		nvarchar(100)
			,@table_name		nvarchar(4000)
			,@field_name		nvarchar(100)
			,@query_script		nvarchar(4000) = ''
			,@emp_code			nvarchar(50)
			,@regional_center	nvarchar(50)
			,@area_office		nvarchar(50)
			,@griya				nvarchar(50)
			,@condition_script	nvarchar(4000)
			,@flag				int
			--
			,@mail_sender			nvarchar(200)
			,@mail_to				nvarchar(200)
			,@mail_cc				nvarchar(100)	= ''
			,@mail_bcc				nvarchar(100)	= ''
			,@mail_subject			nvarchar(200)
			,@mail_body				nvarchar(4000)
			,@mail_file_name		nvarchar(100)	= '-'
			,@mail_file_path		nvarchar(100)	= '-'
			,@generate_status		nvarchar(50)	= 'NONE'
			,@mail_status			nvarchar(50)	= 'PENDING'
			,@cre_date				datetime		= getdate()
			,@cre_by				nvarchar(15)	= 'SYSTEM'
			,@cre_ip_address		nvarchar(15)	= '127.0.0.1'
			,@approval_no			nvarchar(50)	= ''
			
	select	@email_subject	= email_subject
			,@email_body	= email_body
			,@reply_to		= reply_to
			,@mail_subject	= email_subject
	from	master_email_notification
	where	code	= @p_code

	select	@mail_sender = email_sender
	from	dbo.sys_global_param

	-- Arga 11-Nov-2021 ket : for BAF (+)
	set @field_lookup = @p_field
	set @table_name = substring(@field_lookup,1,charindex('.',@field_lookup)-1)
	--select 'get table name', @field_lookup, @table_name

	set @field_lookup = replace(@field_lookup,@table_name+'.','')
	--select 'exclude table name', @field_lookup, @table_name

	set @field_name = rtrim(ltrim(replace(substring(@field_lookup,1,charindex('=',@field_lookup)),'=','')))
	--select 'get field name', @field_lookup, @table_name, @field_name
	
	set @field_lookup = replace(@field_lookup,@field_name,'')
	set @field_lookup = rtrim(ltrim(replace(@field_lookup,'=','')))
	--select 'exclude field name', @field_lookup, @table_name, @field_name

	--set @value = replace(@field_lookup,'"','''')
	--select 'get value', @field_lookup, @table_name, @field_name, @value

	if isnull(@reply_to,'') <> ''
		set @reply_to = '' + @reply_to + ''
	else 
		set @reply_to = 'null'
	
	set @mail_body = @email_body
	
	if @p_attachment_flag = 1
	begin
	    select	@mail_file_name = @p_attachment_file
				,@mail_file_path = @p_attachment_path
				,@generate_status = 'PENDING'
	end
		
			
	if exists (select 1 from dbo.master_reminder_maintenance
				where email_notif_code = @p_code and is_active = '1'
				and reminder_type = 'RMTYOPN') -- for opname trx
	begin
	
		set @value = replace(@field_lookup,'"','')
	
	    if (@table_name = 'EMPLOYEE_MAIN' and @field_name = 'POSITION_CODE')
		begin

			declare c_mail cursor fast_forward read_only for
			select	emp_code, isnull(email,email2)
			from	dbo.employee_main
			where	position_code = @value
	    								
			open c_mail
			fetch next from c_mail
			into @emp_code, @user_email
	    							
			while @@fetch_status = 0
			begin
	    		
				set	@mail_to = @user_email

	    		declare c_roles cursor fast_forward read_only for
	    		select	branch_code, location_code, griya_code
	    		from	dbo.employee_branch
	    		where	emp_code = @emp_code
	    										
	    		open c_roles
	    		fetch next from c_roles
	    		into @regional_center, @area_office, @griya
	    									
	    		while @@fetch_status = 0
	    		begin
	    			
	    			if not exists (select	1
									from	dbo.fa_recon_header
									where	branch_code = @regional_center
									and		asset_location_code = @area_office
									and		griya_code = @griya
									and		trans_flag_code in ('ONPROGRESS','POST'))
					begin
						exec dbo.xsp_email_notif_transaction_insert @p_mail_sender			 = @mail_sender
																	,@p_mail_to				 = @mail_to
																	,@p_mail_cc				 = @mail_cc
																	,@p_mail_bcc			 = @mail_bcc
																	,@p_mail_subject		 = @mail_subject
																	,@p_mail_body			 = @mail_body
																	,@p_mail_file_name		 = @mail_file_name
																	,@p_mail_file_path		 = @mail_file_path
																	,@p_generate_file_status = @generate_status
																	,@p_mail_status			 = @mail_status
																	,@p_cre_date			 = @cre_date
																	,@p_cre_by				 = @cre_by
																	,@p_cre_ip_address		 = @cre_ip_address
																	,@p_mod_date			 = @cre_date
																	,@p_mod_by				 = @cre_by
																	,@p_mod_ip_address		 = @cre_ip_address
																	,@p_approval_no			 = @approval_no
						--exec	msdb.dbo.sp_send_dbmail
						--		@profile_name	= @p_email_profile
						--		,@recipients	= @user_email
						--		,@reply_to		= @reply_to
						--		,@subject		= @email_subject
						--		,@body			= @email_body					    
					end
	    										
	    			fetch next from c_roles
	    			into @regional_center, @area_office, @griya
	    									
	    		end
	    									
	    		close c_roles
	    		deallocate c_roles
	    								
	    		fetch next from c_mail
	    		into @emp_code, @user_email
	    							
			end
	    							
			close c_mail
			deallocate c_mail 
		end
	end
	else -- for rotation receive
	begin
		if (@table_name = 'EMPLOYEE_MAIN' and @field_name = 'POSITION_CODE')
		begin
		    set @table_name += ' em
								inner join employee_branch eb on em.emp_code = eb.emp_code
								inner join fa_request_mutation_header frmh on (eb.branch_code = frmh.to_cost_center
																				and eb.location_code = frmh.to_location_code
																				and eb.griya_code = frmh.to_griya_code)'
			set @condition_script = '		and		frmh.code_barcode = ' + '''' + @p_doc_code + ''''
			set @flag = 1
		end
		
		set @value = replace(@field_lookup,'"','''')

		set @query_script = '
		declare @user_email		nvarchar(100)
				,@profile_name	nvarchar(100)
				,@reply_to		nvarchar(100)
				,@email_subject	nvarchar(100)
				,@email_body	nvarchar(4000)
				--
				,@mail_sender			nvarchar(200)
				,@mail_to				nvarchar(200)
				,@mail_cc				nvarchar(100)	= ''''
				,@mail_bcc				nvarchar(100)	= ''''
				,@mail_subject			nvarchar(200)
				,@mail_body				nvarchar(4000)
				,@mail_file_name		nvarchar(100)	= ''-''
				,@mail_file_path		nvarchar(100)	= ''-''
				,@generate_status		nvarchar(50)	= ''NONE''
				,@mail_status			nvarchar(50)	= ''PENDING''
				,@cre_date				datetime		= getdate()
				,@cre_by				nvarchar(15)	= ''SYSTEM''
				,@cre_ip_address		nvarchar(15)	= ''127.0.0.1''
				,@approval_no			nvarchar(50)	= ''''

		select @profile_name	= ''' + @p_email_profile + '''
			   ,@reply_to		= ' + @reply_to + '
			   ,@email_subject	= ''' + @email_subject + '''
			   ,@email_body		= ''' + @email_body + '''
			   ,@mail_subject	= ''' + @email_subject + '''
			   
		select	@mail_sender = email_sender
		from	dbo.sys_global_param
		
		set @mail_body = @email_body	

		declare c_main cursor fast_forward read_only for
		select	isnull(email,email2)
		from	' + @table_name + '
		where	' + @field_name + ' = ' + @value
				
		if (@flag = 1)
		begin
			set @query_script += char(10)
			set @query_script += @condition_script
		end

		set @query_script += char(10) + char(10)

		set @query_script += '
		open c_main
		fetch next from c_main
		into @user_email
								
		while @@fetch_status = 0
		begin
				
			set	@mail_to = @user_email

			exec dbo.xsp_email_notif_transaction_insert @p_mail_sender				 = @mail_sender
															,@p_mail_to				 = @mail_to
															,@p_mail_cc				 = @mail_cc
															,@p_mail_bcc			 = @mail_bcc
															,@p_mail_subject		 = @mail_subject
															,@p_mail_body			 = @mail_body
															,@p_mail_file_name		 = @mail_file_name
															,@p_mail_file_path		 = @mail_file_path
															,@p_generate_file_status = @generate_status
															,@p_mail_status			 = @mail_status
															,@p_cre_date			 = @cre_date
															,@p_cre_by				 = @cre_by
															,@p_cre_ip_address		 = @cre_ip_address
															,@p_mod_date			 = @cre_date
															,@p_mod_by				 = @cre_by
															,@p_mod_ip_address		 = @cre_ip_address
															,@p_approval_no			 = @approval_no	
									
			fetch next from c_main
			into @user_email
								
		end
								
		close c_main
		deallocate c_main
		'	
		/**
		set @query_script += '
		open c_main
		fetch next from c_main
		into @user_email
								
		while @@fetch_status = 0
		begin
		
		
			exec	msdb.dbo.sp_send_dbmail
					@profile_name	= @profile_name
					,@recipients	= @user_email
					,@reply_to		= @reply_to
					,@subject		= @email_subject
					,@body			= @email_body
									
			fetch next from c_main
			into @user_email
								
		end
								
		close c_main
		deallocate c_main
		'
		**/

		exec (@query_script)
	end
	
	/* -- Arga 11-Nov-2021 ket : for BAF (+)
	select	top 1
			@table = part
	from	[dbo].[sdf_splitstring](@p_field, '.')

	set @param = '@out nvarchar(100) output'
	
	if @table = 'PROJECT_MAIN'
		set @sql = 'SELECT @out = ' + @p_field + ' from ' + @table + ' where code = ''' + @p_doc_code + ''''
	
	else if @table = 'PROJECT_MEMBER'
	begin
			select	@user_email = email
			from	employee_main
			where	emp_code = @p_doc_code
	end
	
	else
		set @sql = 'SELECT @out = ' + @p_field + ' from ' + @table + ' where id = ' + @p_doc_code
	
	exec sp_executesql @sql, @param, @out = @value output
	
	print @sql
	
	select	@user_email = email
	from	employee_main
	where	emp_code = @value
	
	exec	msdb.dbo.sp_send_dbmail
			@profile_name	= @p_email_profile
			,@recipients	= @user_email
			,@reply_to		= @reply_to
			,@subject		= @email_subject
			,@body			= @email_body
	*/
	
end
