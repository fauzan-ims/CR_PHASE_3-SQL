
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_getrows_backup]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 
			,@code	nvarchar(50)
			,@aging	int ;

	--create table #countaging
	--(
	--	code		nvarchar(50) COLLATE Latin1_General_CI_AS
	--	,aging		int
	--)

	--declare c_looping cursor for
	--select		po_code
	--			,(datediff(day,max(eta_date),dbo.xfn_get_system_date())) 'aging'
	--from		dbo.purchase_order_detail
	--group by	po_code

	--open c_looping
	--fetch next from c_looping
	--into	@code
	--		,@aging

	--while @@fetch_status = 0
	--begin
	--		if not exists (select 1 from #countaging where code = @code)
	--		begin
	--			insert into #countaging
	--			(
	--				code
	--				,aging
	--			)
	--			values 
	--			(
	--				@code
	--				,@aging
	--			)
	--		end
	--		else
	--		begin
	--			update #countaging
	--			set		grn = grn + ' - ' + @code
	--			where	 code = @code
	--		end

	--	fetch c_looping
	--	into	@code
	--			,@aging
	--end
	--close c_looping
	--deallocate c_looping

	select	@rows_count = count(1)
	from	purchase_order po
	outer apply(
				select	top 1 pod.spesification, pod.description
				from	dbo.purchase_order_detail pod
				where	pod.po_code = po.code
				--and		( pod.spesification like '%' + @p_keywords + '%'
				--or pod.description like '%' + @p_keywords + '%')
				)detail
	where	po.company_code	   = @p_company_code
			and po.status	   = case @p_status
									 when 'ALL' then po.status
									 else @p_status
								 end
			AND
			(
				po.code													like '%' + @p_keywords + '%'
				or	po.branch_name										like '%' + @p_keywords + '%'
				or	convert(varchar(30), po.order_date, 103)			like '%' + @p_keywords + '%'
				or	po.supplier_name									like '%' + @p_keywords + '%'
				or	po.order_type_code									like '%' + @p_keywords + '%'
				or	po.flag_process										like '%' + @p_keywords + '%'
				or	case po.status
					when 'CLOSEDFULL' then 'CLOSED FULL'
					else po.status 
				end 													like '%' + @p_keywords + '%'
				or	po.remark											like '%' + @p_keywords + '%'
				or	convert(varchar(30),po.eta_date,103)				like '%' + @p_keywords + '%'
				or	day(po.eta_date) - day(dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
				or	po.unit_from										like '%' + @p_keywords + '%'
				or	detail.description									like '%' + @p_keywords + '%'
				or	detail.spesification								like '%' + @p_keywords + '%'
			) ;

	select		po.code
				,po.company_code
				,convert(varchar(30), po.order_date, 103) 'order_date'
				,po.supplier_code
				,po.supplier_name
				,po.branch_code
				,po.branch_name
				,po.division_code
				,po.division_name
				,po.department_code
				,po.department_name
				,po.payment_methode_code
				,po.currency_code
				,po.currency_name
				,case po.order_type_code
					 when 'PO' then 'Purchase Order'
					 when 'SPK' then 'SPK'
					 when 'CONTRACT' then 'CONTRACT'
				 end									  'order_type_code'
				,po.total_amount
				,po.ppn_amount
				,po.pph_amount
				,po.payment_by
				,po.receipt_by
				,case po.is_termin
					 when '1' then 'YES'
					 else 'NO'
				 end									  'is_termin'
				,po.unit_from
				,case po.flag_process
					 when 'MNL' then 'Manual'
					 when 'GNR' then 'Generate'
				 end									  'flag_process'
				,case po.status
					when 'CLOSEDFULL' then 'CLOSED FULL'
					else po.status 
				end 'status'
				,po.remark
				,convert(varchar(30),po.eta_date,103) 'eta_date'
				,case when cast(po.eta_date as date) < cast(dbo.xfn_get_system_date() as date)
					then '1'
					else '0'
				end 'flag_eta_date'
				--,datediff(day,po.eta_date,dbo.xfn_get_system_date()) 'aging'
				,DATEDIFF(DAY, max.eta_date,dbo.xfn_get_system_date()) 'aging'  --ca.aging 'aging'
				,detail.description
				,detail.spesification
				,@rows_count							  'rowcount'
	from		purchase_order po
	OUTER APPLY (
					SELECT	MAX(ETA_DATE)'eta_date'
					FROM	dbo.PURCHASE_ORDER_DETAIL
					WHERE	PO_CODE = po.CODE
	)max
				--left join #countaging ca on ca.code = po.code
	outer apply(
				select top 1 pod.spesification, pod.description
				from dbo.purchase_order_detail pod
				where pod.po_code = po.code
				--and ( pod.spesification like '%' + @p_keywords + '%'
				--or pod.description like '%' + @p_keywords + '%')
				)detail
	where		po.company_code	   = @p_company_code
				and po.status	   = case @p_status
										 when 'ALL' then po.status
										 else @p_status
									 end
				and
				(
					po.code													like '%' + @p_keywords + '%'
					or	po.branch_name										like '%' + @p_keywords + '%'
					or	convert(varchar(30), po.order_date, 103)			like '%' + @p_keywords + '%'
					or	po.supplier_name									like '%' + @p_keywords + '%'
					or	po.order_type_code									like '%' + @p_keywords + '%'
					or	po.flag_process										like '%' + @p_keywords + '%'
					or	case po.status
						when 'CLOSEDFULL' then 'CLOSED FULL'
						else po.status 
					end 													like '%' + @p_keywords + '%'
					or	po.remark											like '%' + @p_keywords + '%'
					or	convert(varchar(30),po.eta_date,103)				like '%' + @p_keywords + '%'
					or	day(po.eta_date) - day(dbo.xfn_get_system_date())	like '%' + @p_keywords + '%'
					or	po.unit_from										like '%' + @p_keywords + '%'
					or	detail.description									like '%' + @p_keywords + '%'
					or	detail.spesification								like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then po.code collate sql_latin1_general_cp1_ci_as
													 when 2 then cast(po.order_date as sql_variant)
													 when 3 then po.supplier_name
													 when 4 then po.remark
													 when 5 then cast(po.eta_date as sql_variant)
													 when 6 then cast(day(po.eta_date) - day(dbo.xfn_get_system_date()) as sql_variant)
													 when 7 then po.unit_from
													 when 8 then po.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then po.code collate sql_latin1_general_cp1_ci_as
													 when 2 then cast(po.order_date as sql_variant)
													 when 3 then po.supplier_name
													 when 4 then po.remark
													 when 5 then cast(po.eta_date as sql_variant)
													 when 6 then cast(day(po.eta_date) - day(dbo.xfn_get_system_date()) as sql_variant)
													 when 7 then po.unit_from
													 when 8 then po.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
