

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_getrows
(
	 @p_keywords							nvarchar(50)
	,@p_pagenumber							int
	,@p_rowspage							int
	,@p_order_by							int
	,@p_sort_by								nvarchar(5)
	,@p_branch_code							nvarchar(50)
	,@p_status								nvarchar(50)
)
as
begin
	
	declare 	@rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select 		@rows_count = count(1)
	from		dbo.faktur_no_replacement 
	where	branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end 
	and		status		= case @p_status
						  		when 'ALL' then status
						  		else @p_status
						  end
	and		(
			
					code								LIKE 	'%'+@p_keywords+'%'
				or	branch_code							LIKE 	'%'+@p_keywords+'%'
				or	branch_name							LIKE 	'%'+@p_keywords+'%'
				or	convert(varchar(15), date,103)		like 	'%'+@p_keywords+'%'
				or	remarks								LIKE 	'%'+@p_keywords+'%'
				or	status								LIKE 	'%'+@p_keywords+'%'

				);

		select		 code			
					,branch_code	
					,branch_name		
					,convert(varchar(15), date,103)	AS date		
					,remarks AS remark			
					,status			
					,@rows_count	 'rowcount'
		from		faktur_no_replacement
	where	branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end 
	and		status		= case @p_status
						  		when 'ALL' then status
						  		else @p_status
						  END
                          
	and				(
					code								LIKE 	'%'+@p_keywords+'%'
				or	branch_code							LIKE 	'%'+@p_keywords+'%'
				or	branch_name							LIKE 	'%'+@p_keywords+'%'
				or	convert(varchar(15), date,103)		like 	'%'+@p_keywords+'%'
				or	remarks								LIKE 	'%'+@p_keywords+'%'
				or	status								LIKE 	'%'+@p_keywords+'%'
					)
		order by	 case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1	then code		
															when 2	then BRANCH_NAME	
															when 3	then cast(date as sql_variant)	
															when 4	then remarks
															when 5	then status				
														end
					end asc
					,case
						when @p_sort_by = 'desc' then case @p_order_by
															when 1	then code		
															when 2	then BRANCH_NAME	
															when 3	then cast(date as sql_variant)	
															when 4	then remarks
															when 5	then status																			
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
