CREATE PROCEDURE [dbo].[xsp_lookup_agreement_for_controlcard]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_for_all			nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	BEGIN
		select	@rows_count = count(1)
		from
				(
					select	'ALL' as 'code'
							,'ALL' as 'ext_code'
							,'ALL' as 'name'
					union
					select	AGREEMENT_NO
							,AGREEMENT_EXTERNAL_NO
							,CLIENT_NAME
					from	dbo.asset					
				) as agreement
		where	(
					agreement.ext_code		like '%' + @p_keywords + '%'
					or	agreement.name		like '%' + @p_keywords + '%'
				) ;

			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'ext_code'
									,'ALL' as 'name'
									,@rows_count 'rowcount'
							union
							select	AGREEMENT_NO
									,AGREEMENT_EXTERNAL_NO
									,CLIENT_NAME
									,@rows_count 'rowcount'
							from	dbo.asset
						) as agreement
			where		(
							agreement.ext_code		like '%' + @p_keywords + '%'
							or	agreement.name  like '%' + @p_keywords + '%'
						)

			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then agreement.code
														when 2 then agreement.name
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement.code
														when 2 then agreement.name
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	END
    ELSE
    begin
	select	@rows_count = count(1)
	from	dbo.ASSET
	where	(
				agreement_external_no				            like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			) ;

	select	agreement_no 'code'
			,agreement_external_no 'ext_code'
			,client_name				                    
			,@rows_count 'rowcount'
	from	dbo.ASSET
	where	(
				agreement_external_no				            like '%' + @p_keywords + '%'
				or	client_name				                    like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then agreement_external_no	                    
													when 2 then client_name  
												end
												end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then agreement_external_no	                    
													when 2 then client_name  	
												end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only 
	end
end ;
