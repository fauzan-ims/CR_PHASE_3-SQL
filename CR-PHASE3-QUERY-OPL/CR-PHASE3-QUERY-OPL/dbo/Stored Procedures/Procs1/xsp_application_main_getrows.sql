CREATE PROCEDURE dbo.xsp_application_main_getrows
(
	@p_keywords			   nvarchar(50)
	,@p_pagenumber		   int
	,@p_rowspage		   int
	,@p_order_by		   int
	,@p_sort_by			   nvarchar(5)
	,@p_branch_code		   nvarchar(50)
	--
	,@p_is_simulation	   nvarchar(1) = '0'
)
as
begin
	declare @rows_count int	= 0; 
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

	select	@rows_count = count(1)
	from	application_main ap
			left join dbo.master_facility mf on (mf.code = ap.facility_code)
			left join dbo.master_workflow mw on (mw.code = ap.level_status)
	where	ap.branch_code			  = case @p_branch_code
											when 'ALL' then ap.branch_code
											else @p_branch_code
										end
			and ap.application_status = 'HOLD' 
			and ap.is_simulation	  = @p_is_simulation
			and (
					ap.application_external_no							like '%' + @p_keywords + '%'
					or ap.client_name									like '%' + @p_keywords + '%'
					or ap.branch_name									like '%' + @p_keywords + '%'
					or convert(varchar(30), ap.application_date, 103)	like '%' + @p_keywords + '%'
					or mf.description									like '%' + @p_keywords + '%' 
					or ap.marketing_name								like '%' + @p_keywords + '%' 
					or ap.application_status							like '%' + @p_keywords + '%' 
					or ap.level_status									like '%' + @p_keywords + '%' 
				) ;

	select		ap.application_no
				,ap.application_external_no
				,ap.client_name
				,ap.branch_name
				,convert(varchar(30), ap.application_date, 103) 'application_date'
				,mf.description 'facility_desc'
				,ap.application_status
				,ap.level_status 'level_code'
				,isnull(mw.description, ap.level_status) 'level_status'
				,ap.return_count
				,ap.agreement_external_no
				,ap.rental_amount
				,ap.currency_code
				,ap.marketing_name
				,ap.is_simulation
				,@rows_count 'rowcount'
	from		application_main ap
				left join dbo.master_facility mf on (mf.code = ap.facility_code)
				left join dbo.master_workflow mw on (mw.code = ap.level_status)
	where		ap.branch_code			  = case @p_branch_code
												when 'ALL' then ap.branch_code
												else @p_branch_code
											end
			and ap.application_status	  = 'HOLD' 
				and ap.is_simulation	  = @p_is_simulation
				and (
						ap.application_external_no							like '%' + @p_keywords + '%'
						or ap.client_name									like '%' + @p_keywords + '%'
						or ap.branch_name									like '%' + @p_keywords + '%'
						or convert(varchar(30), ap.application_date, 103)	like '%' + @p_keywords + '%'
						or mf.description									like '%' + @p_keywords + '%' 
						or ap.marketing_name								like '%' + @p_keywords + '%' 
						or ap.application_status							like '%' + @p_keywords + '%' 
						or ap.level_status									like '%' + @p_keywords + '%' 
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ap.application_external_no + ap.client_name
													 when 2 then ap.branch_name
													 when 3 then cast(ap.application_date as sql_variant)
													 when 4 then mf.description
													 when 5 then ap.marketing_name
													 when 6 then isnull(mw.description, ap.level_status) + ap.application_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ap.application_external_no + ap.client_name
													   when 2 then ap.branch_name
													   when 3 then cast(ap.application_date as sql_variant)
													   when 4 then mf.description
													   when 5 then ap.marketing_name
													   when 6 then isnull(mw.description, ap.level_status) + ap.application_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
