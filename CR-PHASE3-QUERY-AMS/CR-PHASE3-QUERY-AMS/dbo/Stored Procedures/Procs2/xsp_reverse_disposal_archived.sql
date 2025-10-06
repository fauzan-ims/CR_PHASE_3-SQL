CREATE PROCEDURE dbo.xsp_reverse_disposal_archived 
as
begin
	declare @msg						nvarchar(max)
			,@max_value					int	
			,@code						nvarchar(50)
			,@company_code				nvarchar(50)
			,@disposal_code				nvarchar(50)
			,@disposal_date				datetime
			,@reverse_disposal_date		datetime
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@location_code				nvarchar(50)
			,@location_name				nvarchar(250)
			,@description				nvarchar(4000)
			,@reason_type				nvarchar(50)
			,@remarks					nvarchar(4000)
			,@status					nvarchar(25)
			--
			,@asset_code				nvarchar(50)
			,@cost_center_code			nvarchar(50)
			,@cost_center_name			nvarchar(250)
			,@description_detail		nvarchar(4000)
			--
			,@file_name_doc				nvarchar(250)
			,@path_doc					nvarchar(250)
			,@description_doc			nvarchar(400)
			,@cre_date					datetime
			,@cre_by					nvarchar(50)
			,@cre_ip_address			nvarchar(15)
			,@mod_date					datetime
			,@mod_by					nvarchar(50)
			,@mod_ip_address			nvarchar(15) ;

	begin try 
		declare @code_reverse_disposal as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_reverse_disposal_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,disposal_code
				,disposal_date
				,reverse_disposal_date
				,branch_code
				,branch_name
				,location_code
				,location_name
				,description
				,reason_type
				,remarks
				,status
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.reverse_disposal 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,reverse_disposal_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_reverse_disposal_trx
		
		fetch next from c_reverse_disposal_trx 
		into	@code
				,@company_code
				,@disposal_code
				,@disposal_date
				,@reverse_disposal_date
				,@branch_code
				,@branch_name
				,@location_code
				,@location_name
				,@description
				,@reason_type
				,@remarks
				,@status
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_reverse_disposal_history_insert @p_code					= @code
														,@p_company_code			= @company_code
														,@p_disposal_code			= @disposal_code
														,@p_disposal_date			= @disposal_date
														,@p_reverse_disposal_date	= @reverse_disposal_date
														,@p_branch_code				= @branch_code
														,@p_branch_name				= @branch_name
														,@p_location_code			= @location_code
														,@p_location_name			= @location_name
														,@p_description				= @description
														,@p_reason_type				= @reason_type
														,@p_remarks					= @remarks
														,@p_status					= @status
														--
														,@p_cre_date				= @cre_date
														,@p_cre_by					= @cre_by
														,@p_cre_ip_address			= @cre_ip_address
														,@p_mod_date				= @mod_date
														,@p_mod_by					= @mod_by
														,@p_mod_ip_address			= @mod_ip_address	;
			
			-- reverse disposal Detail
			declare c_reverse_disposal_detail cursor fast_forward read_only for 
			select	asset_code
					,cost_center_code
					,cost_center_name
					,description
			from	dbo.reverse_disposal_detail 
			where	reverse_disposal_code = @code 
			
			open c_reverse_disposal_detail
			
			fetch next from c_reverse_disposal_detail 
			into	@asset_code
					,@cost_center_code
					,@cost_center_name
					,@description_detail
			
			while @@fetch_status = 0
			begin
			    
				exec dbo.xsp_reverse_disposal_detail_history_insert @p_id						= 0
				                                                  ,@p_reverse_disposal_code		= @code
				                                                  ,@p_asset_code				= @asset_code 
				                                                  ,@p_cost_center_code			= @cost_center_code 
				                                                  ,@p_cost_center_name			= @cost_center_name 
				                                                  ,@p_description				= @description_detail 
																	--
																  ,@p_cre_date					= @cre_date		
																  ,@p_cre_by					= @cre_by			
																  ,@p_cre_ip_address			= @cre_ip_address	
																  ,@p_mod_date					= @cre_date		
																  ,@p_mod_by					= @cre_by		
																  ,@p_mod_ip_address			= @cre_ip_address
				
				
			    fetch next from c_reverse_disposal_detail 
				into	@asset_code
						,@cost_center_code
						,@cost_center_name
						,@description_detail
			end
			
			close c_reverse_disposal_detail
			deallocate c_reverse_disposal_detail
			

			-- disposal Document
			declare c_reverse_disposal_doc cursor fast_forward read_only for 
			select	file_name
					,path
					,description 
			from	dbo.reverse_disposal_document 
			where	reverse_disposal_code = @code ;
			
			open c_reverse_disposal_doc
			
			fetch next from c_reverse_disposal_doc 
			into	@file_name_doc
					,@path_doc
					,@description_doc
			
			while @@fetch_status = 0
			begin
			    
				declare @p_id bigint;
				exec dbo.xsp_reverse_disposal_document_history_insert @p_id						= 0
				                                                     ,@p_reverse_disposal_code	= @code
				                                                     ,@p_file_name				= @file_name_doc
				                                                     ,@p_path					= @path_doc
				                                                     ,@p_description			= @description_doc
																	 ,@p_cre_date				= @cre_date		
																	 ,@p_cre_by					= @cre_by			
																	 ,@p_cre_ip_address			= @cre_ip_address	
																	 ,@p_mod_date				= @cre_date		
																	 ,@p_mod_by					= @cre_by		
																	 ,@p_mod_ip_address			= @cre_ip_address ;
				
			    fetch next from c_reverse_disposal_doc 
				into	@file_name_doc
						,@path_doc
						,@description_doc
			end
			
			close c_reverse_disposal_doc
			deallocate c_reverse_disposal_doc

			insert into @code_reverse_disposal
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_reverse_disposal_trx 
			into	@code
					,@company_code
					,@disposal_code
					,@disposal_date
					,@reverse_disposal_date
					,@branch_code
					,@branch_name
					,@location_code
					,@location_name
					,@description
					,@reason_type
					,@remarks
					,@status
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_reverse_disposal_trx
		deallocate c_reverse_disposal_trx
		
		-- delete data
		delete	dbo.reverse_disposal 
		where	code in (select code collate latin1_general_ci_as from @code_reverse_disposal) ;

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
