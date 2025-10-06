CREATE PROCEDURE [dbo].[xsp_claim_doc_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_claim_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	claim_doc cd
	where	cd.claim_code = @p_claim_code
			and (
					cd.document_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), cd.document_date, 103)	like '%' + @p_keywords + '%'
					or	cd.document_remarks							like '%' + @p_keywords + '%'
					or	cd.file_name								like '%' + @p_keywords + '%'
					or	cd.paths									like '%' + @p_keywords + '%'
					or	case cd.is_required
							when '1' then '*'
							else 'empty'
						end											like '%' + @p_keywords + '%'
				) ;

		select		cd.id
					--,cd.document_code
					,cd.document_name
					,convert(varchar(30), cd.document_date, 103) 'document_date'
					,cd.document_remarks
					,isnull(cd.file_name,'') 'file_name'
					,isnull(cd.paths,'') 'paths'
					,case cd.is_required
						 when '1' then '*'
						 else 'empty'
					 end 'is_required'
					,@rows_count 'rowcount'
		from		claim_doc cd
		where		cd.claim_code = @p_claim_code
					and (
							cd.document_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), cd.document_date, 103)	like '%' + @p_keywords + '%'
							or	cd.document_remarks							like '%' + @p_keywords + '%'
							or	cd.file_name								like '%' + @p_keywords + '%'
							or	cd.paths									like '%' + @p_keywords + '%'
							or	case cd.is_required
									when '1' then '*'
									else 'empty'
								end											like '%' + @p_keywords + '%'
						)
		order by case 
					when @p_sort_by = 'asc' then case @p_order_by
													when 1  then cd.document_name
													when 2  then cast(cd.document_date as sql_variant)
													when 3  then cd.document_remarks
													when 4  then cd.file_name
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1  then cd.document_name
															when 2  then cast(cd.document_date as sql_variant)
															when 3  then cd.document_remarks
															when 4  then cd.file_name
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;

