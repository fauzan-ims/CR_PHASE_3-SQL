-- Louis Jumat, 04 Juli 2025 11.23.56 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_obligation_getrows_for_monitoring_late_return]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_client_no	   nvarchar(50) = ''
	,@p_agreement_no   nvarchar(50) = ''
	,@p_payment_status nvarchar(10) = ''
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	declare @tempTable table
	(
		agreement_external_no nvarchar(50)
		,client_name		  nvarchar(250)
		,branch_name		  nvarchar(250)
		,asset_no			  nvarchar(50)
		,invoice_no			  nvarchar(50)
		,credit_note_no		  nvarchar(50)
		,waive_no			  nvarchar(50)
		,maturity_date		  datetime
		,bast_date			  datetime
		,late_return_days	  int
		,os_obligation_amount decimal(18, 2)
		,waive_amount decimal(18, 2)
		,credit_amount decimal(18, 2)
		,invoice_amount decimal(18, 2)
		,payment_status		  nvarchar(10)
		,invoice_status		  nvarchar(10)
		,credit_note_status	  nvarchar(10)
		,waive_status		  nvarchar(10)
	) ;

	insert into @tempTable
	(
		agreement_external_no
		,client_name
		,branch_name
		,asset_no
		,maturity_date
		,bast_date
		,late_return_days
		,os_obligation_amount
		,payment_status
		,invoice_no		
		,invoice_status
		,invoice_amount
		,credit_note_no	
		,credit_note_status	
		,credit_amount
		,waive_status		
		,waive_no		
		,waive_amount
	)
	select	replace(aalr.agreement_no,'.','/')
			,am.client_name
			,aalr.branch_name
			,aalr.ASSET_NO
			,maturity_date
			,bast_date
			,late_return_days
			,os_obligation_amount
			,case when aalr.os_obligation_amount - isnull(aalr.invoice_amount,0) - isnull(aalr.credit_amount,0) - isnull(aalr.waive_amount,0) = 0 then 'PAID'
				else aalr.payment_status
			end
			,replace(aalr.invoice_no,'.','/')
			,UPPER(inv.invoice_status)
			,aalr.invoice_amount
			,aalr.credit_note_no
			,UPPER(cn.status)
			,aalr.credit_amount
			,UPPER(wv.waived_status)
			,aalr.waive_no
			,aalr.waive_amount
	from	dbo.agreement_asset_late_return aalr
	inner join dbo.agreement_main am on am.agreement_no = aalr.agreement_no
	outer apply (
			select	invoice_status
			from	dbo.invoice
			where	invoice_no = aalr.invoice_no
					and invoice_status <> 'CANCEL'
	)inv
	outer apply (
			select	status
			from	dbo.credit_note
			where	code = aalr.credit_note_no
					and status <> 'CANCEL'
	) cn
	outer apply (
			select	waived_status
			from	dbo.waived_obligation
			where	code = aalr.waive_no
					and waived_status <> 'CANCEL'
	)wv
	where		am.client_no	= case @p_client_no
										  when '' then am.client_no
										  else @p_client_no
									  end
				and aalr.branch_code	= case @p_branch_code
										  when 'ALL' then aalr.branch_code
										  else @p_branch_code
									  end
				and am.AGREEMENT_NO= case @p_agreement_no
										  when '' then am.agreement_no
										  else @p_agreement_no
									  end

	--select		am.agreement_external_no
	--			,am.client_name
	--			,am.branch_name
	--			,ao.asset_no
	--			,aaa.due_date
	--			,aa.handover_bast_date
	--			,datediff(day, aaa.DUE_DATE, isnull(aa.return_date, dbo.xfn_get_system_date()))
	--			,sum(ao.obligation_amount - isnull(aop.payment_amount, 0))
	--			,case
	--				 when sum(ao.obligation_amount - isnull(aop.payment_amount, 0)) > 0 then 'Hold'
	--				 else 'Paid'
	--			 end
	--from		dbo.agreement_obligation ao with (nolock)
	--			inner join dbo.agreement_main am with (nolock) on (am.agreement_no = ao.agreement_no)
	--			outer apply
	--(
	--	select	sum(aop.payment_amount) 'payment_amount'
	--	from	dbo.agreement_obligation_payment aop with (nolock)
	--	where	aop.obligation_code = ao.code
	--) aop
	--			outer apply
	--(
	--	select		top 1
	--				case
	--					when am.FIRST_PAYMENT_TYPE = 'ARR' then aaa.DUE_DATE
	--					else dateadd(month, 1, aaa.DUE_DATE)
	--				end 'DUE_DATE'
	--	from		dbo.agreement_asset_amortization as aaa with (nolock)
	--	where		aaa.asset_no = ao.asset_no
	--	order by	aaa.due_date desc
	--) aaa
	--			inner join dbo.agreement_information ai with (nolock) on (ai.agreement_no = ao.agreement_no)
	--			inner join dbo.agreement_asset aa with (nolock) on (
	--																   aa.agreement_no	  = ao.agreement_no
	--																   and aa.asset_no	  = ao.asset_no
	--															   )
	--where		obligation_type		= 'LRAP'
	--			and am.client_no	= case @p_client_no
	--									  when '' then am.client_no
	--									  else @p_client_no
	--								  end
	--			and am.branch_code	= case @p_branch_code
	--									  when 'ALL' then am.branch_code
	--									  else @p_branch_code
	--								  end
	--			and ao.agreement_no = case @p_agreement_no
	--									  when '' then am.agreement_no
	--									  else @p_agreement_no
	--								  end
	--group by	datediff(day, aaa.due_date, isnull(aa.return_date, dbo.xfn_get_system_date()))
	--			,am.agreement_external_no
	--			,am.client_name
	--			,am.branch_name
	--			,ao.asset_no
	--			,aaa.due_date
	--			,aa.handover_bast_date ;

	select	@rows_count = count(1)
	from	@temptable 
	where	payment_status = case @p_payment_status
									 when 'ALL' then payment_status
									 else @p_payment_status
								 end
            and
				(
					agreement_external_no							like '%' + @p_keywords + '%'
					or	client_name									like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	asset_no									like '%' + @p_keywords + '%'
					or	convert(varchar(20), maturity_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(20), bast_date, 103)		like '%' + @p_keywords + '%'
					or	late_return_days							like '%' + @p_keywords + '%'
					or	os_obligation_amount						like '%' + @p_keywords + '%'
					or	payment_status								like '%' + @p_keywords + '%'
					or	invoice_no									like '%' + @p_keywords + '%'
					or	waive_no									like '%' + @p_keywords + '%'
					or	credit_note_no								like '%' + @p_keywords + '%'
				)

	select		agreement_external_no
				,client_name
				,branch_name
				,asset_no
				,convert(varchar(20), maturity_date, 103) 'maturity_date'
				,convert(varchar(20), bast_date, 103) 'bast_date'
				,late_return_days
				,os_obligation_amount
				,payment_status
				,invoice_no
				,invoice_status
				,invoice_amount
				,credit_note_no
				,credit_note_status
				,credit_amount
				,waive_no
				,waive_status
				,waive_amount
				,@rows_count 'rowcount'
	from		@tempTable
	where		payment_status = case @p_payment_status
									 when 'ALL' then payment_status
									 else @p_payment_status
								 end
				and
				(
					agreement_external_no							like '%' + @p_keywords + '%'
					or	client_name									like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	asset_no									like '%' + @p_keywords + '%'
					or	convert(varchar(20), maturity_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(20), bast_date, 103)		like '%' + @p_keywords + '%'
					or	late_return_days							like '%' + @p_keywords + '%'
					or	os_obligation_amount						like '%' + @p_keywords + '%'
					or	payment_status								like '%' + @p_keywords + '%'
					or	invoice_no									like '%' + @p_keywords + '%'
					or	waive_no									like '%' + @p_keywords + '%'
					or	credit_note_no								like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then branch_name
													 when 2 then branch_name
													 --when 3 then branch_name
													 when 3 then agreement_external_no
													 when 4 then asset_no
													 when 5 then cast(maturity_date as sql_variant)
													 when 6 then cast(bast_date as sql_variant)
													 when 7 then cast(late_return_days as sql_variant) --+ cast(os_obligation_amount as sql_variant)
												     when 8 then invoice_no
												     when 9 then credit_note_no
												     when 10 then waive_no
												     when 11 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then branch_name
													   when 2 then branch_name
													   --when 3 then branch_name
													   when 3 then agreement_external_no
													   when 4 then asset_no
													   when 5 then cast(maturity_date as sql_variant)
													   when 6 then cast(bast_date as sql_variant)
													   when 7 then cast(late_return_days as sql_variant) --+ cast(os_obligation_amount as sql_variant)
													   when 8 then invoice_no
													   when 9 then credit_note_no
													   when 10 then waive_no
													   when 11 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
