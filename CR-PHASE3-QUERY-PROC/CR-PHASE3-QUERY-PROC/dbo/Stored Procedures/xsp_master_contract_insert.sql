CREATE PROCEDURE [dbo].[xsp_master_contract_insert]
(
	@p_main_contract_no		 nvarchar(50) output
	,@p_client_code			 nvarchar(50)
	,@p_client_name			 nvarchar(250)
	,@p_date				 datetime
	,@p_contract_standart	nvarchar(50)
	,@p_remark				 nvarchar(4000)
	,@p_file_name			 nvarchar(250)	= ''
	,@p_file_path			 nvarchar(250)	= ''
	,@p_memo_file_name		 nvarchar(250)	= ''
	,@p_memo_file_path		 nvarchar(250)	= ''
	,@p_status				 nvarchar(50)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @code				nvarchar(50)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@msg				nvarchar(max)
			,@general_doc_code	nvarchar(50)
			,@is_required		nvarchar(1)

	begin try
		--select	top 1
		--		@is_use_maintenance = is_use_maintenance
		--		,@is_use_replacement = is_use_replacement
		--from	dbo.application_asset
		--where	application_no = @p_application_no ;

		--if (
		--	   @is_use_maintenance = '1'
		--	   and	@is_use_replacement = '0'
		--   )
		--begin
		--	set @opl_code = N'OPL-AGR/FWR' ;
		--end ;
		--else if (@is_use_maintenance = '1')
		--begin
		--	set @opl_code = N'OPL-AGR/FM' ;
		--end ;
		--else if (@is_use_maintenance = '0')
		--begin
		--	set @opl_code = N'OPL-AGR/NM' ;
		--end ;

		
		--if (isnull(@p_main_contract_no, '') = '')
		--begin
		--	set @year = cast(datepart(year, @p_mod_date) as nvarchar)
		--	set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		--	exec dbo.xsp_generate_application_no @p_unique_code = @code output
		--										 ,@p_branch_code = N''
		--										 ,@p_year = @year
		--										 ,@p_month = @month
		--										 ,@p_opl_code = @opl_code
		--										 ,@p_run_number_length = 3
		--										 ,@p_delimiter = N'/'
		--										 ,@p_type = N'MASTER CONTRACT'
		--end 

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = ''
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'MC'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'MASTER_CONTRACT'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.master_contract
		(
			main_contract_no
			,client_code
			,client_name
			,date
			,contract_standart
			,remark
			,file_name
			,file_path
			,memo_file_name
			,memo_file_path
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_client_code
			,@p_client_name
			,@p_date
			,@p_contract_standart
			,@p_remark
			,@p_file_name
			,@p_file_path
			,@p_memo_file_name
			,@p_memo_file_path
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		set @p_main_contract_no = @code ;

		
		declare curr_doc cursor fast_forward read_only for
		select	dgd.general_doc_code
				,dgd.is_required
		from	dbo.master_document_group_detail dgd
		where	dgd.document_group_code	= 'MDG.2211.000001'
		
		open curr_doc
		
		fetch next from curr_doc 
		into @general_doc_code
			,@is_required
		
		while @@fetch_status = 0
		begin
		    exec dbo.xsp_master_contract_document_insert @p_id					= 0
		    											 ,@p_main_contract_no	= @code
		    											 ,@p_document_code		= @general_doc_code
		    											 ,@p_remarks			= ''
		    											 ,@p_filename			= ''
		    											 ,@p_paths				= ''
		    											 ,@p_expired_date		= null
		    											 ,@p_promise_date		= null
		    											 ,@p_is_required		= @is_required
		    											 ,@p_is_valid			= ''
		    											 ,@p_cre_date			= @p_mod_date
		    											 ,@p_cre_by				= @p_mod_by
		    											 ,@p_cre_ip_address		= @p_mod_ip_address
		    											 ,@p_mod_date			= @p_mod_date
		    											 ,@p_mod_by				= @p_mod_by
		    											 ,@p_mod_ip_address		= @p_mod_ip_address
		    
		
		    fetch next from curr_doc 
			into @general_doc_code
				,@is_required
		end
		
		close curr_doc
		deallocate curr_doc

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
