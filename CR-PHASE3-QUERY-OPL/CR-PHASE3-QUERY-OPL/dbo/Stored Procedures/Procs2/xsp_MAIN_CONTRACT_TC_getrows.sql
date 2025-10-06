
-- Louis Selasa, 30 April 2024 18.54.48 --
CREATE PROCEDURE [dbo].[xsp_MAIN_CONTRACT_TC_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_main_contract_no	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.MAIN_CONTRACT_TC
	where	main_contract_no = @p_main_contract_no
			and (
					main_contract_no	like '%' + @p_keywords + '%'
					or	description	like '%' + @p_keywords + '%' 
				) 

	select		id
			   ,main_contract_no
			   ,description
			   ,@rows_count 'rowcount'
	from		dbo.MAIN_CONTRACT_TC
	where		main_contract_no = @p_main_contract_no
				and (
						main_contract_no	like '%' + @p_keywords + '%'
						or	description	like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then main_contract_no
														when 2 then description
													end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then main_contract_no
														when 2 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
