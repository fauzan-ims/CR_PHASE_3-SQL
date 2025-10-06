--created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_insert
(
	@p_code						 nvarchar(50) output
	,@p_vehicle_type_code		 nvarchar(50)
	,@p_vehicle_type_description nvarchar(50)
	,@p_coverage_code			 nvarchar(50)
	,@p_coverage_description	 nvarchar(250)
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
	declare @code				nvarchar(50)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@msg				nvarchar(max)   ;

	begin try

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= ''
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= N'MBI'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= N'MASTER_BUDGET_INSURANCE_RATE'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		if exists
		(
			select	1
			from	dbo.master_budget_insurance_rate
			where	vehicle_type_code = @p_vehicle_type_code
					and coverage_code = @p_coverage_code
		)
		begin
			set	@msg = 'Data Already Exists.'
			raiserror (@msg, 16, -1)
		end

		if @p_is_active = 'T'
			set	@p_is_active = '1'
		else
			set	@p_is_active = '0' 

		insert into dbo.master_budget_insurance_rate
		(
			code
			,vehicle_type_code
			,vehicle_type_description
			,coverage_code
			,coverage_description
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
		(	
			@code						
			,@p_vehicle_type_code		
			,@p_vehicle_type_description
			,@p_coverage_code			
			,@p_coverage_description	
			,null
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
