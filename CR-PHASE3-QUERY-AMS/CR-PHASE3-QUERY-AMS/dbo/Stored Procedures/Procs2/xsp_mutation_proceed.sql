CREATE PROCEDURE dbo.xsp_mutation_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@status					nvarchar(20)
			,@asset_code				nvarchar(50)
			,@to_loct					nvarchar(50)
			,@to_branch_code			nvarchar(50)
			,@to_branch_name			nvarchar(250)
			,@to_location_code			nvarchar(50)
			,@to_division_code			nvarchar(50)
			,@to_division_name			nvarchar(250)
			,@to_departement_code		nvarchar(50)
			,@to_departement_name		nvarchar(250)
			,@to_sub_departement_code	nvarchar(50)
			,@to_sub_departement_name	nvarchar(250)
			,@to_unit_code				nvarchar(50)
			,@to_unit_name				nvarchar(250)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid					int 
			,@max_day					int
			,@mutation_date				datetime
			,@company_code				nvarchar(50)

	begin try --

		select	@status						= dor.status
				,@asset_code				= md.asset_code
				,@to_branch_code			= dor.to_branch_code
				,@to_branch_name			= dor.to_branch_name
				--,@to_location_code			= dor.to_location_code
				,@to_division_code			= dor.to_division_code
				,@to_division_name			= dor.to_division_name
				,@to_departement_code		= dor.to_department_code
				,@to_departement_name		= dor.to_department_name
				--,@to_sub_departement_code	= dor.to_sub_department_code
				--,@to_sub_departement_name	= dor.to_sub_department_name
				--,@to_unit_code				= dor.to_units_code
				--,@to_unit_name				= dor.to_units_name
				,@mutation_date				= dor.mutation_date
				,@company_code				= dor.company_code
		from	dbo.mutation dor
				left  join dbo.mutation_detail md on (md.mutation_code = dor.code)
				left  join	dbo.asset ass on (md.asset_code = ass.code) and (ass.company_code = dor.company_code)
		where	dor.code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@mutation_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0
		begin
			set @msg = 'The maximum back date input transaction is ' + cast(@max_day as char(2)) + ' in each month';
			raiserror(@msg ,16,-1);	    
		end
		
		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@mutation_date,dbo.xfn_get_system_date()) > 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end
		-- End of additional control =================================================== 

		-- Arga 19-Oct-2022 ket : additional request for WOM (+) ==
		if exists (select * from dbo.mutation_detail where mutation_code = @p_code and isnull(cost_center_code,'') = '')
		begin
			set @msg = 'Please fill in the Cost Center'
			raiserror(@msg ,16,-1);	    
		end
		-- ========================================================

		if (@status = 'NEW' and @asset_code is not null and @to_branch_code = '' and @to_branch_name = '')
		begin
			set @msg = 'Please Fill To Branch';
			raiserror(@msg ,16,-1);
		end
		else if (@status = 'NEW' and @asset_code is not null and @to_division_code = '' and @to_division_name = '')
		begin
			set @msg = 'Please Fill To Divison';
			raiserror(@msg ,16,-1);
		end
		else if (@status = 'NEW' and @asset_code is not null and @to_departement_code = '' and @to_departement_name = '')
		begin
			set @msg = 'Please Fill To Department';
			raiserror(@msg ,16,-1);
		end
		-- Trisna 12-Oct-2022 ket : for WOM  (+) ====
		--else if (@status = 'NEW' and @asset_code is not null and @to_sub_departement_code = '' and @to_sub_departement_name = '')
		--begin
		--	set @msg = 'Please Input To Sub Department';
		--	raiserror(@msg ,16,-1);
		--end
		--else if (@status = 'NEW' and @asset_code is not null and @to_unit_code = '' and @to_unit_name = '')
		--begin
		--	set @msg = 'Please Input To Unit';
		--	raiserror(@msg ,16,-1);
		--end
		--===========================================
		else if (@status = 'NEW' or @status = 'RETURNED' and @asset_code is not null)
		begin
			    update	dbo.mutation
				set		status			= 'ON PROGRESS'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
				
				-- Arga 14-Oct-2022 ket : move to receive (-)
				--update	dbo.asset
				--set		last_location_name	= @to_loct
				--where	code				= @asset_code
				
				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
				--												,@p_doc_code		= @p_code
				--												,@p_attachment_flag = 0
				--												,@p_attachment_file = ''
				--												,@p_attachment_path = ''
				--												,@p_company_code	= @company_code
				--												,@p_trx_no			= @p_code
				--												,@p_trx_type		= 'MUTATION'
				-- End of send mail attachment based on setting ================================================

		end
		else if (@status = 'NEW' and @asset_code is null)
		begin
			set @msg = 'Please fill in Mutation Asset';
			raiserror(@msg ,16,-1);
		end
		else if (@status <> 'NEW' or @status <> 'RETURNED')
		begin
			set @msg = 'Data sudah di proses.';
			raiserror(@msg ,16,-1);
		end		
		

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
