CREATE PROCEDURE dbo.xsp_opl_interface_purchase_request_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50) 
	,@p_request_status	nvarchar(10) = 'ALL' 
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
	from	opl_interface_purchase_request
	where	branch_code	= case @p_branch_code
						  	when 'ALL' then branch_code
						  	else @p_branch_code
						  end
			and request_status = case @p_request_status
								 	when 'ALL' then request_status
								 	else @p_request_status
								 end
			and (
					code										 like '%' + @p_keywords + '%'
					or	branch_name								 like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), request_date, 103) like '%' + @p_keywords + '%'
					or	request_status							 like '%' + @p_keywords + '%'
					or	description								 like '%' + @p_keywords + '%'
					or	result_fa_name							 like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), result_date, 103)  like '%' + @p_keywords + '%'
				) ;

	select		code
				,branch_name
				,convert(nvarchar(15), request_date, 103) 'request_date'
				,request_status
				,description
				,result_fa_name
				,convert(nvarchar(15), result_date, 103) 'result_date'
				,@rows_count 'rowcount'
	from		opl_interface_purchase_request
	where		branch_code	= case @p_branch_code
							  	when 'ALL' then branch_code
							  	else @p_branch_code
							  end
				and request_status = case @p_request_status
									 	when 'ALL' then request_status
									 	else @p_request_status
									 end
				and (
						code										 like '%' + @p_keywords + '%'
						or	branch_name								 like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), request_date, 103) like '%' + @p_keywords + '%'
						or	request_status							 like '%' + @p_keywords + '%'
						or	description								 like '%' + @p_keywords + '%'
						or	result_fa_name							 like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), result_date, 103)  like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code										
													 when 2 then branch_name								
													 when 3 then cast(request_date as sql_variant)
													 when 4 then request_status							
													 when 5 then description								
													 when 6 then result_fa_name							
													 when 7 then cast(result_date as sql_variant) 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code								
													   when 2 then branch_name						
													   when 3 then cast(request_date as sql_variant)
													   when 4 then request_status						
													   when 5 then description						
													   when 6 then result_fa_name						
													   when 7 then cast(result_date as sql_variant) 
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
