CREATE procedure [dbo].[xsp_warning_letter_agreement_getrows]
(
	@p_keywords nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage int
	,@p_order_by int
	,@p_sort_by nvarchar(5)
	,@p_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	WARNING_LETTER
			join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO = WARNING_LETTER.AGREEMENT_NO
			join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_OBLIGATION.AGREEMENT_NO
			join dbo.INVOICE on INVOICE.INVOICE_NO					= AGREEMENT_OBLIGATION.INVOICE_NO
	where AGREEMENT_MAIN.CLIENT_NO = @p_code
		and OBLIGATION_DAY		=
			(
				select	max(OBLIGATION_DAY)
				from	WARNING_LETTER
						join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO = WARNING_LETTER.AGREEMENT_NO
						join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_OBLIGATION.AGREEMENT_NO
				where CLIENT_NO = @p_code
			)
		and
		(
				LETTER_NO like '%' + @p_keywords + '%'
				or AGREEMENT_MAIN.BRANCH_NAME like '%' + @p_keywords + '%'
				or WARNING_LETTER.LETTER_DATE like '%' + @p_keywords + '%'
				or AGREEMENT_MAIN.CLIENT_NAME like '%' + @p_keywords + '%'
				or OBLIGATION_DAY like '%' + @p_keywords + '%'
				or LETTER_TYPE like '%' + @p_keywords + '%'
				or LETTER_STATUS like '%' + @p_keywords + '%'
			) ;

	select	AGREEMENT_MAIN.AGREEMENT_NO
			,AGREEMENT_OBLIGATION.ASSET_NO
			,1							'billing_no'
			,DESCRIPTION				'description'
			,MONTHLY_RENTAL_ROUNDED_AMOUNT
			,BILLING_AMOUNT				'billing_amount'
			,TOTAL_PPN_AMOUNT			'ppn_amount'
			,TOTAL_PPH_AMOUNT			'pph_amount'
			,@rows_count				'rowcount'
	from	WARNING_LETTER
			join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO			= WARNING_LETTER.AGREEMENT_NO
			join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO					= AGREEMENT_OBLIGATION.AGREEMENT_NO
			join dbo.INVOICE on INVOICE.INVOICE_NO										= AGREEMENT_OBLIGATION.INVOICE_NO
			join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.AGREEMENT_NO					= AGREEMENT_MAIN.AGREEMENT_NO
			join dbo.AGREEMENT_ASSET_AMORTIZATION on AGREEMENT_ASSET_AMORTIZATION.INVOICE_NO = dbo.AGREEMENT_OBLIGATION.INVOICE_NO
													and AGREEMENT_ASSET_AMORTIZATION.BILLING_NO = dbo.AGREEMENT_OBLIGATION.INSTALLMENT_NO
	where AGREEMENT_MAIN.CLIENT_NO = @p_code
		and OBLIGATION_DAY		=
			(
				select	max(OBLIGATION_DAY)
				from	WARNING_LETTER
						join dbo.AGREEMENT_OBLIGATION on AGREEMENT_OBLIGATION.AGREEMENT_NO = WARNING_LETTER.AGREEMENT_NO
						join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = AGREEMENT_OBLIGATION.AGREEMENT_NO
				where CLIENT_NO = @p_code
			)
		and
		(
				LETTER_NO like '%' + @p_keywords + '%'
				or AGREEMENT_MAIN.BRANCH_NAME like '%' + @p_keywords + '%'
				or convert(varchar(15), WARNING_LETTER.LETTER_DATE, 102) like '%' + @p_keywords + '%'
				or AGREEMENT_MAIN.CLIENT_NAME like '%' + @p_keywords + '%'
				or OBLIGATION_DAY like '%' + @p_keywords + '%'
				or LETTER_TYPE like '%' + @p_keywords + '%'
				or LETTER_STATUS like '%' + @p_keywords + '%'
			)
	order by
		case
			when @p_sort_by = 'asc' then
				case @p_order_by
					when 1 then
						LETTER_NO
					when 2 then
						WARNING_LETTER.BRANCH_NAME
					when 3 then
						convert(varchar(15), WARNING_LETTER.LETTER_DATE, 102)
					when 4 then
						AGREEMENT_MAIN.CLIENT_NAME
					when 5 then
						convert(varchar(15), OBLIGATION_DAY, 102)
					when 6 then
						LETTER_TYPE
					when 7 then
						LETTER_STATUS
				end
		end asc
		,case
			when @p_sort_by = 'desc' then
				case @p_order_by
					when 1 then
						LETTER_NO
					when 2 then
						WARNING_LETTER.BRANCH_NAME
					when 3 then
						convert(varchar(15), WARNING_LETTER.LETTER_DATE, 102)
					when 4 then
						AGREEMENT_MAIN.CLIENT_NAME
					when 5 then
						convert(varchar(15), OBLIGATION_DAY, 102)
					when 6 then
						LETTER_TYPE
					when 7 then
						LETTER_STATUS
				end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;

