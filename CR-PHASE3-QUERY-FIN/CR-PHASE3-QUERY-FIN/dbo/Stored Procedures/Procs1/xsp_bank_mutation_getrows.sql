CREATE PROCEDURE dbo.xsp_bank_mutation_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	--if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	--begin	--	set @p_branch_code = 'ALL'	--end

	select	@rows_count = count(1)
	from	bank_mutation bm
			left join dbo.journal_gl_link jgl on (jgl.code = bm.gl_link_code)
	where	branch_code	 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
			and (
					branch_name				like '%' + @p_keywords + '%'
					or	branch_bank_name	like '%' + @p_keywords + '%'
					or	balance_amount		like '%' + @p_keywords + '%'
				) ;

		select		bm.code
					,branch_name
					,branch_bank_name 'gl_link_name'
					,balance_amount
					,@rows_count 'rowcount'
		from		bank_mutation bm
					left join dbo.journal_gl_link jgl on (jgl.code = bm.gl_link_code)
		where		branch_code	 = case @p_branch_code
											   when 'ALL' then branch_code
											   else @p_branch_code
										   end
					and (
							branch_name				like '%' + @p_keywords + '%'
							or	branch_bank_name	like '%' + @p_keywords + '%'
							or	balance_amount		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then bm.branch_name
														when 2 then bm.branch_bank_name
														when 3 then cast(bm.balance_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then bm.branch_name
														when 2 then bm.branch_bank_name
														when 3 then cast(bm.balance_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
