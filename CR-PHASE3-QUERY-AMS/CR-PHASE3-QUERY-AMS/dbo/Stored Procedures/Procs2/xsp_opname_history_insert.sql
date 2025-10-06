CREATE PROCEDURE dbo.xsp_opname_history_insert
(
	@p_code					nvarchar(50)
	,@p_company_code		nvarchar(50)
	,@p_opname_date			datetime
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_location_code		nvarchar(50)
	,@p_division_code		nvarchar(50)
	,@p_division_name		nvarchar(100)
	,@p_department_code		nvarchar(50)
	,@p_department_name		nvarchar(100)
	,@p_status				nvarchar(20)
	,@p_description			nvarchar(4000)
	,@p_remark				nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into opname_history
		(
			code
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
			@p_code
			,@p_company_code
			,@p_opname_date
			,@p_branch_code
			,@p_branch_name
			,@p_location_code
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_status
			,@p_description
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)

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
