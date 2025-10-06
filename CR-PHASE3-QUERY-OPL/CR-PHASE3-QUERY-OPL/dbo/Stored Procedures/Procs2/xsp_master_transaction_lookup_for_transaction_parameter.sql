CREATE PROCEDURE dbo.xsp_master_transaction_lookup_for_transaction_parameter
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_process_code			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_transaction
	where	is_active='1'
	--and		code not in (
	--							select	transaction_code
	--							from	dbo.master_transaction_parameter
	--							where	process_code	= @p_process_code
	--					)
	and		(
				code							like '%' + @p_keywords + '%'
				or	transaction_name			like '%' + @p_keywords + '%'
			) ;

		select	code
				,transaction_name
				,@rows_count 'rowcount'
		from	dbo.master_transaction
		where	is_active='1'
		--and		code not in (
		--							select	transaction_code
		--							from	dbo.master_transaction_parameter
		--							where	process_code	= @p_process_code
		--					)
		and		(
					code							like '%' + @p_keywords + '%'
					or	transaction_name			like '%' + @p_keywords + '%'
				) 
		order by case	
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then transaction_name
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code
															when 2 then transaction_name
														 end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
