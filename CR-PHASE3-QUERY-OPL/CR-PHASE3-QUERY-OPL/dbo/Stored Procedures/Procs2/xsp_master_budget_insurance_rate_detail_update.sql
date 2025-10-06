--created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_detail_update
(
	@p_id						bigint
	,@p_budget_insurance_code	nvarchar(50)
	,@p_sum_insured_from		decimal(18, 2)
	,@p_sum_insured_to			decimal(18, 2)
	,@p_region_code				nvarchar(50)
	,@p_region_description		nvarchar(250)
	,@p_rate_1					decimal(9, 6)
	,@p_rate_2					decimal(9, 6)
	,@p_rate_3					decimal(9, 6)
	,@p_rate_4					decimal(9, 6)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@value_exp_date nvarchar(50)
			,@exp_date		 datetime ;

	begin try

		select	@value_exp_date = value
		from	dbo.sys_global_param
		where	code = 'EXPDATE' ;

		update	dbo.master_budget_insurance_rate_detail
		set		sum_insured_from		= @p_sum_insured_from		
				,sum_insured_to			= @p_sum_insured_to			
				,region_code			= @p_region_code				
				,region_description		= @p_region_description		
				,rate_1					= @p_rate_1					
				,rate_2					= @p_rate_2					
				,rate_3					= @p_rate_3					
				,rate_4					= @p_rate_4	
				--
				,mod_date				= @p_mod_date				
				,mod_by					= @p_mod_by					
				,mod_ip_address			= @p_mod_ip_address	
		where	budget_insurance_rate_code	= @p_budget_insurance_code
		and		id							= @p_id

		set	@exp_date = dateadd(month, convert (int, @value_exp_date), dbo.xfn_get_system_date())

		update	dbo.master_budget_insurance_rate
		set		exp_date		= @exp_date
				--			 	
				,mod_date		= @p_mod_date				 
				,mod_by			= @p_mod_by					 
				,mod_ip_address	= @p_mod_ip_address		
		where	code			= @p_budget_insurance_code	 

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
