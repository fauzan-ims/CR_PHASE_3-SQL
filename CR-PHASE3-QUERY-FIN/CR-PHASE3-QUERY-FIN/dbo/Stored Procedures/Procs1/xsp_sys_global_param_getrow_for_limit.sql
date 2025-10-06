CREATE PROCEDURE dbo.xsp_sys_global_param_getrow_for_limit
(
	@p_code	nvarchar(50)
)
as
begin
	declare @amount	decimal(18,2)

	declare @temp_table table
	(
		outstanding_limit		decimal(18,2)
		,transaction_limit		decimal(18,2)
	)

	insert into @temp_table
	(
		outstanding_limit
		,transaction_limit
	)
	select	(isnull(limit.value,0) + isnull(sum(orig_amount),0)) - onpay.amount 'outstanding_limit'
			,isnull(limit.value,0) 'transaction_limit'
	from	dbo.bank_mutation_history 
	outer	apply (
					select	cast(replace(replace(value,'.',''),',','') as decimal(18,2)) 'value'
					from	dbo.sys_global_param 
					where	code = @p_code
				  ) limit
	outer	apply (
					select	isnull(sum(payment_amount),0) 'amount'
					from	payment_request 
					where	mod_date > cast(dbo.xfn_get_system_date() as datetime)
					and		payment_status in ('ON PROCESS')
				  ) onpay
	where	source_reff_name = 'Payment Confirm'
	and		transaction_date = cast(dbo.xfn_get_system_date() as datetime)
	and		bank_mutation_code in (select code from dbo.bank_mutation where branch_bank_name = 'MUFG')
	group	by	limit.value
				,onpay.amount

	if not exists(select 1 from @temp_table)
	begin
		select	@amount = isnull(sum(payment_amount),0)
		from	payment_request 
		where	mod_date > cast(dbo.xfn_get_system_date() as datetime)
		and		payment_status in ('ON PROCESS')

		select	cast(replace(replace(value,'.',''),',','') as decimal(18,2)) 'transaction_limit'
				,cast(replace(replace(value,'.',''),',','') as decimal(18,2)) - @amount 'outstanding_limit'
		from	dbo.sys_global_param 
		where	code = @p_code

	end
	else
	begin
		select	outstanding_limit
			   ,transaction_limit 
		from	@temp_table
	end

end
