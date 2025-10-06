CREATE PROCEDURE dbo.xsp_cashier_banknote_and_coin_getrows
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
	from	cashier_banknote_and_coin cbac
			inner join master_banknote_and_coin mbac on (mbac.code = cbac.banknote_code)
	where	cbac.cashier_code = @p_cashier_code
			and (
					mbac.description	  like 	'%'+@p_keywords+'%'
					or mbac.type		  like 	'%'+@p_keywords+'%'
					or mbac.value_amount  like 	'%'+@p_keywords+'%'
					or cbac.quantity	  like 	'%'+@p_keywords+'%'
					or cbac.total_amount  like 	'%'+@p_keywords+'%'
				) ;

		select		id
					,mbac.description
					,mbac.type		
					,mbac.value_amount
					,cbac.quantity	 
					,cbac.total_amount 
					,@rows_count 'rowcount'
		from		cashier_banknote_and_coin cbac
					inner join master_banknote_and_coin mbac on (mbac.code = cbac.banknote_code)
		where		cbac.cashier_code = @p_cashier_code
					and (
							mbac.description	  like 	'%'+@p_keywords+'%'
							or mbac.type		  like 	'%'+@p_keywords+'%'
							or mbac.value_amount  like 	'%'+@p_keywords+'%'
							or cbac.quantity	  like 	'%'+@p_keywords+'%'
							or cbac.total_amount  like 	'%'+@p_keywords+'%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mbac.description
														when 2 then mbac.type		
														when 3 then	cast(mbac.value_amount as sql_variant)
														when 4 then	cast(cbac.quantity as sql_variant)	 
														when 5 then	cast(cbac.total_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mbac.description
														when 2 then mbac.type		
														when 3 then	cast(mbac.value_amount as sql_variant)
														when 4 then	cast(cbac.quantity as sql_variant)	 
														when 5 then	cast(cbac.total_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

