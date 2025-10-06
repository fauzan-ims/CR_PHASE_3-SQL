CREATE PROCEDURE dbo.xsp_master_coverage_loading_update
(
	@p_code			   nvarchar(50)
	,@p_loading_name   nvarchar(250)
	,@p_loading_type   nvarchar(10)
	,@p_age_from	   INT = 0
	,@p_age_to		   INT = 0
	,@p_rate_type	   nvarchar(10)
	,@p_buy_amount	   decimal(18, 2) = NULL
	,@p_sell_amount	   decimal(18, 2) = NULL
	,@p_buy_rate_pct   decimal(9, 6)  = NULL
	,@p_sale_rate_pct  decimal(9, 6)  = NULL
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin TRY
		if exists (select 1 from master_coverage_loading WHERE code <> @p_code and  loading_name = @p_loading_name)
		begin
			SET @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		END
        
		if (@p_age_from > @p_age_to)
		begin
			set @msg = 'Age From must be less than Age To' ;

			raiserror(@msg, 16, -1) ;
		end
        
        if (@p_buy_rate_pct > @p_sale_rate_pct)
		begin
			set @msg = 'Buy Rate must be less than Sell Rate' ;

			raiserror(@msg, 16, -1) ;
		end
        if (@p_buy_amount > @p_sell_amount)
		begin
			set @msg = 'Buy Amount must be less than Sell Amount' ;

			raiserror(@msg, 16, -1) ;
		end
        
		if exists
		(
			select	1
			from	master_coverage_loading
			where	code				<> @p_code
					and	loading_type	= @p_loading_type
					and (
							age_from		   <= @p_age_from
							and @p_age_from <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	code				<> @p_code
					and	loading_type	= @p_loading_type
					and (
							age_from	 <= @p_age_to
							and @p_age_to <= age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	code				<> @p_code
					and	loading_type	= @p_loading_type
					and (
							@p_age_from	<= age_from
							and age_from <= @p_age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	master_coverage_loading
			where	code				<> @p_code
					and	loading_type	= @p_loading_type
					and (
							@p_age_to  <= age_to
							and age_to <= @p_age_to
						)
		)
		begin
			set @msg = 'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;
		update	master_coverage_loading
		set		loading_name	= UPPER(@p_loading_name)
				,loading_type	= @p_loading_type
				,age_from		= @p_age_from
				,age_to			= @p_age_to
				,rate_type		= @p_rate_type
				,buy_amount		= @p_buy_amount
				,sell_amount	= @p_sell_amount
				,buy_rate_pct	= @p_buy_rate_pct
				,sale_rate_pct	= @p_sale_rate_pct
				,is_active		= @p_is_active
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
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


