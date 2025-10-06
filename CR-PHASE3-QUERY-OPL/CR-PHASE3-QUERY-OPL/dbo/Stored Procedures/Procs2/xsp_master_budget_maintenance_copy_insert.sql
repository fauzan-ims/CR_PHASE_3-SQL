CREATE PROCEDURE dbo.xsp_master_budget_maintenance_copy_insert
(
	@p_code						nvarchar(50)	= '' output
	,@p_code_copy				nvarchar(50)
	,@p_unit_code_copy			nvarchar(50)
	,@p_unit_description_copy	nvarchar(250)
	,@p_year_copy				int
	,@p_inflation				decimal(9, 6)
	,@p_location				nvarchar(10)
	,@p_eff_date				datetime
	,@p_exp_date				datetime		= null
	,@p_is_active				nvarchar(1)		= '0'
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@year							nvarchar(2)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@value_exp_date				nvarchar(50) 
			,@group_code					nvarchar(50)
			,@service_code					nvarchar(50)
			,@service_description			nvarchar(250)
			,@unit_qty						int
			,@unit_cost						decimal(18,2)
			,@labor_cost					decimal(18,2)
			,@replacement_cycle				decimal(18,2)
			,@replacement_type				nvarchar(250)
			,@total_cost					decimal(18,2)
			,@group_code_service			nvarchar(50)	
			,@group_description				nvarchar(250)
			,@probability_pct				decimal(18,2)


	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = ''
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'OPLMBM'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'MASTER_BUDGET_MAINTENANCE'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		--set @p_exp_date = dateadd(month, convert(int, @value_exp_date), @p_eff_date) ;


		if exists(select 1 from dbo.master_budget_maintenance where unit_code = @p_unit_code_copy and year = @p_year_copy)
		begin
			set @msg = 'Unit with same year already exists'
			raiserror(@msg, 16, -1)
		end

		if @p_is_active = 'T'
			set @p_is_active = '1' ;
		else
			set @p_is_active = '0' ;

		insert into dbo.master_budget_maintenance
		(
			code
			,unit_code
			,unit_description
			,year
			,inflation
			,location
			,eff_date
			,exp_date
			,is_active
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
			,@p_unit_code_copy
			,@p_unit_description_copy
			,@p_year_copy
			,@p_inflation
			,@p_location
			,@p_eff_date
			,@p_exp_date
			,@p_is_active
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

		
		declare curr_group cursor fast_forward read_only for 
		select	group_code
				,group_description
				,probability_pct
		from	dbo.master_budget_maintenance_group
		where	budget_maintenance_code = @p_code_copy
		open curr_group
		
		fetch next from curr_group
		into	@group_code
				,@group_description
				,@probability_pct
		
		while @@fetch_status = 0
		begin
		    	declare @p_code2 nvarchar(50) ;
		
				exec dbo.xsp_master_budget_maintenance_group_insert @p_code							= @p_code2 output -- nvarchar(50)
																	,@p_budget_maintenance_code		= @p_code
																	,@p_group_code					= @group_code
																	,@p_group_description			= @group_description
																	,@p_probability_pct				= @probability_pct
																	,@p_cre_date					= @p_cre_date
																	,@p_cre_by						= @p_cre_by
																	,@p_cre_ip_address				= @p_cre_ip_address
																	,@p_mod_date					= @p_mod_date
																	,@p_mod_by						= @p_mod_by
																	,@p_mod_ip_address				= @p_mod_ip_address
		
		    fetch next from curr_group 
			into	@group_code
					,@group_description
					,@probability_pct
		end
		
		close curr_group
		deallocate curr_group

		
		declare curr_group_service cursor fast_forward read_only for 
		select	group_code
				,service_code
				,service_description
				,unit_qty
				,unit_cost
				,labor_cost
				,replacement_cycle
				,replacement_type
				,total_cost
		from	dbo.master_budget_maintenance_group_service
		where	budget_maintenance_code = @p_code_copy
		open curr_group_service
		
		fetch next from curr_group_service 
		into	@group_code_service
				,@service_code
				,@service_description
				,@unit_qty
				,@unit_cost
				,@labor_cost
				,@replacement_cycle
				,@replacement_type
				,@total_cost
		
		while @@fetch_status = 0
		begin
		    declare @p_id bigint ;
		
			exec dbo.xsp_master_budget_maintenance_group_service_insert @p_id						= @p_id output -- bigint
																		,@p_budget_maintenance_code = @p_code
																		,@p_group_code				= @group_code_service
																		,@p_service_code			= @service_code	
																		,@p_service_description		= @service_description
																		,@p_unit_qty				= @unit_qty
																		,@p_unit_cost				= @unit_cost
																		,@p_labor_cost				= @labor_cost
																		,@p_replacement_cycle		= @replacement_cycle
																		,@p_replacement_type		= @replacement_type
																		,@p_total_cost				= @total_cost
																		,@p_cre_date				= @p_cre_date
																		,@p_cre_by					= @p_cre_by
																		,@p_cre_ip_address			= @p_cre_ip_address
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_ip_address			= @p_mod_ip_address
		
		    fetch next from curr_group_service 
			into	@group_code_service
					,@service_code
					,@service_description
					,@unit_qty
					,@unit_cost
					,@labor_cost
					,@replacement_cycle
					,@replacement_type
					,@total_cost
		end
		
		close curr_group_service
		deallocate curr_group_service


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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

