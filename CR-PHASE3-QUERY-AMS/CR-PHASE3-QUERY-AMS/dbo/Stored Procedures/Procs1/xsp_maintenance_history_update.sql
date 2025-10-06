CREATE PROCEDURE dbo.xsp_maintenance_history_update
(
	@p_code						nvarchar(50)
	,@p_company_code			nvarchar(50)
	,@p_asset_code				nvarchar(50)
	,@p_transaction_date		datetime
	,@p_transaction_amount		decimal(18, 2)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_location_code			nvarchar(50)
	,@p_requestor_code			nvarchar(50)
	,@p_division_code			nvarchar(50)
	,@p_division_name			nvarchar(250)
	,@p_department_code			nvarchar(50)
	,@p_department_name			nvarchar(250)
	,@p_sub_department_code		nvarchar(50)
	,@p_sub_department_name		nvarchar(250)
	,@p_unit_code				nvarchar(50)
	,@p_unit_name				nvarchar(250)
	,@p_maintenance_by			nvarchar(50)
	,@p_status					nvarchar(20)
	,@p_remark					nvarchar(4000)
	,@p_category_code			nvarchar(50)
	,@p_category_name			nvarchar(50)
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	maintenance_history
		set		company_code			= @p_company_code
				,asset_code				= @p_asset_code
				,transaction_date		= @p_transaction_date
				,transaction_amount		= @p_transaction_amount
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,location_code			= @p_location_code
				,requestor_code			= @p_requestor_code
				,division_code			= @p_division_code
				,division_name			= @p_division_name
				,department_code		= @p_department_code
				,department_name		= @p_department_name
				,sub_department_code	= @p_sub_department_code
				,sub_department_name	= @p_sub_department_name
				,unit_code				= @p_unit_code
				,unit_name				= @p_unit_name
				,maintenance_by			= @p_maintenance_by
				,status					= @p_status
				,remark					= @p_remark
				,category_code			= @p_category_code
				,category_name			= @p_category_name
					--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code	= @p_code

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
