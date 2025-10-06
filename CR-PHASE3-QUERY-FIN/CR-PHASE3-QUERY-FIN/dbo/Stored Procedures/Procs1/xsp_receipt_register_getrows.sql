CREATE PROCEDURE dbo.xsp_receipt_register_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_register_status	nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	receipt_register
	where	branch_code			= case @p_branch_code
									 when 'ALL' then branch_code
									 else @p_branch_code
								  end
			and register_status	= case @p_register_status
									 when 'ALL' then register_status
									 else @p_register_status
								  end
			and (
					code											like 	'%'+@p_keywords+'%'
					or	branch_name									like 	'%'+@p_keywords+'%'
					or	convert(varchar(30), register_date, 103)	like 	'%'+@p_keywords+'%'
					or	receipt_prefix								like 	'%'+@p_keywords+'%'
					or	receipt_postfix								like 	'%'+@p_keywords+'%'
					or	register_remarks							like 	'%'+@p_keywords+'%'
					or	register_status								like 	'%'+@p_keywords+'%'	
				) ;

		select		code
					,branch_name								
					,convert(varchar(30), register_date, 103) 'register_date'
					,receipt_prefix							
					,receipt_postfix							
					,register_remarks								
					,register_status												
					,@rows_count 'rowcount'
		from		receipt_register
		where		branch_code			= case @p_branch_code
											 when 'ALL' then branch_code
											 else @p_branch_code
										  end
					and register_status	= case @p_register_status
											 when 'ALL' then register_status
											 else @p_register_status
										  end
					and (
							code											like 	'%'+@p_keywords+'%'
							or	branch_name									like 	'%'+@p_keywords+'%'
							or	convert(varchar(30), register_date, 103)	like 	'%'+@p_keywords+'%'
							or	receipt_prefix								like 	'%'+@p_keywords+'%'
							or	receipt_postfix								like 	'%'+@p_keywords+'%'
							or	register_remarks							like 	'%'+@p_keywords+'%'
							or	register_status								like 	'%'+@p_keywords+'%'	
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code								
														when 2 then branch_name								
														when 3 then cast(register_date as sql_variant)	
														when 4 then receipt_prefix							
														when 5 then	receipt_postfix							
														when 6 then	register_remarks								
														when 7 then	register_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code								
														when 2 then branch_name								
														when 3 then cast(register_date as sql_variant)	
														when 4 then receipt_prefix							
														when 5 then	receipt_postfix							
														when 6 then	register_remarks								
														when 7 then	register_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
