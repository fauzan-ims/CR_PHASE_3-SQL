CREATE PROCEDURE dbo.xsp_invoice_getrows_for_delivery_request
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	-- Louis Selasa, 01 Juli 2025 15.41.31 -- 
	,@p_client_no			nvarchar(50) = ''
	,@p_from_date			nvarchar(50) = ''
	,@p_to_date				nvarchar(50) = ''
	-- Louis Selasa, 01 Juli 2025 15.41.31 -- 
)
as
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
	from	invoice inv
			left join dbo.invoice_delivery invd on (invd.code = inv.deliver_code)
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
						  end 
	and		inv.deliver_code is null
	and		inv.invoice_status not in ('CANCEL', 'NEW')
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
						 end
	and		inv.new_invoice_date between 
						case when @p_from_date = '' then inv.new_invoice_date else convert(datetime,@p_from_date,102) end
					and
						case when @p_to_date = '' then inv.new_invoice_date else convert(datetime,@p_to_date,102) end
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	--AND		deliver_code <> 'migrasi'
	and		(	
				inv.invoice_external_no												like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_date,103)						like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_due_date,103) 					like '%' + @p_keywords + '%'
				or	inv.invoice_name												like '%' + @p_keywords + '%'
				or	inv.client_name													like '%' + @p_keywords + '%'
				or	inv.client_address												like '%' + @p_keywords + '%'
				or	inv.total_amount												like '%' + @p_keywords + '%'
				or	inv.deliver_code												like '%' + @p_keywords + '%'
				or	invd.status														like '%' + @p_keywords + '%' 
				or	datediff(day,inv.new_invoice_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%' 

			) ;

	select	inv.invoice_no		
			,inv.invoice_external_no			
			,inv.invoice_name
			,inv.branch_name		
			,convert(varchar(20),inv.invoice_date,103) 'invoice_date'		
			,convert(varchar(20),inv.invoice_due_date,103) 'invoice_due_date' 	
			,inv.client_name			
			,inv.total_amount		
			,inv.invoice_status
			,inv.client_address
			,inv.currency_code
			,datediff(day,inv.new_invoice_date, dbo.xfn_get_system_date()) 'aging'
			,inv.deliver_code
			,invd.status
			,@rows_count 'rowcount'
	from	invoice inv
			left join dbo.invoice_delivery invd on (invd.code = inv.deliver_code)
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
						  end 
	and		inv.deliver_code is null
	and		inv.invoice_status not in ('CANCEL', 'NEW')
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
						 end
	and		inv.new_invoice_date between 
						case when @p_from_date = '' then inv.new_invoice_date else convert(datetime,@p_from_date,102) end
					and
						case when @p_to_date = '' then inv.new_invoice_date else convert(datetime,@p_to_date,102) end
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	--AND		deliver_code <> 'migrasi'
	and		(	
				inv.invoice_external_no												like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_date,103)						like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_due_date,103) 					like '%' + @p_keywords + '%'
				or	inv.invoice_name												like '%' + @p_keywords + '%'
				or	inv.client_name													like '%' + @p_keywords + '%'
				or	inv.client_address												like '%' + @p_keywords + '%'
				or	inv.total_amount												like '%' + @p_keywords + '%'
				or	inv.deliver_code												like '%' + @p_keywords + '%'
				or	invd.status														like '%' + @p_keywords + '%' 
				or	datediff(day,inv.new_invoice_date, dbo.xfn_get_system_date())	like '%' + @p_keywords + '%' 

			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then inv.invoice_external_no
														when 2 then cast(invoice_date as sql_variant)
														when 3 then cast(invoice_due_date as sql_variant)
														when 4 then invoice_name
														when 5 then client_name
														when 6 then inv.client_address
														when 7 then cast(total_amount as sql_variant)
														when 8 then cast(datediff(day,inv.new_invoice_date, dbo.xfn_get_system_date()) as sql_variant)
														when 9 then inv.deliver_code
														when 10 then invd.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then inv.invoice_external_no
														when 2 then cast(invoice_date as sql_variant)
														when 3 then cast(invoice_due_date as sql_variant)
														when 4 then invoice_name
														when 5 then client_name
														when 6 then inv.client_address
														when 7 then cast(total_amount as sql_variant)
														when 8 then cast(datediff(day,inv.new_invoice_date, dbo.xfn_get_system_date()) as sql_variant)
														when 9 then inv.deliver_code
														when 10 then invd.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
