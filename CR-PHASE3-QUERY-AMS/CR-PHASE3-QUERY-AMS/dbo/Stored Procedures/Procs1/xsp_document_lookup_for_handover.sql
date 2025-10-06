--create by ALiv at 22/05/2023
CREATE procedure dbo.xsp_document_lookup_for_handover
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_document_group_code	nvarchar(50)
	,@p_handover_code		NVARCHAR(50)
)
as
begin
	declare @rows_count int = 0;

	select	@rows_count = count(1)
	from	sys_document_group_detail sdg
			inner join dbo.sys_general_document sgd on (sdg.document_code = sgd.code)
			left join dbo.handover_asset_doc had on (had.handover_code = sgd.code)
	where	document_group_code	= @p_document_group_code
	and		sdg.document_code not in (select document_code
									  from dbo.handover_asset_doc
									  where handover_code = @p_handover_code)
	and		(
				sdg.document_group_code		 like '%' + @p_keywords + '%'
				or	sdg.document_code		 like '%' + @p_keywords + '%'
				or	sgd.document_name	 like '%' + @p_keywords + '%'
			) ;

	select	sgd.document_name
			,sdg.document_code
			,@rows_count 'rowcount'
	from	sys_document_group_detail sdg
			inner join dbo.sys_general_document sgd on (sdg.document_code = sgd.code)
			left join dbo.handover_asset_doc had on (had.handover_code = sgd.code)
	where	document_group_code	= @p_document_group_code
	and		sdg.document_code not in (select document_code
									  from dbo.handover_asset_doc
									  where handover_code = @p_handover_code)
	and		(
				sdg.document_group_code		 like '%' + @p_keywords + '%'
				or	sdg.document_code		 like '%' + @p_keywords + '%'
				or	sgd.document_name	 like '%' + @p_keywords + '%'
			) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgd.document_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sgd.document_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
