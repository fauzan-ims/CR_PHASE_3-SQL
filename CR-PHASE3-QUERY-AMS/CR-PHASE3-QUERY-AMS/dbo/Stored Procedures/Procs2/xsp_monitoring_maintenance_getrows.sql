CREATE procedure [dbo].[xsp_monitoring_maintenance_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_from_date	datetime = ''
	,@p_to_date		datetime
)
as
begin
	declare @rows_count			int = 0
			,@asset_code		nvarchar(50)
			,@item_name			nvarchar(400)
			,@plat_no			nvarchar(20)
			,@rental_status		nvarchar(100)
			,@branch_name		nvarchar(250)
			,@service_code		nvarchar(50)
			,@service_name		nvarchar(250)
			,@miles				int
			,@maintenance_date	varchar(50)
			,@aging				int
			,@last_service_date varchar(50)
			,@last_km_service	int
			,@code_asset		nvarchar(50)
			,@id_schedule		bigint
			,@id_schedule2		bigint ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	declare @tabletemp table
	(
		asset_code					  nvarchar(50)
		,item_name					  nvarchar(400)
		,plat_no					  nvarchar(20)
		,rental_status				  nvarchar(100)
		,branch_name				  nvarchar(250)
		,service_code				  nvarchar(50)
		,service_name				  nvarchar(250)
		,miles						  int
		,maintenance_date			  varchar(50)
		,aging						  int
		,last_service_date			  varchar(50)
		,last_km_service			  int
		,count_data_jatuh_tempo		  int
		,count_data_belum_jatuh_tempo int
	) ;

	insert into @tabletemp
	(
		asset_code
		,item_name
		,plat_no
		,rental_status
		,branch_name
		,service_code
		,service_name
		,miles
		,maintenance_date
		,aging
		,last_service_date
		,last_km_service
		,count_data_jatuh_tempo
		,count_data_belum_jatuh_tempo
	)
	select		top 1000
				ass.code
				,ass.item_name
				,av.plat_no
				,ass.rental_status
				,ass.branch_name
				,max(ams.service_code)
				,max(ams.service_name)
				,max(ams.miles)
				,convert(varchar(30), max(ams.maintenance_date), 103)
				,datediff(day, max(ams.maintenance_date), (dbo.xfn_get_system_date()))
				,convert(varchar(30), ass.last_service_date, 103)
				,ass.last_km_service
				,tempo.sudah_jatuh_tempo
				,belum_jatuh_tempo.belum_jatuh_tempo
	from		dbo.asset								  ass with (nolock)
				inner join dbo.asset_vehicle			  av with (nolock) on (ass.code = av.asset_code)
				inner join dbo.asset_maintenance_schedule ams with (nolock) on (
																				   ams.asset_code = ass.code
																				   and ams.maintenance_status = 'SCHEDULE PENDING'
																				   and isnull(reff_trx_no, '') = ''
																				   and ams.maintenance_date <= @p_to_date
																			   )
							outer apply
				(
					select	count(ams.id) 'belum_jatuh_tempo'
					from	dbo.asset_maintenance_schedule ams with (nolock)
					where	ams.ASSET_CODE				= ass.code
							and maintenance_status		= 'SCHEDULE PENDING'
							and isnull(reff_trx_no, '') = ''
							and ams.maintenance_date
							between @p_from_date and @p_to_date
				)													  belum_jatuh_tempo
				outer apply
	(
		select	count(ams.id) 'sudah_jatuh_tempo'
				--,count(	  case
				--			  when ams.MAINTENANCE_DATE > @p_from_date then 1
				--			  else 0
				--		  end
				--	  )		  'belum_jatuh_tempo'
		from	dbo.asset_maintenance_schedule ams with (nolock)
		where	ams.ASSET_CODE				= ass.CODE
				and maintenance_status		= 'SCHEDULE PENDING'
				and isnull(reff_trx_no, '') = ''
				and ams.maintenance_date	< @p_to_date
	)													  tempo
	where		ass.branch_code		   = case @p_branch_code
											 when 'ALL' then ass.branch_code
											 else @p_branch_code
										 end
				and ass.status in
	(
		'STOCK', 'REPLACEMENT'
	)
				and ass.is_maintenance = '1'
				and not exists
	(
		select	1
		from	dbo.MAINTENANCE mnt with (nolock)
		where	mnt.ASSET_CODE = ass.code
				and mnt.STATUS in
	(
		'HOLD', 'ON PROCESS'
	)
	)
				and
				(
					ass.CODE											like '%' + @p_keywords + '%'
					or	item_name										like '%' + @p_keywords + '%'
					or	plat_no											like '%' + @p_keywords + '%'
					or	rental_status									like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), last_service_date, 103)	like '%' + @p_keywords + '%'
					or	last_km_service									like '%' + @p_keywords + '%'
				)
	group by	ass.code
				,ass.item_name
				,av.plat_no
				,ass.rental_status
				,ass.branch_name
				,convert(varchar(30), ass.last_service_date, 103)
				,ass.last_km_service
				,tempo.sudah_jatuh_tempo
				,belum_jatuh_tempo.belum_jatuh_tempo ;

	select	@rows_count = count(1)
	from	@tabletemp
	where	(
				asset_code															like '%' + @p_keywords + '%'
				or	item_name														like '%' + @p_keywords + '%'
				or	plat_no															like '%' + @p_keywords + '%'
				or	rental_status													like '%' + @p_keywords + '%'
				or	datediff(day, maintenance_date, (dbo.xfn_get_system_date()))	like '%' + @p_keywords + '%'
				or	convert(varchar(30), maintenance_date, 103)						like '%' + @p_keywords + '%'
				or	service_name													like '%' + @p_keywords + '%'
				or	miles															like '%' + @p_keywords + '%'
				or	branch_name														like '%' + @p_keywords + '%'
				or	convert(varchar(30), last_service_date, 103)					like '%' + @p_keywords + '%'
				or	last_km_service													like '%' + @p_keywords + '%'
			) ;

	select		asset_code					 'code'
				,item_name
				,plat_no
				,rental_status
				,branch_name
				,service_code
				,service_name
				,miles
				,maintenance_date
				,aging
				,last_service_date
				,last_km_service
				,count_data_jatuh_tempo
				,count_data_belum_jatuh_tempo
				,@rows_count				 'rowcount'
	from		@tabletemp
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code + item_name + plat_no
													 when 2 then branch_name
													 when 3 then service_name
													 when 4 then cast(maintenance_date as sql_variant)
													 when 5 then cast(miles as sql_variant)
													 when 6 then cast(last_service_date as sql_variant) --+ last_km_service 
													 when 7 then rental_status
													 when 8 then aging
													 when 9 then count_data_belum_jatuh_tempo
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code + item_name + plat_no
													   when 2 then branch_name
													   when 3 then service_name
													   when 4 then cast(maintenance_date as sql_variant)
													   when 5 then cast(miles as sql_variant)
													   when 6 then cast(last_service_date as sql_variant) --+ last_km_service 
													   when 7 then rental_status
													   when 8 then aging
													   when 9 then count_data_belum_jatuh_tempo
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
