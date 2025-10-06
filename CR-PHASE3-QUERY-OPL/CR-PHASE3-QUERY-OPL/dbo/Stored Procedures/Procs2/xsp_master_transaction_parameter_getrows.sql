CREATE PROCEDURE dbo.xsp_master_transaction_parameter_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_process_code		nvarchar(50)
)
as
BEGIN

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_transaction_parameter mtp
			left join dbo.master_transaction mt on (mtp.transaction_code = mt.code)
			left join dbo.journal_gl_link jglb on (jglb.code			  = mtp.gl_link_code)
	where	mtp.process_code = @p_process_code		
	and		(
					mt.transaction_name					like '%' + @p_keywords + '%'
				or	case mtp.is_calculate_by_system
						when '1' then 'Yes'
						else 'No'
					end									like '%' + @p_keywords + '%'
				or	case mtp.is_transaction
						when '1' then 'Yes'
						else 'No'
					end									like '%' + @p_keywords + '%'
				or	mtp.maximum_disc_pct				like '%' + @p_keywords + '%'
				or	mtp.debet_or_credit					like '%' + @p_keywords + '%'
				or	jglb.gl_link_name					like '%' + @p_keywords + '%'
				--or	case mtp.is_discount_editable
				--		when '1' then 'Yes'
				--		else 'No'
				--	end									like '%' + @p_keywords + '%'
			) ;

		select		mtp.id
					,mtp.transaction_code
					,mt.transaction_name 'process_name'
					,case mtp.is_transaction
						when '1' then 'Yes'
						else 'No'
					end	'is_transaction'
					,case mtp.is_calculate_by_system
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_calculate_by_system'
					,case mtp.is_discount_editable
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_discount_editable'
					,mtp.gl_link_code
					,mtp.discount_gl_link_code
					,mtp.maximum_disc_pct
					,mtp.maximum_disc_amount
					,mtp.debet_or_credit
					,jglb.gl_link_name
					,@rows_count 'rowcount'
		from		master_transaction_parameter mtp
					left join dbo.master_transaction mt on (mtp.transaction_code = mt.code)
					left join dbo.journal_gl_link jglb on (jglb.code			  = mtp.gl_link_code)
		where		mtp.process_code = @p_process_code		
		and			(
							mt.transaction_name					like '%' + @p_keywords + '%'
						or	case mtp.is_calculate_by_system
								when '1' then 'Yes'
								else 'No'
							end									like '%' + @p_keywords + '%'
						or	case mtp.is_transaction
								when '1' then 'Yes'
								else 'No'
							end									like '%' + @p_keywords + '%'
						or	mtp.maximum_disc_pct				like '%' + @p_keywords + '%'
						or	mtp.debet_or_credit					like '%' + @p_keywords + '%'
						or	jglb.gl_link_name					like '%' + @p_keywords + '%'
						--or	case mtp.is_discount_editable
						--		when '1' then 'Yes'
						--		else 'No'
						--	end									like '%' + @p_keywords + '%'
					) 

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mt.transaction_name
													when 2 then mtp.debet_or_credit
													when 3 then jglb.gl_link_name
													when 4 then mtp.is_calculate_by_system
													when 5 then cast(mtp.is_transaction as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mt.transaction_name
														when 2 then mtp.debet_or_credit
														when 3 then jglb.gl_link_name
														when 4 then mtp.is_calculate_by_system
														when 5 then cast(mtp.is_transaction as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
