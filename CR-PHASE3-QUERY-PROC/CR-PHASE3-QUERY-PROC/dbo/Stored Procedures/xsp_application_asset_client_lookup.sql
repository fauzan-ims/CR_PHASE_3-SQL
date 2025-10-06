CREATE procedure [dbo].[xsp_application_asset_client_lookup]
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

	create table #temp_client_main
	(
		client_no	 nvarchar(50)
		,client_name nvarchar(250)
	) ;

	insert into #temp_client_main
	(
		client_no
		,client_name
	)
	select	distinct
			client_no
			,client_name
	from	dbo.client_main ;

	select	@rows_count = count(1)
	from	#temp_client_main
	where	(
				client_no		like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			) ;

	select		client_no	 'client_code'
				,client_name
				,@rows_count 'rowcount'
	from		#temp_client_main
	where		(
					client_no		like '%' + @p_keywords + '%'
					or	client_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then client_no
													 when 2 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then client_no
													   when 2 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
