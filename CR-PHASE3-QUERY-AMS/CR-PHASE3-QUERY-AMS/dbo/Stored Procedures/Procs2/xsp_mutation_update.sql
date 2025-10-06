CREATE PROCEDURE dbo.xsp_mutation_update
(
	@p_code						 nvarchar(50)
	,@p_company_code			 nvarchar(50)
	,@p_mutation_date			 datetime
	,@p_requestor_code			 nvarchar(50)
	,@p_requestor_name			 nvarchar(250)
	,@p_branch_request_code		 nvarchar(50)
	,@p_branch_request_name		 nvarchar(250)
	,@p_from_branch_code		 nvarchar(50)
	,@p_from_branch_name		 nvarchar(250)
	,@p_from_division_code		 nvarchar(50)	= ''
	,@p_from_division_name		 nvarchar(250)	= ''
	,@p_from_department_code	 nvarchar(50)	= ''
	,@p_from_department_name	 nvarchar(250)	= ''
	,@p_from_pic_code			 nvarchar(50)	= null
	,@p_to_branch_code			 nvarchar(50)
	,@p_to_branch_name			 nvarchar(250)
	,@p_to_division_code		 nvarchar(50)
	,@p_to_division_name		 nvarchar(250)
	,@p_to_department_code		 nvarchar(50)
	,@p_to_department_name		 nvarchar(250)
	,@p_to_pic_code				 nvarchar(50)	= ''
	,@p_status					 nvarchar(20)
	,@p_remark					 nvarchar(4000)	= null
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max) 
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid	int 
			,@max_day	int

	begin try
		
		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@p_mutation_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0
		begin
			set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
			raiserror(@msg ,16,-1);	    
		end

		if (@p_mutation_date > dbo.xfn_get_system_date() )
		begin
			set @msg = 'Mutation Date must be less than System Date';
			raiserror(@msg ,16,-1);	    
		end
		
		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@p_mutation_date,dbo.xfn_get_system_date()) > 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end
		-- End of additional control ===================================================

		update	mutation
		set		company_code				 = @p_company_code
				,mutation_date				 = @p_mutation_date
				,requestor_code				 = @p_requestor_code
				,requestor_name				 = @p_requestor_name
				,branch_request_code		 = @p_branch_request_code
				,branch_request_name		 = @p_branch_request_name
				,from_branch_code			 = @p_from_branch_code
				,from_branch_name			 = @p_from_branch_name
				,from_division_code			 = @p_from_division_code
				,from_division_name			 = @p_from_division_name
				,from_department_code		 = @p_from_department_code
				,from_department_name		 = @p_from_department_name
				,from_pic_code				 = @p_from_pic_code
				,to_branch_code				 = @p_to_branch_code
				,to_branch_name				 = @p_to_branch_name
				,to_division_code			 = @p_to_division_code
				,to_division_name			 = @p_to_division_name
				,to_department_code			 = @p_to_department_code
				,to_department_name			 = @p_to_department_name
				,to_pic_code				 = @p_to_pic_code
				,status						 = @p_status
				,remark						 = @p_remark
				--
				,mod_date					 = @p_mod_date
				,mod_by						 = @p_mod_by
				,mod_ip_address				 = @p_mod_ip_address
		where	code						 = @p_code ;
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
