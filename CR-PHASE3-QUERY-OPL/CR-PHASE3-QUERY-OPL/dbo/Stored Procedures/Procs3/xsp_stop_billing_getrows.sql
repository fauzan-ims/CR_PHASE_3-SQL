CREATE PROCEDURE [dbo].[xsp_stop_billing_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	,@p_status				nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.stop_billing sb
			inner join dbo.agreement_main am on (am.agreement_no = sb.agreement_no)
	where	sb.branch_code = case @p_branch_code
								when 'ALL' then sb.branch_code
								else @p_branch_code 
							end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		(
				sb.code								like '%' + @p_keywords + '%'
				or sb.branch_name					like '%' + @p_keywords + '%'
				or convert(varchar(15), date,103)	like '%' + @p_keywords + '%'
				or status							like '%' + @p_keywords + '%'
				or am.agreement_external_no			like '%' + @p_keywords + '%'


			) ;

	select	code
		   ,sb.branch_name
		   ,am.agreement_external_no 'agreement_no'
		   ,am.client_name
		   ,status
		   ,convert(varchar(15), date,103) 'date'
		   ,@rows_count 'rowcount'
	from	dbo.stop_billing sb
			inner join dbo.agreement_main am on (am.agreement_no = sb.agreement_no)
	where	sb.branch_code = case @p_branch_code
								when 'ALL' then sb.branch_code
								else @p_branch_code 
							end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		(
				code								like '%' + @p_keywords + '%'
				or sb.branch_name					like '%' + @p_keywords + '%'
				or convert(varchar(15), date,103)	like '%' + @p_keywords + '%'
				or status							like '%' + @p_keywords + '%'
				or am.agreement_external_no			like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then sb.branch_name
													when 3 then am.agreement_external_no + am.client_name
													when 4 then cast(date as sql_variant)
													when 5 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then sb.branch_name
													when 3 then am.agreement_external_no + am.client_name
													when 4 then cast(date as sql_variant)
													when 5 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
