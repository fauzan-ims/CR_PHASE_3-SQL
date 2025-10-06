CREATE PROCEDURE dbo.xsp_master_fee_amount_lookup
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_facility_code nvarchar(50)
	,@p_currency_code nvarchar(50)
	,@p_eff_date	  datetime
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		master_fee mf
				outer apply
	(
		select top 1
					mfa.fee_rate
					,mfa.fee_amount
		from		dbo.master_fee_amount mfa
		where		mfa.fee_code		   = mf.code
					and mfa.facility_code  = @p_facility_code
					and mfa.currency_code  = @p_currency_code
					and mfa.effective_date <= @p_eff_date
		order by	mfa.effective_date desc
	) as fee_amount
	where		is_active = '1'
				and (
						mf.code				like '%' + @p_keywords + '%'
						or	mf.description	like '%' + @p_keywords + '%'
					)
 
		select		mf.code
					,mf.description
					,fee_amount.fee_rate
					,fee_amount.fee_amount
					,@rows_count 'rowcount'
		from		master_fee mf
					outer apply
		(
			select top 1
						mfa.fee_rate
						,mfa.fee_amount
			from		dbo.master_fee_amount mfa
			where		mfa.fee_code		   = mf.code
						and mfa.facility_code  = @p_facility_code
						and mfa.currency_code  = @p_currency_code
						and mfa.effective_date <= @p_eff_date
			order by	mfa.effective_date desc
		) as fee_amount
		where		is_active = '1'
					and (
							mf.code				like '%' + @p_keywords + '%'
							or	mf.description	like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mf.code
													when 2 then mf.description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mf.code
													when 2 then mf.description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
