

CREATE PROCEDURE dbo.xsp_invoice_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50) 
	,@p_invoice_status		nvarchar(10)
	,@p_client_no			nvarchar(50) = ''
	,@p_from_date			nvarchar(50) = ''
	,@p_to_date				nvarchar(50) = ''
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
	from	invoice inv with (nolock)
			--outer apply (select code from dbo.credit_note cn where cn.invoice_no = inv.invoice_no and cn.status = 'POST')cn
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
						  end 
	and		inv.invoice_status = case @p_invoice_status
						  		when 'ALL' then inv.invoice_status
						  		else @p_invoice_status
						  end
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
						 end
	and		inv.new_invoice_date between 
						case when @p_from_date = '' then inv.new_invoice_date else convert(datetime,@p_from_date,102) end
					and
						case when @p_to_date = '' then inv.new_invoice_date else convert(datetime,@p_to_date,102) end
	and		(	
				invoice_no										like '%' + @p_keywords + '%'
				or	invoice_external_no							like '%' + @p_keywords + '%'
				or	faktur_no									like '%' + @p_keywords + '%'
				or	branch_name									like '%' + @p_keywords + '%'
				or	invoice_name								like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_date,103)		like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_due_date,103) 	like '%' + @p_keywords + '%'
				or	client_name									like '%' + @p_keywords + '%'
				or	total_amount								like '%' + @p_keywords + '%'
				or	invoice_status								like '%' + @p_keywords + '%'
				or	currency_code								like '%' + @p_keywords + '%'
				or	inv.credit_billing_amount					like '%' + @p_keywords + '%'

			) ;

	select	inv.invoice_no
			,inv.invoice_external_no
			,inv.faktur_no
			,inv.invoice_name
			,inv.branch_name		
			,convert(varchar(20),inv.invoice_date,103) 'invoice_date'		
			,convert(varchar(20),inv.invoice_due_date,103) 'invoice_due_date' 	
			,inv.client_name			
			,inv.total_amount		
			,inv.invoice_status
			,inv.currency_code
			--,cn.code 'credit_note_no'
			,inv.credit_billing_amount
			,@rows_count 'rowcount'
	from	invoice inv with (nolock)
			--outer apply (select code from dbo.credit_note cn where cn.invoice_no = inv.invoice_no and cn.status = 'POST')cn
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
							  end 
	and		inv.invoice_status = case @p_invoice_status
						  		when 'ALL' then inv.invoice_status
						  		else @p_invoice_status
							  end
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
							 end
	and		inv.new_invoice_date between case when @p_from_date = '' then inv.new_invoice_date else convert(datetime,@p_from_date,102) end
	and		case when @p_to_date = '' then inv.new_invoice_date else convert(datetime,@p_to_date,102) end
	and		(	
				inv.invoice_no										like '%' + @p_keywords + '%'
				or	inv.invoice_external_no							like '%' + @p_keywords + '%'
				or	inv.faktur_no									like '%' + @p_keywords + '%'
				or	inv.branch_name									like '%' + @p_keywords + '%'
				or	inv.invoice_name								like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_date,103)		like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_due_date,103) 	like '%' + @p_keywords + '%'
				or	inv.client_name									like '%' + @p_keywords + '%'
				or	inv.total_amount								like '%' + @p_keywords + '%'
				or	inv.invoice_status								like '%' + @p_keywords + '%'
				or	inv.currency_code								like '%' + @p_keywords + '%'
				or	inv.credit_billing_amount						like '%' + @p_keywords + '%'

			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then invoice_external_no
														when 2 then branch_name
														when 3 then invoice_name
														when 4 then invoice_date --convert(varchar(20),invoice_date,103)
														when 5 then invoice_due_date--convert(varchar(20),invoice_due_date,103)
														when 6 then client_name
														when 7 then currency_code 
														when 8 then cast(total_amount as sql_variant)
														when 9 then cast(credit_billing_amount as sql_variant)
														when 10 then invoice_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then invoice_external_no
														when 2 then branch_name
														when 3 then invoice_name
														when 4 then invoice_date --convert(varchar(20),invoice_date,103)
														when 5 then invoice_due_date--convert(varchar(20),invoice_due_date,103)
														when 6 then client_name
														when 7 then currency_code 
														when 8 then cast(total_amount as sql_variant)
														when 9 then cast(credit_billing_amount as sql_variant)
														when 10 then invoice_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
