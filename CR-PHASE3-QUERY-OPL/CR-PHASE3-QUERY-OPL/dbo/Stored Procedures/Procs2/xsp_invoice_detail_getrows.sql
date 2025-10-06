CREATE PROCEDURE dbo.xsp_invoice_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_invoice_no		nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	invoice_detail ivd
			inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
			inner join dbo.agreement_asset aas on (aas.asset_no = ivd.asset_no)
	where	ivd.invoice_no = @p_invoice_no
	and		(
				ivd.agreement_no						like '%'+@p_keywords+'%'
				or	ivd.asset_no						like '%'+@p_keywords+'%'
				or	am.client_name						like '%'+@p_keywords+'%'
				or	ivd.description						like '%'+@p_keywords+'%'
				or	ivd.quantity						like '%'+@p_keywords+'%'
				or	ivd.billing_amount					like '%'+@p_keywords+'%'
				or	ivd.total_amount					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_01					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_02					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_03					like '%'+@p_keywords+'%'
				or	aas.fa_name							like '%'+@p_keywords+'%'
				or	am.agreement_external_no			like '%'+@p_keywords+'%'
			);

	select	ivd.id
			,ivd.invoice_no
			,ivd.agreement_no
			,am.agreement_external_no
			,am.client_name
			,ivd.asset_no
			,ivd.billing_no
			,ivd.description
			,ivd.quantity
			,ivd.billing_amount
			,ivd.discount_amount
			,ivd.ppn_amount
			,ivd.pph_amount
			,ivd.total_amount 
			,aas.fa_reff_no_01
			,aas.fa_reff_no_02
			,aas.fa_reff_no_03
			,aas.fa_name + ' Plat No : ' + aas.fa_reff_no_01 + ', Chasis No : ' + aas.fa_reff_no_02 + ', Engine No : ' + aas.fa_reff_no_03 as 'fa_name'
			,@rows_count	 'rowcount'
	from	invoice_detail ivd
			inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
			inner join dbo.agreement_asset aas on (aas.asset_no = ivd.asset_no)
	where	ivd.invoice_no = @p_invoice_no
	and		(
				ivd.agreement_no						like '%'+@p_keywords+'%'
				or	ivd.asset_no						like '%'+@p_keywords+'%'
				or	am.client_name						like '%'+@p_keywords+'%'
				or	ivd.description						like '%'+@p_keywords+'%'
				or	ivd.quantity						like '%'+@p_keywords+'%'
				or	ivd.billing_amount					like '%'+@p_keywords+'%'
				or	ivd.total_amount					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_01					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_02					like '%'+@p_keywords+'%'
				or	aas.fa_reff_no_03					like '%'+@p_keywords+'%'
				or	aas.fa_name							like '%'+@p_keywords+'%'
				or	am.agreement_external_no			like '%'+@p_keywords+'%'
			)
	order by	 case
					when @p_sort_by = 'asc' then case @p_order_by
							when 1	then am.agreement_external_no
							when 2	then ivd.asset_no
							when 3	then cast(ivd.description as sql_variant)
							when 4	then cast(ivd.quantity as sql_variant)
							when 5	then cast(ivd.billing_amount as sql_variant)
							when 6	then cast(ivd.total_amount as sql_variant)
	end
		end asc
			 ,case
					when @p_sort_by = 'desc' then case @p_order_by
							when 1	then am.agreement_external_no
							when 2	then ivd.asset_no
							when 3	then cast(ivd.description as sql_variant)
							when 4	then cast(ivd.quantity as sql_variant)
							when 5	then cast(ivd.billing_amount as sql_variant)
							when 6	then cast(ivd.total_amount as sql_variant)
	end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end
