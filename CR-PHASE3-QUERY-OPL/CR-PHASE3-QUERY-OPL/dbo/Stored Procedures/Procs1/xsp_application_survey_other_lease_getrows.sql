--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_application_survey_other_lease_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_other_lease asol
	where	asol.application_survey_code = @p_application_survey_code
			and (
					asol.rental_company				like '%' + @p_keywords + '%'
					or	asol.unit					like '%' + @p_keywords + '%'
					or	asol.jenis_kendaraan		like '%' + @p_keywords + '%'
					or	asol.os_periode				like '%' + @p_keywords + '%'
					or	asol.nilai_pinjaman			like '%' + @p_keywords + '%'
				) ;

	select		asol.id
				,asol.application_survey_code
				,asol.rental_company
				,asol.unit
				,asol.jenis_kendaraan
				,asol.os_periode
				,asol.nilai_pinjaman
				,@rows_count	 'rowcount'
	from		dbo.application_survey_other_lease asol
	where		asol.application_survey_code = @p_application_survey_code
				and (
						asol.rental_company			like '%' + @p_keywords + '%'
						or	asol.unit					like '%' + @p_keywords + '%'
						or	asol.jenis_kendaraan		like '%' + @p_keywords + '%'
						or	asol.os_periode				like '%' + @p_keywords + '%'
						or	asol.nilai_pinjaman			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asol.rental_company
													 when 2 then cast(asol.unit as sql_variant)
													 when 3 then asol.jenis_kendaraan
													 when 4 then cast(asol.os_periode as sql_variant)
													 when 5 then cast(asol.nilai_pinjaman as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asol.rental_company
														when 2 then cast(asol.unit as sql_variant)
														when 3 then asol.jenis_kendaraan
														when 4 then cast(asol.os_periode as sql_variant)
														when 5 then cast(asol.nilai_pinjaman as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
