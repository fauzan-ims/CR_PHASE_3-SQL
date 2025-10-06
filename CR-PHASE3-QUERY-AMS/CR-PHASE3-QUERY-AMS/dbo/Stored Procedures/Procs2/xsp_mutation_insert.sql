CREATE PROCEDURE dbo.xsp_mutation_insert
(
	@p_code						 nvarchar(50)	output
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
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@year		nvarchar(4)
			,@month		nvarchar(2)
			,@code		nvarchar(50)
			-- Arga 12-Oct-2022 ket : for WOM (+)
			,@is_valid	int 
			,@max_day	int

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	-- Arga 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
	set @is_valid = dbo.xfn_date_validation(@p_mutation_date)
	select @max_day = cast(value as int) from sys_global_param where code = 'MDT'

	if @is_valid = 0
	begin
		set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
		raiserror(@msg ,16,-1);	    
	end

	else if (@p_mutation_date > dbo.xfn_get_system_date() )
	begin
		set @msg = 'Mutation Date must be less than System Date';
		raiserror(@msg ,16,-1);	    
	end
		
	-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
	if datediff(month,@p_mutation_date,dbo.xfn_get_system_date()) > 1
	begin
		set @msg = 'Back date transactions are not allowed for this transaction';
		raiserror(@msg ,16,-1);	 
	end
	-- End of additional control ===================================================

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_from_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'AMSMT'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'MUTATION'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;
	 
	
		insert into mutation
		(
			code
			,company_code
			,mutation_date
			,requestor_code
			,requestor_name
			,branch_request_code
			,branch_request_name
			,from_branch_code
			,from_branch_name
			,from_division_code
			,from_division_name
			,from_department_code
			,from_department_name
			,from_pic_code
			,to_branch_code
			,to_branch_name
			,to_division_code
			,to_division_name
			,to_department_code
			,to_department_name
			,to_pic_code
			,status
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
		(	@code
			,@p_company_code
			,@p_mutation_date
			,@p_requestor_code
			,@p_requestor_name
			,@p_branch_request_code
			,@p_branch_request_name
			,@p_from_branch_code
			,@p_from_branch_name
			,@p_from_division_code
			,@p_from_division_name
			,@p_from_department_code
			,@p_from_department_name
			,@p_from_pic_code
			,@p_to_branch_code
			,@p_to_branch_name
			,@p_to_division_code
			,@p_to_division_name
			,@p_to_department_code
			,@p_to_department_name
			,@p_to_pic_code
			,@p_status
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
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
	end catch ;	
end ;
