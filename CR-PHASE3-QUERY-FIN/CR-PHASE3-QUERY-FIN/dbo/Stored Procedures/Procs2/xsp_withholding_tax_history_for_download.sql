CREATE PROCEDURE dbo.xsp_withholding_tax_history_for_download
(
	@p_tax_file_no	  nvarchar(50)=''
	,@p_from_date	  datetime=''
	,@p_to_date		  datetime=''
	,@p_branch_code	  nvarchar(50)
	,@p_tax_file_name nvarchar(250)=''
)
as
begin

	if exists	(					select	1
					from	sys_global_param
					where	code	  = 'HO'
							and value = @p_branch_code				)	begin		set @p_branch_code = 'ALL'	end

	select	branch_name 'Branch'
			,tax_file_no								
			,tax_file_name
			,convert(varchar(30), payment_date, 103) 'Transaction Date'
			,tax_type 'Type'
			,tax_payer_reff_code 'Payer Reff Code'
			,remark 'Remarks'
			,payment_amount 'Payment Amount'
			,acc.accumulate 'Accumulate'
			,tax_pct 'Tax pct'
			,tax_amount 'Tax amount'
			,tax_file_no								
			,tax_file_name
	from	withholding_tax_history wth
			outer apply
	(
		select	sum(wt.payment_amount) accumulate
		from	dbo.withholding_tax_history wt
		where	tax_file_no = @p_tax_file_no
				and wt.payment_date
				between @p_from_date and @p_to_date
	) acc
	where	tax_file_no			= @p_tax_file_no
			and wth.payment_date
			between @p_from_date and @p_to_date
			and wth.branch_code = case @p_branch_code
									  when 'ALL' then branch_code
									  else @p_branch_code
								  end
			--and tax_file_name	= @p_tax_file_name order by wth.PAYMENT_DATE desc ;
end ;

