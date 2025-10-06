CREATE PROCEDURE [dbo].[xsp_invoice_delivery_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_status			nvarchar(50)
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
	from		invoice_delivery ind
		outer apply (
		select top 1 
			inv.invoice_no,
			inv.invoice_external_no,
			inv.client_name
		from dbo.invoice_delivery_detail idd
		left join dbo.invoice inv with(nolock) on inv.invoice_no = idd.invoice_no
		where idd.delivery_code = ind.code
	) inv
	--inner join dbo.invoice_delivery_detail idd on idd.delivery_code = ind.code
	--left join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
	where	ind.branch_code	= case @p_branch_code
								when 'ALL' then ind.branch_code
								else @p_branch_code
							end
	and		ind.STATUS		= case @p_status
								when 'ALL' then ind.STATUS
								else @p_status
							end
	AND		(
					ind.code												 like '%' + @p_keywords + '%'
					or ind.branch_code										 like '%' + @p_keywords + '%'
					or ind.branch_name										 like '%' + @p_keywords + '%'
					or ind.date												 like '%' + @p_keywords + '%'
					or ind.method											 like '%' + @p_keywords + '%'
					or ind.client_address									 like '%' + @p_keywords + '%'
					or inv.client_name										 like '%' + @p_keywords + '%'
					or ind.client_no										 like '%' + @p_keywords + '%'
					or ind.employee_name									 like '%' + @p_keywords + '%'
					or convert(varchar(30), ind.date, 103)					 like '%' + @p_keywords + '%'
					or ind.remark											 like '%' + @p_keywords + '%'
					or ind.status											 like '%' + @p_keywords + '%'
					or case 
						when ind.status in ('ON PROCESS', 'DONE') then datediff(day, ind.date, ind.proceed_date)
						when ind.status = 'HOLD' then datediff(day, ind.date, dbo.xfn_get_system_date())
						when ind.status = 'CANCEL' then 0
						else null -- fallback jika ada status tidak dikenali 
					end														 like '%' + @p_keywords + '%'
					or inv.invoice_no										 like '%' + @p_keywords + '%'
					or inv.invoice_external_no								 like '%' + @p_keywords + '%'
			) ;

	select		ind.code
				,ind.branch_code
				,ind.branch_name
				,convert(varchar(30), ind.date, 103) 'date'
				,ind.method
				,ind.client_address
				,inv.client_name 'billing_to_name'
				,inv.client_name
				,ind.client_no
				,ind.employee_name
				,CASE 
					WHEN ind.STATUS IN ('ON PROCESS', 'DONE') THEN DATEDIFF(DAY, ind.DATE, ind.PROCEED_DATE)
					WHEN ind.STATUS = 'HOLD' THEN DATEDIFF(DAY, ind.DATE, dbo.xfn_get_system_date())
					WHEN ind.STATUS = 'CANCEL' THEN 0
					ELSE NULL -- fallback jika ada status tidak dikenali
				END AS 'aging'
				--,datediff(day, ind.date, 
				--	case 
				--		when ind.status = 'on process' or ind.status = 'done' then ind.proceed_date
				--		WHEN ind.status = 'hold' THEN dbo.xfn_get_system_date()
				--		else 0                        
				--	end
				--) as aging
				,ind.remark
				,ind.status
				,@rows_count 'rowcount'
	from		invoice_delivery ind
		outer apply (
		select top 1 
			inv.invoice_no,
			inv.invoice_external_no,
			inv.client_name
		from dbo.invoice_delivery_detail idd
		left join dbo.invoice inv with(nolock) on inv.invoice_no = idd.invoice_no
		where idd.delivery_code = ind.code
	) inv
	--inner join dbo.invoice_delivery_detail idd on idd.delivery_code = ind.code
	--left join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
	where	ind.branch_code	= case @p_branch_code
								when 'ALL' then ind.branch_code
								else @p_branch_code
							end
	and		ind.STATUS		= case @p_status
								when 'ALL' then ind.STATUS
								else @p_status
							end
	and		(																 
					ind.code												 like '%' + @p_keywords + '%'
					or ind.branch_code										 like '%' + @p_keywords + '%'
					or ind.branch_name										 like '%' + @p_keywords + '%'
					or convert(varchar(30), ind.date, 103)					 like '%' + @p_keywords + '%'
					or ind.method											 like '%' + @p_keywords + '%'
					or ind.client_address									 like '%' + @p_keywords + '%'
					or inv.client_name										 like '%' + @p_keywords + '%'
					or ind.client_no										 like '%' + @p_keywords + '%'
					or ind.employee_name									 like '%' + @p_keywords + '%'
					or ind.remark											 like '%' + @p_keywords + '%'
					or ind.status											 like '%' + @p_keywords + '%'
					or case 
						when ind.status in ('ON PROCESS', 'DONE') then datediff(day, ind.date, ind.proceed_date)
						when ind.status = 'HOLD' then datediff(day, ind.date, dbo.xfn_get_system_date())
						when ind.status = 'CANCEL' then 0
						else null -- fallback jika ada status tidak dikenali 
					end														 like '%' + @p_keywords + '%'
					or inv.invoice_no										 like '%' + @p_keywords + '%'
					or inv.invoice_external_no								 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ind.code
													 when 2 then ind.branch_name
													 when 3 then cast(ind.date as sql_variant)
													 when 4 then ind.method + ind.employee_name
													 when 5 then ind.client_address	
													 when 6 then inv.client_name
													 when 7 then ind.client_no
													 when 8 then cast(
														case 
															when ind.STATUS IN ('ON PROCESS', 'DONE') then DATEDIFF(DAY, ind.DATE, ind.PROCEED_DATE)
															when ind.STATUS = 'HOLD' then DATEDIFF(DAY, ind.DATE, dbo.xfn_get_system_date())
															when ind.STATUS = 'CANCEL' then 0
															else null
														end as sql_variant)
													 when 9 then ind.remark
													 when 10 then ind.status
													 --when 9 then inv.total_amount
													 --when 10 then idd.delivery_status		
													 --when 11 then cast(idd.delivery_date as sql_variant)
													 --when 12 then idd.receiver_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ind.code
													 when 2 then ind.branch_name
													 when 3 then cast(ind.date as sql_variant)
													 when 4 then ind.method + ind.employee_name
													 when 5 then ind.client_address	
													 when 6 then inv.client_name
													 when 7 then ind.client_no
													 when 8 then cast(
														case 
															when ind.STATUS IN ('ON PROCESS', 'DONE') then DATEDIFF(DAY, ind.DATE, ind.PROCEED_DATE)
															when ind.STATUS = 'HOLD' then DATEDIFF(DAY, ind.DATE, dbo.xfn_get_system_date())
															when ind.STATUS = 'CANCEL' then 0
															else null
														end as sql_variant)
													  when 9 then ind.remark
													  when 10 then ind.status
													 --when 9 then inv.total_amount
													 --when 10 then idd.delivery_status		
													 --when 11 then cast(idd.delivery_date as sql_variant)
													 --when 12 then idd.receiver_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
