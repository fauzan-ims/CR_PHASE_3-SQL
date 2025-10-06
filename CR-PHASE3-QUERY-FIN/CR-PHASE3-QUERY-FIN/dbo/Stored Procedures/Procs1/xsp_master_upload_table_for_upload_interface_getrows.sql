CREATE PROCEDURE dbo.xsp_master_upload_table_for_upload_interface_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_upload_table
	where	is_active = '1'
	and		(
				description						like '%' + @p_keywords + '%'
				or	tabel_name					like '%' + @p_keywords + '%'
			) ;

		select	code
				,description		
				,tabel_name		
				,template_name	
				,sp_validate_name
				,sp_post_name	
				,sp_cancel_name	
				,case is_active
					when '1' then 'Yes'
					else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
		from	master_upload_table
		where	is_active = '1'
		and		(
					description						like '%' + @p_keywords + '%'
					or	tabel_name					like '%' + @p_keywords + '%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then description
														when 2 then tabel_name
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then description
														when 2 then tabel_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
