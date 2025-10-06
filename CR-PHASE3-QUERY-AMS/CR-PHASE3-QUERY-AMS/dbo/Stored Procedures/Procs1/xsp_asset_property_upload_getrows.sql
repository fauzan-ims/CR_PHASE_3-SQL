CREATE procedure dbo.xsp_asset_property_upload_getrows
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
	from	asset_property_upload
	where	(
				fa_upload_id like '%' + @p_keywords + '%'
				or	file_name like '%' + @p_keywords + '%'
				or	upload_no like '%' + @p_keywords + '%'
				or	asset_code like '%' + @p_keywords + '%'
				or	imb_no like '%' + @p_keywords + '%'
				or	certificate_no like '%' + @p_keywords + '%'
				or	land_size like '%' + @p_keywords + '%'
				or	building_size like '%' + @p_keywords + '%'
				or	status_of_ruko like '%' + @p_keywords + '%'
				or	number_of_ruko_and_floor like '%' + @p_keywords + '%'
				or	total_square like '%' + @p_keywords + '%'
				or	vat like '%' + @p_keywords + '%'
				or	no_lease_agreement like '%' + @p_keywords + '%'
				or	date_of_lease_agreement like '%' + @p_keywords + '%'
				or	land_and_building_tax like '%' + @p_keywords + '%'
				or	security_deposit like '%' + @p_keywords + '%'
				or	penalty like '%' + @p_keywords + '%'
				or	owner like '%' + @p_keywords + '%'
				or	address like '%' + @p_keywords + '%'
				or	purchase like '%' + @p_keywords + '%'
				or	total_rental_period like '%' + @p_keywords + '%'
				or	rental_period like '%' + @p_keywords + '%'
				or	rental_price_per_year like '%' + @p_keywords + '%'
				or	rental_price_per_month like '%' + @p_keywords + '%'
				or	total_rental_price like '%' + @p_keywords + '%'
				or	start_rental_date like '%' + @p_keywords + '%'
				or	end_rental_date like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
			) ;

	select		fa_upload_id
				,file_name
				,upload_no
				,asset_code
				,imb_no
				,certificate_no
				,land_size
				,building_size
				,status_of_ruko
				,number_of_ruko_and_floor
				,total_square
				,vat
				,no_lease_agreement
				,date_of_lease_agreement
				,land_and_building_tax
				,security_deposit
				,penalty
				,owner
				,address
				,purchase
				,total_rental_period
				,rental_period
				,rental_price_per_year
				,rental_price_per_month
				,total_rental_price
				,start_rental_date
				,end_rental_date
				,remark
				,@rows_count 'rowcount'
	from		asset_property_upload
	where		(
					fa_upload_id like '%' + @p_keywords + '%'
					or	file_name like '%' + @p_keywords + '%'
					or	upload_no like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	imb_no like '%' + @p_keywords + '%'
					or	certificate_no like '%' + @p_keywords + '%'
					or	land_size like '%' + @p_keywords + '%'
					or	building_size like '%' + @p_keywords + '%'
					or	status_of_ruko like '%' + @p_keywords + '%'
					or	number_of_ruko_and_floor like '%' + @p_keywords + '%'
					or	total_square like '%' + @p_keywords + '%'
					or	vat like '%' + @p_keywords + '%'
					or	no_lease_agreement like '%' + @p_keywords + '%'
					or	date_of_lease_agreement like '%' + @p_keywords + '%'
					or	land_and_building_tax like '%' + @p_keywords + '%'
					or	security_deposit like '%' + @p_keywords + '%'
					or	penalty like '%' + @p_keywords + '%'
					or	owner like '%' + @p_keywords + '%'
					or	address like '%' + @p_keywords + '%'
					or	purchase like '%' + @p_keywords + '%'
					or	total_rental_period like '%' + @p_keywords + '%'
					or	rental_period like '%' + @p_keywords + '%'
					or	rental_price_per_year like '%' + @p_keywords + '%'
					or	rental_price_per_month like '%' + @p_keywords + '%'
					or	total_rental_price like '%' + @p_keywords + '%'
					or	start_rental_date like '%' + @p_keywords + '%'
					or	end_rental_date like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then file_name
													 when 2 then upload_no
													 when 3 then asset_code
													 when 4 then imb_no
													 when 5 then certificate_no
													 when 6 then status_of_ruko
													 when 7 then number_of_ruko_and_floor
													 when 8 then total_square
													 when 9 then no_lease_agreement
													 when 10 then land_and_building_tax
													 when 11 then owner
													 when 12 then address
													 when 13 then purchase
													 when 14 then total_rental_period
													 when 15 then rental_period
													 when 16 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then file_name
													   when 2 then upload_no
													   when 3 then asset_code
													   when 4 then imb_no
													   when 5 then certificate_no
													   when 6 then status_of_ruko
													   when 7 then number_of_ruko_and_floor
													   when 8 then total_square
													   when 9 then no_lease_agreement
													   when 10 then land_and_building_tax
													   when 11 then owner
													   when 12 then address
													   when 13 then purchase
													   when 14 then total_rental_period
													   when 15 then rental_period
													   when 16 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
