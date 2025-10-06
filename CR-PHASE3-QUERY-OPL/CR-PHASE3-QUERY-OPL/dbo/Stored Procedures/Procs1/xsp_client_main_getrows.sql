CREATE PROCEDURE dbo.xsp_client_main_getrows
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
	from	client_main
	where	(
				code							like '%' + @p_keywords + '%'
				or	client_type					like '%' + @p_keywords + '%'
				or	client_name					like '%' + @p_keywords + '%' 
				or	case is_validate
						when '1' then 'YES'
						else 'NO'
					end							like '%' + @p_keywords + '%'
				or	status_slik_checking		like '%' + @p_keywords + '%'
				or	status_dukcapil_checking	like '%' + @p_keywords + '%'
			) ;
			 
		select		code
					,client_type
					,client_name 
					,case is_validate
						 when '1' then 'YES'
						 else 'NO'
					 end 'is_validate'
					,status_slik_checking
					,status_dukcapil_checking
					,@rows_count 'rowcount'
		from		client_main
		where		(
						code							like '%' + @p_keywords + '%'
						or	client_type					like '%' + @p_keywords + '%'
						or	client_name					like '%' + @p_keywords + '%' 
						or	case is_validate
								when '1' then 'YES'
								else 'NO'
							end							like '%' + @p_keywords + '%'
						or	status_slik_checking		like '%' + @p_keywords + '%'
						or	status_dukcapil_checking	like '%' + @p_keywords + '%'
					) 
		order by case  
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then code
												when 2 then client_type
												when 3 then client_name 
												when 4 then is_validate
												when 5 then status_slik_checking
												when 6 then status_dukcapil_checking
												end
			end asc 
			,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then code
												when 2 then client_type
												when 3 then client_name 
												when 4 then is_validate
												when 5 then status_slik_checking
												when 6 then status_dukcapil_checking
												end
	end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

