CREATE procedure [dbo].[xsp_warning_letter_delivery_address_lookup]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
BEGIN
	DECLARE @rows_count INT = 0 ;

	select	@rows_count = count(1)
	from	warning_letter_delivery wld
			outer apply
			(
				select	DISTINCT
						b.billing_to_address
						,b.billing_to_phone_no
						,b.deliver_to_name
						,b.billing_to_npwp
						,b.email
				from	dbo.agreement_main			   a
						inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
				where	a.client_no = wld.client_no
				and a.AGREEMENT_STATUS = 'GO LIVE'
			) taskAgg
	where	wld.code = @p_code
	and		(
				taskAgg.billing_to_address			like '%' + @p_keywords + '%'
				or	taskagg.deliver_to_name			like '%' + @p_keywords + '%'
				or	taskagg.billing_to_npwp			like '%' + @p_keywords + '%'
				or	taskagg.billing_to_phone_no		like '%' + @p_keywords + '%'
				or	taskagg.email					likE '%' + @p_keywords + '%'
			) ;

	select	taskagg.billing_to_address		'delivery_address'
			,taskagg.deliver_to_name		'delivery_to_name'
			,taskagg.billing_to_npwp		'client_npwp'
			,taskagg.billing_to_phone_no	'client_phone_no'
			,taskagg.email					'client_email'
			,@rows_count 'rowcount'
	from	warning_letter_delivery wld
			outer apply
			(
				select	DISTINCT
						b.billing_to_address
						,b.billing_to_phone_no
						,b.deliver_to_name
						,b.billing_to_npwp
						,b.email
				from	dbo.agreement_main			   a
						inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
				where	a.client_no = wld.client_no
				and a.AGREEMENT_STATUS = 'GO LIVE' and b.ASSET_STATUS = 'RENTED'
			) taskAgg
	where	wld.code = @p_code
	and		(
				taskAgg.billing_to_address			like '%' + @p_keywords + '%'
				or	taskagg.deliver_to_name			like '%' + @p_keywords + '%'
				or	taskagg.billing_to_npwp			like '%' + @p_keywords + '%'
				or	taskagg.billing_to_phone_no		like '%' + @p_keywords + '%'
				or	taskagg.email					likE '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then taskagg.billing_to_address
													 when 2 then taskagg.billing_to_npwp
													 when 3 then taskagg.billing_to_phone_no
													 when 4 then taskagg.email
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then taskagg.billing_to_address
													 when 2 then taskagg.billing_to_npwp
													 when 3 then taskagg.billing_to_phone_no
													 when 4 then taskagg.email
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
