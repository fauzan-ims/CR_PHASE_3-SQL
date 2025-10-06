CREATE PROCEDURE dbo.xsp_disposal_lookup_for_reverse_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_branch_code		nvarchar(50)
	,@p_location_code	nvarchar(50)
	,@p_disposal_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select 	@rows_count = count(1) 
	from 	dbo.disposal dsp
			inner join dbo.disposal_detail dsd on (dsd.disposal_code = dsp.code)
			inner join dbo.asset ass on (ass.code = dsd.asset_code)
 	where	dsp.status = 'POST' 
	and		ass.status = 'DISPOSED'
	and		dsp.company_code = @p_company_code
	and		dsp.branch_code = @p_branch_code
	and		dsp.location_code = @p_location_code
	and		dsd.asset_code not in (select rdd.asset_code
									from dbo.reverse_disposal_detail rdd
									inner join dbo.reverse_disposal rd on (rd.code = rdd.reverse_disposal_code)
									where rd.disposal_code = @p_disposal_code 
									and rd.company_code = @p_company_code 
									and rd.status in ('NEW', 'POST'))
	and		dsd.disposal_code = @p_disposal_code
	and		(
				dsd.asset_code			like '%' + @p_keywords + '%'
				or	ass.barcode			like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
			) ;

	select dsp.code	'disposal_code'
		  ,dsp.company_code
		  ,dsd.asset_code
		  ,ass.item_name
		  ,convert(nvarchar(30), dsp.disposal_date, 103) 'disposal_date_lookup'
		  ,dsp.branch_code
		  ,dsp.branch_name
		  ,dsp.location_code
		  ,ass.barcode
		  ,dsp.description
		  ,dsp.reason_type
		  ,dsp.remarks
		  ,dsp.status
		  ,ass.code 'asset_code'
		  ,@rows_count 'rowcount'
	from	dbo.disposal dsp
			inner join dbo.disposal_detail dsd on (dsd.disposal_code = dsp.code)
			inner join dbo.asset ass on (ass.code = dsd.asset_code)
	where	dsp.status = 'POST' 
	and		ass.status = 'DISPOSED'
	and		dsp.company_code = @p_company_code
	and		dsp.branch_code = @p_branch_code
	and		dsp.location_code = @p_location_code
	and		dsd.asset_code not in (select rdd.asset_code
									from dbo.reverse_disposal_detail rdd
									inner join dbo.reverse_disposal rd on (rd.code = rdd.reverse_disposal_code)
									where rd.disposal_code = @p_disposal_code 
									and rd.company_code = @p_company_code 
									and rd.status in ('NEW', 'POST'))
	and		dsd.disposal_code = @p_disposal_code
	and		(
				dsd.asset_code			like '%' + @p_keywords + '%'
				or	ass.barcode			like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then dsd.asset_code
												when 2 then ass.item_name
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
												when 1 then dsd.asset_code
												when 2 then ass.item_name
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
