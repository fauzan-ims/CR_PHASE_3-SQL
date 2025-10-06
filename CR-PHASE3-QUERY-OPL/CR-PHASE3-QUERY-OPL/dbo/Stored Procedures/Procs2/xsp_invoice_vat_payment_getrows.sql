CREATE PROCEDURE dbo.xsp_invoice_vat_payment_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	,@p_status				nvarchar(15)
	,@p_from_date			datetime = ''
	,@p_to_date				datetime = ''
)
AS
BEGIN

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
	from	invoice_vat_payment ivp
	where	ivp.branch_code	= case @p_branch_code
								when 'ALL' then ivp.branch_code
								else @p_branch_code
						  end
	and		status	= case @p_status
								when 'ALL' then status
								else @p_status
						  end
	--and		date between @p_from_date and @p_to_date			 
	and		(	
				code												like '%' + @p_keywords + '%'
				or	ivp.branch_name									like '%' + @p_keywords + '%'
				or	ivp.status										like '%' + @p_keywords + '%'
				or	convert(varchar(20),ivp.date,103)				like '%' + @p_keywords + '%'
				or	ivp.remark										like '%' + @p_keywords + '%'
				or	ivp.total_ppn_amount							like '%' + @p_keywords + '%'
			) ;

	select	code										
			,ivp.branch_name									
			,ivp.remark								
			,convert(varchar(20),ivp.date,103)		'date'
			,ivp.status						
			,ivp.total_ppn_amount	
			,ivp.currency_code							
			,@rows_count 'rowcount'
	from	invoice_vat_payment ivp
	where	ivp.branch_code	= case @p_branch_code
								when 'ALL' then ivp.branch_code
								else @p_branch_code
						  end
	and		status	= case @p_status
								when 'ALL' then status
								else @p_status
						  end
	--and		date between @p_from_date and @p_to_date			 
	and		(	
				code												like '%' + @p_keywords + '%'
				or	ivp.branch_name									like '%' + @p_keywords + '%'
				or	ivp.status										like '%' + @p_keywords + '%'
				or	convert(varchar(20),ivp.date,103)				like '%' + @p_keywords + '%'
				or	ivp.remark										like '%' + @p_keywords + '%'
				or	ivp.total_ppn_amount							like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ivp.code
														when 2 then ivp.branch_name
														when 3 then cast(ivp.date as sql_variant)
														when 4 then ivp.remark
														when 5 then cast(ivp.total_ppn_amount as sql_variant)
														when 6 then ivp.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ivp.code
														when 2 then ivp.branch_name
														when 3 then cast(ivp.date as sql_variant)
														when 4 then ivp.remark
														when 5 then cast(ivp.total_ppn_amount as sql_variant)
														when 6 then ivp.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
