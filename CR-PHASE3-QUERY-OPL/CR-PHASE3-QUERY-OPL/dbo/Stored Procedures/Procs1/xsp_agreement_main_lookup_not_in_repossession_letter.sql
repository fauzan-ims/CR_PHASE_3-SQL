CREATE PROCEDURE dbo.xsp_agreement_main_lookup_not_in_repossession_letter
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_is_remedial nvarchar(1)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	-- (+) Ari 2023-10-20 ket : HO menampilkan semua
	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;
	-- (+) Ari 2023-10-20

	select	@rows_count = count(1)
	from	agreement_main am
			left join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
	where	--branch_code = @p_branch_code
			branch_code = case @p_branch_code -- (+) Ari 2023-10-20 ket : HO menampilkan semua
								when 'ALL' 
								then branch_code
								else @p_branch_code 
						  end
			and not exists
	(
		select	agreement_no
		from	dbo.repossession_letter rp
		where	rp.agreement_no = am.agreement_no
				and rp.letter_status not in
	(
		'CANCEL', 'SETTLEMENT'
	)
	)
			and
			(
				agreement_external_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			) ;

	select		am.agreement_no
				,agreement_external_no
				,client_name
				,ai.ovd_rental_amount 'overdue_invoice_amount'
				,ai.ovd_penalty_amount
				,ai.ovd_days
				,ai.ovd_period
				,@rows_count 'rowcount'
	from		agreement_main am
				left join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
	where		--branch_code = @p_branch_code
				branch_code = case @p_branch_code -- (+) Ari 2023-10-20 ket : HO menampilkan semua
									when 'ALL' 
									then branch_code
									else @p_branch_code 
							  end
				and not exists
	(
		select	agreement_no
		from	dbo.repossession_letter rp
		where	rp.agreement_no = am.agreement_no
				and rp.letter_status not in
	(
		'CANCEL', 'SETTLEMENT'
	)
	)
				and
				(
					agreement_external_no like '%' + @p_keywords + '%'
					or	client_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then agreement_external_no
													 when 2 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then agreement_external_no
													   when 2 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
