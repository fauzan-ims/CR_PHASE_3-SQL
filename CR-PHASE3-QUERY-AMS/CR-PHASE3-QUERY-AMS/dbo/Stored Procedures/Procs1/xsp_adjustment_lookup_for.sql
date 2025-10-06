CREATE PROCEDURE dbo.xsp_adjustment_lookup_for
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_adjustment_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_general_subcode sgs
			inner join dbo.sys_general_code sgc on (sgc.code = sgs.general_code)
	where	sgs.company_code = @p_company_code
	and		sgs.general_code = 'ADJC'
	and		sgs.is_active = '1'
	and		sgs.code not in
				(
					select	adjs.adjusment_transaction_code
					from	dbo.adjustment_detail adjs
							inner join dbo.adjustment adj on (adj.code = adjs.adjustment_code)
					where	adj.company_code = @p_company_code
							and adjs.adjustment_code = @p_adjustment_code
				)
			and (
					sgs.code				like '%' + @p_keywords + '%'
					or	sgs.description		like '%' + @p_keywords + '%'
				) ;

	select	sgs.code
			,sgs.description
			,@rows_count 'rowcount'
	from	dbo.sys_general_subcode sgs
			inner join dbo.sys_general_code sgc on (sgc.code = sgs.general_code)
	where	sgs.company_code = @p_company_code
	and		sgs.general_code = 'ADJC'
	and		sgs.is_active = '1'
	and		sgs.code not in
			(
				select	adjs.adjusment_transaction_code
				from	dbo.adjustment_detail adjs
						inner join dbo.adjustment adj on (adj.code = adjs.adjustment_code)
				where	adj.company_code = @p_company_code
						and adjs.adjustment_code = @p_adjustment_code
			)
	and		(
				sgs.code				like '%' + @p_keywords + '%'
				or	sgs.description		like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sgs.code
													 when 2 then sgs.description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then sgs.code
														when 2 then sgs.description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
