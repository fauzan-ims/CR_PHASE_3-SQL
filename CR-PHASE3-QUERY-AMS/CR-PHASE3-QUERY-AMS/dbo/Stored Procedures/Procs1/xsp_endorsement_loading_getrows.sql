CREATE PROCEDURE dbo.xsp_endorsement_loading_getrows
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
	from	endorsement_loading el
			inner join dbo.master_coverage_loading mcl on (mcl.code = el.loading_code)
	where	el.endorsement_code = @p_endorsement_code
			and el.old_or_new   = @p_old_or_new
			and (
					mcl.loading_name			like '%' + @p_keywords + '%'
					or	el.year_period			like '%' + @p_keywords + '%'
					or	el.initial_buy_amount	like '%' + @p_keywords + '%'
					or	el.initial_sell_amount	like '%' + @p_keywords + '%'
					or	el.remain_buy			like '%' + @p_keywords + '%'
					or	el.remain_sell			like '%' + @p_keywords + '%'
				) ; 
		select		el.id
					,mcl.loading_name
					,el.year_period
					,el.initial_buy_amount
					,el.initial_sell_amount
					,el.remain_buy
					,el.remain_sell
					,@rows_count 'rowcount'
		from		endorsement_loading el
					inner join dbo.master_coverage_loading mcl on (mcl.code = el.loading_code)
		where		el.endorsement_code = @p_endorsement_code
					and el.old_or_new   = @p_old_or_new
					and (
							mcl.loading_name			like '%' + @p_keywords + '%'
							or	el.year_period			like '%' + @p_keywords + '%'
							or	el.initial_buy_amount	like '%' + @p_keywords + '%'
							or	el.initial_sell_amount	like '%' + @p_keywords + '%'
							or	el.remain_buy			like '%' + @p_keywords + '%'
							or	el.remain_sell			like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mcl.loading_name
													when 2 then try_cast(el.year_period as nvarchar(20))
													when 3 then try_cast(el.initial_buy_amount as nvarchar(20))
													when 4 then try_cast(el.remain_buy as nvarchar(20))
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mcl.loading_name
													when 2 then try_cast(el.year_period as nvarchar(20))
													when 3 then try_cast(el.initial_buy_amount as nvarchar(20))
													when 4 then try_cast(el.remain_buy as nvarchar(20))
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

