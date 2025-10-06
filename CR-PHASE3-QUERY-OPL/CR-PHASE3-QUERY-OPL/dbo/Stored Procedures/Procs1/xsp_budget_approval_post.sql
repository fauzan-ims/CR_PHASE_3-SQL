CREATE procedure dbo.xsp_budget_approval_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				  nvarchar(max)
			,@asset_no			  nvarchar(50)
			,@cost_code			  nvarchar(50)
			,@cost_amount_monthly decimal(18, 2)
			,@cost_amount_yearly  decimal(18, 2) ;

	begin try
		if exists
		(
			select	1
			from	dbo.budget_approval
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			if ((
					select	isnull(sum(cost_amount_monthly), 0)
					from	dbo.budget_approval_detail
					where	budget_approval_code = @p_code
				) = 0
			   )
			begin
				set @msg = 'Please input Budget Amount' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else
			begin
				select	@asset_no			  = asset_no
						,@cost_code			  = bad.cost_code
						,@cost_amount_monthly = cost_amount_monthly
						,@cost_amount_yearly  = cost_amount_yearly 
				from	budget_approval ba
						inner join dbo.budget_approval_detail bad on (bad.budget_approval_code = ba.code)
				where	code				  = @p_code ;

				update	dbo.application_asset_budget
				set		cost_amount_monthly = @cost_amount_monthly
						,cost_amount_yearly = @cost_amount_yearly
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	asset_no			= @asset_no
						and cost_code		= @cost_code ;

				update	dbo.budget_approval
				set		status			= 'POST'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
			end ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
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
