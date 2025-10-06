CREATE PROCEDURE dbo.xsp_master_insurance_rate_non_life_insert
(
	@p_code						 nvarchar(50) output
	,@p_insurance_code			 nvarchar(50)
	,@p_collateral_type_code	 nvarchar(50)
	,@p_collateral_category_code nvarchar(50)
	,@p_coverage_code			 nvarchar(50)
	,@p_day_in_year				 nvarchar(10)
	,@p_region_code				 nvarchar(50) = null
	,@p_occupation_code			 nvarchar(50) = null
	,@p_is_active				 nvarchar(1)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AMSRNL'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_INSURANCE_RATE_NON_LIFE'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
    
		if exists (select 1 from master_insurance_rate_non_life 
					where	insurance_code				= @p_insurance_code
					and		collateral_type_code		= @p_collateral_type_code
					and		coverage_code				= @p_coverage_code
					and		isnull(occupation_code,'')	= isnull(@p_occupation_code,'')
					and		isnull(region_code,'')		= isnull(@p_region_code  ,'')
					and		collateral_category_code	= @p_collateral_category_code)
		begin
			set @msg = 'Combination already exist';
			raiserror(@msg, 16, -1) ;
		end
		insert into master_insurance_rate_non_life
		(
			code
			,insurance_code
			,collateral_type_code
			,collateral_category_code
			,coverage_code
			,day_in_year
			,region_code
			,occupation_code
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
			,@p_insurance_code
			,@p_collateral_type_code
			,@p_collateral_category_code
			,@p_coverage_code
			,@p_day_in_year
			,@p_region_code
			,@p_occupation_code
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
	end catch ;	;
end ;




