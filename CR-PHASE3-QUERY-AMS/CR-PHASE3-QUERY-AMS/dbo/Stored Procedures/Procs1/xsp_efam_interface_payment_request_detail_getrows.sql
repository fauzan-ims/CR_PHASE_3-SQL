CREATE PROCEDURE dbo.xsp_efam_interface_payment_request_detail_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_company_code		 nvarchar(50)
	,@p_payment_request_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	efam_interface_payment_request_detail eprd
			inner join ifinsys.dbo.journal_gl_link			  jgl on jgl.code = eprd.gl_link_code
	where	eprd.company_code		 = @p_company_code
			and payment_request_code = @p_payment_request_code
			and
			(
				jgl.gl_link_name							like '%' + @p_keywords + '%'
				or	branch_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), orig_amount, 103)	like '%' + @p_keywords + '%'
				or	remarks									like '%' + @p_keywords + '%'
			) ;

	select		id
				,payment_request_code
				,eprd.COMPANY_CODE
				,branch_code
				,branch_name
				,jgl.gl_link_name				 'gl_link_code'
				--,agreement_no
				,facility_code
				,facility_name
				,purpose_loan_code
				,purpose_loan_name
				,purpose_loan_detail_code
				,purpose_loan_detail_name
				,orig_currency_code
				,orig_amount
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				,@rows_count			 'rowcount'
	from		efam_interface_payment_request_detail eprd
				inner join ifinsys.dbo.journal_gl_link			  jgl on jgl.code = eprd.gl_link_code
	where		eprd.company_code		 = @p_company_code
				and payment_request_code = @p_payment_request_code
				and
				(
					jgl.gl_link_name									like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), orig_amount, 103)	like '%' + @p_keywords + '%'
					or	remarks									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then gl_link_code
													 when 2 then branch_name
													 when 3 then cast(orig_amount as sql_variant)
													 when 4 then remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then gl_link_code
													   when 2 then branch_name
													   when 3 then cast(orig_amount as sql_variant)
													   when 4 then remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
