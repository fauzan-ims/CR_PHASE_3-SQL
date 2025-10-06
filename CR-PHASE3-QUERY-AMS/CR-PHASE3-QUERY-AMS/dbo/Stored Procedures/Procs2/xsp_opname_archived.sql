CREATE PROCEDURE dbo.xsp_opname_archived 
as
begin
	declare @msg					nvarchar(max)
			,@max_value				int	
			,@code					nvarchar(50)
			,@company_code			nvarchar(50)
			,@opname_date			datetime
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@location_code			nvarchar(50)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(100)
			,@department_code		nvarchar(50)
			,@department_name		nvarchar(100)
			,@status				nvarchar(20)
			,@description			nvarchar(4000)
			,@remark				nvarchar(4000)
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
		declare @code_opname as table
		(
			code nvarchar(50)
		)

		select	@max_value = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAD'

		declare c_opname_trx cursor fast_forward read_only for 
		select	code
				,company_code
				,opname_date
				,branch_code
				,branch_name
				,location_code
				,division_code
				,division_name
				,department_code
				,department_name
				,status
				,description
				,remark
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.opname 
		where	status in ('REJECT', 'CANCEL')
		and		datediff(month,opname_date, dbo.xfn_get_system_date()) > @max_value ;

		open c_opname_trx
		
		fetch next from c_opname_trx 
		into	@code
				,@company_code
				,@opname_date
				,@branch_code
				,@branch_name
				,@location_code
				,@division_code
				,@division_name
				,@department_code
				,@department_name
				,@status
				,@description
				,@remark
				,@cre_date
				,@cre_by
				,@cre_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
		
		while @@fetch_status = 0
		begin
		    
			exec dbo.xsp_opname_history_insert @p_code				= @code
			                                  ,@p_company_code		= @company_code
			                                  ,@p_opname_date		= @opname_date
			                                  ,@p_branch_code		= @branch_code
			                                  ,@p_branch_name		= @branch_name
			                                  ,@p_location_code		= @location_code
			                                  ,@p_division_code		= @division_code
			                                  ,@p_division_name		= @division_name
			                                  ,@p_department_code	= @department_code
			                                  ,@p_department_name	= @department_name
			                                  ,@p_status			= @status
			                                  ,@p_description		= @description
			                                  ,@p_remark			= @remark
											  --
											  ,@p_cre_date			= @cre_date
											  ,@p_cre_by			= @cre_by
											  ,@p_cre_ip_address	= @cre_ip_address
											  ,@p_mod_date			= @mod_date
											  ,@p_mod_by			= @mod_by
											  ,@p_mod_ip_address	= @mod_ip_address;
			
			-- opname Detail
			insert into dbo.opname_detail_history
			(
			    opname_code
				,asset_code
				,stock
				,quantity
				,depre_comercial
				,depre_fiscal
				,branch_code
				,branch_name
				,location_code
				,condition_code
				,location_in
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
			select   @code
					,asset_code 
					,stock		
					,quantity	
					,depre_comercial	
					,depre_fiscal		
					,branch_code		
					,branch_name		
					,location_code		
					,condition_code		
					,location_in		
					,file_name			
					,path		
					--		
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.opname_detail 
			where	opname_code = @code ;
			



			insert into @code_opname
			(
			    code
			)
			values 
			(
				@code
			)

		    fetch next from c_opname_trx 
			into	@code
					,@company_code
					,@opname_date
					,@branch_code
					,@branch_name
					,@location_code
					,@division_code
					,@division_name
					,@department_code
					,@department_name
					,@status
					,@description
					,@remark
					,@cre_date
					,@cre_by
					,@cre_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
		end
		
		close c_opname_trx
		deallocate c_opname_trx
		
		-- delete data
		delete	dbo.opname 
		where	code in (select code collate latin1_general_ci_as from @code_opname) ;

	end try
	Begin catch
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

