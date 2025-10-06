CREATE PROCEDURE [dbo].[xsp_register_main_getrows_for_asset]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	register_main 
	where	fa_code = @p_asset_code
	and(
					code											like '%' + @p_keywords + '%'
					or	convert(varchar(30), register_date, 103)	like '%' + @p_keywords + '%'
					or	register_status								like '%' + @p_keywords + '%'
					or	register_remarks							like '%' + @p_keywords + '%'
					or	public_service_settlement_amount			like '%' + @p_keywords + '%'
				) ;

		select		code
					,convert(varchar(30), register_date, 103) 'register_date'		
					,register_status
					,register_remarks
					,public_service_settlement_amount + (realization_service_fee * realization_service_tax_ppn_pct / 100) - (realization_service_fee * realization_service_tax_pph_pct / 100) 'public_service_settlement_amount'
					,@rows_count 'rowcount'
		from		register_main
		where		fa_code = @p_asset_code
		and(
							code											like '%' + @p_keywords + '%'
							or	convert(varchar(30), register_date, 103)	like '%' + @p_keywords + '%'
							or	register_status								like '%' + @p_keywords + '%'
							or	register_remarks							like '%' + @p_keywords + '%'
							or	public_service_settlement_amount			like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then cast(register_date as sql_variant)
													when 3 then register_status
													when 4 then cast(public_service_settlement_amount as sql_variant)
													when 5 then register_remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then cast(register_date as sql_variant)
													when 3 then register_status
													when 4 then cast(public_service_settlement_amount as sql_variant)
													when 5 then register_remarks
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
