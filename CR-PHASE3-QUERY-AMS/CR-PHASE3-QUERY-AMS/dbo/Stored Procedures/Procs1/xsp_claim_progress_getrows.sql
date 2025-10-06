CREATE PROCEDURE dbo.xsp_claim_progress_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_claim_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	claim_progress cps
			LEFT join dbo.sys_general_subcode sgs on (sgs.code = cps.claim_progress_code)
	where	claim_code = @p_claim_code
			and (
					id																			like '%' + @p_keywords + '%'
					or	sgs.description															like '%' + @p_keywords + '%'
					or	convert(varchar(30), claim_progress_date, 103) 							like '%' + @p_keywords + '%'
					or	format(cast(cps.cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 	like '%' + @p_keywords + '%'
					or	claim_progress_remarks													like '%' + @p_keywords + '%'
				) ;

		select		id
					,ISNULL(sgs.description, cps.claim_progress_code) 'description'	
					,format(cast(cps.cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'cre_date'
					,convert(varchar(30), claim_progress_date, 103) 'claim_progress_date'
					,claim_progress_remarks
					,@rows_count 'rowcount'
		from		claim_progress cps
					LEFT join dbo.sys_general_subcode sgs on (sgs.code = cps.claim_progress_code)
		where		claim_code = @p_claim_code
					and (
							id																			like '%' + @p_keywords + '%'
							or	sgs.description															like '%' + @p_keywords + '%'
							or	convert(varchar(30), claim_progress_date, 103) 							like '%' + @p_keywords + '%'
							or	format(cast(cps.cre_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 	like '%' + @p_keywords + '%'
							or	claim_progress_remarks													like '%' + @p_keywords + '%'
						)
	
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then cast(cps.cre_date as sql_variant)
													when 2 then cast(claim_progress_date as sql_variant) 
													when 3 then sgs.description
													when 4 then claim_progress_remarks
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then cast(cps.cre_date as sql_variant)
													when 2 then cast(claim_progress_date as sql_variant) 
													when 3 then sgs.description
													when 4 then claim_progress_remarks
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

