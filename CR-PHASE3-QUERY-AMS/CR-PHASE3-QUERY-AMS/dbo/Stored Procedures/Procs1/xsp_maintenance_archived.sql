CREATE PROCEDURE dbo.xsp_maintenance_archived 
as
begin
	declare @msg					nvarchar(max)
			,@max_value				int	
			,@code					nvarchar(50)
			,@company_code			nvarchar(50)
			,@asset_code			nvarchar(50)
			,@transaction_date		datetime
			,@transaction_amount	decimal(18, 2)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@location_code			nvarchar(50)
			,@requestor_code		nvarchar(50)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(250)
			,@department_code		nvarchar(50)
			,@department_name		nvarchar(250)
			,@sub_department_code	nvarchar(50)
			,@sub_department_name	nvarchar(250)
			,@unit_code				nvarchar(50)
			,@unit_name				nvarchar(250)
			,@maintenance_by		nvarchar(50)
			,@status				nvarchar(20)
			,@remark				nvarchar(4000)
			,@category_code			nvarchar(50)
			,@category_name			nvarchar(250)
			--
			,@description_detail	nvarchar(4000)
			--
			,@file_name_doc			nvarchar(250)
			,@path_doc				nvarchar(250)
			,@description_doc		nvarchar(400)
			,@cre_date				datetime
			,@cre_by				nvarchar(50)
			,@cre_ip_address		nvarchar(15)
			,@mod_date				datetime
			,@mod_by				nvarchar(50)
			,@mod_ip_address		nvarchar(15) ;

	begin try 
		declare @code_maintenance as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_maintenance_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,asset_code
				,transaction_date
				,transaction_amount
				,branch_code
				,branch_name
				,requestor_code
				,division_code
				,division_name
				,department_code
				,department_name
				,maintenance_by
				,status
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.maintenance 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,transaction_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_maintenance_trx
		
		fetch next from c_maintenance_trx 
		into	@code
				,@company_code
				,@asset_code
				,@transaction_date
				,@transaction_amount
				,@branch_code
				,@branch_name
				,@requestor_code
				,@division_code
				,@division_name
				,@department_code
				,@department_name
				,@maintenance_by
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
		    
			exec dbo.xsp_maintenance_history_insert @p_code					= @code
													,@p_company_code		= @company_code
													,@p_asset_code			= @asset_code			
													,@p_transaction_date	= @transaction_date		
													,@p_transaction_amount	= @transaction_amount	
													,@p_branch_code			= @branch_code			
													,@p_branch_name			= @branch_name			
													,@p_location_code		= ''		
													,@p_requestor_code		= @requestor_code		
													,@p_division_code		= @division_code		
													,@p_division_name		= @division_name		
													,@p_department_code		= @department_code		
													,@p_department_name		= @department_name		
													,@p_sub_department_code = ''	
													,@p_sub_department_name = ''	
													,@p_unit_code			= ''			
													,@p_unit_name			= ''			
													,@p_maintenance_by		= @maintenance_by		
													,@p_status				= @status				
													,@p_remark				= @remark	
													,@p_category_code		= ''
													,@p_category_name		= ''			
													--
													,@p_cre_date			= @cre_date
													,@p_cre_by				= @cre_by
													,@p_cre_ip_address		= @cre_ip_address
													,@p_mod_date			= @mod_date
													,@p_mod_by				= @mod_by
													,@p_mod_ip_address		= @mod_ip_address	;
			
			-- maintenance Detail
			insert into dbo.maintenance_detail_history
			(
			    maintenance_code
				,asset_code
				,file_name
				,path
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	maintenance_code
					,service_code
					,file_name
					,path
					--
					,@cre_date		
					,@cre_by		
					,@cre_ip_address
					,@cre_date		
					,@cre_by		
					,@cre_ip_address	
			from	dbo.maintenance_detail 
			where	maintenance_code = @code ;



			insert into @code_maintenance
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_maintenance_trx 
			into	@code
					,@company_code
					,@asset_code
					,@transaction_date
					,@transaction_amount
					,@branch_code
					,@branch_name
					,@requestor_code
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@maintenance_by
					,@status
					,@remark
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_maintenance_trx
		deallocate c_maintenance_trx
		
		-- delete data
		delete	dbo.maintenance 
		where	code in (select code collate latin1_general_ci_as from @code_maintenance) ;

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

