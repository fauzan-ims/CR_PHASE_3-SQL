CREATE PROCEDURE dbo.xsp_receipt_main_lookup_for_cashier_receipt_allocated
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_cashier_code nvarchar(50)
	,@p_branch_code	 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	receipt_main rm
	where	not exists
			(
				select	cra.receipt_code
				from	cashier_receipt_allocated cra
				where	cra.receipt_code	 = rm.code
						and cra.cashier_code = @p_cashier_code
			)
			and branch_code		= case @p_branch_code
							  			when 'ALL' then branch_code
							  			else @p_branch_code
								  end
			and rm.receipt_status = 'NEW'
			and isnull(rm.cashier_code,'') = ''
			and (
					rm.receipt_no			like '%' + @p_keywords + '%'
				) ;

		select		code
					,receipt_no
					,@rows_count 'rowcount'
		from		receipt_main rm
		where		not exists
					(
						select	cra.receipt_code
						from	cashier_receipt_allocated cra
						where	cra.receipt_code	 = rm.code
								and cra.cashier_code = @p_cashier_code
					)
					and branch_code		= case @p_branch_code
							  					when 'ALL' then branch_code
							  					else @p_branch_code
										  end
					and rm.receipt_status = 'NEW'
					and isnull(rm.cashier_code,'') = ''
					and (
							rm.receipt_no			like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then receipt_no
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then receipt_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
