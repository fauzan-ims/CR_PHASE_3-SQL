CREATE PROCEDURE [dbo].[xsp_client_personal_work_getrows]
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_client_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_personal_work cpw
			left join dbo.sys_general_subcode sgsb on (sgsb.code		 = cpw.company_business_line)
			left join dbo.sys_general_subcode_detail sgsd on (sgsd.code = cpw.company_sub_business_line)
	where	client_code = @p_client_code
			and (
					company_name									like '%' + @p_keywords + '%'
					or	sgsb.description 							like '%' + @p_keywords + '%'
					or	sgsd.description 							like '%' + @p_keywords + '%'
					or	convert(varchar(30), work_start_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), work_end_date, 103)	like '%' + @p_keywords + '%'
				) ;

	select		id
				,company_name
				,sgsb.description 'company_business_line'
				,sgsd.description 'company_sub_business_line'
				,convert(varchar(30), work_start_date, 103)	'work_start_date'
				,convert(varchar(30), work_end_date, 103) 'work_end_date'
				,@rows_count 'rowcount'
	from		client_personal_work cpw
				left join dbo.sys_general_subcode sgsb on (sgsb.code		 = cpw.company_business_line)
				left join dbo.sys_general_subcode_detail sgsd on (sgsd.code = cpw.company_sub_business_line)
	where		client_code = @p_client_code
				and (
						company_name									like '%' + @p_keywords + '%'
						or	sgsb.description 							like '%' + @p_keywords + '%'
						or	sgsd.description 							like '%' + @p_keywords + '%'
						or	convert(varchar(30), work_start_date, 103)	like '%' + @p_keywords + '%'
						or	convert(varchar(30), work_end_date, 103)	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then company_name
														when 2 then company_business_line
														when 3 then company_sub_business_line
														when 4 then convert(varchar(30), work_start_date, 103)	
														when 5 then convert(varchar(30), work_end_date, 103)	
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then company_name
														when 2 then company_business_line
														when 3 then company_sub_business_line
														when 4 then convert(varchar(30), work_start_date, 103)	
														when 5 then convert(varchar(30), work_end_date, 103)	
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

