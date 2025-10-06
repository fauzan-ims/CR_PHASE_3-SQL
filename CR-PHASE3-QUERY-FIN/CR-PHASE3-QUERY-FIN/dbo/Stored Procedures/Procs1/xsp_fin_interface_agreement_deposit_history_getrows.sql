CREATE PROCEDURE dbo.xsp_fin_interface_agreement_deposit_history_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	dbo.fin_interface_agreement_deposit_history dm
			left join dbo.agreement_main am on (am.agreement_no = dm.agreement_no)
	where	dm.branch_code = case @p_branch_code
								 when 'ALL' then dm.branch_code
								 else @p_branch_code
							 end
			and (
					dm.branch_name					like '%' + @p_keywords + '%'
					or	dm.deposit_type				like '%' + @p_keywords + '%'
					or	dm.orig_currency_code		like '%' + @p_keywords + '%'
					or	am.agreement_external_no	like '%' + @p_keywords + '%'
					or	am.client_name				like '%' + @p_keywords + '%'
					or	dm.orig_amount				like '%' + @p_keywords + '%'
				) ;

		select		id
					,dm.branch_name
					,dm.deposit_type			
					,dm.orig_currency_code
					,am.agreement_external_no
					,am.client_name			
					,dm.orig_amount		
					,@rows_count 'rowcount'
		from		fin_interface_agreement_deposit_history dm
					left join dbo.agreement_main am on (am.agreement_no = dm.agreement_no)
		where		dm.branch_code = case @p_branch_code
										 when 'ALL' then dm.branch_code
										 else @p_branch_code
									 end
					and (
							dm.branch_name					like '%' + @p_keywords + '%'
							or	dm.deposit_type				like '%' + @p_keywords + '%'
							or	dm.orig_currency_code		like '%' + @p_keywords + '%'
							or	am.agreement_external_no	like '%' + @p_keywords + '%'
							or	am.client_name				like '%' + @p_keywords + '%'
							or	dm.orig_amount				like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dm.branch_name
														when 2 then dm.deposit_type			
														when 3 then dm.orig_currency_code
														when 4 then am.agreement_external_no
														when 5 then cast(dm.orig_amount as sql_variant)	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dm.branch_name
														when 2 then dm.deposit_type			
														when 3 then dm.orig_currency_code
														when 4 then am.agreement_external_no
														when 5 then cast(dm.orig_amount as sql_variant)	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
