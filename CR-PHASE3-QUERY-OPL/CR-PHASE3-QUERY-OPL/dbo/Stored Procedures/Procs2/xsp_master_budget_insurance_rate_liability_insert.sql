--Created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_liability_insert
(
	@p_code						nvarchar(50) output
	,@p_type					nvarchar(50)
	,@p_coverage_code			nvarchar(50)
	,@p_coverage_description	nvarchar(250)
	,@p_coverage_amount			decimal(18, 2)
	,@p_rate_of_limit			decimal(9, 6)
	,@p_is_active				nvarchar(1)
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
	declare @code				nvarchar(50)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@msg				nvarchar(max) 
			,@exp_date			datetime 
			,@value_exp_date	nvarchar(50);
	begin try

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= ''
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= N'BIRL'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= N'MASTER_BUDGET_INSURANCE_RATE_LIABILITY'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		if exists 
		(
			select	1
			from	master_budget_insurance_rate_liability
			where	type			  = @p_type
					and coverage_code = @p_coverage_code
					and coverage_amount = @p_coverage_amount

		)
		begin
			set	@msg = 'Combination Already Exists.'
			raiserror (@msg, 16, -1)
		end

		if @p_is_active = 'T'
			set	@p_is_active = '1'
		else
			set	@p_is_active = '0'

		insert into dbo.master_budget_insurance_rate_liability
		(
			code
			,type
			,coverage_code
			,coverage_description
			,coverage_amount
			,rate_of_limit
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
			,@p_type				
			,@p_coverage_code		
			,@p_coverage_description
			,@p_coverage_amount		
			,@p_rate_of_limit		
			,@p_is_active	
			--		
			,@p_cre_date			
			,@p_cre_by				
			,@p_cre_ip_address		
			,@p_mod_date			
			,@p_mod_by				
			,@p_mod_ip_address		
		) 

		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		set	@exp_date = dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())

		update	master_budget_insurance_rate_liability
		set		exp_date		= @exp_date
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @code

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
end
