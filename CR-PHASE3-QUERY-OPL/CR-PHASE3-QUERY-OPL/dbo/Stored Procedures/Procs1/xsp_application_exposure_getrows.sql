CREATE PROCEDURE dbo.xsp_application_exposure_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_exposure
	where	application_no = @p_application_no
			and (
					agreement_no								  like '%' + @p_keywords + '%'
					or	convert(varchar(30), agreement_date, 103) like '%' + @p_keywords + '%'
					or	amount_finance_amount			          like '%' + @p_keywords + '%'
					or	description							      like '%' + @p_keywords + '%'
					or	installment_amount						  like '%' + @p_keywords + '%'
					or	facility_name						      like '%' + @p_keywords + '%'
					or	os_installment_amount				      like '%' + @p_keywords + '%'
					or	os_tenor							      like '%' + @p_keywords + '%'
					or	tenor								      like '%' + @p_keywords + '%'
					or	relation_type						      like '%' + @p_keywords + '%'
					or	ovd_installment_amount				      like '%' + @p_keywords + '%'
					or	ovd_days								  like '%' + @p_keywords + '%'
					or	max_ovd_days							  like '%' + @p_keywords + '%'
					or	group_name	 							  like '%' + @p_keywords + '%'
				) ;

	select		application_no
				,agreement_no
				,convert(varchar(30), agreement_date, 103) 'agreement_date'
				,amount_finance_amount
				,description
				,installment_amount
				,facility_name
				,os_installment_amount
				,os_tenor
				,tenor
				,relation_type
				,ovd_installment_amount
				,ovd_days
				,max_ovd_days
				,group_name
				,@rows_count 'rowcount'
	from		application_exposure
	where		application_no = @p_application_no
				and (
						agreement_no								  like '%' + @p_keywords + '%'
						or	convert(varchar(30), agreement_date, 103) like '%' + @p_keywords + '%'
						or	amount_finance_amount			          like '%' + @p_keywords + '%'
						or	description							      like '%' + @p_keywords + '%'
						or	installment_amount						  like '%' + @p_keywords + '%'
						or	facility_name						      like '%' + @p_keywords + '%'
						or	os_installment_amount				      like '%' + @p_keywords + '%'
						or	os_tenor							      like '%' + @p_keywords + '%'
						or	tenor								      like '%' + @p_keywords + '%'
						or	relation_type						      like '%' + @p_keywords + '%'
						or	ovd_installment_amount				      like '%' + @p_keywords + '%'
						or	ovd_days								  like '%' + @p_keywords + '%'
						or	max_ovd_days							  like '%' + @p_keywords + '%'
						or	group_name	 							  like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_no + group_name
													 when 2 then convert(varchar(30), agreement_date, 103)
													 when 3 then cast(ovd_days as sql_variant)
													 when 4 then relation_type + description
													 when 5 then facility_name
													 when 6 then cast(tenor as sql_variant)
													 when 7 then cast(amount_finance_amount as sql_variant)
													 when 8 then cast(ovd_installment_amount as sql_variant)
													 when 9 then cast(installment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then agreement_no
													 when 2 then convert(varchar(30), agreement_date, 103)
													 when 3 then cast(ovd_days as sql_variant)
													 when 4 then relation_type + description
													 when 5 then facility_name
													 when 6 then cast(tenor as sql_variant)
													 when 7 then cast(amount_finance_amount as sql_variant)
													 when 8 then cast(ovd_installment_amount as sql_variant)
													 when 9 then cast(installment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

