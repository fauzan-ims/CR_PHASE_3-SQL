CREATE PROCEDURE [dbo].[xsp_maintenance_detail_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_maintenance_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	maintenance_detail md
			inner join dbo.maintenance mnt on (mnt.code = md.maintenance_code)
			inner join dbo.asset ass on (ass.code = mnt.asset_code)
			left join dbo.asset_maintenance_schedule ams on (ams.id = md.asset_maintenance_schedule_id)
	where	maintenance_code = @p_maintenance_code
	and		(
					md.service_name		 like '%' + @p_keywords + '%'
					or	md.service_type	 like '%' + @p_keywords + '%'
					or	md.quantity		 like '%' + @p_keywords + '%'
			) ;

	select		md.id
				,maintenance_code
				,md.service_code
				,md.service_name
				,md.file_name
				,path
				,ass.type_code
				,md.quantity
				,ams.maintenance_no
				,md.service_type
				,md.total_amount
				,md.pph_amount
				,md.ppn_amount
				,md.total_amount
				,md.payment_amount
				,ams.miles
				,ams.hour
				,md.part_number
				,convert(varchar(30), ams.maintenance_date, 103) 'maintenance_date'
				,@rows_count 'rowcount'
	from		maintenance_detail md 
				inner join dbo.maintenance mnt on (mnt.code = md.maintenance_code)
				inner join dbo.asset ass on (ass.code = mnt.asset_code)
				left join dbo.asset_maintenance_schedule ams on (ams.id = md.asset_maintenance_schedule_id)
	where		maintenance_code = @p_maintenance_code
	and			(
					md.service_name		 like '%' + @p_keywords + '%'
					or	md.service_type	 like '%' + @p_keywords + '%'
					or	md.quantity		 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then md.service_name
														WHEN 2 THEN md.service_type
														when 3 then cast(md.quantity as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then md.service_name
														WHEN 2 THEN md.service_type
														when 3 then cast(md.quantity as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
