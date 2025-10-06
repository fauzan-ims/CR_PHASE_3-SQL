CREATE PROCEDURE dbo.xsp_endorsement_period_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_endorsement_code nvarchar(50)
	,@p_old_or_new		 nvarchar(3)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	endorsement_period ep
			inner join dbo.master_coverage mc on (mc.code = ep.coverage_code)
	where	ep.endorsement_code = @p_endorsement_code
			and ep.old_or_new   = @p_old_or_new
			and (
					mc.coverage_name			like '%' + @p_keywords + '%'
					or	ep.year_period			like '%' + @p_keywords + '%'
					or	ep.initial_buy_amount	like '%' + @p_keywords + '%'
					or	ep.initial_sell_amount	like '%' + @p_keywords + '%'
					or	ep.remain_buy			like '%' + @p_keywords + '%'
					or	ep.remain_sell			like '%' + @p_keywords + '%'
				) ;

		select		ep.id
					,mc.coverage_name		
					,ep.year_period			
					,ep.initial_buy_amount	
					,ep.initial_sell_amount	
					,ep.remain_buy			
					,ep.remain_sell			
					,@rows_count 'rowcount'
		from		endorsement_period ep
					inner join dbo.master_coverage mc on (mc.code = ep.coverage_code)
		where		ep.endorsement_code = @p_endorsement_code
					and ep.old_or_new   = @p_old_or_new
					and (
							mc.coverage_name			like '%' + @p_keywords + '%'
							or	ep.year_period			like '%' + @p_keywords + '%'
							or	ep.initial_buy_amount	like '%' + @p_keywords + '%'
							or	ep.initial_sell_amount	like '%' + @p_keywords + '%'
							or	ep.remain_buy			like '%' + @p_keywords + '%'
							or	ep.remain_sell			like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mc.coverage_name		
													when 2 then cast(ep.year_period  as sql_variant)		
													when 3 then cast(ep.initial_buy_amount  as sql_variant)	
													when 4 then cast(ep.remain_buy  as sql_variant)	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mc.coverage_name		
													when 2 then cast(ep.year_period  as sql_variant)		
													when 3 then cast(ep.initial_buy_amount  as sql_variant)	
													when 4 then cast(ep.remain_buy  as sql_variant)	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

