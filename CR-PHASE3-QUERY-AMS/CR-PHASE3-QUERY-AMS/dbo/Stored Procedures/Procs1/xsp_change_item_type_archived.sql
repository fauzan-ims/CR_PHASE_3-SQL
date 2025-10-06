CREATE PROCEDURE dbo.xsp_change_item_type_archived 
as
begin
	declare @msg							nvarchar(max)
			,@max_value						int	
			,@code							nvarchar(50)
			,@company_code					nvarchar(50)
			,@date							datetime
			,@description					nvarchar(1000)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@location_code					nvarchar(50)
			,@location_name					nvarchar(250)
			,@from_item_code				nvarchar(50)
			,@from_item_name				nvarchar(250)
			,@to_item_code					nvarchar(50)
			,@to_item_name					nvarchar(250)
			,@from_category_code			nvarchar(50)
			,@from_category_name			nvarchar(250)
			,@to_category_code				nvarchar(50)
			,@to_category_name				nvarchar(250)
			,@original_price_amount			decimal(18, 2)
			,@net_book_value_amount			decimal(18, 2)
			,@remark						nvarchar(4000)
			,@status						nvarchar(50)
			,@asset_code					nvarchar(50)
			,@barcode						nvarchar(50)
			--
			,@description_detail			nvarchar(4000)
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
		declare @code_change_item_type as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_change_item_type_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,date
				,description
				,branch_code
				,branch_name
				,from_item_code
				,from_item_name
				,to_item_code
				,to_item_name
				,from_category_code
				,from_category_name
				,to_category_code
				,to_category_name
				,original_price_amount
				,net_book_value_amount
				,remark
				,status
				,asset_code
				,barcode
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.change_item_type 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,date, dbo.xfn_get_system_date()) > @max_value ;

		open c_change_item_type_trx
		
		fetch next from c_change_item_type_trx 
		into	@code
				,@company_code
				,@date
				,@description
				,@branch_code
				,@branch_name
				,@from_item_code
				,@from_item_name
				,@to_item_code
				,@to_item_name
				,@from_category_code
				,@from_category_name
				,@to_category_code
				,@to_category_name
				,@original_price_amount
				,@net_book_value_amount
				,@remark
				,@status
				,@asset_code
				,@barcode
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_change_item_type_history_insert @p_code					= @code
														,@p_company_code			= @company_code
														,@p_date					= @date
														,@p_description				= @description               
														,@p_branch_code				= @branch_code               
														,@p_branch_name				= @branch_name               
														,@p_location_code			= ''             
														,@p_location_name			= ''             
														,@p_from_item_code			= @from_item_code            
														,@p_from_item_name			= @from_item_name            
														,@p_to_item_code			= @to_item_code              
														,@p_to_item_name			= @to_item_name              
														,@p_from_category_code		= @from_category_code        
														,@p_from_category_name		= @from_category_name        
														,@p_to_category_code		= @to_category_code          
														,@p_to_category_name		= @to_category_name          
														,@p_original_price_amount	= @original_price_amount     
														,@p_net_book_value_amount	= @net_book_value_amount     
														,@p_remark					= @remark                    
														,@p_status					= @status               
														,@p_asset_code				= @asset_code
														,@p_barcode					= @barcode     
														--
														,@p_cre_date				= @cre_date
														,@p_cre_by					= @cre_by
														,@p_cre_ip_address			= @cre_ip_address
														,@p_mod_date				= @mod_date
														,@p_mod_by					= @mod_by
														,@p_mod_ip_address			= @mod_ip_address	;
			
			
			insert into @code_change_item_type
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_change_item_type_trx 
			into	@code
					,@company_code
					,@date
					,@description
					,@branch_code
					,@branch_name
					,@from_item_code
					,@from_item_name
					,@to_item_code
					,@to_item_name
					,@from_category_code
					,@from_category_name
					,@to_category_code
					,@to_category_name
					,@original_price_amount
					,@net_book_value_amount
					,@remark
					,@status
					,@asset_code
					,@barcode
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_change_item_type_trx
		deallocate c_change_item_type_trx
		
		-- delete data
		delete	dbo.change_item_type 
		where	code in (select code collate latin1_general_ci_as from @code_change_item_type) ;

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

