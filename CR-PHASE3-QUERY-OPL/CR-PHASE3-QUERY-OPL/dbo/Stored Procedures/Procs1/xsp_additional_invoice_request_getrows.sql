CREATE PROCEDURE [dbo].[xsp_additional_invoice_request_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	--
	,@p_invoice_status nvarchar(10) = 'ALL'
	,@p_branch_code	   nvarchar(50)
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
	from	dbo.additional_invoice_request air
			inner join dbo.sys_general_subcode sgs on (sgs.code = air.invoice_type)
	where	branch_code	   = case @p_branch_code
								 when 'ALL' then branch_code
								 else @p_branch_code
							 end
			and air.status = case @p_invoice_status
								 when 'ALL' then air.status
								 else @p_invoice_status
							 end
			and (
					air.code										like '%' + @p_keywords + '%'
					or air.invoice_name								like '%' + @p_keywords + '%'
					or convert(varchar(15), air.invoice_date,103)	like '%' + @p_keywords + '%'
					or sgs.description								like '%' + @p_keywords + '%'
					or air.total_amount								like '%' + @p_keywords + '%'
					or air.status									like '%' + @p_keywords + '%'
					or air.branch_name								like '%' + @p_keywords + '%'
					or air.client_name								like '%' + @p_keywords + '%'
					or air.currency_code							like '%' + @p_keywords + '%'
				) ;

	select		air.code
				,air.invoice_name
				,convert(varchar(30), air.invoice_date, 103) 'invoice_date'
				,sgs.description 'invoice_type'
				,air.total_amount
				,air.status
				,air.branch_name
				,air.branch_code
				,air.client_name
				,air.currency_code
				,@rows_count 'rowcount'
	from		additional_invoice_request air
				inner join dbo.sys_general_subcode sgs on (sgs.code = air.invoice_type)
	where		branch_code	   = case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								 end
				and air.status = case @p_invoice_status
									 when 'ALL' then air.status
									 else @p_invoice_status
								 end
				and (
						air.code										like '%' + @p_keywords + '%'
						or air.invoice_name								like '%' + @p_keywords + '%'
						or convert(varchar(15), air.invoice_date,103)	like '%' + @p_keywords + '%'
						or sgs.description								like '%' + @p_keywords + '%'
						or air.total_amount								like '%' + @p_keywords + '%'
						or air.status									like '%' + @p_keywords + '%'
						or air.branch_name								like '%' + @p_keywords + '%'
						or air.client_name								like '%' + @p_keywords + '%'
						or air.currency_code							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then air.code
													 when 2 then air.branch_name
													 when 3 then cast(air.invoice_date as sql_variant)
													 when 4 then air.invoice_name
													 when 5 then sgs.description
													 when 6 then air.currency_code
													 when 7 then cast(air.total_amount as sql_variant)
													 when 8 then air.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then air.code
													 when 2 then air.branch_name
													 when 3 then cast(air.invoice_date as sql_variant)
													 when 4 then air.invoice_name
													 when 5 then sgs.description
													 when 6 then air.currency_code
													 when 7 then cast(air.total_amount as sql_variant)
													 when 8 then air.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
