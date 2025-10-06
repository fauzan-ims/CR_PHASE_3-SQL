CREATE PROCEDURE dbo.xsp_master_insurance_coverage_loading_update
(
	@p_id						bigint
	,@p_insurance_coverage_code nvarchar(50)
	,@p_loading_code			nvarchar(50)
	,@p_age_from				int            = NULL
	,@p_age_to					int			   = NULL
	,@p_rate_type				nvarchar(10)
	,@p_rate_pct				decimal(18, 6) = NULL
	,@p_rate_amount				decimal(18, 2) = NULL
	,@p_loading_type			nvarchar(10)
	,@p_buy_rate_pct			decimal(18, 6) = NULL
	,@p_buy_rate_amount			decimal(18, 2) = NULL
	,@p_is_active				nvarchar(1)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	
	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try 
		if (@p_age_from > @p_age_to)
		begin
			set @msg = 'Age From must be less than or equal Age To' ;

			raiserror(@msg, 16, -1) ;
		end
        
        if (@p_buy_rate_pct > @p_rate_pct)
		begin
			set @msg = 'Buy Rate must be less than or equal Sell Rate' ;

			raiserror(@msg, 16, -1) ;
		end
        if (@p_buy_rate_amount > @p_rate_amount)
		begin
			set @msg = 'Buy Amount must be less than or equal Sell Amount' ;

			raiserror(@msg, 16, -1) ;
		end
         

		update	master_insurance_coverage_loading
		set		insurance_coverage_code = @p_insurance_coverage_code
				,loading_code			= @p_loading_code
				,age_from				= @p_age_from
				,age_to					= @p_age_to
				,rate_type				= @p_rate_type
				,rate_pct				= @p_rate_pct
				,rate_amount			= @p_rate_amount
				,loading_type			= @p_loading_type
				,buy_rate_pct			= @p_buy_rate_pct
				,buy_rate_amount		= @p_buy_rate_amount
				,is_active				= @p_is_active
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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




