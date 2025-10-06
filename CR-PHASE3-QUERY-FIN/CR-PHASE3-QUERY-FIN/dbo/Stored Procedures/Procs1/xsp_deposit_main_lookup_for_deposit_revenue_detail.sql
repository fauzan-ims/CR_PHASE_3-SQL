CREATE PROCEDURE dbo.xsp_deposit_main_lookup_for_deposit_revenue_detail
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_currency_code		 nvarchar(3)
	,@p_agreement_no		 nvarchar(50)
	,@p_deposit_revenue_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	deposit_main dm
	where	not exists
			(
				select	drd.deposit_code
				from	dbo.deposit_revenue_detail drd
				where	drd.deposit_code			  = dm.code
						and drd.deposit_revenue_code = @p_deposit_revenue_code
			)
			and dm.deposit_currency_code	= @p_currency_code
			and isnull(dm.agreement_no,'')	= isnull(@p_agreement_no,'')
			and isnull(transaction_code,'') = ''
			and deposit_amount > 0
			and (
					dm.deposit_currency_code 	like '%' + @p_keywords + '%'
					or dm.deposit_type			like '%' + @p_keywords + '%'
					or dm.deposit_amount		like '%' + @p_keywords + '%'
				) ;

		select		dm.code
					,dm.agreement_no
					,dm.deposit_type
					,dm.deposit_amount	
					,dm.deposit_currency_code
					,@rows_count 'rowcount'
		from		deposit_main dm
		where		not exists
					(
						select	drd.deposit_code
						from	dbo.deposit_revenue_detail drd
						where	drd.deposit_code			 = dm.code
								and drd.deposit_revenue_code = @p_deposit_revenue_code
					)
					and dm.deposit_currency_code	= @p_currency_code
					and isnull(dm.agreement_no,'')	= isnull(@p_agreement_no,'')
					and isnull(transaction_code,'') = ''
					and deposit_amount > 0
					and (
							dm.deposit_currency_code 	like '%' + @p_keywords + '%'
							or dm.deposit_type			like '%' + @p_keywords + '%'
							or dm.deposit_amount		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then dm.deposit_currency_code
														when 3 then cast(dm.deposit_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then dm.deposit_currency_code
														when 3 then cast(dm.deposit_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
