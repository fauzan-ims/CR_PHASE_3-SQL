
--created by, Rian at 11/05/2023	

CREATE PROCEDURE [dbo].[xsp_application_asset_detail_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_asset_no   nvarchar(50)
	,@p_type	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_asset_detail aad
	where	aad.asset_no = @p_asset_no
			and	aad.type = @p_type
			and (
					aad.asset_no				like '%' + @p_keywords + '%'
					or	aad.type				like '%' + @p_keywords + '%'
					or	aad.description			like '%' + @p_keywords + '%'
					or	aad.amount				like '%' + @p_keywords + '%'
					or case aad.is_subject_to_purchase when '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
				) ;

	select		aad.id
				,aad.code
				,aad.asset_no
				,aad.type
				,aad.description
				,aad.amount
				,case aad.is_subject_to_purchase when '1' then 'Yes' else 'No' end 'is_subject_to_purchase'
				,@rows_count 'rowcount'
	from		dbo.application_asset_detail aad
	where		aad.asset_no = @p_asset_no
				and	aad.type = @p_type
				and (
						aad.asset_no			like '%' + @p_keywords + '%'
						or	aad.type			like '%' + @p_keywords + '%'
						or	aad.description		like '%' + @p_keywords + '%'
						or	aad.amount			like '%' + @p_keywords + '%'
						or case aad.is_subject_to_purchase when '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then aad.description
													 when 2 then cast(aad.amount as sql_variant)
													 when 3 then case aad.is_subject_to_purchase when '1' then 'Yes' else 'No' end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then aad.description
														when 2 then cast(aad.amount as sql_variant)
														when 3 then case aad.is_subject_to_purchase when '1' then 'Yes' else 'No' end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
