CREATE PROCEDURE [dbo].[xsp_master_transaction_parameter_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_process_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_transaction_parameter	  mtp
			inner join dbo.master_transaction mt on (mt.code			 = mtp.transaction_code)
													and (mt.company_code = mtp.company_code)
	where	mtp.process_code = @p_process_code
	and		(
				mt.transaction_name				like '%' + @p_keywords + '%'
				or	mtp.debet_or_credit			like '%' + @p_keywords + '%'
				or	mtp.gl_link_name			like '%' + @p_keywords + '%'
			) ;

	select		id
				,mtp.company_code
				,transaction_code
				,process_code
				,order_key
				,parameter_amount
				,case is_calculate_by_system
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_calculate_by_system'
				,case is_transaction
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_transaction'
				,case is_amount_editable
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_amount_editable'
				,case is_discount_editable
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_discount_editable'
				,gl_link_code
				,mtp.gl_link_name
				,discount_gl_link_code
				,maximum_disc_pct
				,maximum_disc_amount
				,case is_journal
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_journal'
				,debet_or_credit
				,case is_discount_jurnal
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_discount_jurnal'
				,case is_reduce_transaction
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_reduce_transaction'
				,case is_psak
					 when '1' then 'YES'
					 else 'NO'
				 end				  'is_psak'
				,psak_gl_link_code
				,mt.transaction_name  'process_name'
				,@rows_count		  'rowcount'
	from		master_transaction_parameter	  mtp
				inner join dbo.master_transaction mt on (mt.code			 = mtp.transaction_code)
														and (mt.company_code = mtp.company_code)
	where		mtp.process_code = @p_process_code
	and			(
					mt.transaction_name				like '%' + @p_keywords + '%'
					or	mtp.debet_or_credit			like '%' + @p_keywords + '%'
					or	mtp.gl_link_name			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mt.transaction_name
													 when 2 then mtp.gl_link_name
													 when 3 then mtp.debet_or_credit
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then mt.transaction_name
														when 2 then mtp.gl_link_name
														when 3 then mtp.debet_or_credit
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
