--created by, Rian at 11/05/2023	

CREATE procedure dbo.xsp_application_survey_bank_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_bank asb
	where	asb.application_survey_code = @p_application_survey_code
			and (
					asb.bank_code					like '%' + @p_keywords + '%'
					or	asb.bank_account_no			like '%' + @p_keywords + '%'
					or	asb.bank_account_name		like '%' + @p_keywords + '%'
				) ;

	select		asb.ID
			   ,asb.APPLICATION_SURVEY_CODE
			   ,asb.BANK_CODE
			   ,asb.BANK_ACCOUNT_NO
			   ,asb.BANK_ACCOUNT_NAME
	from		dbo.application_survey_bank asb
	where		asb.application_survey_code = @p_application_survey_code
				and (
						asb.bank_code					like '%' + @p_keywords + '%'
						or	asb.bank_account_no			like '%' + @p_keywords + '%'
						or	asb.bank_account_name		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asb.bank_code
													 when 2 then asb.bank_account_no
													 when 3 then asb.bank_account_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asb.bank_code
														when 2 then asb.bank_account_no
														when 3 then asb.bank_account_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
