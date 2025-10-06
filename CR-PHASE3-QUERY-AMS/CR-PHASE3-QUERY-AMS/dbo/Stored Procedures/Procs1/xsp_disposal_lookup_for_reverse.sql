CREATE PROCEDURE dbo.xsp_disposal_lookup_for_reverse
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
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
	and		dsd.disposal_code not in (select disposal_code
									from dbo.reverse_disposal 
									where company_code = @p_company_code 
									and status in ('NEW', 'ON PROGRESS'))
	and		(
				dsp.code				like '%' + @p_keywords + '%'
				or	dsp.disposal_date	like '%' + @p_keywords + '%'
				or	dsp.branch_name		like '%' + @p_keywords + '%'
				or	dsp.location_code	like '%' + @p_keywords + '%'
				or	dsp.description		like '%' + @p_keywords + '%'
				or	ass.code			like '%' + @p_keywords + '%'
				or	ass.barcode			like '%' + @p_keywords + '%'
			) ;

	select dsp.code	'disposal_code'
		  ,dsp.company_code
		  ,convert(nvarchar(30), dsp.disposal_date, 103) 'disposal_date_lookup'
		  ,dsp.branch_code
		  ,dsp.branch_name
		  ,dsp.location_code
		  ,dsp.location_name
		  ,dsp.description
		  ,dsp.reason_type
		  ,dsp.remarks
		  ,dsp.status
		  ,@rows_count 'rowcount'
	from	dbo.disposal dsp
			inner join dbo.disposal_detail dsd on (dsd.disposal_code = dsp.code)
			inner join dbo.asset ass on (ass.code = dsd.asset_code)
	where	dsp.status = 'POST' 
	and		ass.status = 'DISPOSED'
	and		dsp.company_code = @p_company_code
	and		dsd.disposal_code not in (select disposal_code
									from dbo.reverse_disposal 
									where company_code = @p_company_code
									and status in ('NEW', 'ON PROGRESS'))
	and		(
				dsp.code				like '%' + @p_keywords + '%'
				or	dsp.disposal_date	like '%' + @p_keywords + '%'
				or	dsp.branch_name		like '%' + @p_keywords + '%'
				or	dsp.location_code	like '%' + @p_keywords + '%'
				or	dsp.description		like '%' + @p_keywords + '%'
				or	ass.code			like '%' + @p_keywords + '%'
				or	ass.barcode			like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then dsp.code
												when 2 then cast(dsp.disposal_date as sql_variant)
												when 3 then dsp.branch_name
												when 4 then dsp.location_code
												when 5 then dsp.description
												when 6 then dsp.status
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
												when 1 then dsp.code
												when 2 then cast(dsp.disposal_date as sql_variant)
												when 3 then dsp.branch_name
												when 4 then dsp.location_code
												when 5 then dsp.description
												when 6 then dsp.status
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
