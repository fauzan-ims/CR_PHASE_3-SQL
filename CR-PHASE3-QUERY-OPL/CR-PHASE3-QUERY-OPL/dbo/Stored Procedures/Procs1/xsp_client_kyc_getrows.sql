CREATE PROCEDURE [dbo].[xsp_client_kyc_getrows]
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
	from	client_kyc
	where	(
				client_code				like '%' + @p_keywords + '%'
				or	ao_remark			like '%' + @p_keywords + '%'
				or	ao_source_fund		like '%' + @p_keywords + '%'
				or	result_status		like '%' + @p_keywords + '%'
				or	result_remark		like '%' + @p_keywords + '%' 
				or	kyc_officer_code	like '%' + @p_keywords + '%'
				or	kyc_officer_name	like '%' + @p_keywords + '%'
			) ;

	select		client_code
				,ao_remark
				,ao_source_fund
				,result_status
				,result_remark 
				,kyc_officer_code
				,kyc_officer_name
				,@rows_count 'rowcount'
	from		client_kyc
	where		(
					client_code				like '%' + @p_keywords + '%'
					or	ao_remark			like '%' + @p_keywords + '%'
					or	ao_source_fund		like '%' + @p_keywords + '%'
					or	result_status		like '%' + @p_keywords + '%'
					or	result_remark		like '%' + @p_keywords + '%' 
					or	kyc_officer_code	like '%' + @p_keywords + '%'
					or	kyc_officer_name	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then client_code
													 when 2 then ao_remark
													 when 3 then ao_source_fund
													 when 4 then result_status
													 when 5 then result_remark 
													 when 6 then kyc_officer_code
													 when 7 then kyc_officer_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then client_code
													 when 2 then ao_remark
													 when 3 then ao_source_fund
													 when 4 then result_status
													 when 5 then result_remark 
													 when 6 then kyc_officer_code
													 when 7 then kyc_officer_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

