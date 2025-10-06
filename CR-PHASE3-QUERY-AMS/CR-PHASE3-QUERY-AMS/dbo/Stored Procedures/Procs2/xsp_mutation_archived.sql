CREATE PROCEDURE dbo.xsp_mutation_archived 
as
begin
	declare @msg							nvarchar(max)
			,@max_value						int	
			,@code							nvarchar(50)
			,@company_code					nvarchar(50)
			,@mutation_date					datetime
			,@requestor_code				nvarchar(50)
			,@branch_request_code			nvarchar(50)
			,@branch_request_name			nvarchar(250)
			,@from_units_code				nvarchar(50)
			,@from_units_name				nvarchar(250)
			,@to_units_code					nvarchar(50)
			,@to_units_name					nvarchar(250)
			,@status						nvarchar(50)
			,@remark						nvarchar(250)
			,@date							datetime
			,@document_refference_no		nvarchar(50)
			,@document_refference_type		nvarchar(10)
			,@usage_duration				int
			,@from_branch_code				nvarchar(50)
			,@from_branch_name				nvarchar(250)
			,@to_branch_code				nvarchar(50)
			,@to_branch_name				nvarchar(250)
			,@from_location_code			nvarchar(50)
			,@to_location_code				nvarchar(50)
			,@from_pic_code					nvarchar(50)
			,@to_pic_code					nvarchar(50)
			,@from_division_code			nvarchar(50)
			,@from_division_name			nvarchar(250)
			,@to_division_code				nvarchar(50)
			,@to_division_name				nvarchar(250)
			,@from_department_code			nvarchar(50)
			,@from_department_name			nvarchar(250)
			,@to_department_code			nvarchar(50)
			,@to_department_name			nvarchar(250)
			,@from_sub_department_code		nvarchar(50)
			,@from_sub_department_name		nvarchar(250)
			,@to_sub_department_code		nvarchar(50)
			,@to_sub_department_name		nvarchar(250)
			,@from_unit_code				nvarchar(50)
			,@from_unit_name				nvarchar(250)
			,@to_unit_code					nvarchar(50)
			,@to_unit_name					nvarchar(250)
			--
			,@mutation_code					nvarchar(50)
			,@asset_code					nvarchar(50)
			,@cost_center_code				nvarchar(50)
			,@cost_center_name				nvarchar(250)
			,@description					nvarchar(4000)
			,@receive_date					datetime
			,@remark_unpost					nvarchar(4000)
			,@remark_return					nvarchar(4000)
			,@file_name						nvarchar(250)
			,@path							nvarchar(250)
			,@status_received				nvarchar(25)
			--
			,@file_name_doc					nvarchar(250)
			,@path_doc						nvarchar(250)
			,@description_doc				nvarchar(400)
			,@cre_date						datetime
			,@cre_by						nvarchar(50)
			,@cre_ip_address				nvarchar(15)
			,@mod_date						datetime
			,@mod_by						nvarchar(50)
			,@mod_ip_address				nvarchar(15) ;

	begin try 
		declare @code_mutation as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_mutation_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,mutation_date
				,requestor_code
				,branch_request_code
				,branch_request_name
				,from_branch_code
				,from_branch_name
				,from_division_code
				,from_division_name
				,from_department_code
				,from_department_name
				,from_pic_code
				,to_branch_code
				,to_branch_name
				,to_division_code
				,to_division_name
				,to_department_code
				,to_department_name
				,to_pic_code
				,status
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.mutation 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,mutation_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_mutation_trx
		
		fetch next from c_mutation_trx 
		into	@code
				,@company_code
				,@mutation_date
				,@requestor_code
				,@branch_request_code
				,@branch_request_name
				,@from_branch_code
				,@from_branch_name
				,@from_division_code
				,@from_division_name
				,@from_department_code
				,@from_department_name
				,@from_pic_code
				,@to_branch_code
				,@to_branch_name
				,@to_division_code
				,@to_division_name
				,@to_department_code
				,@to_department_name
				,@to_pic_code
				,@status
				,@remark
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_mutation_history_insert @p_code						= @code                            
												,@p_company_code				= @company_code			
												,@p_mutation_date				= @mutation_date			
												,@p_requestor_code				= @requestor_code			
												,@p_branch_request_code			= @branch_request_code		
												,@p_branch_request_name			= @branch_request_name		
												,@p_from_branch_code			= @from_branch_code		
												,@p_from_branch_name			= @from_branch_name		
												,@p_from_division_code			= @from_division_code		
												,@p_from_division_name			= @from_division_name		
												,@p_from_department_code		= @from_department_code	
												,@p_from_department_name		= @from_department_name	
												,@p_from_sub_department_code	= ''
												,@p_from_sub_department_name	= ''
												,@p_from_units_code				= ''			
												,@p_from_units_name				= ''			
												,@p_from_location_code			= ''		
												,@p_from_pic_code				= @from_pic_code			
												,@p_to_branch_code				= @to_branch_code			
												,@p_to_branch_name				= @to_branch_name			
												,@p_to_division_code			= @to_division_code		
												,@p_to_division_name			= @to_division_name		
												,@p_to_department_code			= @to_department_code		
												,@p_to_department_name			= @to_department_name		
												,@p_to_sub_department_code		= ''	
												,@p_to_sub_department_name		= ''	
												,@p_to_units_code				= ''			
												,@p_to_units_name				= ''			
												,@p_to_location_code			= ''		
												,@p_to_pic_code					= @to_pic_code				
												,@p_status						= @status					
												,@p_remark						= @remark					
												,@p_cre_date					= @cre_date		
												,@p_cre_by						= @cre_by			
												,@p_cre_ip_address				= @cre_ip_address			
												,@p_mod_date					= @mod_date		
												,@p_mod_by						= @mod_by			
												,@p_mod_ip_address				= @mod_ip_address ;			
			
			-- Mutation Detail
			declare c_mutation_detail cursor fast_forward read_only for 
			select	asset_code
					,cost_center_code
					,cost_center_name
					,description
					,receive_date
					,remark_unpost
					,remark_return
					,file_name
					,path
					,status_received
			from	dbo.mutation_detail 
			where	mutation_code = @code 
			
			open c_mutation_detail
			
			fetch next from c_mutation_detail 
			into	@asset_code
					,@cost_center_code
					,@cost_center_name
					,@description
					,@receive_date
					,@remark_unpost
					,@remark_return
					,@file_name
					,@path
					,@status_received
			
			while @@fetch_status = 0
			begin
			    
				exec dbo.xsp_mutation_detail_history_insert @p_id					= 0
															,@p_mutation_code		= @mutation_code	
															,@p_asset_code			= @asset_code		
															,@p_cost_center_code	= @cost_center_code
															,@p_cost_center_name	= @cost_center_name
															,@p_description			= @description		
															,@p_receive_date		= @receive_date	
															,@p_remark_unpost		= @remark_unpost	
															,@p_remark_return		= @remark_return	
															,@p_file_name			= @file_name		
															,@p_path				= @path			
															,@p_status_received		= @status_received	
															,@p_cre_date			= @cre_date
															,@p_cre_by				= @cre_by	
															,@p_cre_ip_address		= @cre_ip_address	
															,@p_mod_date			= @mod_date
															,@p_mod_by				= @mod_by
															,@p_mod_ip_address		= @mod_ip_address
				
				
			    fetch next from c_mutation_detail 
				into	@asset_code
						,@cost_center_code
						,@cost_center_name
						,@description
						,@receive_date
						,@remark_unpost
						,@remark_return
						,@file_name
						,@path
						,@status_received
			end
			
			close c_mutation_detail
			deallocate c_mutation_detail
			

			-- Mutation Document
			declare c_mutation_doc cursor fast_forward read_only for 
			select	file_name
					,path
					,description 
			from	dbo.mutation_document 
			where	mutation_code = @code ;
			
			open c_mutation_doc
			
			fetch next from c_mutation_doc 
			into	@file_name_doc
					,@path_doc
					,@description_doc
			
			while @@fetch_status = 0
			begin
			    
				exec dbo.xsp_mutation_document_history_insert @p_id				= 0
				                                             ,@p_mutation_code	= @code
				                                             ,@p_file_name		= @file_name_doc
				                                             ,@p_path			= @path_doc
				                                             ,@p_description	= @description_doc
															 ,@p_cre_date		= @cre_date
															 ,@p_cre_by			= @cre_by	
															 ,@p_cre_ip_address	= @cre_ip_address	
															 ,@p_mod_date		= @mod_date
															 ,@p_mod_by			= @mod_by
															 ,@p_mod_ip_address	= @mod_ip_address ;
				
			    fetch next from c_mutation_doc 
				into	@file_name_doc
						,@path_doc
						,@description_doc
			end
			
			close c_mutation_doc
			deallocate c_mutation_doc

			insert into @code_mutation
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_mutation_trx 
			into	@code
					,@company_code
					,@mutation_date
					,@requestor_code
					,@branch_request_code
					,@branch_request_name
					,@from_branch_code
					,@from_branch_name
					,@from_division_code
					,@from_division_name
					,@from_department_code
					,@from_department_name
					,@from_location_code
					,@from_pic_code
					,@to_branch_code
					,@to_branch_name
					,@to_division_code
					,@to_division_name
					,@to_department_code
					,@to_department_name
					,@to_pic_code
					,@status
					,@remark
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_mutation_trx
		deallocate c_mutation_trx
		
		-- delete data
		delete	dbo.mutation 
		where	code in (select code collate latin1_general_ci_as from @code_mutation) ;

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
