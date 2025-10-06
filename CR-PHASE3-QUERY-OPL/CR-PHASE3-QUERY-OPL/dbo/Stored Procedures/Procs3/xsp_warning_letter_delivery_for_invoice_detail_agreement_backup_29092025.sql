CREATE PROCEDURE dbo.xsp_warning_letter_delivery_for_invoice_detail_agreement_backup_29092025
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
	declare 	@rows_count int = 0 
				,@invoice_no nvarchar(50) = replace(@p_invoice_no,'/','.')

	select 	@rows_count = count(1)
	from	invoice_detail ivd
			inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
			inner join dbo.agreement_asset aas on (aas.asset_no = ivd.asset_no)
	where	ivd.invoice_no = @invoice_no
	and		(
				am.agreement_external_no				like '%'+@p_keywords+'%'
				or	ivd.asset_no						like '%'+@p_keywords+'%'
				or	ivd.billing_no						like '%'+@p_keywords+'%'
				or	ivd.description						like '%'+@p_keywords+'%'
				or	aas.monthly_rental_rounded_amount	like '%'+@p_keywords+'%'
				or	ivd.billing_amount					like '%'+@p_keywords+'%'
				or	ivd.ppn_amount						like '%'+@p_keywords+'%'
				or	ivd.pph_amount						like '%'+@p_keywords+'%'
			);

	select	am.agreement_external_no
			,ivd.asset_no
			,ivd.billing_no
			,ivd.description
			,aas.monthly_rental_rounded_amount
			,ivd.billing_amount
			,ivd.ppn_amount
			,ivd.pph_amount
			,@rows_count	 'rowcount'
	from	invoice_detail ivd
			inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
			inner join dbo.agreement_asset aas on (aas.asset_no = ivd.asset_no)
	where	ivd.invoice_no = @invoice_no
	and		(
				am.agreement_external_no				like '%'+@p_keywords+'%'
				or	ivd.asset_no						like '%'+@p_keywords+'%'
				or	ivd.billing_no						like '%'+@p_keywords+'%'
				or	ivd.description						like '%'+@p_keywords+'%'
				or	aas.monthly_rental_rounded_amount	like '%'+@p_keywords+'%'
				or	ivd.billing_amount					like '%'+@p_keywords+'%'
				or	ivd.ppn_amount						like '%'+@p_keywords+'%'
				or	ivd.pph_amount						like '%'+@p_keywords+'%'
			)
	order by	 case
					when @p_sort_by = 'asc' then case @p_order_by
							when 1	then am.agreement_external_no
							when 2	then ivd.asset_no
							when 3	then cast(ivd.billing_no as sql_variant)
							when 4	then ivd.description 
							when 5	then cast(aas.monthly_rental_rounded_amount as sql_variant)
							when 6	then cast(ivd.billing_amount as sql_variant)
							when 7	then cast(ivd.ppn_amount as sql_variant)
							when 8	then cast(ivd.pph_amount as sql_variant)
	end
		end asc
			 ,case
					when @p_sort_by = 'desc' then case @p_order_by
							when 1	then am.agreement_external_no
							when 2	then ivd.asset_no
							when 3	then cast(ivd.billing_no as sql_variant)
							when 4	then ivd.description 
							when 5	then cast(aas.monthly_rental_rounded_amount as sql_variant)
							when 6	then cast(ivd.billing_amount as sql_variant)
							when 7	then cast(ivd.ppn_amount as sql_variant)
							when 8	then cast(ivd.pph_amount as sql_variant)
	end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end
