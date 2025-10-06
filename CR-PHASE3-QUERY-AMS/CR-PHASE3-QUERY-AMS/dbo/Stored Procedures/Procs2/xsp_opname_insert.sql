CREATE PROCEDURE [dbo].[xsp_opname_insert]
(
	@p_code				nvarchar(50) output
	,@p_company_code	nvarchar(50) ='DSF'
	,@p_opname_date		datetime
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_location_code	nvarchar(50)	= ''
	,@p_location_name	nvarchar(250)	= ''
	,@p_status			nvarchar(20)
	,@p_division_code	nvarchar(20)	= ''
	,@p_division_name	nvarchar(20)	= ''
	,@p_department_code	nvarchar(20)	= ''
	,@p_department_name	nvarchar(20)	= ''
	,@p_description		nvarchar(4000)	= ''
	,@p_remark			nvarchar(4000)	= ''
	,@p_pic_code		nvarchar(50)	= ''
	,@p_pic_name		nvarchar(250)
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
	declare @msg							nvarchar(max)
			,@year							nvarchar(4) 
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@code_detail					nvarchar(50)
			,@depre_category_comm_code		nvarchar(50)
			,@depre_category_fiscal_code	nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@location_code					nvarchar(250)
			,@condition						nvarchar(50)
			,@stock							int = 0
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid						int 
			,@max_day						int

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	---- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
	--set @is_valid = dbo.xfn_date_validation(@p_opname_date)
	--select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

	--if @is_valid = 0
	--begin
	--	set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
	--	raiserror(@msg ,16,-1);	    
	--end
		
	---- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
	--if datediff(month,@p_opname_date,dbo.xfn_get_system_date()) > 0
	--begin
	--	set @msg = 'Back date transactions are not allowed for this transaction';
	--	raiserror(@msg ,16,-1);	 
	--end
	-- End of additional control ===================================================

	if dbo.xfn_get_system_date() < @p_opname_date
	begin
		set @msg = 'Opname Date must be less or equal than System Date.';
		raiserror(@msg, 16, -1) ;
	end   
		
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'SO'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'OPNAME'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;

	
		insert into opname
		(
			code
			,company_code
			,opname_date
			,branch_code
			,branch_name
			,location_code
			,location_name
			,division_code	
			,division_name	
			,department_code	
			,department_name	
			,status
			,description
			,remark
			,pic_code
			,pic_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_company_code
			,@p_opname_date
			,@p_branch_code
			,@p_branch_name
			,@p_location_code
			,@p_location_name
			,@p_division_code	
			,@p_division_name	
			,@p_department_code	
			,@p_department_name	
			,@p_status
			,@p_description
			,@p_remark
			,@p_pic_code
			,@p_pic_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;

		
		--declare curr_opname_detail_insert cursor fast_forward read_only for
		--select	code
		--		,depre_category_comm_code
		--		,depre_category_fiscal_code
		--		,branch_code
		--		,branch_name
		--		,condition 
		--from	dbo.asset
		--where	branch_code		= @p_branch_code
		--and		@p_location_code = @p_location_code
		--and		company_code	= @p_company_code
		--and		division_code	= case @p_division_code	
		--							when '' then division_code
		--							else @p_division_code
		--						  end
		--and		department_code	= case @p_department_code	
		--							when '' then department_code
		--							else @p_department_code
		--						  end
		--and status = 'STOCK'
		
		--open curr_opname_detail_insert
		
		--fetch next from curr_opname_detail_insert 
		--into @code_detail
		--	,@depre_category_comm_code
		--	,@depre_category_fiscal_code
		--	,@branch_code
		--	,@branch_name
		--	,@condition
		
		--while @@fetch_status = 0
		--begin
		--	declare @p_id bigint ;
			
		--	exec dbo.xsp_opname_detail_insert @p_id							= 0
		--									  ,@p_opname_code				= @p_code
		--									  ,@p_asset_code				= @code_detail
		--									  ,@p_branch_code				= @branch_code
		--									  ,@p_branch_name				= @branch_name
		--									  ,@p_location_code				= ''
		--									  ,@p_condition_code			= @condition
		--									  ,@p_location_in				= ''
		--									  ,@p_file						= ''
		--									  ,@p_path						= ''
		--									  ,@p_cre_date					= @p_cre_date
		--									  ,@p_cre_by					= @p_cre_by
		--									  ,@p_cre_ip_address			= @p_cre_ip_address
		--									  ,@p_mod_date					= @p_mod_date
		--									  ,@p_mod_by					= @p_mod_by
		--									  ,@p_mod_ip_address			= @p_mod_ip_address
			
		--	--exec dbo.xsp_opname_detail_insert @p_id						 = 0
		--	--								  ,@p_opname_code			 = @p_code
		--	--								  ,@p_asset_code			 = @code_detail
		--	--								  ,@p_stock					 = @stock
		--	--								  ,@p_quantity				 = 0
		--	--								  ,@p_depre_comercial		 = @depre_category_comm_code
		--	--								  ,@p_depre_fiscal			 = @depre_category_fiscal_code
		--	--								  ,@p_branch_code			 = @branch_code
		--	--								  ,@p_branch_name			 = @branch_name
		--	--								  ,@p_location_code			 = @location_code
		--	--								  ,@p_condition_code		 = ''
		--	--								  ,@p_location_in			 = ''
		--	--								  ,@p_file					 = ''
		--	--								  ,@p_path					 = ''
		--	--								  ,@p_cre_date				 = @p_cre_date
		--	--								  ,@p_cre_by				 = @p_cre_by
		--	--								  ,@p_cre_ip_address		 = @p_cre_ip_address
		--	--								  ,@p_mod_date				 = @p_mod_date
		--	--								  ,@p_mod_by				 = @p_mod_by
		--	--								  ,@p_mod_ip_address		 = @p_mod_ip_address
		
		--    fetch next from curr_opname_detail_insert 
		--	into @code_detail
		--		,@depre_category_comm_code
		--		,@depre_category_fiscal_code
		--		,@branch_code
		--		,@branch_name
		--		,@condition
		--end
		
		--close curr_opname_detail_insert
		--deallocate curr_opname_detail_insert

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
