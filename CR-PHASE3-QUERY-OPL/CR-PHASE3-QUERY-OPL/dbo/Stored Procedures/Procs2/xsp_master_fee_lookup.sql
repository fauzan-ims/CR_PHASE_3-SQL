CREATE PROCEDURE dbo.xsp_master_fee_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	-- untuk mengambil fee amount harus menggunakan facility dan currency code
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_fee mf 
	where	is_active = '1'
			and mf.is_calculated = '0'
			and (
					mf.code				like '%' + @p_keywords + '%'
					or	mf.description	like '%' + @p_keywords + '%'
				) ;
				 
		select		mf.code
					,mf.description 
					,@rows_count 'rowcount'
		from		master_fee mf 
		where		is_active = '1'
					and mf.is_calculated = '0'
					and (
							mf.code				like '%' + @p_keywords + '%'
							or	mf.description	like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mf.code
													when 2 then mf.description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mf.code
													when 2 then mf.description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
