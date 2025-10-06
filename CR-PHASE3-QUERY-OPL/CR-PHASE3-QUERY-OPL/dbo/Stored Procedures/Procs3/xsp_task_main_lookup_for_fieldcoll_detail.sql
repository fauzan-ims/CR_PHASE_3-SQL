CREATE PROCEDURE dbo.xsp_task_main_lookup_for_fieldcoll_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_field_code		nvarchar(50)
	,@p_fieldcoll_code  nvarchar(50)
	--,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	task_main tm
			inner join dbo.agreement_main am on (am.agreement_no = tm.agreement_no)
			left join dbo.agreement_client_address aca on (aca.agreement_no = am.agreement_no)
	where	not exists
						(
							select	fdl.agreement_no
							from	dbo.fieldcoll_detail fdl
							where	fdl.agreement_no	= tm.agreement_no
									and fdl.field_code	= @p_field_code
						)
			--and	tm.branch_code	= case @p_branch_code
			--						when 'ALL' then amn.branch_code
			--						else @p_branch_code
			--				  end
			and tm.field_status = 'NEW'
			and tm.field_collector_code = @p_fieldcoll_code
			and (
					am.agreement_external_no		like '%' + @p_keywords + '%'
					or am.client_name				like '%' + @p_keywords + '%'
					or am.overdue_days				like '%' + @p_keywords + '%'
					or aca.address					like '%' + @p_keywords + '%'
					or am.installment_amount		like '%' + @p_keywords + '%'
				) ;

		select		tm.id
					,tm.agreement_no
					,am.agreement_external_no
					,am.client_name
					,am.overdue_days
					,aca.address
					,am.installment_amount
					,@rows_count 'rowcount'
		from		task_main tm
					inner join dbo.agreement_main am on (am.agreement_no = tm.agreement_no)
					left join dbo.agreement_client_address aca on (aca.agreement_no = am.agreement_no)
		where		not exists
								(
									select	fdl.agreement_no
									from	dbo.fieldcoll_detail fdl
									where	fdl.agreement_no	= am.agreement_no
											and fdl.field_code	= @p_field_code
								)
					--and	amn.branch_code	= case @p_branch_code
					--				when 'ALL' then amn.branch_code
					--				else @p_branch_code
					--		  end
					and tm.field_status = 'NEW'
					and tm.field_collector_code = @p_fieldcoll_code
					and (
							am.agreement_external_no		like '%' + @p_keywords + '%'
							or am.client_name				like '%' + @p_keywords + '%'
							or am.overdue_days				like '%' + @p_keywords + '%'
							or aca.address					like '%' + @p_keywords + '%'
							or am.installment_amount		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(am.overdue_days as sql_variant)
														when 3 then aca.address
														when 4 then cast(am.installment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then am.agreement_external_no
														when 2 then cast(am.overdue_days as sql_variant)
														when 3 then aca.address
														when 4 then cast(am.installment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

