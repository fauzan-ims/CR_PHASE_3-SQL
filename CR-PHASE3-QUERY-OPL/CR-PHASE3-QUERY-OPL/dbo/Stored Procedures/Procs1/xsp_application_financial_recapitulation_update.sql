CREATE PROCEDURE dbo.xsp_application_financial_recapitulation_update
(
	@p_code								nvarchar(50)
	,@p_application_code				nvarchar(50)
	,@p_from_periode_year				nvarchar(4)  = null
	,@p_from_periode_month				nvarchar(2)  = null
	,@p_to_periode_year					nvarchar(4)  = null
	,@p_to_periode_month				nvarchar(2)  = null
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max) 
			,@total_asset					decimal(18, 2) --1100
			,@total_liabilitas				decimal(18, 2) --3100
			,@laba_ditahan					decimal(18, 2) --4120
			,@modal_saham					decimal(18, 2) --4110
			,@current_rasio_pct				decimal(9, 6)
			,@debet_to_asset_pct			decimal(9, 6)
			,@return_on_equity_pct			decimal(9, 6)

	begin try
		if (@p_from_periode_month is null and @p_to_periode_month is null)
		begin
			select	@p_from_periode_year	= from_periode_year
					,@p_from_periode_month	= from_periode_month
					,@p_to_periode_year		= to_periode_year
					,@p_to_periode_month	= to_periode_month
			from	application_financial_recapitulation
			where	code					= @p_code
					and application_no		= @p_application_code ;
		end

		if (@p_from_periode_year + @p_from_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112))
		begin
			set @msg = 'From Month - Year must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_to_periode_year + @p_to_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112))
		begin
			set @msg = 'To Month - Year must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_from_periode_year + @p_from_periode_month =  @p_to_periode_year + @p_to_periode_month)
		begin
			set @msg = 'From Month - Year cannot be equal than To Month - Year';
			raiserror(@msg, 16, -1) ;
		end
		if (@p_to_periode_year + @p_to_periode_month <  @p_from_periode_year + @p_from_periode_month)
		begin
			set @msg = 'To Month - Year must be greater or equal than From Month - Year';
			raiserror(@msg, 16, -1) ;
		end

		if exists
		(
			select	1
			from	application_financial_recapitulation
			where	application_no		   = @p_application_code
					and from_periode_year  = @p_from_periode_year
					and to_periode_year	   = @p_to_periode_year
					and from_periode_month = @p_from_periode_month
					and to_periode_month   = @p_to_periode_month
					and code			   <> @p_code
		)
		begin
			set @msg = 'Combination already exists' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		select	@total_asset = isnull(statement_to_value_amount, 0)
		from	dbo.application_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_code
				and statement_code			  = '1100' ;

		select	@total_liabilitas = isnull(statement_to_value_amount, 0)
		from	dbo.application_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_code
				and statement_code			  = '3100' ; 

		select	@laba_ditahan = isnull(statement_to_value_amount, 0)
		from	dbo.application_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_code
				and statement_code			  = '4120' ;

		select	@modal_saham = isnull(statement_to_value_amount, 0)
		from	dbo.application_financial_recapitulation_detail
		where	financial_recapitulation_code = @p_code
				and statement_code			  = '4110' ;

		update	application_financial_recapitulation
		set		application_no						= @p_application_code
				,from_periode_year					= @p_from_periode_year
				,from_periode_month					= @p_from_periode_month
				,to_periode_year					= @p_to_periode_year
				,to_periode_month					= @p_to_periode_month
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code								= @p_code ;

		if (@total_liabilitas = 0)
		begin
			set @current_rasio_pct = 0 ;
		end
		else
		begin
			set @current_rasio_pct = @total_asset / @total_liabilitas ;
		end

		if (@total_asset = 0)
		begin
			set @debet_to_asset_pct = 0 ;
		end
		else
		begin
			set @debet_to_asset_pct = @total_liabilitas / @total_asset ;
		end

		if (@modal_saham = 0)
		begin
			set @return_on_equity_pct = 0 ;
		end
		else
		begin
			set @return_on_equity_pct = @laba_ditahan / @modal_saham ;
		end

		update	dbo.application_financial_recapitulation
		set		current_rasio_pct		= isnull(@current_rasio_pct, 0)
				,debet_to_asset_pct		= isnull(@debet_to_asset_pct, 0)
				,return_on_equity_pct	= isnull(@return_on_equity_pct, 0)
		where	code					= @p_code ; 
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

