create procedure dbo.xsp_agreement_deposit_main_lookup
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_agreement_no		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.agreement_deposit_main dm
	where	dm.agreement_no		= case @p_agreement_no
									when '' then dm.agreement_no
									else @p_agreement_no
								  end
			and dm.deposit_amount > 0
			and (
					dm.deposit_type			like '%' + @p_keywords + '%'
					or	deposit_amount		like '%' + @p_keywords + '%'
			) ;

		select		code
					,dm.branch_code
					,dm.branch_name
					,dm.agreement_no
					,dm.deposit_type
					,deposit_currency_code
					,deposit_amount	
					,@rows_count 'rowcount'
		from		dbo.agreement_deposit_main dm
		where		dm.agreement_no		= case @p_agreement_no
											when '' then dm.agreement_no
											else @p_agreement_no
										  end
					and dm.deposit_amount > 0
					and	(
							dm.deposit_type			like '%' + @p_keywords + '%'
							or	deposit_amount		like '%' + @p_keywords + '%'
					)
		group by	code
					,dm.branch_code
					,dm.branch_name
					,dm.agreement_no
					,dm.deposit_type
					,deposit_currency_code
					,deposit_amount	
		order by	case when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then deposit_amount
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then deposit_amount
												   end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
