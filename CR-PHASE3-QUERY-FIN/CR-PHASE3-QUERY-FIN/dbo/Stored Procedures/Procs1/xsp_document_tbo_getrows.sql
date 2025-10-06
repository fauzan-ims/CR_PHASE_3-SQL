CREATE procedure [dbo].[xsp_document_tbo_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_status	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.document_tbo			   dt
			inner join dbo.master_contract mc on dt.main_contract_no = mc.main_contract_no
	where	dt.status = case @p_status
							when 'all' then dt.status
							else @p_status
						end
			and
			(
				mc.client_name							like '%' + @p_keywords + '%'
				or	mc.main_contract_no					like '%' + @p_keywords + '%'
				or	convert(varchar(15), mc.date, 103)	like '%' + @p_keywords + '%'
				or	dt.status							like '%' + @p_keywords + '%'
			) ;

	select		dt.code
				,dt.main_contract_no
				,convert(varchar(30), mc.date, 103) 'date'
				,mc.client_name
				,dt.status
				,@rows_count						'rowcount'
	from		dbo.document_tbo			   dt
				inner join dbo.master_contract mc on dt.main_contract_no = mc.main_contract_no
	where		dt.status = case @p_status
								when 'all' then dt.status
								else @p_status
							end
				and
				(
					mc.client_name							like '%' + @p_keywords + '%'
					or	mc.main_contract_no					like '%' + @p_keywords + '%'
					or	convert(varchar(15), mc.date, 103)	like '%' + @p_keywords + '%'
					or	dt.status							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mc.client_name
													 when 2 then dt.main_contract_no
													 when 3 then cast(mc.date as sql_variant)
													 when 4 then dt.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mc.client_name
													   when 2 then dt.main_contract_no
													   when 3 then cast(mc.date as sql_variant)
													   when 4 then dt.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
