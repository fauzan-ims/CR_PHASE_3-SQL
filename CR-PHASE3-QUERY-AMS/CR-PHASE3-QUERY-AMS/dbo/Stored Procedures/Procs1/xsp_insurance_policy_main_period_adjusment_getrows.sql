CREATE PROCEDURE dbo.xsp_insurance_policy_main_period_adjusment_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_policy_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	insurance_policy_main_period_adjusment ipmpa
			outer apply ( select isnull(sum(ipmp.total_buy_amount),0) 'total_buy_amount'
								 --,isnull(sum(ipmp.total_sell_amount),0) 'total_sell_amount'
								 --,isnull(sum(ipmp.initial_discount_amount),0) 'initial_discount_amount'
								 --,isnull(sum(ipmp.initial_admin_fee_amount),0) 'initial_admin_fee_amount'
								 --,isnull(sum(ipmp.initial_stamp_fee_amount),0) 'initial_stamp_fee_amount'
						   from dbo.insurance_policy_main_period ipmp 
						   where ipmp.policy_code		  = ipmpa.policy_code
								 and ipmp.year_periode	  = ipmpa.year_periode
						)ipmp
			outer apply (	select	isnull(sum(total_sell_amount),0) 'total_sell_amount', isnull(sum(ipml.total_buy_amount),0) 'total_buy_amount' 
							from	dbo.insurance_policy_main_loading ipml 
							where	ipml.policy_code		= ipmpa.policy_code
							and		ipml.year_period		= ipmpa.year_periode
						) loading

		where		ipmpa.policy_code = @p_policy_code
					and (
						ipmpa.id												like '%' + @p_keywords + '%'
						or ipmpa.year_periode									like '%' + @p_keywords + '%'
						--or ipmp.total_sell_amount								like '%' + @p_keywords + '%'
						or loading.total_sell_amount 							like '%' + @p_keywords + '%'
						or ipmp.total_buy_amount								like '%' + @p_keywords + '%'
						or loading.total_buy_amount 							like '%' + @p_keywords + '%'
						--or ipmp.initial_discount_amount 						like '%' + @p_keywords + '%'
						--or ipmp.initial_admin_fee_amount 						like '%' + @p_keywords + '%'
						or ipmpa.adjustment_buy_amount							like '%' + @p_keywords + '%'
						or ipmpa.adjustment_discount_amount						like '%' + @p_keywords + '%'
						or ipmpa.adjustment_admin_amount						like '%' + @p_keywords + '%'
					)

		select		ipmpa.id
					,ipmpa.year_periode
					--,(ipmp.total_sell_amount + loading.total_sell_amount) 'total_sell_amount' 
					--,(ipmp.total_buy_amount + loading.total_buy_amount) + (ipmp.initial_discount_amount) - isnull(ipmp.initial_admin_fee_amount,0) - isnull(ipmp.initial_stamp_fee_amount,0) 'total_buy_amount'
					--,(ipmp.initial_discount_amount) 'total_discount_amount'
					--,ipmp.initial_admin_fee_amount + ipmp.initial_stamp_fee_amount 'initial_admin_fee_amount'
					,ipmpa.adjustment_buy_amount
					,ipmpa.adjustment_discount_amount
					,ipmpa.adjustment_admin_amount
					,@rows_count 'rowcount'
		from		insurance_policy_main_period_adjusment ipmpa
					outer apply ( select isnull(sum(ipmp.total_buy_amount),0) 'total_buy_amount'
										 --,isnull(sum(ipmp.total_sell_amount),0) 'total_sell_amount'
										 --,isnull(sum(ipmp.initial_discount_amount),0) 'initial_discount_amount'
										 --,isnull(sum(ipmp.initial_admin_fee_amount),0) 'initial_admin_fee_amount'
										 --,isnull(sum(ipmp.initial_stamp_fee_amount),0) 'initial_stamp_fee_amount'
								  from dbo.insurance_policy_main_period ipmp 
								  where ipmp.policy_code		  = ipmpa.policy_code
										and ipmp.year_periode	  = ipmpa.year_periode
								)ipmp
					outer apply (	select	isnull(sum(total_sell_amount),0) 'total_sell_amount'
											,isnull(sum(ipml.total_buy_amount),0) 'total_buy_amount' 
									from	dbo.insurance_policy_main_loading ipml 
									where	ipml.policy_code		= ipmpa.policy_code
									and		ipml.year_period		= ipmpa.year_periode
								) loading

		where		ipmpa.policy_code = @p_policy_code
					and (
						ipmpa.id												like '%' + @p_keywords + '%'
						or ipmpa.year_periode									like '%' + @p_keywords + '%'
						--or ipmp.total_sell_amount								like '%' + @p_keywords + '%'
						or loading.total_sell_amount 							like '%' + @p_keywords + '%'
						or ipmp.total_buy_amount								like '%' + @p_keywords + '%'
						or loading.total_buy_amount 							like '%' + @p_keywords + '%'
						--or ipmp.initial_discount_amount 						like '%' + @p_keywords + '%'
						--or ipmp.initial_admin_fee_amount 						like '%' + @p_keywords + '%'
						or ipmpa.adjustment_buy_amount							like '%' + @p_keywords + '%'
						or ipmpa.adjustment_discount_amount						like '%' + @p_keywords + '%'
						or ipmpa.adjustment_admin_amount						like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ipmpa.year_periode
													--when 2 then	cast((ipmp.total_sell_amount + loading.total_sell_amount)  as sql_variant) 
													when 3 then	cast((ipmp.total_buy_amount + loading.total_buy_amount)  as sql_variant)
													--when 4 then	cast((ipmp.initial_discount_amount)  as sql_variant)
													--when 5 then cast(ipmp.initial_admin_fee_amount  as sql_variant)
													when 6 then	cast(ipmpa.adjustment_buy_amount  as sql_variant)
													when 7 then	cast(ipmpa.adjustment_admin_amount  as sql_variant)
													when 8 then	cast(ipmpa.adjustment_discount_amount  as sql_variant) 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then ipmpa.year_periode
													--when 2 then	cast((ipmp.total_sell_amount + loading.total_sell_amount)  as sql_variant) 
													when 3 then	cast((ipmp.total_buy_amount + loading.total_buy_amount)  as sql_variant)
													--when 4 then	cast((ipmp.initial_discount_amount)  as sql_variant)
													--when 5 then cast(ipmp.initial_admin_fee_amount  as sql_variant)
													when 6 then	cast(ipmpa.adjustment_buy_amount  as sql_variant)
													when 7 then	cast(ipmpa.adjustment_admin_amount  as sql_variant)
													when 8 then	cast(ipmpa.adjustment_discount_amount  as sql_variant) 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

