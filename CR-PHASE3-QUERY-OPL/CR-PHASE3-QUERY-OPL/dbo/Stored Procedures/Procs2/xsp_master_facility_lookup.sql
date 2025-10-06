CREATE PROCEDURE dbo.xsp_master_facility_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_for_all	   nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;
	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
				(
					select	'ALL' as 'code'
							,'ALL' as 'description'
					union
					select	code
							,description
					from	master_facility
					where	is_active = '1'
				) as facility
		where	(
					facility.code like '%' + @p_keywords + '%'
					or	facility.description like '%' + @p_keywords + '%'
				) ;

			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'description'
									,@rows_count 'rowcount'
							union
							select	code
									,description
									,@rows_count 'rowcount'
							from	master_facility
							where	is_active = '1'
						) as facility
			where		(
							facility.code like '%' + @p_keywords + '%'
							or	facility.description like '%' + @p_keywords + '%'
						)

			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
													when 1 then facility.code
													when 2 then facility.description
						  						end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then facility.code
														when 2 then facility.description
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
    else
	begin
		select	@rows_count = count(1)
		from	master_facility
		where	is_active = '1'
				and (
						code							like '%' + @p_keywords + '%'
						or	description					like '%' + @p_keywords + '%'
					) ;

			select		code
						,description
						,@rows_count 'rowcount'
			from		master_facility
			where		is_active = '1'
						and (
								code							like '%' + @p_keywords + '%'
								or	description					like '%' + @p_keywords + '%'
							)
			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then description
						  						end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then DESCRIPTION
                                                 end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
