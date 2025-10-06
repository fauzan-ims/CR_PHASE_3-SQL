CREATE PROCEDURE dbo.xsp_bank_mutation_history_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_bank_mutation_code	nvarchar(50)
	,@p_from_date			datetime
	,@p_to_date				datetime
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	bank_mutation_history
	where	bank_mutation_code	=	@p_bank_mutation_code
			and cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
			and	(
					convert(varchar(30), value_date, 103)	like '%' + @p_keywords + '%'
					or	source_reff_code					like '%' + @p_keywords + '%'
					or	source_reff_name					like '%' + @p_keywords + '%'
					or	orig_amount							like '%' + @p_keywords + '%'
					or	orig_currency_code					like '%' + @p_keywords + '%'
					or	exch_rate							like '%' + @p_keywords + '%'
					or	remarks								like '%' + @p_keywords + '%'
					or	base_amount							like '%' + @p_keywords + '%'
					or	case is_reconcile
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		id
					,bank_mutation_code
					,convert(varchar(30), value_date, 103) 'value_date'
					,source_reff_code
					,source_reff_name
					,orig_amount
					,orig_currency_code
					,exch_rate
					,remarks
					,base_amount
					,case is_reconcile
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_reconcile'
					,@rows_count 'rowcount'
		from		bank_mutation_history
		where		bank_mutation_code	=	@p_bank_mutation_code
					and cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
					and	(
							convert(varchar(30), value_date, 103)	like '%' + @p_keywords + '%'
							or	source_reff_code					like '%' + @p_keywords + '%'
							or	source_reff_name					like '%' + @p_keywords + '%'
							or	orig_amount							like '%' + @p_keywords + '%'
							or	orig_currency_code					like '%' + @p_keywords + '%'
							or	exch_rate							like '%' + @p_keywords + '%'
							or	base_amount							like '%' + @p_keywords + '%'
							or	remarks								like '%' + @p_keywords + '%'
							or	case is_reconcile
								when '1' then 'Yes'
								else 'No'
							end										like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then cast(value_date as sql_variant)
						when 2 then source_reff_code
						when 3 then cast(orig_amount as sql_variant)
						when 4 then orig_currency_code
						when 5 then cast(base_amount as sql_variant)
						when 6 then remarks
						when 7 then is_reconcile
					end asc, 
					case @p_order_by
						when 1 then cast(id as sql_variant)
					END desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		id
					,bank_mutation_code
					,convert(varchar(30), value_date, 103) 'value_date'
					,source_reff_code
					,source_reff_name
					,orig_amount
					,orig_currency_code
					,exch_rate
					,base_amount
					,remarks
					,case is_reconcile
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_reconcile'
					,@rows_count 'rowcount'
		from		bank_mutation_history
		where		bank_mutation_code	=	@p_bank_mutation_code
					and cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date) 
					and	(
							convert(varchar(30), value_date, 103)	like '%' + @p_keywords + '%'
							or	source_reff_code					like '%' + @p_keywords + '%'
							or	source_reff_name					like '%' + @p_keywords + '%'
							or	orig_amount							like '%' + @p_keywords + '%'
							or	orig_currency_code					like '%' + @p_keywords + '%'
							or	exch_rate							like '%' + @p_keywords + '%'
							or	remarks								like '%' + @p_keywords + '%'
							or	base_amount							like '%' + @p_keywords + '%'
							or	case is_reconcile
								when '1' then 'Yes'
								else 'No'
							end										like '%' + @p_keywords + '%'
						)
		order by	case @p_order_by
						when 1 then cast(value_date as sql_variant)
						when 2 then source_reff_code
						when 3 then cast(orig_amount as sql_variant)
						when 4 then orig_currency_code
						when 5 then cast(base_amount as sql_variant)
						when 6 then remarks
						when 7 then is_reconcile
					end desc, 
					case @p_order_by
						when 1 then cast(id as sql_variant)
					END desc
					offset  ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
