
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_procurement_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_status			nvarchar(50)
	,@p_branch			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch
	)
	begin
		set @p_branch = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	procurement
	where	company_code = @p_company_code
			and status	 = case @p_status
							   when 'ALL' then status
							   else @p_status
						   end
			and branch_code = case @p_branch
									 when 'ALL' then branch_code
									 else @p_branch
								 end
			and (
					code													like '%' + @p_keywords + '%'
					or	procurement_request_code							like '%' + @p_keywords + '%'
					or	convert(varchar(30), procurement_request_date, 103) like '%' + @p_keywords + '%'
					or	branch_name											like '%' + @p_keywords + '%'
					or	item_name											like '%' + @p_keywords + '%'
					or	specification										like '%' + @p_keywords + '%'
					or	remark												like '%' + @p_keywords + '%'
					or	status												like '%' + @p_keywords + '%'
					or	unit_from											like '%' + @p_keywords + '%'
					or	bbn_name											like '%' + @p_keywords + '%'
					or	bbn_location										like '%' + @p_keywords + '%'
					or	bbn_address											like '%' + @p_keywords + '%'
					or	deliver_to_address									like '%' + @p_keywords + '%'
				) ;

	select		code
				,procurement_request_item_id
				,procurement_request_code
				,convert(varchar(30), procurement_request_date, 103) 'procurement_request_date'
				,branch_code
				,branch_name
				,item_code
				,item_name
				,item_type_code
				,item_type_name
				,quantity_request
				,approved_quantity
				,specification
				,remark
				,new_purchase
				,purchase_type_code
				,purchase_type_name
				,quantity_purchase
				,status
				,company_code
				,unit_from
				,requestor_code
				,requestor_name
				,bbn_name
				,bbn_location
				,bbn_address
				,deliver_to_address
				,@rows_count 'rowcount'
	from		procurement
	where		company_code = @p_company_code
				and status	 = case @p_status
								   when 'ALL' then status
								   else @p_status
							   end
				and branch_code = case @p_branch
									 when 'ALL' then branch_code
									 else @p_branch
								 end
				and (
						code													like '%' + @p_keywords + '%'
						or	procurement_request_code							like '%' + @p_keywords + '%'
						or	convert(varchar(30), procurement_request_date, 103) like '%' + @p_keywords + '%'
						or	branch_name											like '%' + @p_keywords + '%'
						or	item_name											like '%' + @p_keywords + '%'
						or	specification										like '%' + @p_keywords + '%'
						or	remark												like '%' + @p_keywords + '%'
						or	status												like '%' + @p_keywords + '%'
						or	unit_from											like '%' + @p_keywords + '%'
						or	bbn_name											like '%' + @p_keywords + '%'
						or	bbn_location										like '%' + @p_keywords + '%'
						or	bbn_address											like '%' + @p_keywords + '%'
						or	deliver_to_address									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(procurement_request_date as sql_variant)
													 when 3 then branch_name
													 when 4 then item_name
													 when 5 then specification
													 when 6 then bbn_name
													 when 7 then deliver_to_address
													 when 8 then remark
													 when 9 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(procurement_request_date as sql_variant)
													 when 3 then branch_name
													 when 4 then item_name
													 when 5 then specification
													 when 6 then bbn_name
													 when 7 then deliver_to_address
													 when 8 then remark
													 when 9 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
