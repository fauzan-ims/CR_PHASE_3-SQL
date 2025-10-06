CREATE PROCEDURE dbo.xsp_inventory_adjustment_update
(
	 @p_code					nvarchar(50)
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
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	 update inventory_adjustment
	set
		 company_code			= @p_company_code
		,adjustment_date		= @p_adjustment_date
		,branch_code			= @p_branch_code
		,branch_name			= @p_branch_name
		,division_code			= @p_division_code
		,division_name			= @p_division_name
		,department_code		= @p_department_code
		,department_name		= @p_department_name
		,sub_department_code	= @p_sub_department_code
		,sub_department_name	= @p_sub_department_name
		,units_code				= @p_units_code
		,units_name				= @p_units_name
		,reason					= @p_reason
		,remark					= @p_remark
		,status					= @p_status
			--
		,mod_date				= @p_mod_date
		,mod_by					= @p_mod_by
		,mod_ip_address			= @p_mod_ip_address
	where		code	= @p_code

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
