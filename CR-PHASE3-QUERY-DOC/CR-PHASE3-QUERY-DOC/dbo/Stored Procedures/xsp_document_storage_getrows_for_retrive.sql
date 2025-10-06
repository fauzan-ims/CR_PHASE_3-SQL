CREATE PROCEDURE dbo.xsp_document_storage_getrows_for_retrive
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_storage_status  nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	END

	select	@rows_count = count(1)
	from	document_storage
	where	branch_code		= case @p_branch_code
									  when 'ALL' then branch_code
									  else @p_branch_code
							  end
			and storage_status	= case @p_storage_status
										when 'ALL' then storage_status
										else @p_storage_status
									end
			and storage_type = 'RETRIVE'
			and (
					branch_name									like '%' + @p_keywords + '%'
					or	storage_status							like '%' + @p_keywords + '%'
					or	remark									like '%' + @p_keywords + '%'
					or	convert(varchar(30), storage_date, 103)	like '%' + @p_keywords + '%'
					or	code									like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,storage_status
					,remark
					,convert(varchar(30), storage_date, 103) 'storage_date'	
					,@rows_count 'rowcount'
		from	document_storage
		where	branch_code		= case @p_branch_code
									  when 'ALL' then branch_code
									  else @p_branch_code
							  end
				and storage_status	= case @p_storage_status
										when 'ALL' then storage_status
										else @p_storage_status
									end
				and storage_type = 'RETRIVE'
				and (
						branch_name									like '%' + @p_keywords + '%'
						or	storage_status							like '%' + @p_keywords + '%'
						or	remark									like '%' + @p_keywords + '%'
						or	convert(varchar(30), storage_date, 103)	like '%' + @p_keywords + '%'
						or	code									like '%' + @p_keywords + '%'
					)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then branch_name
													when 3 then cast(storage_date as sql_variant)
													when 4 then remark
													when 5 then storage_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name
														when 3 then cast(storage_date as sql_variant)
														when 4 then remark
														when 5 then storage_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
