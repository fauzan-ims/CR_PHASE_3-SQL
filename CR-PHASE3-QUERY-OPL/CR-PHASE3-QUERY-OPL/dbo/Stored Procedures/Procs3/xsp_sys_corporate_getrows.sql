CREATE PROCEDURE dbo.xsp_sys_corporate_getrows
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
	from	sys_corporate
	where	(
				client_code							like '%' + @p_keywords + '%'
				or	full_name						like '%' + @p_keywords + '%'
				or	tax_file_no						like '%' + @p_keywords + '%'
				or	est_date						like '%' + @p_keywords + '%'
				or	corporate_status				like '%' + @p_keywords + '%'
				or	business_type					like '%' + @p_keywords + '%'
				or	subbusiness_type				like '%' + @p_keywords + '%'
				or	corporate_type					like '%' + @p_keywords + '%'
				or	business_experience				like '%' + @p_keywords + '%'
				or	email							like '%' + @p_keywords + '%'
				or	contact_person_name				like '%' + @p_keywords + '%'
				or	contact_person_area_phone_no	like '%' + @p_keywords + '%'
				or	contact_person_phone_no			like '%' + @p_keywords + '%'
			) ;
			 
		select		client_code
					,@rows_count 'rowcount'
		from		sys_corporate
		where		(
						client_code							like '%' + @p_keywords + '%'
						or	full_name						like '%' + @p_keywords + '%'
						or	tax_file_no						like '%' + @p_keywords + '%'
						or	est_date						like '%' + @p_keywords + '%'
						or	corporate_status				like '%' + @p_keywords + '%'
						or	business_type					like '%' + @p_keywords + '%'
						or	subbusiness_type				like '%' + @p_keywords + '%'
						or	corporate_type					like '%' + @p_keywords + '%'
						or	business_experience				like '%' + @p_keywords + '%'
						or	email							like '%' + @p_keywords + '%'
						or	contact_person_name				like '%' + @p_keywords + '%'
						or	contact_person_area_phone_no	like '%' + @p_keywords + '%'
						or	contact_person_phone_no			like '%' + @p_keywords + '%'
					) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then client_code
													when 2 then full_name
													when 3 then tax_file_no
													when 4 then corporate_status
													when 5 then business_type
													when 6 then subbusiness_type
													when 7 then corporate_type
													when 8 then email
													when 9 then contact_person_name
													when 10 then contact_person_area_phone_no
													when 11 then contact_person_phone_no
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then client_code
													when 2 then full_name
													when 3 then tax_file_no
													when 4 then corporate_status
													when 5 then business_type
													when 6 then subbusiness_type
													when 7 then corporate_type
													when 8 then email
													when 9 then contact_person_name
													when 10 then contact_person_area_phone_no
													when 11 then contact_person_phone_no
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

