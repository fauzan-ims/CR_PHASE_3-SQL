create procedure dbo.xsp_master_account_payable_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_account_payable 
	where	(
					ap_code					    like '%' + @p_keywords + '%'
					or	remarks				    like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
				) ;

		select		code
                    ,ap_code
                    ,remarks
                    ,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_account_payable 
		where		(
						ap_code					    like '%' + @p_keywords + '%'
						or	remarks				    like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ap_code
														when 2 then remarks
														when 3 then is_active
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ap_code
														when 2 then remarks
														when 3 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
