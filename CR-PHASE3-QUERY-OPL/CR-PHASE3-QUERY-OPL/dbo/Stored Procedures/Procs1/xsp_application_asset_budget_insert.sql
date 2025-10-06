CREATE PROCEDURE [dbo].[xsp_application_asset_budget_insert]
(
	@p_id						 bigint			= 0 output
	,@p_asset_no				 nvarchar(50)
	,@p_cost_code				 nvarchar(50)
	,@p_cost_type				 nvarchar(10)	= 'FIXED'
	,@p_cost_amount_monthly		 decimal(18, 2) = 0
	,@p_cost_amount_yearly		 decimal(18, 2) = 0 
	,@p_cost_budget_amount		 decimal(18, 2) = 0 
	,@p_is_subject_to_purchase	 nvarchar(1)	= '0'
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
	declare @msg nvarchar(max) ;

	begin try

		if @p_is_subject_to_purchase = 'Y'
			set @p_is_subject_to_purchase = '1' ;
		else
			set @p_is_subject_to_purchase = '0' ;
			
		insert into dbo.application_asset_budget
		(
			asset_no
			,cost_code
			,cost_type
			,cost_amount_monthly
			,cost_amount_yearly
			,budget_adjustment_amount
			,budget_amount
			,is_subject_to_purchase
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_no
			,@p_cost_code
			,@p_cost_type
			,@p_cost_amount_monthly
			,@p_cost_amount_yearly
			,0
			,@p_cost_amount_yearly
			,@p_is_subject_to_purchase
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update	dbo.application_asset
		set		is_calculate_amortize	= '0'
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	asset_no				= @p_asset_no ;

		set @p_id = @@identity ;
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

