CREATE PROCEDURE dbo.xsp_cashier_receipt_allocated_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_cashier_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	cashier_receipt_allocated cra
			inner join dbo.receipt_main rm on (rm.code = cra.receipt_code) 
	where	cra.cashier_code = @p_cashier_code
			and (
					rm.receipt_no																		like'%'+@p_keywords+'%'
					or	cra.receipt_status																like'%'+@p_keywords+'%'
					or	Format(cast(cra.receipt_use_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like'%'+@p_keywords+'%'
					or	cra.receipt_use_trx_code														like'%'+@p_keywords+'%'
				) ;

		select		id
					,rm.receipt_no					
					,cra.receipt_status								
					,Format(cast(cra.receipt_use_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'receipt_use_date'
					,cra.receipt_use_trx_code					
					,@rows_count 'rowcount'
		from		cashier_receipt_allocated cra
					inner join dbo.receipt_main rm on (rm.code = cra.receipt_code) 
		where		cra.cashier_code = @p_cashier_code
					and (
							rm.receipt_no																		like'%'+@p_keywords+'%'
							or	cra.receipt_status																like'%'+@p_keywords+'%'
							or	Format(cast(cra.receipt_use_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like'%'+@p_keywords+'%'
							or	cra.receipt_use_trx_code														like'%'+@p_keywords+'%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rm.receipt_no
														when 2 then cra.receipt_use_trx_code	
														when 3 then convert(varchar(30), cra.receipt_use_date, 103)	
														when 4 then cra.receipt_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rm.receipt_no
														when 2 then cra.receipt_use_trx_code	
														when 3 then convert(varchar(30), cra.receipt_use_date, 103)	
														when 4 then cra.receipt_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
