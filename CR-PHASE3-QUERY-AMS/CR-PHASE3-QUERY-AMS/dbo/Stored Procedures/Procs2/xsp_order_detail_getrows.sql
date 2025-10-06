CREATE PROCEDURE dbo.xsp_order_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_order_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	declare @order_detail table
	(
		id					  int
		,fa_code			  nvarchar(50)
		,item_name			  nvarchar(250)
		,dp_to_public_service decimal(18, 2)
		,register_code		  nvarchar(50)
		,register_remarks	  nvarchar(4000)
		,is_reimburse		  nvarchar(1)
		,plat_no			  nvarchar(50)
		,chassis_no			  nvarchar(50)
		,engine_no			  nvarchar(50)
		,document_name		  nvarchar(4000)
	) ;

	insert into @order_detail
	(
		id
		,fa_code
		,item_name
		,dp_to_public_service
		,register_code
		,register_remarks
		,is_reimburse
		,plat_no
		,chassis_no
		,engine_no
		,document_name
	)
	select	id
			,rm.fa_code
			,ass.item_name
			,od.dp_to_public_service
			,od.register_code
			,rm.register_remarks
			,od.is_reimburse
			,av.plat_no
			,av.chassis_no
			,av.engine_no
			,stuff((
					   select	distinct
								', ' + replace(sgs.description,'&','DAN')
					   from		dbo.register_detail				   rd
								inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
					   where	rd.register_code = rm.code
					   for xml path('')
				   ), 1, 1, ''
				  )
	from	order_detail				od
			inner join register_main	rm on (rm.code		 = od.register_code)
			inner join dbo.asset		ass on ass.code		 = rm.fa_code
			left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	od.order_code = @p_order_code
			and
			(
				rm.fa_code															like '%' + @p_keywords + '%'
				or	ass.item_name													like '%' + @p_keywords + '%'
				or	convert(varchar, cast(od.dp_to_public_service as money), 1)		like '%' + @p_keywords + '%'
				or	od.register_code												like '%' + @p_keywords + '%'
				or	rm.register_remarks												like '%' + @p_keywords + '%'
				or	av.plat_no														like '%' + @p_keywords + '%'
				or	av.chassis_no													like '%' + @p_keywords + '%'
				or	av.engine_no													like '%' + @p_keywords + '%'
				or	stuff((
							  select	distinct
										', ' + replace(sgs.description,'&','DAN')
							  from		dbo.register_detail				   rd
										inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
							  where		rd.register_code = rm.code
							  for xml path('')
						  ), 1, 1, ''
						 ) like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@order_detail ;

	select		id
				,fa_code
				,item_name
				,dp_to_public_service
				,register_code
				,register_remarks
				,is_reimburse
				,plat_no
				,chassis_no
				,engine_no
				,document_name
				,@rows_count 'rowcount'
	from		@order_detail
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then register_code
													 when 2 then fa_code
													 when 3 then plat_no
													 when 4 then document_name
													 when 5 then cast(dp_to_public_service as sql_variant)
													 when 6 then register_remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then register_code
													   when 2 then fa_code
													   when 3 then plat_no
													   when 4 then document_name
													   when 5 then cast(dp_to_public_service as sql_variant)
													   when 6 then register_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
