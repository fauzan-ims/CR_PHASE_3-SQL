CREATE PROCEDURE dbo.xsp_budget_approval_detail_update
(
	@p_budget_approval_code	nvarchar(50)
	,@p_cost_code			nvarchar(50) 
	,@p_cost_amount_monthly decimal(18, 2)
	,@p_cost_amount_yearly	decimal(18, 2)
	-- 
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ; 

	begin try

		if exists
		(
			select	1
			from	master_budget_cost
			where	code			 = @p_cost_code
					and bill_periode = 'MONTHLY'
		)
		begin
			update	budget_approval_detail
			set		cost_amount_monthly			= @p_cost_amount_monthly
					,cost_amount_yearly			= @p_cost_amount_monthly * 12
					--	
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	cost_code					= @p_cost_code
					and budget_approval_code	= @p_budget_approval_code ;
		end ;
		else
		begin
			update	budget_approval_detail
			set		cost_amount_monthly			= @p_cost_amount_yearly / 12
					,cost_amount_yearly			= @p_cost_amount_yearly
					--	
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	cost_code					= @p_cost_code
					and budget_approval_code	= @p_budget_approval_code ;
		end
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
