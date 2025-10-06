CREATE PROCEDURE dbo.xsp_additional_invoice_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_invoice_status		nvarchar(10)
	,@p_branch_code			nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	additional_invoice anv
			inner join dbo.sys_general_subcode sgs on (sgs.code = anv.invoice_type)
	where	branch_code = case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code 
							end
	and		anv.invoice_status = case @p_invoice_status
									when 'ALL' then anv.invoice_status
								else @p_invoice_status 
							end
	and		(
				anv.code										like '%' + @p_keywords + '%'
				or anv.invoice_name								like '%' + @p_keywords + '%'
				or convert(varchar(15), anv.invoice_date,103)	like '%' + @p_keywords + '%'
				or sgs.description								like '%' + @p_keywords + '%'
				or anv.total_amount								like '%' + @p_keywords + '%'
				or anv.invoice_status							like '%' + @p_keywords + '%'
				or anv.branch_name								like '%' + @p_keywords + '%'
				or anv.client_name								like '%' + @p_keywords + '%'
				or anv.currency_code							like '%' + @p_keywords + '%'


			) ;

	select	anv.code
            ,anv.invoice_name
            ,convert(varchar(30), anv.invoice_date,103) 'invoice_date'
            ,sgs.description 'invoice_type_name'
            ,anv.total_amount
            ,anv.invoice_status
			,anv.branch_name
			,anv.branch_code
			,anv.client_name
			,anv.currency_code
			,@rows_count 'rowcount'
	from	additional_invoice anv
			inner join dbo.sys_general_subcode sgs on (sgs.code = anv.invoice_type)
	where	branch_code = case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code 
							end
	and		anv.invoice_status = case @p_invoice_status
									when 'ALL' then anv.invoice_status
								else @p_invoice_status 
							end
	and		(
				anv.code										like '%' + @p_keywords + '%'
				or anv.invoice_name								like '%' + @p_keywords + '%'
				or convert(varchar(15), anv.invoice_date,103)	like '%' + @p_keywords + '%'
				or sgs.description								like '%' + @p_keywords + '%'
				or anv.total_amount								like '%' + @p_keywords + '%'
				or anv.invoice_status							like '%' + @p_keywords + '%'
				or anv.branch_name								like '%' + @p_keywords + '%'
				or anv.client_name								like '%' + @p_keywords + '%'
				or anv.currency_code							like '%' + @p_keywords + '%'


			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then anv.code
													when 2 then cast(anv.invoice_date as sql_variant)
													when 3 then anv.branch_name
													when 4 then anv.client_name 
													when 5 then anv.invoice_name
													when 6 then sgs.description
													when 7 then anv.currency_code 
													when 8 then cast(anv.total_amount as sql_variant)
													when 9 then anv.invoice_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then anv.code
													when 2 then cast(anv.invoice_date as sql_variant)
													when 3 then anv.branch_name
													when 4 then anv.client_name 
													when 5 then anv.invoice_name
													when 6 then sgs.description
													when 7 then anv.currency_code 
													when 8 then cast(anv.total_amount as sql_variant)
													when 9 then anv.invoice_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
