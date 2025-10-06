CREATE PROCEDURE [dbo].[xsp_master_transaction_parameter_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_process_code nvarchar(50)
	,@p_company_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_transaction_parameter mtp
			left join dbo.master_transaction mt on (mtp.transaction_code = mt.code)
			left join dbo.journal_gl_link jgl on (jgl.code				 = mtp.gl_link_code)
	where	mtp.company_code	 = @p_company_code
			and mtp.process_code = @p_process_code
			and (
					mt.transaction_name		like '%' + @p_keywords + '%'
					or	mtp.debet_or_credit like '%' + @p_keywords + '%'
					or	mtp.order_key		like '%' + @p_keywords + '%'
					or	mtp.gl_link_name	like '%' + @p_keywords + '%'
				) ;

	select		mtp.id
				,mtp.transaction_code
				,mt.transaction_name 'process_name'
				,mtp.process_code
				,mtp.order_key
				,mtp.parameter_amount
				,mtp.gl_link_code
				,mtp.gl_link_name
				,mtp.discount_gl_link_code
				,mtp.maximum_disc_pct
				,mtp.maximum_disc_amount
				,mtp.debet_or_credit
				,mtp.psak_gl_link_code
				,case mtp.is_taxable
					when '0' then 'No'
					else 'Yes'
				end 'is_taxable'
				,@rows_count 'rowcount'
	from		master_transaction_parameter mtp
				left join dbo.master_transaction mt on (mtp.transaction_code = mt.code)
				left join dbo.journal_gl_link jgl on (jgl.code				 = mtp.gl_link_code)
	where		mtp.company_code	 = @p_company_code
				and mtp.process_code = @p_process_code
				and (
						mt.transaction_name		like '%' + @p_keywords + '%'
						or	mtp.debet_or_credit like '%' + @p_keywords + '%'
						or	mtp.order_key		like '%' + @p_keywords + '%'
						or	mtp.gl_link_name	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mt.transaction_name
													 when 2 then mtp.gl_link_name
													 when 3 then mtp.debet_or_credit
													 when 4 then cast(mtp.order_key as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then mt.transaction_name
														when 2 then mtp.gl_link_name
														when 3 then mtp.debet_or_credit
														when 4 then cast(mtp.order_key as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
