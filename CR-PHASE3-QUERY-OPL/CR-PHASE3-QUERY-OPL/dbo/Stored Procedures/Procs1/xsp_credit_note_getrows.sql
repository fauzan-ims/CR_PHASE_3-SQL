CREATE procedure [dbo].[xsp_credit_note_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(50)
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
	from	credit_note cn
			inner join invoice i on (i.invoice_no = cn.invoice_no) --(+)raffyanda 30/10/2023 18:47 perubahan invoice no menjadi invoice external no
	where	cn.branch_code = case @p_branch_code
								 when 'ALL' then cn.branch_code
								 else @p_branch_code
							 end
			and status	   = case @p_status
								 when 'ALL' then status
								 else @p_status
							 end
			and
			(
				code												 like '%' + @p_keywords + '%'
				or	cn.branch_name									 like '%' + @p_keywords + '%'
				or	convert(varchar(30),date,103)					 like '%' + @p_keywords + '%'
				or	status											 like '%' + @p_keywords + '%'
				or	remark											 like '%' + @p_keywords + '%'
				or	i.invoice_external_no							 like '%' + @p_keywords + '%'
				or	cn.total_amount									 like '%' + @p_keywords + '%'
				or	new_total_amount								 like '%' + @p_keywords + '%'
			) ;

	select		code
				,cn.branch_code
				,cn.branch_name
				,convert(varchar(30), date, 103) 'date'
				--,status
				,case status
					 when 'DONE' then 'POST'
					 else status
				 end 'status'
				,remark
				,i.invoice_external_no 'invoice_no'
				,cn.currency_code
				,billing_amount
				,discount_amount
				,ppn_pct
				,ppn_amount
				,pph_pct
				,pph_amount
				,cn.total_amount
				,credit_amount
				,new_faktur_no
				,new_ppn_amount
				,new_pph_amount
				,new_total_amount
				,@rows_count 'rowcount'
	from		credit_note cn
				inner join invoice i on (i.invoice_no = cn.invoice_no)
	where		cn.branch_code = case @p_branch_code
									 when 'ALL' then cn.branch_code
									 else @p_branch_code
								 end
				and status	   = case @p_status
									 when 'ALL' then status
									 else @p_status
								 end
				and
				(
					code												 like '%' + @p_keywords + '%'
					or	cn.branch_name									 like '%' + @p_keywords + '%'
					or	convert(varchar(30),date,103)					 like '%' + @p_keywords + '%'
					or	status											 like '%' + @p_keywords + '%'
					or	remark											 like '%' + @p_keywords + '%'
					or	i.invoice_external_no							 like '%' + @p_keywords + '%'
					or	cn.total_amount									 like '%' + @p_keywords + '%'
					or	new_total_amount								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then cn.branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then i.invoice_external_no
													 when 5 then cast(cn.total_amount as sql_variant)
													 when 6 then cast(new_total_amount as sql_variant)
													 when 7 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then cn.branch_name
													   when 3 then cast(date as sql_variant)
													   when 4 then i.invoice_external_no
													   when 5 then cast(cn.total_amount as sql_variant)
													   when 6 then cast(new_total_amount as sql_variant)
													   when 7 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
