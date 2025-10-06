CREATE PROCEDURE dbo.xsp_doc_interface_agreement_update_getrows
(
	@p_keywords	         nvarchar(50)
	,@p_pagenumber       int
	,@p_rowspage         int
	,@p_order_by         int
	,@p_sort_by	         nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;
	
	select	@rows_count = count(1)
	from	dbo.doc_interface_agreement_update diau
			left join dbo.agreement_main am on (am.agreement_no = diau.agreement_no)
	where	(
				am.agreement_external_no						      like '%' + @p_keywords + '%'
				or	diau.client_name							      like '%' + @p_keywords + '%'
				or	diau.agreement_sub_status						  like '%' + @p_keywords + '%'
				or	diau.agreement_status						      like '%' + @p_keywords + '%'
				or	convert(varchar(30), diau.termination_date, 103)  like '%' + @p_keywords + '%'
				or	diau.termination_status							  like '%' + @p_keywords + '%'
				or	diau.agreement_status							  like '%' + @p_keywords + '%'
			) ;

		select		agreement_external_no
                    ,diau.agreement_status
                    ,diau.agreement_sub_status
                    ,diau.termination_date
                    ,diau.termination_status
					,diau.agreement_status
                    ,diau.client_name
					,@rows_count 'rowcount'
		from		doc_interface_agreement_update diau
					left join dbo.agreement_main am on (am.agreement_no = diau.agreement_no)
		where		(
						am.agreement_external_no						      like '%' + @p_keywords + '%'
						or	diau.client_name							      like '%' + @p_keywords + '%'
						or	diau.agreement_sub_status						  like '%' + @p_keywords + '%'
						or	diau.agreement_status						      like '%' + @p_keywords + '%'
						or	convert(varchar(30), diau.termination_date, 103)  like '%' + @p_keywords + '%'
						or	diau.termination_status							  like '%' + @p_keywords + '%'
						or	diau.agreement_status							  like '%' + @p_keywords + '%'
					)
		order by case	
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then am.agreement_external_no + diau.client_name
													when 2 then diau.agreement_sub_status
													when 3 then cast(diau.termination_date as sql_variant)
													when 4 then diau.termination_status
													when 5 then diau.agreement_status
												end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then am.agreement_external_no + diau.client_name
															when 2 then diau.agreement_sub_status
															when 3 then cast(diau.termination_date as sql_variant)
															when 4 then diau.termination_status
															when 5 then diau.agreement_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
