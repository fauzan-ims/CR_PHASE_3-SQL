CREATE PROCEDURE dbo.xsp_sys_client_negative_and_warning_getrows
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
	from	sys_client_negative_and_warning
	where	(
				code						like '%' + @p_keywords + '%'
				or	status					like '%' + @p_keywords + '%'
				or	source					like '%' + @p_keywords + '%'
				or	client_type				like '%' + @p_keywords + '%'
				or	client_id				like '%' + @p_keywords + '%'
				or	fullname				like '%' + @p_keywords + '%'
				or	mother_maiden_name		like '%' + @p_keywords + '%'
				or	dob						like '%' + @p_keywords + '%'
				or	id_no					like '%' + @p_keywords + '%'
				or	tax_file_no				like '%' + @p_keywords + '%'
				or	est_date				like '%' + @p_keywords + '%'
				or	entry_date				like '%' + @p_keywords + '%'
				or	entry_reason			like '%' + @p_keywords + '%'
				or	exit_date				like '%' + @p_keywords + '%'
				or	exit_reason				like '%' + @p_keywords + '%'
			) ;
			 
		select		code
					,@rows_count 'rowcount'
		from		sys_client_negative_and_warning
		where		(
						code						like '%' + @p_keywords + '%'
						or	status					like '%' + @p_keywords + '%'
						or	source					like '%' + @p_keywords + '%'
						or	client_type				like '%' + @p_keywords + '%'
						or	client_id				like '%' + @p_keywords + '%'
						or	fullname				like '%' + @p_keywords + '%'
						or	mother_maiden_name		like '%' + @p_keywords + '%'
						or	dob						like '%' + @p_keywords + '%'
						or	id_no					like '%' + @p_keywords + '%'
						or	tax_file_no				like '%' + @p_keywords + '%'
						or	est_date				like '%' + @p_keywords + '%'
						or	entry_date				like '%' + @p_keywords + '%'
						or	entry_reason			like '%' + @p_keywords + '%'
						or	exit_date				like '%' + @p_keywords + '%'
						or	exit_reason				like '%' + @p_keywords + '%'
					) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then status
													when 3 then source
													when 4 then client_type
													when 5 then client_id
													when 6 then fullname
													when 7 then mother_maiden_name
													when 8 then id_no
													when 9 then tax_file_no
													when 10 then entry_reason
													when 11 then exit_reason
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then status
													when 3 then source
													when 4 then client_type
													when 5 then client_id
													when 6 then fullname
													when 7 then mother_maiden_name
													when 8 then id_no
													when 9 then tax_file_no
													when 10 then entry_reason
													when 11 then exit_reason
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

