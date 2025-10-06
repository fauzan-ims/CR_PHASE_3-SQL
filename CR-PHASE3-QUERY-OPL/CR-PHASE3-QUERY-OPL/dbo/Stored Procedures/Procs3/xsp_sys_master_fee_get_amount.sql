CREATE PROCEDURE dbo.xsp_sys_master_fee_get_amount
(
	@p_facility_code	 nvarchar(50)
	,@p_currency_code	 nvarchar(50)
	,@p_eff_date		 datetime
	,@p_asset_count		 int			= 1
	,@p_asset_amount	 decimal(18, 2)
	,@p_financing_amount decimal(18, 2)
	,@p_fee_code		 nvarchar(50)
	,@p_calculate_by	 nvarchar(10)	output
	,@p_default_rate	 decimal(9, 6)	output
	,@p_default_amount	 decimal(18, 2) output
	,@p_fee_amount		 decimal(18, 2) output
	,@p_reff_no			 nvarchar(50)	= '' -- tambahan untuk kebutuhan perhitungan fee by function ( bisa berisi aplikasino/ drandown no / plafond no)
)
as
begin
	declare @msg					nvarchar(max)
			,@function_name			nvarchar(250)
			,@is_fn_overide			nvarchar(1)
			,@function_overide_name nvarchar(250)
			,@calculate_base		nvarchar(11)
			,@calculate_from		nvarchar(20)
			,@base_amount			decimal(18, 2) ;

	begin try

		-- urutan prioritas fee
		-- paket - plafond - general
		--if exists
		--(
		--	select	1
		--	from	dbo.master_package_fee
		--	where	package_code = @p_package_code
		--			and fee_code = @p_fee_code
		--)
		--begin -- jika tanpa package ambil dari master fee
		--	select	@p_calculate_by = calculate_by
		--			,@p_default_rate = fee_rate
		--			,@p_default_amount = fee_amount
		--			,@calculate_base = calculate_base
		--			,@calculate_from = calculate_from
		--			,@function_name = fn_default_name
		--			,@is_fn_overide = is_fn_override
		--			,@function_overide_name = fn_override_name
		--	from	dbo.master_package_fee
		--	where	package_code = @p_package_code
		--			and fee_code = @p_fee_code ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.plafond_fee
		--	where	plafond_code	= @p_plafond_code
		--			and fee_code	= @p_fee_code
		--			and fee_paid_on <> 'PLAFOND'
		--)
		--begin -- jika ada di plafond
		--	select	@p_calculate_by = case
		--								  when default_fee_rate > 0 then 'PCT'
		--								  else 'AMOUNT'
		--							  end
		--			,@p_default_rate = default_fee_rate
		--			,@p_default_amount = fee_amount
		--			,@calculate_base = 'APP'
		--			,@calculate_from = 'FINANCING'
		--			,@function_name = ''
		--	from	dbo.plafond_fee
		--	where	plafond_code	= @p_plafond_code
		--			and fee_code	= @p_fee_code
		--			and fee_paid_on <> 'PLAFOND' ;
		--end ;
		--else 
		if exists
		(
			select	1
			from	dbo.master_fee_amount
			where	facility_code	   = @p_facility_code
					and fee_code	   = @p_fee_code
					and currency_code  = @p_currency_code
					and effective_date <= @p_eff_date
		)
		begin -- jika tanpa plafond dan tanpa package ambil dari master fee
			select top 1
						@p_calculate_by = calculate_by
						,@p_default_rate = fee_rate
						,@p_default_amount = fee_amount
						,@calculate_base = calculate_base
						,@calculate_from = calculate_from
						,@function_name = fn_default_name
						,@is_fn_overide = is_fn_override
						,@function_overide_name = fn_override_name
			from		master_fee_amount
			where		facility_code	   = @p_facility_code
						and currency_code  = @p_currency_code
						and fee_code	   = @p_fee_code
						and effective_date <= @p_eff_date
			order by	effective_date desc ;
		end ;
		else
		begin -- selain itu ambil top 1
			select top 1
						@p_calculate_by = calculate_by
						,@p_default_rate = fee_rate
						,@p_default_amount = fee_amount
						,@calculate_base = calculate_base
						,@calculate_from = calculate_from
						,@function_name = fn_default_name
						,@is_fn_overide = is_fn_override
						,@function_overide_name = fn_override_name
			from		master_fee_amount
			where		effective_date	  <= @p_eff_date
						and fee_code	  = @p_fee_code
						and currency_code = @p_currency_code
			order by	effective_date desc ;
		end ;

		if @p_calculate_by = 'PCT'
		begin
			if @calculate_from = 'FINANCING'
			begin
				set @base_amount = @p_financing_amount ;
			end ;
			else
			begin
				set @base_amount = @p_asset_amount ;
			end ;

			set @p_fee_amount = (@p_default_rate * @base_amount) / 100.00 ;
		end ;
		else if @p_calculate_by = 'AMOUNT'
		begin
			set @p_fee_amount = @p_default_amount ;
		end ;
		else -- BY FUNCTION
		begin
			if (@is_fn_overide = 0)
			begin
				exec @p_fee_amount = @function_name @p_reff_no ;
			end ;
			else
			begin
				exec @p_fee_amount = @function_overide_name @p_reff_no ;
			end ;

			set @p_default_rate = 0 ;
			set @p_default_amount = @p_fee_amount ;
		end ;

		if (@calculate_base <> 'APP')
		begin
			set @p_fee_amount = @p_fee_amount * @p_asset_count ; --jika kalkulasi base application
		end ;
		else
		begin
			set @p_fee_amount = @p_fee_amount * 1 ; --jika kalkulasi berdasarkan asset maka dikalikan dengan jumlah asset 
		end ;
	--end ;
	--else
	--begin
	--	set @msg = 'Please check your Setting Data Master for this value on Sales -> General Policy -> Fee' ;

	--	raiserror(@msg, 16, -1) ;
	--end ;
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

