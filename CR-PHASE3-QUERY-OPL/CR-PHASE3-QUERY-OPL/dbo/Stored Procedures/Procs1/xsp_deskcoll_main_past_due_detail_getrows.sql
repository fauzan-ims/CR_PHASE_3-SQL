CREATE PROCEDURE dbo.xsp_deskcoll_main_past_due_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_id				int
)
as
begin
	declare @rows_count int = 0 ;
	select	@rows_count = count(1)
	from	deskcoll_main dmn
			inner join dbo.agreement_main am on am.agreement_no = dmn.agreement_no
			inner join dbo.agreement_client_address aca on aca.agreement_no = am.agreement_no
	where	dmn.id	= @p_id
			and	(
					dmn.id											like '%' + @p_keywords + '%'
					or	aca.address									like '%' + @p_keywords + '%'
					or	aca.province_name							like '%' + @p_keywords + '%'
					or	aca.city_name								like '%' + @p_keywords + '%'
					or	aca.sub_district							like '%' + @p_keywords + '%'
					or	aca.village									like '%' + @p_keywords + '%'
					or	aca.rt										like '%' + @p_keywords + '%'
					or	aca.rw										like '%' + @p_keywords + '%'
					or	am.area_phone_no_1							like '%' + @p_keywords + '%'
					or	am.phone_no_1								like '%' + @p_keywords + '%'
					or	am.area_phone_no_2							like '%' + @p_keywords + '%'
					or	am.phone_no_2								like '%' + @p_keywords + '%'

					
				) ;

		select		dmn.id
					,aca.address			
					,aca.province_name	
					,aca.city_name		
					,aca.sub_district	
					,aca.village			
					,aca.rt				
					,aca.rw				
					,am.area_phone_no_1	
					,am.phone_no_1		
					,am.area_phone_no_2	
					,am.phone_no_2									
					,@rows_count 'rowcount'
		from		deskcoll_main dmn
					inner join dbo.agreement_main am on am.agreement_no = dmn.agreement_no
					inner join dbo.agreement_client_address aca on aca.agreement_no = am.agreement_no
		where		dmn.id	= @p_id
					and	(
							dmn.id											like '%' + @p_keywords + '%'
							or	aca.address									like '%' + @p_keywords + '%'
							or	aca.province_name							like '%' + @p_keywords + '%'
							or	aca.city_name								like '%' + @p_keywords + '%'
							or	aca.sub_district							like '%' + @p_keywords + '%'
							or	aca.village									like '%' + @p_keywords + '%'
							or	aca.rt										like '%' + @p_keywords + '%'
							or	aca.rw										like '%' + @p_keywords + '%'
							or	am.area_phone_no_1							like '%' + @p_keywords + '%'
							or	am.phone_no_1								like '%' + @p_keywords + '%'
							or	am.area_phone_no_2							like '%' + @p_keywords + '%'
							or	am.phone_no_2								like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then dmn.id							
													when 2 then aca.address					
													when 3 then aca.province_name			
													when 4 then aca.city_name				
													when 5 then aca.sub_district			
													when 6 then	aca.village					
													when 7 then	aca.rt						
													when 8 then	aca.rw						
													when 9 then	am.area_phone_no_1			
													when 10 then am.phone_no_1				
													when 11 then am.area_phone_no_2			
													when 12 then am.phone_no_2	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dmn.id							
														when 2 then aca.address					
														when 3 then aca.province_name			
														when 4 then aca.city_name				
														when 5 then aca.sub_district			
														when 6 then	aca.village					
														when 7 then	aca.rt						
														when 8 then	aca.rw						
														when 9 then	am.area_phone_no_1			
														when 10 then am.phone_no_1				
														when 11 then am.area_phone_no_2			
														when 12 then am.phone_no_2	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
