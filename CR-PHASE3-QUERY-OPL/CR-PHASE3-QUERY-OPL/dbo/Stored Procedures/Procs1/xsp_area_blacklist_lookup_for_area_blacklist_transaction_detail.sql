--created by, Rian at 16/05/2023 

CREATE procedure dbo.xsp_area_blacklist_lookup_for_area_blacklist_transaction_detail
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_area_blacklist_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	area_blacklist ab
	where	is_active = '1'
			and not exists (
								select	1
								from	dbo.area_blacklist_transaction_detail abtd
								where	abtd.area_blacklist_transaction_code = @p_area_blacklist_transaction_code
										and abtd.zip_code_code = ab.zip_code_code
							)
			and (
					ab.postal_code			like '%' + @p_keywords + '%'
					or	ab.zip_code_name	like '%' + @p_keywords + '%'
				) ;

		select		ab.postal_code
					,ab.zip_code_code
					,ab.zip_code_name
					,@rows_count 'rowcount'
		from		area_blacklist ab
		where		is_active = '1'
					and not exists (
										select	1
										from	dbo.area_blacklist_transaction_detail abtd
										where	abtd.area_blacklist_transaction_code = @p_area_blacklist_transaction_code
												and abtd.zip_code_code = ab.zip_code_code
									)
					and (
							ab.postal_code			like '%' + @p_keywords + '%'
							or	ab.zip_code_name	like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ab.postal_code
														when 2 then ab.zip_code_name
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ab.postal_code
														when 2 then ab.zip_code_name
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
