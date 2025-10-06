CREATE procedure dbo.xsp_adjustment_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_adjustment_code nvarchar(50)
)
as
begin
	declare @rows_count	   int = 0
			,@company_name nvarchar(50) ;

	select	@rows_count = count(1)
	from	dbo.adjustment_detail			  adl
			inner join dbo.adjustment		  adj on (adj.code					= adl.adjustment_code)
			left join dbo.sys_general_subcode sgs on (
														 sgs.code				= adl.adjusment_transaction_code
														 and   sgs.company_code = adj.company_code
													 )
	where	adjustment_code = @p_adjustment_code
			and
			(
				sgs.description		like '%' + @p_keywords + '%'
				or	adl.amount		like '%' + @p_keywords + '%'
			) ;

	select		adl.id
				,adl.adjustment_code
				,isnull(sgs.description, adl.adjustment_description) 'transcation_type'
				,adl.amount
				,@rows_count										 'rowcount'
	from		dbo.adjustment_detail			  adl
				inner join dbo.adjustment		  adj on (adj.code					= adl.adjustment_code)
				left join dbo.sys_general_subcode sgs on (
															 sgs.code				= adl.adjusment_transaction_code
															 and   sgs.company_code = adj.company_code
														 )
	where		adjustment_code = @p_adjustment_code
				and
				(
					sgs.description		like '%' + @p_keywords + '%'
					or	adl.amount		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 --when 1 then adl.adjustment_code
													 when 1 then sgs.description
													 when 2 then cast(adl.amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   --when 1 then adl.adjustment_code
													   when 1 then sgs.description
													   when 2 then cast(adl.amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
