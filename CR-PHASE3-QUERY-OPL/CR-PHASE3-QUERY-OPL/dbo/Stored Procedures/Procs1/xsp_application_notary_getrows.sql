CREATE PROCEDURE dbo.xsp_application_notary_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_notary an
	where	application_no = @p_application_no
			and (
					notary_service_name			like '%' + @p_keywords + '%'
					or	an.fee_admin_amount		like '%' + @p_keywords + '%'
					or	an.fee_bnbp_amount		like '%' + @p_keywords + '%'
					or	an.notary_fee_amount	like '%' + @p_keywords + '%'
					or	an.total_notary_amount	like '%' + @p_keywords + '%'
					or	an.remarks				like '%' + @p_keywords + '%'
					or	an.currency_code		like '%' + @p_keywords + '%'
				) ;
				 
		select		id
					,an.notary_service_name
					,an.fee_admin_amount
					,an.fee_bnbp_amount
					,an.notary_fee_amount
					,an.total_notary_amount
					,an.remarks
					,an.currency_code
					,@rows_count 'rowcount'
		from		application_notary an
		where		application_no = @p_application_no
					and (
							an.notary_service_name		like '%' + @p_keywords + '%'
							or	an.fee_admin_amount		like '%' + @p_keywords + '%'
							or	an.fee_bnbp_amount		like '%' + @p_keywords + '%'
							or	an.notary_fee_amount	like '%' + @p_keywords + '%'
							or	an.total_notary_amount	like '%' + @p_keywords + '%'
							or	an.remarks				like '%' + @p_keywords + '%'
							or	an.currency_code		like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then an.notary_service_name
													when 2 then an.currency_code
													when 3 then cast(an.fee_admin_amount as sql_variant)
													when 4 then cast(an.fee_bnbp_amount as sql_variant)
													when 5 then cast(an.notary_fee_amount as sql_variant)
													when 6 then cast(an.total_notary_amount as sql_variant)
													when 7 then an.remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then an.notary_service_name
													when 2 then an.currency_code
													when 3 then cast(an.fee_admin_amount as sql_variant)
													when 4 then cast(an.fee_bnbp_amount as sql_variant)
													when 5 then cast(an.notary_fee_amount as sql_variant)
													when 6 then cast(an.total_notary_amount as sql_variant)
													when 7 then an.remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

