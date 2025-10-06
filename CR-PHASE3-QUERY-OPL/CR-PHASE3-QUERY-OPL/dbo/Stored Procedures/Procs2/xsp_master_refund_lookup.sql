---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_refund_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_facility_code nvarchar(50) = ''
	,@p_currency_code nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_refund mr
			left join master_fee mf on (mf.code = mr.fee_code)
	where	mr.is_active = '1'
			and mr.facility_code	= case @p_facility_code
										when '' then mr.facility_code
										else @p_facility_code
									  end
			and mr.currency_code	= case @p_currency_code
										when '' then mr.currency_code
										else @p_currency_code
									  end
			and (
					mr.code				like '%' + @p_keywords + '%'
					or	mr.description	like '%' + @p_keywords + '%'
				) ;
				 
		select		mr.code
					,mr.description
					,mr.fee_code
					,mf.description 'fee_name'
					,isnull(mr.refund_amount, 0) 'refund_amount'
					,isnull(mr.refund_pct, 0) 'refund_pct'
					,@rows_count 'rowcount'
		from		master_refund mr
					left join master_fee mf on (mf.code = mr.fee_code)
		where		mr.is_active = '1'
					and mr.facility_code	= case @p_facility_code
												when '' then mr.facility_code
												else @p_facility_code
											  end
					and mr.currency_code	= case @p_currency_code
												when '' then mr.currency_code
												else @p_currency_code
											  end
					and (
							mr.code				like '%' + @p_keywords + '%'
							or	mr.description	like '%' + @p_keywords + '%'
						) 
 		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mr.code
													when 2 then mr.description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mr.code
													when 2 then mr.description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

