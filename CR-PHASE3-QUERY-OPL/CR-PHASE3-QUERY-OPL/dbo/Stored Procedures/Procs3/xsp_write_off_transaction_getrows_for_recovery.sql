CREATE PROCEDURE [dbo].[xsp_write_off_transaction_getrows_for_recovery]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_wo_code			nvarchar(50)
	,@p_is_transaction	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	write_off_transaction wot
			inner join dbo.master_transaction mt on (mt.code = wot.transaction_code)
	where	wot.wo_code				= @p_wo_code
	and		wot.is_transaction		= @p_is_transaction
	--and		wot.transaction_code	= 'DOUBFUL'
	and		(
				mt.transaction_name			like '%' + @p_keywords + '%'
				or	transaction_amount		like '%' + @p_keywords + '%'
			) ;

	select	wot.id
			,mt.transaction_name
			,wot.transaction_amount
			,wot.transaction_code
			,@rows_count 'rowcount'
	from	write_off_transaction wot
			inner join dbo.master_transaction mt on (mt.code = wot.transaction_code)
	where	wot.wo_code				= @p_wo_code
	and		wot.is_transaction		= @p_is_transaction
	--and		wot.transaction_code	= 'DOUBFUL'
	and		(
				mt.transaction_name			like '%' + @p_keywords + '%'
				or	wot.transaction_amount	like '%' + @p_keywords + '%'
			)
	order by	case
					WHEN @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then mt.transaction_name
													when 2 then cast(wot.transaction_amount as sql_variant)
												end 
											end asc,
												
								case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then mt.transaction_name
													when 2 then cast(wot.transaction_amount as sql_variant)
												end 
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

