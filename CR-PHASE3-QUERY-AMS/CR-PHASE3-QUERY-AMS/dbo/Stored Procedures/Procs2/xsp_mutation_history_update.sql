CREATE PROCEDURE dbo.xsp_mutation_history_update
(
	@p_code							nvarchar(50)
	,@p_company_code				nvarchar(50)
	,@p_mutation_date				datetime
	,@p_requestor_code				nvarchar(50)
	,@p_requestor_name				nvarchar(250)
	,@p_branch_request_code			nvarchar(50)
	,@p_branch_request_name			nvarchar(250)
	,@p_from_branch_code			nvarchar(50)
	,@p_from_branch_name			nvarchar(250)
	,@p_from_division_code			nvarchar(50)
	,@p_from_division_name			nvarchar(250)
	,@p_from_department_code		nvarchar(50)
	,@p_from_department_name		nvarchar(250)
	,@p_from_sub_department_code	nvarchar(50)
	,@p_from_sub_department_name	nvarchar(250)
	,@p_from_units_code				nvarchar(50)
	,@p_from_units_name				nvarchar(250)
	,@p_from_location_code			nvarchar(50)
	,@p_from_pic_code				nvarchar(50)
	,@p_to_branch_code				nvarchar(50)
	,@p_to_branch_name				nvarchar(250)
	,@p_to_division_code			nvarchar(50)
	,@p_to_division_name			nvarchar(250)
	,@p_to_department_code			nvarchar(50)
	,@p_to_department_name			nvarchar(250)
	,@p_to_sub_department_code		nvarchar(50)
	,@p_to_sub_department_name		nvarchar(250)
	,@p_to_units_code				nvarchar(50)
	,@p_to_units_name				nvarchar(250)
	,@p_to_location_code			nvarchar(50)
	,@p_to_pic_code					nvarchar(50)
	,@p_status						nvarchar(20)
	,@p_remark						nvarchar(4000)
		--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	mutation_history
		set		company_code				= @p_company_code
				,mutation_date				= @p_mutation_date
				,requestor_code				= @p_requestor_code
				,requestor_name				= @p_requestor_name
				,branch_request_code		= @p_branch_request_code
				,branch_request_name		= @p_branch_request_name
				,from_branch_code			= @p_from_branch_code
				,from_branch_name			= @p_from_branch_name
				,from_division_code			= @p_from_division_code
				,from_division_name			= @p_from_division_name
				,from_department_code		= @p_from_department_code
				,from_department_name		= @p_from_department_name
				,from_sub_department_code	= @p_from_sub_department_code
				,from_sub_department_name	= @p_from_sub_department_name
				,from_units_code			= @p_from_units_code
				,from_units_name			= @p_from_units_name
				,from_location_code			= @p_from_location_code
				,from_pic_code				= @p_from_pic_code
				,to_branch_code				= @p_to_branch_code
				,to_branch_name				= @p_to_branch_name
				,to_division_code			= @p_to_division_code
				,to_division_name			= @p_to_division_name
				,to_department_code			= @p_to_department_code
				,to_department_name			= @p_to_department_name
				,to_sub_department_code		= @p_to_sub_department_code
				,to_sub_department_name		= @p_to_sub_department_name
				,to_units_code				= @p_to_units_code
				,to_units_name				= @p_to_units_name
				,to_location_code			= @p_to_location_code
				,to_pic_code				= @p_to_pic_code
				,status						= @p_status
				,remark						= @p_remark
					--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
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
