---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_refund_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_facility_code nvarchar(50) = 'All'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_refund mr
			inner join dbo.master_facility mf on (mf.code = mr.facility_code)
	where	mr.facility_code	= case @p_facility_code
									when 'ALL' then mr.facility_code
									else @p_facility_code
								  end
			and (
					mr.code							like '%' + @p_keywords + '%'
					or	mr.description				like '%' + @p_keywords + '%'
					or	mf.description				like '%' + @p_keywords + '%'
					or	case mr.is_psak
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
					or	case mr.is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;
				 
		select		mr.code
					,mr.description
					,mf.description	'facility_desc'
					,case mr.is_psak
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_psak'
					,case mr.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from		master_refund mr
					inner join dbo.master_facility mf on (mf.code = mr.facility_code)
		where		mr.facility_code	= case @p_facility_code
											when 'ALL' then mr.facility_code
											else @p_facility_code
										  end
					and (
							mr.code							like '%' + @p_keywords + '%'
							or	mr.description				like '%' + @p_keywords + '%'
							or	mf.description				like '%' + @p_keywords + '%'
							or	case mr.is_psak
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
							or	case mr.is_active
									when '1' then 'Yes'
									else 'No'
								end							like '%' + @p_keywords + '%'
						) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mr.code
													when 2 then mr.description
													when 3 then mf.description
													when 4 then mr.is_psak
													when 5 then mr.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mr.code
													when 2 then mr.description
													when 3 then mf.description
													when 4 then mr.is_psak
													when 5 then mr.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

