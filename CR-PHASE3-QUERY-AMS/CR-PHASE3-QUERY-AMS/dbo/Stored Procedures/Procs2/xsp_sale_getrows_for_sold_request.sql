
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_sale_getrows_for_sold_request]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(20)
	,@p_sell_type		nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	sale sl
	outer apply(SELECT sum(sd.sell_request_amount) 'sell_request_amount', count(id) 'id' from dbo.SALE_DETAIL sd where sd.SALE_CODE = sl.code) sale_detail
	where	sl.branch_code = case @p_branch_code
								when 'ALL' then sl.branch_code
								else @p_branch_code
							end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		sl.sell_type = case @p_sell_type
						when 'ALL' then sl.sell_type
						else @p_sell_type
					end
	and		sl.company_code = @p_company_code
	and		(
				sl.code														like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sale_date, 103)					like '%' + @p_keywords + '%'
				or	sl.branch_name											like '%' + @p_keywords + '%'
				or	status													like '%' + @p_keywords + '%'
				or	sl.remark												like '%' + @p_keywords + '%'
				or	case when sl.sell_type = 'COP' then 'PURCHASE REQUIREMENT AFTER LEASE'
						else sl.sell_type
					end 													like '%' + @p_keywords + '%'
				or	sale_detail.sell_request_amount							like '%' + @p_keywords + '%'
				or	sale_detail.id											like '%' + @p_keywords + '%'
				or	sl.buyer_name											like '%' + @p_keywords + '%'
			) ;

	select	sl.code
			,sl.company_code
			,convert(nvarchar(30), sale_date, 103) 'sale_date'
			,sl.description
			,sl.branch_code
			,sl.branch_name
			,sale_amount
			,remark
			,status
			,CASE WHEN sl.sell_type = 'COP' THEN 'PURCHASE REQUIREMENT AFTER LEASE'
				ELSE SL.SELL_TYPE
				END 'sell_type'
			--,sl.sell_type
			,sale_detail.sell_request_amount
			,sale_detail.id
			,sl.buyer_name
			,@rows_count 'rowcount'
	from	sale sl
	outer apply(SELECT sum(sd.sell_request_amount) 'sell_request_amount', count(id) 'id' from dbo.SALE_DETAIL sd where sd.SALE_CODE = sl.code) sale_detail
	where	sl.branch_code = case @p_branch_code
								when 'ALL' then sl.branch_code
								else @p_branch_code
							end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		sl.sell_type = case @p_sell_type
						when 'ALL' then sl.sell_type
						else @p_sell_type
					end
	and		sl.company_code = @p_company_code
	and		(
				sl.code														like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sale_date, 103)					like '%' + @p_keywords + '%'
				or	sl.branch_name											like '%' + @p_keywords + '%'
				or	sale_detail.sell_request_amount							like '%' + @p_keywords + '%'
				or	sale_detail.id											like '%' + @p_keywords + '%'
				or	status													like '%' + @p_keywords + '%'
				or	sl.remark												like '%' + @p_keywords + '%'
				--or	sl.sell_type										like '%' + @p_keywords + '%'
				or	case when sl.sell_type = 'COP' then 'PURCHASE REQUIREMENT AFTER LEASE'
						else sl.sell_type
					end														like '%' + @p_keywords + '%'
				or	sl.buyer_name											like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then sl.code
												when 2 then sl.branch_name
												when 3 then cast(sale_date as sql_variant)
												when 4 then cast(sale_detail.sell_request_amount as sql_variant)
												when 5 then sell_type--sl.sell_type
												when 6 then sl.remark
												when 7 then status
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
												when 1 then sl.code
												when 2 then sl.branch_name
												when 3 then cast(sale_date as sql_variant)
												when 4 then cast(sale_detail.sell_request_amount as sql_variant)
												when 5 then sell_type--sl.sell_type
												when 6 then sl.remark
												when 7 then status
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
