create PROCEDURE dbo.xsp_sys_company_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_company sc
			inner join dbo.sys_subscription_type sst on sst.code = sc.subscription_type_code
	where	(
				sc.code													like '%' + @p_keywords + '%'
				or	sc.name												like '%' + @p_keywords + '%'
				or	sc.address											like '%' + @p_keywords + '%'
				or	sst.description										like '%' + @p_keywords + '%'
				or	convert(varchar(30), sc.subscription_end_date, 103)	like '%' + @p_keywords + '%'
			) ;


	select		sc.code
				,sc.name
				,sc.address
				,sc.phone_no
				,sst.description 'subscription_type_name'
				,convert(varchar(30), sc.subscription_end_date, 103) 'subscription_end_date'
				,sc.max_user
				,@rows_count 'rowcount'
	from		sys_company sc
				inner join dbo.sys_subscription_type sst on sst.code = sc.subscription_type_code
	where		(
					sc.code													like '%' + @p_keywords + '%'
					or	sc.name												like '%' + @p_keywords + '%'
					or	sc.address											like '%' + @p_keywords + '%'
					or	sst.description										like '%' + @p_keywords + '%'
					or	convert(varchar(30), sc.subscription_end_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sc.code
														when 2 then sc.name
														when 3 then sc.address
														when 4 then sc.phone_no
														when 5 then sst.description
														when 6 then cast(sc.subscription_end_date as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by							
														when 1 then sc.code
														when 2 then sc.name
														when 3 then sc.address
														when 4 then sc.phone_no
														when 5 then sst.description
														when 6 then cast(sc.subscription_end_date as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
