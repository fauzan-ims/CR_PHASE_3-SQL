CREATE PROCEDURE dbo.xsp_reverse_sale_archived 
as
begin
	declare @msg						nvarchar(max)
			,@max_value					int	
			,@code						nvarchar(50)
			,@company_code				nvarchar(50)
			,@sale_code					nvarchar(50)
			,@sale_date					datetime
			,@reverse_sale_date    		datetime
			,@reason_reverse_code		nvarchar(50)
			,@description				nvarchar(4000)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@location_code				nvarchar(50)
			,@location_name				nvarchar(250)
			,@to_bank_account_no		nvarchar(50)
			,@to_bank_account_name		nvarchar(250)
			,@to_bank_code				nvarchar(50)
			,@to_bank_name				nvarchar(250)
			,@buyer						nvarchar(250)
			,@buyer_phone_no       		nvarchar(50)
			,@sale_amount				decimal(18, 2)
			,@remark					nvarchar(4000)
			,@status					nvarchar(20)
			--
			,@asset_code				nvarchar(50)
			,@description_detail		nvarchar(4000)
			,@sale_value				decimal(18, 2)
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
		declare @code_reverse_sale as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_reverse_sale_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,sale_code
				,sale_date
				,reverse_sale_date
				,reason_reverse_code
				,description
				,branch_code
				,branch_name
				,location_code
				,location_name
				,to_bank_account_no
				,to_bank_account_name
				,to_bank_code
				,to_bank_name
				,buyer
				,buyer_phone_no
				,sale_amount
				,remark
				,status
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.reverse_sale 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,reverse_sale_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_reverse_sale_trx
		
		fetch next from c_reverse_sale_trx 
		into	@code
				,@company_code
				,@sale_code
				,@sale_date
				,@reverse_sale_date
				,@reason_reverse_code
				,@description
				,@branch_code
				,@branch_name
				,@location_code
				,@location_name
				,@to_bank_account_no
				,@to_bank_account_name
				,@to_bank_code
				,@to_bank_name
				,@buyer
				,@buyer_phone_no
				,@sale_amount
				,@remark
				,@status
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_reverse_sale_history_insert @p_code					= @code
													,@p_company_code			= @company_code
													,@p_sale_code				= @sale_code				
													,@p_sale_date				= @sale_date			    
													,@p_reverse_sale_date		= @reverse_sale_date    	
													,@p_reason_reverse_code		= @reason_reverse_code		
													,@p_description				= @description				
													,@p_branch_code				= @branch_code				
													,@p_branch_name				= @branch_name				
													,@p_location_code			= @location_code			
													,@p_location_name			= @location_name			
													,@p_to_bank_account_no		= @to_bank_account_no		
													,@p_to_bank_account_name	= @to_bank_account_name		
													,@p_to_bank_code			= @to_bank_code				
													,@p_to_bank_name			= @to_bank_name				
													,@p_buyer					= @buyer				    
													,@p_buyer_phone_no			= @buyer_phone_no       	
													,@p_sale_amount				= @sale_amount				
													,@p_remark					= @remark					
													,@p_status					= @status					
													--
													,@p_cre_date				= @cre_date
													,@p_cre_by					= @cre_by
													,@p_cre_ip_address			= @cre_ip_address
													,@p_mod_date				= @mod_date
													,@p_mod_by					= @mod_by
													,@p_mod_ip_address			= @mod_ip_address;
			
			-- reverse sale detail
			insert into dbo.reverse_sale_detail_history
			(
			    reverse_sale_code
				,asset_code
				,description
				,net_book_value
				,sale_value
				,cost_center_code
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select   
					@code
					,asset_code
					,description
					,net_book_value
					,sale_value
					,cost_center_code
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
			from	dbo.reverse_sale_detail 
			where	reverse_sale_code = @code ;
			


			-- reverse sale Document
			insert into dbo.reverse_sale_document_history
			(
			    reverse_sale_code
				,file_name
				,path
				,description
				,cre_by
				,cre_date
				,cre_ip_address
				,mod_by
				,mod_date
				,mod_ip_address
			)
			select	@code
					,file_name
					,path
					,description
					--
					,cre_by
					,cre_date
					,cre_ip_address
					,mod_by
					,mod_date
					,mod_ip_address
			from	dbo.reverse_sale_document
			where	reverse_sale_code = @code ;
			



			insert into @code_reverse_sale
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_reverse_sale_trx 
			into	@code
					,@company_code
					,@sale_code
					,@sale_date
					,@reverse_sale_date
					,@reason_reverse_code
					,@description
					,@branch_code
					,@branch_name
					,@location_code
					,@location_name
					,@to_bank_account_no
					,@to_bank_account_name
					,@to_bank_code
					,@to_bank_name
					,@buyer
					,@buyer_phone_no
					,@sale_amount
					,@remark
					,@status
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_reverse_sale_trx
		deallocate c_reverse_sale_trx
		
		-- delete data
		delete	dbo.reverse_sale 
		where	code in (select code collate latin1_general_ci_as from @code_reverse_sale) ;

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
