CREATE PROCEDURE dbo.xsp_sys_general_subcode_lookup_for_register_detail	
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_register_code	nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_general_subcode sgs
	where	sgs.is_active = '1'
	and		not exists
			(
				select  service_code
				from	dbo.register_detail 
				where	service_code		= sgs.code
				and		register_code		= @p_register_code
			)
	and		sgs.general_code = 'PBSSVC'
	and		(
					description like '%' + @p_keywords + '%'
			) ;

		select		code
					,description
					,is_active
					,@rows_count 'rowcount'
		from		sys_general_subcode sgs
		where	sgs.is_active = '1'
		and		not exists
				(
					select  service_code
					from	dbo.register_detail 
					where	service_code		= sgs.code
					and		register_code		= @p_register_code
				)
		and		sgs.general_code = 'PBSSVC'
		and		(
						description like '%' + @p_keywords + '%'
				)  
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
