CREATE PROCEDURE dbo.xsp_journal_gl_link_lookup_for_voucher
(
	@p_keywords	   NVARCHAR(50)
	,@p_pagenumber INT
	,@p_rowspage   INT
	,@p_order_by   INT
	,@p_sort_by	   NVARCHAR(5)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	SELECT	@rows_count = COUNT(1)
	FROM	dbo.journal_gl_link
	WHERE	
			--code NOT IN (
			--				SELECT	gl_link_code 
			--				FROM	dbo.master_transaction
			--			)
			
			--and 
			is_bank		= '0'
			and		is_active	= '1'
			and		(
						gl_link_name			like '%' + @p_keywords + '%'
					) ;

		select	code
				,gl_link_name
				,is_provit_or_cost
				,@rows_count 'rowcount'
		from	dbo.journal_gl_link
		where	
				--code not in (
				--				select	gl_link_code 
				--				from	dbo.master_transaction
				--			)
				--and 
				is_bank		= '0'
				and	is_active	= '1'
				and	(
						gl_link_name				like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then gl_link_name
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then gl_link_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
