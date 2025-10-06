CREATE PROCEDURE [dbo].[xsp_inquiry_client_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	create table #temp_table
	(
		client_no			nvarchar(50)
		,client_name		nvarchar(250)
		,total_asset		int
		,total_rental_lease decimal(18, 2)
		,total_overdue		decimal(18, 2)
	) ;

	insert into #temp_table
	(
		client_no
		,client_name
		,total_asset
		,total_rental_lease
		,total_overdue
	)
	select	distinct
			cm.client_no
			,cm.client_name
			,isnull(agreement_asset.total_asset, 0)
			,isnull(amortization.billing_amount, 0)
			,isnull(obligation.overdue, 0)
	from	dbo.client_main cm
			outer apply
	(
		select		count(1) 'total_asset'
					,am.client_no
		from		dbo.agreement_asset			  aa
					inner join dbo.agreement_main am on am.agreement_no = aa.agreement_no
		where		am.client_no = cm.client_no
		group by	am.client_no
	)						agreement_asset
			outer apply
	(
		select	sum(aaa.billing_amount) 'billing_amount'
		from	dbo.agreement_asset_amortization aaa
				inner join dbo.agreement_asset	 aa on aa.asset_no	   = aaa.asset_no
				inner join dbo.agreement_main	 am on am.agreement_no = aa.agreement_no
		where	am.client_no = cm.client_no
	) amortization
			outer apply
	(
		select	sum(obligation_amount - payment_amount) 'overdue'
		from	dbo.agreement_obligation	  ao
				inner join dbo.AGREEMENT_MAIN am on am.AGREEMENT_NO = ao.AGREEMENT_NO
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) payment_amount
			from	dbo.agreement_obligation_payment aop
			where	aop.obligation_code = ao.code
		)									  aop
		where	am.client_no		= cm.client_no
				and obligation_type = 'OVDP'
				and ao.cre_by		<> 'MIGRASI'
	) obligation ;
	--where	cm.CLIENT_NO = '0078' ;


	--select	distinct
	--		cm.client_no
	--		,cm.client_name
	--		,agreement_asset.total_asset
	--		,agreement_asset.billing_amount
	--		,agreement_asset.overdue
	--from	dbo.client_main cm
	--		--inner join dbo.agreement_main am on cm.client_no = am.client_no
	--		outer apply
	--(
	--	select		count(1)				 'total_asset'
	--				,sum(0) 'billing_amount'
	--				,am.client_no
	--				,0						 'overdue'
	--	from		dbo.agreement_main							am
	--				inner join dbo.agreement_asset				aa on aa.agreement_no	= am.agreement_no
	--				--inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = am.agreement_no
	--				--												   and aa.asset_no	= aaa.asset_no
	--	--left join dbo.agreement_obligation			ao on ao.agreement_no		   = am.agreement_no
	--	--												  and	ao.obligation_type = 'OVDP'
	--	--left join agreement_obligation_payment		aop on aop.obligation_code	   = ao.code
	--	where		am.client_no = cm.client_no
	--	group by	am.client_no
	--)						agreement_asset ;

	select	@rows_count = count(1)
	from	#temp_table
	where	(
				client_no				like '%' + @p_keywords + '%'
				or	client_name			like '%' + @p_keywords + '%'
				or	total_asset			like '%' + @p_keywords + '%'
				or	total_rental_lease	like '%' + @p_keywords + '%'
				or	total_overdue		like '%' + @p_keywords + '%'
			) ;

	select		client_no
				,client_name
				,total_asset
				,total_rental_lease
				,total_overdue
				,@rows_count 'rowcount'
	from		#temp_table
	where		(
					client_no				like '%' + @p_keywords + '%'
					or	client_name			like '%' + @p_keywords + '%'
					or	total_asset			like '%' + @p_keywords + '%'
					or	total_rental_lease	like '%' + @p_keywords + '%'
					or	total_overdue		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then client_no
													 when 2 then client_name
													 when 3 then cast(total_asset as sql_variant)
													 when 4 then cast(total_rental_lease as sql_variant)
													 when 5 then cast(total_overdue as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then client_no
													   when 2 then client_name
													   when 3 then cast(total_asset as sql_variant)
													   when 4 then cast(total_rental_lease as sql_variant)
													   when 5 then cast(total_overdue as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
