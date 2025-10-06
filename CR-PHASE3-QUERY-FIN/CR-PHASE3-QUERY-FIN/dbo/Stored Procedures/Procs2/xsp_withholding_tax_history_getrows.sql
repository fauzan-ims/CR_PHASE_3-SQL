CREATE PROCEDURE dbo.xsp_withholding_tax_history_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_tax_file_no			nvarchar(50)
	,@p_from_date			datetime
	,@p_to_date				datetime
	,@p_branch_code			nvarchar(50)
	,@p_tax_file_name		nvarchar(250)

)
as
begin
	declare @rows_count int = 0;

	if exists	(					select	1
					from	sys_global_param
					where	code	  = 'HO'
							and value = @p_branch_code				)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from		withholding_tax_history wth
					outer apply (	
							select	sum(wt.payment_amount) accumulate 
							from	dbo.withholding_tax_history wt 
							where	tax_file_no	 = @p_tax_file_no
									and cast(wt.payment_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						) acc
		where		tax_file_no = case @p_tax_file_no
									   when '' then tax_file_no
									   else @p_tax_file_no
								   end
					and cast(wth.payment_date as date)  between cast(@p_from_date as date) and cast(@p_to_date as date)
					and wth.branch_code = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
					--and tax_file_name = case @p_tax_file_name
					--				   when '' then tax_file_name
					--				   else @p_tax_file_name
					--			   end
			and (
					branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), payment_date, 103) like '%' + @p_keywords + '%'
					or	payment_amount							like '%' + @p_keywords + '%'
					or	tax_payer_reff_code						like '%' + @p_keywords + '%'
					or	tax_type								like '%' + @p_keywords + '%'
					or	tax_file_no								like '%' + @p_keywords + '%'
					or	tax_file_name							like '%' + @p_keywords + '%'
					or	tax_pct									like '%' + @p_keywords + '%'
					or	tax_amount								like '%' + @p_keywords + '%'
					or	remark									like '%' + @p_keywords + '%'
					or	acc.accumulate							like '%' + @p_keywords + '%'

				) ;

		select		id
					,branch_name
					,convert(varchar(30), payment_date, 103) 'payment_date' 
					,payment_amount							
					,tax_payer_reff_code						
					,tax_type								
					,tax_file_no								
					,tax_file_name
					,tax_amount
					,tax_pct							
					,remark
					,acc.accumulate
					,@rows_count 'rowcount'
		from		withholding_tax_history wth
					outer apply (	
							select	sum(wt.payment_amount) accumulate 
							from	dbo.withholding_tax_history wt 
							where	tax_file_no	 = @p_tax_file_no
									and cast(wt.payment_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						) acc
		where		tax_file_no = case @p_tax_file_no
									   when '' then tax_file_no
									   else @p_tax_file_no
								   end
					and cast(wth.payment_date as date)  between cast(@p_from_date as date) and cast(@p_to_date as date)
					and wth.branch_code = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
					--and tax_file_name = case @p_tax_file_name
					--				   when '' then tax_file_name
					--				   else @p_tax_file_name
					--			   end
					and (
							branch_name									like '%' + @p_keywords + '%'
							or	convert(varchar(30), payment_date, 103) like '%' + @p_keywords + '%'
							or	payment_amount							like '%' + @p_keywords + '%'
							or	tax_payer_reff_code						like '%' + @p_keywords + '%'
							or	tax_type								like '%' + @p_keywords + '%'
							or	tax_file_no								like '%' + @p_keywords + '%'
							or	tax_file_name							like '%' + @p_keywords + '%'
							or	tax_pct									like '%' + @p_keywords + '%'
							or	tax_amount								like '%' + @p_keywords + '%'
							or	remark									like '%' + @p_keywords + '%'
							or	acc.accumulate							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then branch_name
														when 2 then cast(payment_date as sql_variant)
														when 3 then tax_type + tax_payer_reff_code
														when 4 then remark
														when 5 then cast(payment_amount as sql_variant)
														when 6 then cast(acc.accumulate as sql_variant)
														when 7 then cast(tax_pct as sql_variant)
														when 8 then cast(tax_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then branch_name
														when 2 then cast(payment_date as sql_variant)
														when 3 then tax_type + tax_payer_reff_code
														when 4 then remark
														when 5 then cast(payment_amount as sql_variant)
														when 6 then cast(acc.accumulate as sql_variant)
														when 7 then cast(tax_pct as sql_variant)
														when 8 then cast(tax_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

