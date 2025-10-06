CREATE PROCEDURE [dbo].[xsp_deposit_move_detail_getrows]
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_deposit_move_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.deposit_move_detail dmd
			inner join dbo.agreement_main amt on (amt.agreement_no = dmd.to_agreement_no)
			left join ifinopl.dbo.agreement_deposit_main iadm on (iadm.agreement_no = amt.agreement_no and iadm.deposit_type = 'installment')
			left join ifinopl.dbo.agreement_deposit_main oadm on (oadm.agreement_no = amt.agreement_no and oadm.deposit_type = 'other')
	where	deposit_move_code = @p_deposit_move_code
			and
			(
				amt.agreement_external_no	like '%' + @p_keywords + '%'
				or	to_deposit_type_code	like '%' + @p_keywords + '%'
				or	amt.client_name			like '%' + @p_keywords + '%'
				or	to_amount				like '%' + @p_keywords + '%'
				or	isnull(iadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
				or	isnull(oadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
			) ;

	select		id
				,agreement_external_no as 'to_agreement_no'
				,to_deposit_type_code
				,to_amount
				,amt.client_name 'to_client_name'
				,isnull(iadm.deposit_amount, 0) 'installment_deposit_amount'
				,isnull(oadm.deposit_amount, 0) 'other_deposit_amount'
				,@rows_count as 'rowcount'
	from		dbo.deposit_move_detail dmd
				inner join dbo.agreement_main amt on (amt.agreement_no = dmd.to_agreement_no)
				left join ifinopl.dbo.agreement_deposit_main iadm on (iadm.agreement_no = amt.agreement_no and iadm.deposit_type = 'installment')
				left join ifinopl.dbo.agreement_deposit_main oadm on (oadm.agreement_no = amt.agreement_no and oadm.deposit_type = 'other')
	where		deposit_move_code = @p_deposit_move_code
				and
				(
					amt.agreement_external_no	like '%' + @p_keywords + '%'
					or	to_deposit_type_code	like '%' + @p_keywords + '%'
					or	amt.client_name			like '%' + @p_keywords + '%'
					or	to_amount				like '%' + @p_keywords + '%'
					or	isnull(iadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
					or	isnull(oadm.deposit_amount, 0)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													   when 1 then amt.agreement_external_no
													   when 2 then cast(isnull(iadm.deposit_amount, isnull(oadm.deposit_amount, 0)) as sql_variant)
													   when 3 then to_deposit_type_code
													   when 4 then cast(to_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then amt.agreement_external_no
													   when 2 then cast(isnull(iadm.deposit_amount, isnull(oadm.deposit_amount, 0)) as sql_variant)
													   when 3 then to_deposit_type_code
													   when 4 then cast(to_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
