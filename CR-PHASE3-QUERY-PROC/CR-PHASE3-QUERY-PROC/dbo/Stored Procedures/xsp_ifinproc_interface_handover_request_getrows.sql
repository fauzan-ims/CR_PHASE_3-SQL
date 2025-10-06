--CREATED by ALIV on 16/05/2023
CREATE PROCEDURE dbo.xsp_ifinproc_interface_handover_request_getrows
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
	from	ifinproc_interface_handover_request ihr
	where	ihr.branch_code = case @p_branch_code
								 when 'ALL' then ihr.branch_code
								 else @p_branch_code
							 end
			and ihr.status  = case @p_status
								 when 'ALL' then ihr.status
								 else @p_status
							 end
	and		(
				id													like '%' + @p_keywords + '%'
				or	code											like '%' + @p_keywords + '%'
				or	branch_code										like '%' + @p_keywords + '%'
				or	branch_name										like '%' + @p_keywords + '%'
				or	status											like '%' + @p_keywords + '%'
				or	convert(varchar(30),transaction_date,103)		like '%' + @p_keywords + '%'
				or	type											like '%' + @p_keywords + '%'
				or	remark											like '%' + @p_keywords + '%'
				or	fa_code											like '%' + @p_keywords + '%'
				or	fa_name											like '%' + @p_keywords + '%'
				or	handover_from									like '%' + @p_keywords + '%'
				or	handover_to										like '%' + @p_keywords + '%'
				or	unit_condition									like '%' + @p_keywords + '%'
				or	reff_no											like '%' + @p_keywords + '%'
				or	reff_name										like '%' + @p_keywords + '%'
				or	handover_address								like '%' + @p_keywords + '%'
				or	handover_phone_area								like '%' + @p_keywords + '%'
				or	handover_phone_no								like '%' + @p_keywords + '%'
				or	handover_eta_date								like '%' + @p_keywords + '%'
				or	handover_code									like '%' + @p_keywords + '%'
				or	handover_bast_date								like '%' + @p_keywords + '%'
				or	handover_remark									like '%' + @p_keywords + '%'
				or	handover_status									like '%' + @p_keywords + '%'
				or	asset_status									like '%' + @p_keywords + '%'
				or	convert(varchar(30),settle_date,103)			like '%' + @p_keywords + '%'
				or	job_status										like '%' + @p_keywords + '%'
				or	failed_remarks									like '%' + @p_keywords + '%'
			) ;

	select		id
				,code					
				,branch_name		
				,status				
				,convert(varchar(30),transaction_date,103)'transaction_date'
				,type				
				,remark				
				,fa_code					
				,handover_from		
				,handover_to							
				,convert(varchar(30),settle_date,103)'settle_date'	
				,@rows_count 'rowcount'
	from		ifinproc_interface_handover_request ihr
	where		ihr.branch_code = case @p_branch_code
								 when 'ALL' then ihr.branch_code
								 else @p_branch_code
							 end
	and			ihr.status  = case @p_status
								 when 'ALL' then ihr.status
								 else @p_status
							 END
	AND			(
					id													like '%' + @p_keywords + '%'
					or	code											like '%' + @p_keywords + '%'
					or	branch_code										like '%' + @p_keywords + '%'
					or	branch_name										like '%' + @p_keywords + '%'
					or	status											like '%' + @p_keywords + '%'
					or	convert(varchar(30),transaction_date,103)		like '%' + @p_keywords + '%'
					or	type											like '%' + @p_keywords + '%'
					or	remark											like '%' + @p_keywords + '%'
					or	fa_code											like '%' + @p_keywords + '%'
					or	fa_name											like '%' + @p_keywords + '%'
					or	handover_from									like '%' + @p_keywords + '%'
					or	handover_to										like '%' + @p_keywords + '%'
					or	unit_condition									like '%' + @p_keywords + '%'
					or	reff_no											like '%' + @p_keywords + '%'
					or	reff_name										like '%' + @p_keywords + '%'
					or	handover_address								like '%' + @p_keywords + '%'
					or	handover_phone_area								like '%' + @p_keywords + '%'
					or	handover_phone_no								like '%' + @p_keywords + '%'
					or	handover_eta_date								like '%' + @p_keywords + '%'
					or	handover_code									like '%' + @p_keywords + '%'
					or	handover_bast_date								like '%' + @p_keywords + '%'
					or	handover_remark									like '%' + @p_keywords + '%'
					or	handover_status									like '%' + @p_keywords + '%'
					or	asset_status									like '%' + @p_keywords + '%'
					or	convert(varchar(30),settle_date,103)			like '%' + @p_keywords + '%'
					or	job_status										like '%' + @p_keywords + '%'
					or	failed_remarks									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then type
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then handover_from + handover_to
													 when 6 then fa_code
													 when 7 then ihr.remark
													 when 8 then ihr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then type
														when 4 then cast(transaction_date as sql_variant)
														when 5 then handover_from + handover_to
														when 6 then fa_code
														when 7 then ihr.remark
														when 8 then ihr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
