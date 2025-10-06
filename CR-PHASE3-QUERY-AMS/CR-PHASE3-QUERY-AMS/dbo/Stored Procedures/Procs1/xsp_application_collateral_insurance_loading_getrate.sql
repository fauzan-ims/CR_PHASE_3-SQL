CREATE procedure dbo.xsp_application_collateral_insurance_loading_getrate
(
	@p_insurance_code	nvarchar(50)
	,@p_is_commercial	nvarchar(1)	 = ''
	,@p_is_authorized	nvarchar(1)	 = ''
	,@p_coverage_code	nvarchar(50) = ''
	,@p_collateral_year nvarchar(4)
	,@p_year_periode	int
)
as
begin
	declare @loading_type	 nvarchar(10)
			,@age_from		 int
			,@age_to		 int
			,@umur_kendaraan int
			,@id_coverage	 bigint ;

	declare @Temp table
	(
		rate_type		 nvarchar(10)
		,rate_pct		 decimal(9, 6)
		,rate_amount	 decimal(18, 2)
		,loading_type	 nvarchar(10)
		,buy_rate_pct	 decimal(9, 6)
		,buy_rate_amount decimal(18, 2)
		,loading_code	 nvarchar(50)
		,loading_name	 nvarchar(250)
	) ;

	set @umur_kendaraan = datediff(year, @p_collateral_year, (dateadd(year, (@p_year_periode - 1), dbo.xfn_get_system_date()))) ;

	declare cursor_master_insurance_coverage_loading cursor fast_forward read_only for
	select	micl.id
			,micl.loading_type
			,micl.age_from
			,micl.age_to
	from	dbo.master_insurance_coverage_loading micl
			inner join dbo.master_insurance_coverage mic on (mic.code = micl.insurance_coverage_code)
	where	mic.coverage_code	   = @p_coverage_code
			and mic.insurance_code = @p_insurance_code ;

	open cursor_master_insurance_coverage_loading ;

	fetch next from cursor_master_insurance_coverage_loading
	into @id_coverage
		 ,@loading_type
		 ,@age_from
		 ,@age_to ;

	while @@fetch_status = 0
	begin
		if @loading_type = 'AGE'
		   and	@umur_kendaraan
		   between @age_from and @age_to
		begin
			insert into @Temp
			(
				rate_type
				,rate_pct
				,rate_amount
				,loading_type
				,buy_rate_pct
				,buy_rate_amount
				,loading_code
				,loading_name
			)
			select	micl.rate_type
					,micl.rate_pct
					,micl.rate_amount
					,micl.loading_type
					,micl.buy_rate_pct
					,micl.buy_rate_amount
					,micl.loading_code
					,mcl.loading_name
			from	dbo.master_insurance_coverage_loading micl
					inner join dbo.master_insurance_coverage mic on (mic.code = micl.insurance_coverage_code)
					inner join dbo.master_coverage_loading mcl on (mcl.code	  = micl.loading_code)
			where	micl.id = @id_coverage ;
		end ;
		else if @loading_type = 'RENTAL'
				and @p_is_commercial = '1'
		begin
			insert into @Temp
			(
				rate_type
				,rate_pct
				,rate_amount
				,loading_type
				,buy_rate_pct
				,buy_rate_amount
				,loading_code
				,loading_name
			)
			select	micl.rate_type
					,micl.rate_pct
					,micl.rate_amount
					,micl.loading_type
					,micl.buy_rate_pct
					,micl.buy_rate_amount
					,micl.loading_code
					,mcl.loading_name
			from	dbo.master_insurance_coverage_loading micl
					inner join dbo.master_insurance_coverage mic on (mic.code = micl.insurance_coverage_code)
					inner join dbo.master_coverage_loading mcl on (mcl.code	  = micl.loading_code)
			where	micl.id = @id_coverage ;
		end ;
		else if @loading_type = 'AUTHORIZED'
				and @p_is_authorized = '1'
		begin
			insert into @Temp
			(
				rate_type
				,rate_pct
				,rate_amount
				,loading_type
				,buy_rate_pct
				,buy_rate_amount
				,loading_code
				,loading_name
			)
			select	micl.rate_type
					,micl.rate_pct
					,micl.rate_amount
					,micl.loading_type
					,micl.buy_rate_pct
					,micl.buy_rate_amount
					,micl.loading_code
					,mcl.loading_name
			from	dbo.master_insurance_coverage_loading micl
					inner join dbo.master_insurance_coverage mic on (mic.code = micl.insurance_coverage_code)
					inner join dbo.master_coverage_loading mcl on (mcl.code	  = micl.loading_code)
			where	micl.id = @id_coverage ;
		end ;

		fetch next from cursor_master_insurance_coverage_loading
		into @id_coverage
			 ,@loading_type
			 ,@age_from
			 ,@age_to ;
	end ;

	close cursor_master_insurance_coverage_loading ;
	deallocate cursor_master_insurance_coverage_loading ;
end ;
