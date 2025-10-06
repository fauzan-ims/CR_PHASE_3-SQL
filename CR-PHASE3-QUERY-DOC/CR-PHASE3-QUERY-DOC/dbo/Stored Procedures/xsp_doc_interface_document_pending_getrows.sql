CREATE PROCEDURE dbo.xsp_doc_interface_document_pending_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_document_status nvarchar(10)
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
	from	doc_interface_document_pending didp
			--left join dbo.agreement_main am on (am.agreement_no = didp.agreement_no)
	where	didp.branch_code		 = case @p_branch_code
										   when 'ALL' then didp.branch_code
										   else @p_branch_code
									   end
			and didp.document_status = case @p_document_status
										   when 'ALL' then document_status
										   else @p_document_status
									   end
			and (
					didp.code											like '%' + @p_keywords + '%'
					--or	am.agreement_external_no						like '%' + @p_keywords + '%'
					--or	am.client_name									like '%' + @p_keywords + '%'
					or	didp.branch_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), didp.entry_date, 103)		like '%' + @p_keywords + '%'
					or	didp.document_status							like '%' + @p_keywords + '%'
				) ;

	select		didp.code
				--,am.agreement_external_no
				--,am.client_name
				,didp.branch_name
				,convert(varchar(30), didp.entry_date, 103) 'entry_date'
				,didp.document_status
				,@rows_count 'rowcount'
	from		doc_interface_document_pending didp
				--left join dbo.agreement_main am on (am.agreement_no = didp.agreement_no)
	where		didp.branch_code		 = case @p_branch_code
											   when 'ALL' then didp.branch_code
											   else @p_branch_code
										   end
				and didp.document_status = case @p_document_status
											   when 'ALL' then document_status
											   else @p_document_status
										   end
				and (
						didp.code											like '%' + @p_keywords + '%'
						--or	am.agreement_external_no						like '%' + @p_keywords + '%'
						--or	am.client_name									like '%' + @p_keywords + '%'
						or	didp.branch_name								like '%' + @p_keywords + '%'
						or	convert(varchar(30), didp.entry_date, 103)		like '%' + @p_keywords + '%'
						or	didp.document_status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then didp.code
													 when 2 then didp.branch_name
													 --when 3 then am.agreement_external_no
													 when 4 then cast(didp.entry_date as sql_variant)
													 when 5 then didp.document_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then didp.code
													   when 2 then didp.branch_name
													   --when 3 then am.agreement_external_no
													   when 4 then cast(didp.entry_date as sql_variant)
													   when 5 then didp.document_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
