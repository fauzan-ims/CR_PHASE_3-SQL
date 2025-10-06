CREATE procedure dbo.xsp_dashboard_get_so_asset_nasional_trial
(
	@p_company_code nvarchar(50)
)
as
begin
	declare @msg		  nvarchar(max)
			,@total_data  int
			,@region_name nvarchar(250)
			,@status	  nvarchar(250) ;

	declare @temp_table table
	(
		total_data	 decimal(18, 2)
		,reff_name	 nvarchar(250)
		,series_name nvarchar(250)
	) ;

	declare @temp_status table
	(
		location_in nvarchar(250)
	) ;

	declare @temp_descripion table
	(
		office_name nvarchar(250)
	) ;

	--------------------------------
	insert into @temp_status
	(
		location_in
	)
	select		od.location_in
	from		dbo.opname op
				inner join dbo.opname_detail od on (od.opname_code = op.code)
				left join dbo.asset ass on (ass.code			   = od.asset_code)
	where		od.location_in <> ''
				and op.status  = 'POST'
	group by	od.location_in ;

	insert into @temp_descripion
	(
		office_name
	)
	select		ass.regional_name
	from		dbo.opname op
				inner join dbo.opname_detail od on (od.opname_code = op.code)
				left join dbo.asset ass on (ass.code			   = od.asset_code)
	where		od.location_in <> ''
				and op.status  = 'POST'
	group by	ass.regional_name ;

	insert into @temp_table
	(
		total_data
		,reff_name
		,series_name
	)
	select	0
			,b.office_name
			,a.location_in
	from	@temp_status a
			cross join @temp_descripion b ;

	update	c
	set		c.total_data = total.code
	from	@temp_table c
			outer apply
	(
		select	count(op.code) 'code'
		from	dbo.opname op
				inner join dbo.opname_detail od on (od.opname_code = op.code)
				left join dbo.asset ass on (ass.code			   = od.asset_code)
		where	od.location_in		  <> ''
				and op.status		  = 'POST'
				and od.location_in	  = c.series_name collate sql_latin1_general_cp1_ci_as
				and ass.regional_name = c.reff_name collate sql_latin1_general_cp1_ci_as
	) total ;

	--declare cursor_name cursor fast_forward read_only for
	--select	count(op.code)
	--		,ass.regional_name
	--		,od.location_in
	--from dbo.opname op
	--inner join dbo.opname_detail od on (od.opname_code = op.code)
	--left join dbo.asset ass on (ass.code = od.asset_code)
	--where od.location_in <> ''
	--and op.status = 'POST'
	--group by ass.regional_name,od.location_in

	--open cursor_name

	--fetch next from cursor_name 
	--into @total_data
	--	,@region_name
	--	,@status

	--while @@fetch_status = 0
	--begin
	--		declare @temp_table table
	--		(
	--			total_data		decimal(18,2)
	--			,reff_name		nvarchar(250)
	--			,series_name	nvarchar(250)
	--		) ;

	--		insert into @temp_table
	--		(
	--			total_data
	--			,reff_name
	--			,series_name
	--		)
	--		values
	--		(	@total_data
	--			,@region_name
	--			,@status
	--		) 

	--	    fetch next from cursor_name 
	--		into @total_data
	--			,@region_name
	--			,@status
	--	end

	--close cursor_name
	--deallocate cursor_name
	select		total_data
				,reff_name
				,series_name
	from		@temp_table
	order by	series_name ;
end ;
