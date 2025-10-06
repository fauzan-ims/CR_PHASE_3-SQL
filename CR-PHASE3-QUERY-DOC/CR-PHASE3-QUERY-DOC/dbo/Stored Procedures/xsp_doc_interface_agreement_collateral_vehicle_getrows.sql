CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_vehicle_getrows
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

	select	@rows_count = count(1)
	from	doc_interface_agreement_collateral_vehicle
	where	(
				id							like '%' + @p_keywords + '%'
				or	agreement_no			like '%' + @p_keywords + '%'
				or	collateral_no			like '%' + @p_keywords + '%'
				or	plafond_no				like '%' + @p_keywords + '%'
				or	plafond_collateral_no	like '%' + @p_keywords + '%'
				or	remarks					like '%' + @p_keywords + '%'
				or	bpkb_no					like '%' + @p_keywords + '%'
				or	bpkb_date				like '%' + @p_keywords + '%'
				or	bpkb_name				like '%' + @p_keywords + '%'
				or	bpkb_address			like '%' + @p_keywords + '%'
				or	stnk_name				like '%' + @p_keywords + '%'
				or	stnk_exp_date			like '%' + @p_keywords + '%'
				or	stnk_tax_date			like '%' + @p_keywords + '%'
			) ;

	if @p_sort_by = 'asc'
	begin
		select		id
					,agreement_no
					,collateral_no
					,plafond_no
					,plafond_collateral_no
					,remarks
					,bpkb_no
					,bpkb_date
					,bpkb_name
					,bpkb_address
					,stnk_name
					,stnk_exp_date
					,stnk_tax_date
					,@rows_count 'rowcount'
		from		doc_interface_agreement_collateral_vehicle
		where		(
						id							like '%' + @p_keywords + '%'
						or	agreement_no			like '%' + @p_keywords + '%'
						or	collateral_no			like '%' + @p_keywords + '%'
						or	plafond_no				like '%' + @p_keywords + '%'
						or	plafond_collateral_no	like '%' + @p_keywords + '%'
						or	remarks					like '%' + @p_keywords + '%'
						or	bpkb_no					like '%' + @p_keywords + '%'
						or	bpkb_date				like '%' + @p_keywords + '%'
						or	bpkb_name				like '%' + @p_keywords + '%'
						or	bpkb_address			like '%' + @p_keywords + '%'
						or	stnk_name				like '%' + @p_keywords + '%'
						or	stnk_exp_date			like '%' + @p_keywords + '%'
						or	stnk_tax_date			like '%' + @p_keywords + '%'
					)
		order by	case @p_order_by
						when 1 then agreement_no + plafond_no
						when 2 then collateral_no + plafond_collateral_no
						when 3 then bpkb_name + bpkb_no
						when 4 then stnk_name
						when 5 then remarks
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		id
					,agreement_no
					,collateral_no
					,plafond_no
					,plafond_collateral_no
					,remarks
					,bpkb_no
					,bpkb_date
					,bpkb_name
					,bpkb_address
					,stnk_name
					,stnk_exp_date
					,stnk_tax_date
					,@rows_count 'rowcount'
		from		doc_interface_agreement_collateral_vehicle
		where		(
						id							like '%' + @p_keywords + '%'
						or	agreement_no			like '%' + @p_keywords + '%'
						or	collateral_no			like '%' + @p_keywords + '%'
						or	plafond_no				like '%' + @p_keywords + '%'
						or	plafond_collateral_no	like '%' + @p_keywords + '%'
						or	remarks					like '%' + @p_keywords + '%'
						or	bpkb_no					like '%' + @p_keywords + '%'
						or	bpkb_date				like '%' + @p_keywords + '%'
						or	bpkb_name				like '%' + @p_keywords + '%'
						or	bpkb_address			like '%' + @p_keywords + '%'
						or	stnk_name				like '%' + @p_keywords + '%'
						or	stnk_exp_date			like '%' + @p_keywords + '%'
						or	stnk_tax_date			like '%' + @p_keywords + '%'
					)
		order by	case @p_order_by
						when 1 then agreement_no + plafond_no
						when 2 then collateral_no + plafond_collateral_no
						when 3 then bpkb_name + bpkb_no
						when 4 then stnk_name
						when 5 then remarks
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
