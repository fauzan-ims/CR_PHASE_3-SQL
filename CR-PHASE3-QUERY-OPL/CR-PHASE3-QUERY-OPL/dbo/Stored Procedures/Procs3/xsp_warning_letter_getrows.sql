CREATE PROCEDURE dbo.xsp_warning_letter_getrows
(
	@p_keywords		  NVARCHAR(50)
	,@p_pagenumber	  INT
	,@p_rowspage	  INT
	,@p_order_by	  INT
	,@p_sort_by		  NVARCHAR(5)
	,@p_branch_code	  NVARCHAR(50)
	,@p_letter_status NVARCHAR(10)
	,@p_letter_type   NVARCHAR(3) = ''
)
AS
BEGIN
	declare @rows_count int = 0 ;

	IF EXISTS
	(
		SELECT	1
		FROM	sys_global_param
		WHERE	code	  = 'HO'
				AND value = @p_branch_code
	)
	BEGIN
		SET @p_branch_code = 'ALL' ;
	END ;
    
	SELECT	@rows_count = COUNT(1)
	FROM	warning_letter wl
			left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
			outer apply
			(
				select	 sum(isnull(a.obligation_amount,0) - isnull(b.payment_amount,0))'total_overdue_amount'
				from	dbo.agreement_main ama
				left join dbo.agreement_obligation a on a.agreement_no = ama.agreement_no
				left join dbo.agreement_obligation_payment b on b.obligation_code = a.code
				where	am.client_no = ama.client_no
			)obl
			outer apply 
			(
				select	count(a.agreement_no) as total_agreement_count,
						count(b.asset_no) as total_asset_count,
						sum(b.monthly_rental_rounded_amount) as total_monthly_rental_amount
				from	dbo.agreement_main a
				inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
				where	a.client_no = am.client_no
						and a.agreement_status = 'GO LIVE'
			) taskagg
	WHERE	wl.letter_type					= CASE @p_letter_type
												  WHEN '' THEN wl.letter_type
												  ELSE @p_letter_type
											  END
			AND wl.branch_code				= case @p_branch_code
												  when 'ALL' then wl.branch_code
												  else @p_branch_code
											  end
			and wl.letter_status			= case @p_letter_status
												  when 'ALL' then wl.letter_status
												  else @p_letter_status
											  end
			
            and wl.generate_type			= 'MANUAL'
			and wl.letter_no not in (select letter_code from dbo.warning_letter_delivery_detail)
			and (
					wl.branch_name									like '%' + @p_keywords + '%'
					or	wl.letter_no								like '%' + @p_keywords + '%'
					or	wl.letter_type								like '%' + @p_keywords + '%'
					or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	wl.overdue_days								like '%' + @p_keywords + '%'
					or	wl.last_print_by							like '%' + @p_keywords + '%'
					or	wl.letter_status							like '%' + @p_keywords + '%'
					or	wl.installment_no							like '%' + @p_keywords + '%'
				) ;

		select		wl.CODE
					,wl.branch_name
					,wl.letter_no
					,wl.letter_type
					,convert(varchar(30), wl.letter_date, 103) 'letter_date'
					,am.agreement_external_no
					,am.client_name
					,wl.overdue_days
					--,case wl.letter_status
					--	 when 'HOLD' then 'POST'
					--	 when 'CANCEL' then 'CANCEL'
					--	 when 'REQUEST' then 'REQUEST'
					--	 when 'ON PROCESS' then 'ON PROCESS'
					-- end 	'letter_status'
					,wl.letter_status
					,wl.installment_no
					,taskagg.total_agreement_count
					,taskagg.total_asset_count
					,taskagg.total_monthly_rental_amount
					,obl.total_overdue_amount					
					,@rows_count 'rowcount'
		from		warning_letter wl
					left join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
					outer apply
					(
						select	 sum(isnull(a.obligation_amount,0) - isnull(b.payment_amount,0))'total_overdue_amount'
						from	dbo.agreement_main ama
						left join dbo.agreement_obligation a on a.agreement_no = ama.agreement_no
						left join dbo.agreement_obligation_payment b on b.obligation_code = a.code
						where	am.client_no = ama.client_no
					)obl
					outer apply 
					(
						select	count(a.agreement_no) as total_agreement_count,
								count(b.asset_no) as total_asset_count,
								sum(b.monthly_rental_rounded_amount) as total_monthly_rental_amount
						from	dbo.agreement_main a
						inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
						where	a.client_no = am.client_no
								and a.agreement_status = 'GO LIVE'
					) taskagg
		where		wl.letter_type					= case @p_letter_type
														  when '' then wl.letter_type
														  else @p_letter_type
													  end
					and wl.branch_code				= case @p_branch_code
														  when 'ALL' then wl.branch_code
														  else @p_branch_code
													  end
					and wl.letter_status			= case @p_letter_status
														  when 'ALL' then wl.letter_status
														  else @p_letter_status
													  end
					and wl.generate_type			= 'MANUAL'
					and wl.letter_no not in (select letter_code from dbo.warning_letter_delivery_detail)
					and (
							wl.branch_name									like '%' + @p_keywords + '%'
							or	wl.letter_no								like '%' + @p_keywords + '%'
							or	wl.letter_type								like '%' + @p_keywords + '%'
							or	convert(varchar(30), wl.letter_date, 103)	like '%' + @p_keywords + '%'
							or	am.agreement_external_no					like '%' + @p_keywords + '%'
							or	am.client_name								like '%' + @p_keywords + '%'
							or	wl.overdue_days								like '%' + @p_keywords + '%'
							or	wl.letter_status							like '%' + @p_keywords + '%'
							or	wl.installment_no							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then cast(wl.overdue_days as sql_variant)
														when 6 then cast(wl.installment_no as sql_variant)
														when 7 then wl.letter_type
														when 8 then case wl.letter_status
																		 when 'HOLD' then 'POST'
																		 when 'CANCEL' then 'CANCEL'
																		 when 'REQUEST' then 'REQUEST'
																	 end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then wl.letter_no
														when 2 then wl.branch_name
														when 3 then cast(wl.letter_date as sql_variant)
														when 4 then am.agreement_external_no
														when 5 then cast(wl.overdue_days as sql_variant)
														when 6 then cast(wl.installment_no as sql_variant)
														when 7 then wl.letter_type
														when 8 then case wl.letter_status
																		 when 'HOLD' then 'POST'
																		 when 'CANCEL' then 'CANCEL'
																		 when 'REQUEST' then 'REQUEST'
																	 end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
