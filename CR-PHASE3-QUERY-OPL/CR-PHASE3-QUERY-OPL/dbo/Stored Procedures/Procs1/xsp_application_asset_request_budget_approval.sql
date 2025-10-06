CREATE PROCEDURE dbo.xsp_application_asset_request_budget_approval
(
	@p_asset_no				nvarchar(50)
	,@p_cost_code			nvarchar(50)
    ,@p_cost_amount_yearly  decimal(18,2)
    ,@p_cost_amount_monthly decimal(18,2) 
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg				   nvarchar(max)
			,@budget_approval_code nvarchar(50)
			,@request_date		   datetime = dbo.xfn_get_system_date() ;

	begin try
		if not exists
		(
			select	1
			from	dbo.budget_approval ba
					inner join budget_approval_detail bad on (bad.budget_approval_code = ba.code)
			where	asset_no		  = @p_asset_no
					and bad.cost_code = @p_cost_code
					and status not in
					(
						'POST', 'CANCEL'
					)
		)
		begin 
			exec dbo.xsp_budget_approval_insert @p_code				= @budget_approval_code output 
												,@p_asset_no		= @p_asset_no
												,@p_status			= N'HOLD'
												,@p_date			= @request_date
												,@p_cre_date		= @p_mod_date	  
												,@p_cre_by			= @p_mod_by		  
												,@p_cre_ip_address	= @p_mod_ip_address
												,@p_mod_date		= @p_mod_date	  
												,@p_mod_by			= @p_mod_by		  
												,@p_mod_ip_address	= @p_mod_ip_address

			insert into dbo.budget_approval_detail
			(
				budget_approval_code
				,cost_code
				,cost_type
				,cost_amount_monthly
				,cost_amount_yearly
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@budget_approval_code
					,@p_cost_code
					,cost_type
					,@p_cost_amount_monthly
					,@p_cost_amount_yearly
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.master_budget_cost
			where	code		  = @p_cost_code
					and is_active = '1' ;

			update	dbo.application_asset
			set		budget_approval_code	= @budget_approval_code
					,is_calculate_amortize	= '0'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	asset_no				= @p_asset_no ;

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
