CREATE PROCEDURE dbo.xsp_application_asset_reservation_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_status	   nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset_reservation
	--13/12/2022 Rian, Menambahkan case untuk status
	where	status = case @p_status
						  		when 'ALL' then status
						  		else @p_status
						end
			and (
					employee_name								like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), reserv_date, 103) like '%' + @p_keywords + '%'
					or	remark									like '%' + @p_keywords + '%'
					or	fa_code									like '%' + @p_keywords + '%'
					or	fa_name									like '%' + @p_keywords + '%'
				) ;

	select		id
				,employee_code
				,employee_name
				,convert(nvarchar(15), reserv_date, 103) 'reserv_date'
				,status
				,remark
				,fa_code
				,fa_name
				,application_no
				,@rows_count 'rowcount'
	from		application_asset_reservation
	--13/12/2022 Rian, Menambahkan case untuk status
	where	status = case @p_status
						  		when 'ALL' then status
						  		else @p_status
						  end
				and (
						employee_name								like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), reserv_date, 103) like '%' + @p_keywords + '%'
						or	remark									like '%' + @p_keywords + '%'
						or	fa_code									like '%' + @p_keywords + '%'
						or	fa_name									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then employee_name
													 when 2 then cast(reserv_date as sql_variant)
													 when 3 then remark
													 when 4 then fa_code + fa_name
													 when 5 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then employee_name
													   when 2 then cast(reserv_date as sql_variant)
													   when 3 then remark
													   when 4 then fa_code + fa_name
													   when 5 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
