CREATE PROCEDURE dbo.xsp_application_asset_budget_update
(
	@p_asset_no					nvarchar(50)
	,@p_cost_code				nvarchar(50) 
	,@p_cost_amount_monthly		decimal(18, 2) = 0 
	,@p_cost_amount_yearly		decimal(18, 2) = 0 
	-- 
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max) ;

	begin try  

	if @p_cost_code = 'MBDC.2211.000003'
	begin
		if exists
		(
			select	1
			from	dbo.application_asset_budget
			where	asset_no			   = @p_asset_no
					and cost_code		   = @p_cost_code
					and cost_amount_yearly <> @p_cost_amount_yearly
		)
		begin
			update	application_asset_budget
			set		--cost_amount_monthly		   = @p_cost_amount_yearly
					--cost_amount_yearly		   = @p_cost_amount_yearly 
					budget_amount			   = @p_cost_amount_yearly
					--	
					,mod_date				   = @p_mod_date
					,mod_by					   = @p_mod_by
					,mod_ip_address			   = @p_mod_ip_address
			where	cost_code				   = @p_cost_code
					and asset_no			   = @p_asset_no ;
		end 
	end
	else
	begin
		if exists
		(
			select	1
			from	dbo.application_asset_budget
			where	asset_no			   = @p_asset_no
					and cost_code		   = @p_cost_code
					and cost_amount_yearly <> @p_cost_amount_yearly
		)
		begin
			update	application_asset_budget
			set		cost_amount_monthly		   = @p_cost_amount_yearly
					,cost_amount_yearly		   = @p_cost_amount_yearly 
					,budget_amount			   = @p_cost_amount_yearly
					--	
					,mod_date				   = @p_mod_date
					,mod_by					   = @p_mod_by
					,mod_ip_address			   = @p_mod_ip_address
			where	cost_code				   = @p_cost_code
					and asset_no			   = @p_asset_no ;
		end 
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



