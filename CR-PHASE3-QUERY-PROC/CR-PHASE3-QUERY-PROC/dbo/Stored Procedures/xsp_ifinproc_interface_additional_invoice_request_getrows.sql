--CREATED by ALIV on 16/05/2023
CREATE PROCEDURE dbo.xsp_ifinproc_interface_additional_invoice_request_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
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
	from	ifinproc_interface_additional_invoice_request iai
	where	iai.branch_code = case @p_branch_code
								 when 'ALL' then iai.branch_code
								 else @p_branch_code
							 end
	and		(
				branch_name										like '%' + @p_keywords + '%'
				or convert(varchar(30),date,103)				like '%' + @p_keywords + '%'
				or invoice_name									like '%' + @p_keywords + '%'
				or client_no									like '%' + @p_keywords + '%'
				or client_name									like '%' + @p_keywords + '%'
				or total_billing_amount							like '%' + @p_keywords + '%'
				or currency										like '%' + @p_keywords + '%'
				or reff_no										like '%' + @p_keywords + '%'		
			) ;

	select		id
				,reff_no					
				,convert(varchar(30),date,103)'date'	
				,branch_name			
				,client_name
				,invoice_name				
				,case invoice_type
					 	when 'MBLS' then 'MOBILISASI'
					end 'invoice_type'					
				,currency					
				,total_billing_amount		
				,@rows_count 'rowcount'
	from		ifinproc_interface_additional_invoice_request iai
	where		iai.branch_code = case @p_branch_code
								 when 'ALL' then iai.branch_code
								 else @p_branch_code
							 end
	AND			(
					branch_name										like '%' + @p_keywords + '%'
					or convert(varchar(30),date,103)				like '%' + @p_keywords + '%'
					or invoice_name									like '%' + @p_keywords + '%'
					or client_no									like '%' + @p_keywords + '%'
					or client_name									like '%' + @p_keywords + '%'
					or total_billing_amount							like '%' + @p_keywords + '%'
					or currency										like '%' + @p_keywords + '%'
					or reff_no										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then iai.reff_no
													 when 2 then cast(iai.date as sql_variant)
													 when 3 then iai.branch_name
													 when 4 then iai.client_name
													 when 5 then iai.invoice_name
													 when 6 then iai.currency
													 when 7 then cast(iai.total_billing_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then iai.reff_no
														when 2 then cast(iai.date as sql_variant)
														when 3 then iai.branch_name
														when 4 then iai.client_name
														when 5 then iai.invoice_name
														when 6 then iai.currency
														when 7 then cast(iai.total_billing_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
