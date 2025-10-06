CREATE PROCEDURE dbo.xsp_change_category_archived 
as
begin
	declare @msg								nvarchar(max)
			,@max_value							int	
			,@code								nvarchar(50)
			,@company_code						nvarchar(50)
			,@date								datetime
			,@asset_code						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@location_code						nvarchar(50)
			,@location_name						nvarchar(250)
			,@description						nvarchar(4000)
			,@from_category_code				nvarchar(50)
			,@to_category_code					nvarchar(50)
			,@from_net_book_value_comm			nvarchar(50)
			,@to_net_book_value_comm			nvarchar(50)
			,@from_net_book_value_fiscal		nvarchar(50)
			,@to_net_book_value_fiscal			nvarchar(50)
			,@cost_center_code					nvarchar(50)
			,@cost_center_name					nvarchar(50)
			,@from_item_code					nvarchar(50)
			,@to_item_code						nvarchar(50)
			,@to_depre_category_fiscal_code		nvarchar(50)
			,@to_depre_category_comm_code		nvarchar(50)
			,@remarks							nvarchar(4000)
			,@status							nvarchar(25)
			,@from_depre_category_fiscal_code	nvarchar(50)
			,@from_depre_category_comm_code		nvarchar(50)
			--
			,@description_detail				nvarchar(4000)
			--
			,@file_name_doc						nvarchar(250)
			,@path_doc							nvarchar(250)
			,@description_doc					nvarchar(400)
			,@cre_date							datetime
			,@cre_by							nvarchar(50)
			,@cre_ip_address					nvarchar(15)
			,@mod_date							datetime
			,@mod_by							nvarchar(50)
			,@mod_ip_address					nvarchar(15) ;

	begin try 
		declare @code_change_category as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_change_category_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,date
				,asset_code
				,branch_code
				,branch_name
				,description
				,from_category_code
				,to_category_code
				,from_net_book_value_comm
				,to_net_book_value_comm
				,from_net_book_value_fiscal
				,to_net_book_value_fiscal
				,from_item_code
				,to_item_code
				,to_depre_category_fiscal_code
				,to_depre_category_comm_code
				,remarks
				,status
				,from_depre_category_fiscal_code
				,from_depre_category_comm_code
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.change_category 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,date, dbo.xfn_get_system_date()) > @max_value ;

		open c_change_category_trx
		
		fetch next from c_change_category_trx 
		into	@code
				,@company_code
				,@date
				,@asset_code
				,@branch_code
				,@branch_name
				,@location_code
				,@location_name
				,@description
				,@from_category_code
				,@to_category_code
				,@from_net_book_value_comm
				,@to_net_book_value_comm
				,@from_net_book_value_fiscal
				,@to_net_book_value_fiscal
				,@cost_center_code
				,@cost_center_name
				,@from_item_code
				,@to_item_code
				,@to_depre_category_fiscal_code
				,@to_depre_category_comm_code
				,@remarks
				,@status
				,@from_depre_category_fiscal_code
				,@from_depre_category_comm_code
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_change_category_history_insert @p_code								= @code
														,@p_company_code					= @company_code
														,@p_date							= @date
														,@p_asset_code						= @asset_code                    
														,@p_branch_code						= @branch_code                   
														,@p_branch_name						= @branch_name                   
														,@p_location_code					= @location_code                 
														,@p_location_name					= @location_name                 
														,@p_description						= @description                   
														,@p_from_category_code				= @from_category_code            
														,@p_to_category_code				= @to_category_code              
														,@p_from_net_book_value_comm		= @from_net_book_value_comm      
														,@p_to_net_book_value_comm			= @to_net_book_value_comm        
														,@p_from_net_book_value_fiscal		= @from_net_book_value_fiscal    
														,@p_to_net_book_value_fiscal		= @to_net_book_value_fiscal      
														,@p_cost_center_code				= @cost_center_code              
														,@p_cost_center_name				= @cost_center_name              
														,@p_from_item_code					= @from_item_code                
														,@p_to_item_code					= @to_item_code                  
														,@p_to_depre_category_fiscal_code	= @to_depre_category_fiscal_code 
														,@p_to_depre_category_comm_code		= @to_depre_category_comm_code   
														,@p_from_depre_category_fiscal_code	= @from_depre_category_fiscal_code
														,@p_from_depre_category_comm_code	= @from_depre_category_comm_code
														,@p_remarks							= @remarks                       
														,@p_status							= @status                        
														--
														,@p_cre_date						= @cre_date
														,@p_cre_by							= @cre_by
														,@p_cre_ip_address					= @cre_ip_address
														,@p_mod_date						= @mod_date
														,@p_mod_by							= @mod_by
														,@p_mod_ip_address					= @mod_ip_address	;
			
			
			insert into @code_change_category
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_change_category_trx 
			into	@code
					,@company_code
					,@date
					,@asset_code
					,@branch_code
					,@branch_name
					,@location_code
					,@location_name
					,@description
					,@from_category_code
					,@to_category_code
					,@from_net_book_value_comm
					,@to_net_book_value_comm
					,@from_net_book_value_fiscal
					,@to_net_book_value_fiscal
					,@cost_center_code
					,@cost_center_name
					,@from_item_code
					,@to_item_code
					,@to_depre_category_fiscal_code
					,@to_depre_category_comm_code
					,@remarks
					,@status
					,@from_depre_category_fiscal_code
					,@from_depre_category_comm_code
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_change_category_trx
		deallocate c_change_category_trx
		
		-- delete data
		delete	dbo.change_category 
		where	code in (select code collate latin1_general_ci_as from @code_change_category) ;

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
