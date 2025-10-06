--created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_liability_update
(
	@p_code						nvarchar(50) 
	,@p_type					nvarchar(50)
	,@p_coverage_code			nvarchar(50)
	,@p_coverage_description	nvarchar(250)
	,@p_coverage_amount			decimal(18, 2)
	,@p_rate_of_limit			decimal(9, 6)
	,@p_is_active				nvarchar(1)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)
			,@value_exp_date nvarchar(50)
	begin try

		if exists 
		(
			select	1
			from	master_budget_insurance_rate_liability
			where	type				= @p_type
					and coverage_code	= @p_coverage_code
					and coverage_amount = @p_coverage_amount
					and	code			<> @p_code
		)
		begin
			set	@msg = 'Data Already Exists.'
			raiserror (@msg, 16, -1)
		end

		if @p_is_active = 'T'
			set	@p_is_active = '1'
		else
			set	@p_is_active = '0'
		
		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		update	dbo.master_budget_insurance_rate_liability
		set		type						= @p_type		
				,coverage_code				= @p_coverage_code
				,coverage_description		= @p_coverage_description
				,coverage_amount			= @p_coverage_amount	
				,rate_of_limit				= @p_rate_of_limit	
				,is_active					= @p_is_active	
				,exp_date					= dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())
				--	
				,mod_date					= @p_mod_date		
				,mod_by						= @p_mod_by			
				,mod_ip_address				= @p_mod_ip_address	
		where	code						= @p_code
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
