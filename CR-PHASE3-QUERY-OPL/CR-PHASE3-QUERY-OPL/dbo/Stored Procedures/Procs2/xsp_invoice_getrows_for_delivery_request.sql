CREATE PROCEDURE dbo.xsp_invoice_getrows_for_delivery_request
(
	@p_keywords				NVARCHAR(50)
	,@p_pagenumber			INT
	,@p_rowspage			INT
	,@p_order_by			INT
	,@p_sort_by				NVARCHAR(5)
	--
	,@p_branch_code			NVARCHAR(50)
	-- Louis Selasa, 01 Juli 2025 15.41.31 -- 
	,@p_client_no			NVARCHAR(50) = ''
	,@p_from_date			NVARCHAR(50) = ''
	,@p_to_date				NVARCHAR(50) = ''
	,@p_delivery_status		NVARCHAR(50) = ''
	-- Louis Selasa, 01 Juli 2025 15.41.31 -- 
)
AS
BEGIN

	DECLARE @rows_count INT = 0 ;

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
			outer apply(	select	top 1 invd.code, invd.status 
							from	dbo.invoice_delivery invd with (nolock) 
							where	(invd.code = inv.deliver_code) 
							order by invd.cre_date desc
					)invd
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
						  end 
	and		inv.invoice_status not in ('CANCEL', 'NEW')
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
						 end
	and			cast(inv.new_invoice_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	and		isnull(invd.status,'') = case @p_delivery_status
								when 'ALL' then isnull(invd.status,'')
								else @p_delivery_status
						  end 
	and		(	
				inv.invoice_external_no												like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_date,103)						like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_due_date,103) 					like '%' + @p_keywords + '%'
				or	inv.invoice_name												like '%' + @p_keywords + '%'
				or	inv.client_name													like '%' + @p_keywords + '%'
				or	inv.client_address												like '%' + @p_keywords + '%'
				or	inv.total_amount												like '%' + @p_keywords + '%'
				or	invd.code														like '%' + @p_keywords + '%'
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
			,invd.code deliver_code
			,invd.status
			,@rows_count 'rowcount'
	from	invoice inv with (nolock)
			outer apply(	select	top 1 invd.code, invd.status 
							from	dbo.invoice_delivery invd with (nolock) 
							where	(invd.code = inv.deliver_code) 
							order by invd.cre_date desc
					)invd
	where	inv.branch_code	= case @p_branch_code
								when 'ALL' then inv.branch_code
								else @p_branch_code
						  end 
	and		inv.invoice_status not in ('CANCEL', 'NEW')
						  -- Louis Selasa, 01 Juli 2025 15.41.16 -- 
	and		inv.client_no	= case @p_client_no
								when '' then inv.client_no
								else @p_client_no
						 end
	and		cast(inv.new_invoice_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
						  -- Louis Selasa, 01 Juli 2025 15.41.16 --
	and		isnull(invd.status,'') = case @p_delivery_status
								when 'ALL' then isnull(invd.status,'')
								else @p_delivery_status
						  end 
	and		(	
				inv.invoice_external_no												like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_date,103)						like '%' + @p_keywords + '%'
				or	convert(varchar(20),inv.invoice_due_date,103) 					like '%' + @p_keywords + '%'
				or	inv.invoice_name												like '%' + @p_keywords + '%'
				or	inv.client_name													like '%' + @p_keywords + '%'
				or	inv.client_address												like '%' + @p_keywords + '%'
				or	inv.total_amount												like '%' + @p_keywords + '%'
				or	invd.code														like '%' + @p_keywords + '%'
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
														when 9 then invd.code
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
														when 9 then invd.code
														when 10 then invd.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;