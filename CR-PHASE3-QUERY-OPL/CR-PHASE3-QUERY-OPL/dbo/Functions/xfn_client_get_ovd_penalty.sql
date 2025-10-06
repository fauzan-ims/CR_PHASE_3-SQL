
create function [dbo].[xfn_client_get_ovd_penalty]
(
	@p_client_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	--(+) Rinda 11/01/202111:06:29 notes :	
	declare @ovd_penalty		 decimal(18, 2)
			,@obligation_payment decimal(18, 2)
			,@amount_calculate	 decimal(18, 2) = 0
			,@amount_obligation	 decimal(18, 2)
			,@invoice_no		 nvarchar(50) 
			,@billing_no	 nvarchar(50)
			,@due_date		 datetime
			,@asset_no		 nvarchar(50) 
			,@ovd_days		 int
			,@amount_penalty decimal(18, 2)

	--declare curr_install cursor local fast_forward read_only for
	--select	aa.invoice_no
	--		,aa.asset_no
	--from	dbo.agreement_invoice aa with (nolock)
	--where	aa.agreement_no			   = @p_agreement_no
	--		and aa.invoice_no not in
	--			(
	--				select	invoice_no
	--				from	dbo.agreement_invoice_payment
	--				where	agreement_invoice_code = aa.code
	--			)
	--		and cast(due_date as date) < cast(@p_date as date) ;

	--open curr_install ;

	--fetch	curr_install
	--into	@invoice_no 
	--		,@asset_no

	--while @@fetch_status = 0
	--begin
	--	set @amount_calculate = @amount_calculate + isnull(dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, @p_date, @invoice_no, @asset_no), 0) ;

	--	fetch	curr_install
	--	into	@invoice_no 
	--			,@asset_no
	--end ;

	--close curr_install ;
	--deallocate curr_install ;

	--
	-- Hari - 15.Jul.2023 07:57 PM --	perubahan cara hitung per invoice detail per agreement, asset dan billing
	--	declare c_amort cursor local fast_forward read_only for
	--		select		 aid.agreement_no
	--					,aid.asset_no
	--					,aid.invoice_no
	--					,aid.billing_no
	--					,aiv.invoice_due_date 
	--		from		dbo.invoice					  aiv
	--					inner join dbo.invoice_detail aid on aid.invoice_no = aiv.invoice_no
	--		where		aiv.invoice_status	 = 'POST'
	--					and aiv.invoice_type = 'RENTAL'
	--					and (aiv.invoice_due_date) <= cast(@p_date as date)


	--		open c_amort
	--		fetch c_amort
	--		into	@p_agreement_no
	--				,@asset_no
	--				,@invoice_no	
	--				,@billing_no
	--				,@due_date

	--		while @@fetch_status = 0  
	--		begin
	--			set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@due_date, @p_date) ;
	--			set @amount_penalty = dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, @p_date, @invoice_no, @asset_no) ;
		 
	--			if (@amount_penalty > 0)
	--			BEGIN
	--				SET @amount_calculate = @amount_calculate+@amount_penalty
	--			end

	--			fetch c_amort
	--			into @p_agreement_no
	--				,@asset_no
	--				,@invoice_no	
	--				,@billing_no
	--				,@due_date
	--		end
	--		close c_amort
	--		deallocate c_amort

	---- ambil pembayaran nya
	--select	@obligation_payment = isnull(sum(aop.payment_amount), 0)
	--from	agreement_obligation_payment aop with (nolock)
	--		inner join agreement_obligation ao on (aop.obligation_code = ao.code)
	--where	aop.agreement_no	   = @p_agreement_no
	--		and ao.obligation_type = 'OVDP' ;

	--set @ovd_penalty = isnull(@amount_calculate, 0) - @obligation_payment ;

	
SELECT @ovd_penalty =  SUM( isnull(ao.obligation_amount, 0) - ISNULL(pay.payment,0))
from agreement_obligation ao
join dbo.AGREEMENT_MAIN on AGREEMENT_MAIN.AGREEMENT_NO = ao.AGREEMENT_NO
    outer apply
				(
					select sum(aop.payment_amount) 'payment'
					from dbo.agreement_obligation_payment aop
					where ao.code = aop.obligation_code
				) pay
where CLIENT_NO = @p_client_no
      and ao.obligation_type = 'OVDP';

	return isnull(round(@ovd_penalty, 0), 0) ;
end ;


