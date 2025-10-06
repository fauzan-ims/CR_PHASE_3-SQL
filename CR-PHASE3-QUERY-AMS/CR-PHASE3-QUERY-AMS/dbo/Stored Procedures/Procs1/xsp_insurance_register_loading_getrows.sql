CREATE PROCEDURE dbo.xsp_insurance_register_loading_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_register_loading irl
			inner join dbo.master_coverage_loading mcl on (mcl.code = irl.loading_code)
	where	register_code = @p_register_code
			and (							 
					mcl.loading_name			like '%' + @p_keywords + '%'
					or irl.year_period			like '%' + @p_keywords + '%'
					or irl.total_buy_amount		like '%' + @p_keywords + '%'
					or irl.total_sell_amount	like '%' + @p_keywords + '%'
				) ;

		select		irl.id
					,mcl.loading_name
					,irl.year_period		
					,irl.total_buy_amount	
					,irl.total_sell_amount
					,@rows_count 'rowcount'
		from		insurance_register_loading irl
					inner join dbo.master_coverage_loading mcl on (mcl.code = irl.loading_code)
		where		register_code = @p_register_code
					and (
							mcl.loading_name			like '%' + @p_keywords + '%'
							or irl.year_period			like '%' + @p_keywords + '%'
							or irl.total_buy_amount		like '%' + @p_keywords + '%'
							or irl.total_sell_amount	like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then irl.year_period	 
													when 2 then mcl.loading_name
													when 3 then cast(irl.total_buy_amount as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then irl.year_period	 
													when 2 then mcl.loading_name
													when 3 then cast(irl.total_buy_amount as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

