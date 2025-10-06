CREATE PROCEDURE dbo.xsp_master_application_flow_detail_getrows

(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_application_flow_code nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_application_flow_detail mafd
			inner join dbo.master_workflow mw on (mw.code = mafd.workflow_code)
	where	application_flow_code = @p_application_flow_code
			and (
				id						like 	'%'+@p_keywords+'%'
				or	mw.description		like 	'%'+@p_keywords+'%'
				or	mafd.is_approval	like 	'%'+@p_keywords+'%'
				or	mafd.is_sign		like 	'%'+@p_keywords+'%'
				or	order_key			like 	'%'+@p_keywords+'%'
			); 
		select	id
				,mw.description 'workflow_desc'
				,mafd.is_approval
				,mafd.is_sign
				,order_key
				,@rows_count	 'rowcount'
		from	master_application_flow_detail mafd
				inner join dbo.master_workflow mw on (mw.code = mafd.workflow_code)
		where	application_flow_code = @p_application_flow_code
				and (
					id						like 	'%'+@p_keywords+'%'
					or	mw.description		like 	'%'+@p_keywords+'%'
					or	mafd.is_approval	like 	'%'+@p_keywords+'%'
					or	mafd.is_sign		like 	'%'+@p_keywords+'%'
					or	order_key			like 	'%'+@p_keywords+'%'
				) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then mw.description
													when 2	then mafd.is_sign
													when 3	then mafd.is_approval
													when 4	then cast(order_key as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1	then mw.description
													when 2	then mafd.is_sign
													when 3	then mafd.is_approval
													when 4	then cast(order_key as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end
