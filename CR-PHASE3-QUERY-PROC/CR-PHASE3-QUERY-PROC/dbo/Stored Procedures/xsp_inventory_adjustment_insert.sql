CREATE PROCEDURE dbo.xsp_inventory_adjustment_insert
(
	 @p_code					nvarchar(50) output
	,@p_company_code			nvarchar(50)
	,@p_adjustment_date			datetime
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_division_code			nvarchar(50)
	,@p_division_name			nvarchar(25)
	,@p_department_code			nvarchar(50)
	,@p_department_name			nvarchar(250)
	,@p_sub_department_code		nvarchar(50)	= ''
	,@p_sub_department_name		nvarchar(250)	= ''
	,@p_units_code				nvarchar(50)	= ''
	,@p_units_name				nvarchar(250)	= ''
	,@p_reason					nvarchar(100)
	,@p_remark					nvarchar(4000)
	,@p_status					nvarchar(25)
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
	declare @msg nvarchar(max) 
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code  nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_company_code
													,@p_sys_document_code	= ''
													,@p_custom_prefix		= 'IAD'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'INVENTORY_ADJUSTMENT'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= '0' ;


	insert into inventory_adjustment
	(
		 code
		,company_code
		,adjustment_date
		,branch_code
		,branch_name
		,division_code
		,division_name
		,department_code
		,department_name
		,sub_department_code
		,sub_department_name
		,units_code
		,units_name
		,reason
		,remark
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
		,@p_company_code
		,@p_adjustment_date
		,@p_branch_code
		,@p_branch_name
		,@p_division_code
		,@p_division_name
		,@p_department_code
		,@p_department_name
		,@p_sub_department_code
		,@p_sub_department_name
		,@p_units_code
		,@p_units_name
		,@p_reason
		,@p_remark
		,@p_status
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	)
	set @p_code = @code

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
end
