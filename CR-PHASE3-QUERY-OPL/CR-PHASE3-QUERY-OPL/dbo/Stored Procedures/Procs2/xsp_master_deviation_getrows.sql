
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_deviation_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_deviation md
			inner join dbo.master_facility mf on (mf.code = md.facility_code)
	where	(
				md.description					like 	'%'+@p_keywords+'%'
				or	md.type						like 	'%'+@p_keywords+'%'
				or	mf.description				like 	'%'+@p_keywords+'%'
				or	 case is_manual
						 when '1' then 'Yes'
						 else 'No'
					 end 						like 	'%'+@p_keywords+'%'
				or	 case md.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 						like 	'%'+@p_keywords+'%'
		);

	select	md.code
			,md.description
			,type
			,mf.description	'facility_desc'
			,case is_manual
					when '1' then 'Yes'
					else 'No'
				end 	'is_manual'
			,case md.is_active
					when '1' then 'Yes'
					else 'No'
				end 	'is_active'
			,@rows_count	 'rowcount'
	from	master_deviation md
			inner join dbo.master_facility mf on (mf.code = md.facility_code)
	where	(
				md.description					like 	'%'+@p_keywords+'%'
				or	md.type						like 	'%'+@p_keywords+'%'
				or	mf.description				like 	'%'+@p_keywords+'%'
				or	 case is_manual
							when '1' then 'Yes'
							else 'No'
						end 						like 	'%'+@p_keywords+'%'
				or	 case md.is_active
							when '1' then 'Yes'
							else 'No'
						end 						like 	'%'+@p_keywords+'%'
		)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1	then md.description
														when 2	then md.type
														when 3	then mf.description
														when 4	then is_manual
														when 5	then md.is_active
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1	then md.description
														when 2	then md.type
														when 3	then mf.description
														when 4	then is_manual
														when 5	then md.is_active
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end

