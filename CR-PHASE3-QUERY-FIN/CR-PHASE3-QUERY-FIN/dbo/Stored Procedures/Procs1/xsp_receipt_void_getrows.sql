CREATE PROCEDURE dbo.xsp_receipt_void_getrows
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_void_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	receipt_void rv
			inner join dbo.sys_general_subcode sgs on (sgs.code = rv.void_reason_code)
	where	branch_code		= case @p_branch_code
							  	  when 'ALL' then branch_code
							  	  else @p_branch_code
							  end
			and void_status = case @p_void_status
								  when 'ALL' then void_status
								  else @p_void_status
							  end
			and (
					rv.code										like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), void_date, 103)	like '%' + @p_keywords + '%'
					or	sgs.description							like '%' + @p_keywords + '%'
					or	void_status								like '%' + @p_keywords + '%'
				) ;

		select		rv.code
					,branch_name							
					,convert(varchar(30), void_date, 103) 'void_date'
					,void_reason_code	
					,sgs.description 'void_reason_desc'				
					,void_status							
					,@rows_count 'rowcount'
		from		receipt_void rv
					inner join dbo.sys_general_subcode sgs on (sgs.code = rv.void_reason_code)
		where		branch_code		= case @p_branch_code
								  		  when 'ALL' then branch_code
								  		  else @p_branch_code
									  end
					and void_status = case @p_void_status
										  when 'ALL' then void_status
										  else @p_void_status
									  end
					and (
							rv.code										like '%' + @p_keywords + '%'
							or	branch_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), void_date, 103)	like '%' + @p_keywords + '%'
							or	sgs.description							like '%' + @p_keywords + '%'
							or	void_status								like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then rv.code
														when 2 then branch_name							
														when 3 then convert(varchar(30), void_date, 103)
														when 4 then sgs.description					
														when 5 then void_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rv.code
														when 2 then branch_name							
														when 3 then convert(varchar(30), void_date, 103)
														when 4 then sgs.description					
														when 5 then void_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
