CREATE PROCEDURE [dbo].[xsp_get_list_obligation_amount]
(
	@p_agreement_no		nvarchar(50)
	,@p_obligation_type nvarchar(10)
	,@p_date			datetime
)
as
begin
	declare @amount				 decimal(18, 2)
			,@obligation_amount	 decimal(18, 2)
			,@obligation_payment decimal(18, 2)
			,@installment_no	 int
			,@amount_penalty	 decimal(18, 2)
			,@ovd_days			 int
			,@due_date			 datetime 
			,@invoice_no		 nvarchar(50)
			,@asset_no			 nvarchar(50);

	if (@p_date = dbo.xfn_get_system_date())
	begin

		--select	distinct ao.agreement_no
		--		,ao.installment_no
		--		,ao.obligation_amount - detail.payment_amount 'agreement_amount'
		--		,ao.obligation_type
		--		,ao.obligation_date
		--from	dbo.agreement_obligation ao
		--		outer apply
		--(
		--	select	isnull(sum(aop.payment_amount), 0) 'payment_amount'
		--	from	dbo.agreement_obligation_payment aop
		--	where	aop.obligation_code = ao.code
		--) detail
		--where	ao.agreement_no									 = @p_agreement_no
		--		and ao.obligation_type							 = @p_obligation_type
		--		and ao.obligation_date							 <= @p_date
		--		and ao.obligation_amount - detail.payment_amount > 0 ;

		-- (+) Ari 2023-10-11 ket : get obligation summary per kontrak per installment
		select	 ao.agreement_no
				,ao.installment_no 'billing_no'
				,ao.installment_no
				,isnull(sum(ao.obligation_amount - detail.payment_amount),0) 'agreement_amount'
				,ao.obligation_type
				,ao.obligation_date
		from	dbo.agreement_obligation ao
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) 'payment_amount'
			from	dbo.agreement_obligation_payment aop
			where	aop.obligation_code = ao.code
		) detail
		where	ao.agreement_no									 = @p_agreement_no
				and ao.obligation_type							 = @p_obligation_type
				and ao.obligation_date							 <= @p_date
				and ao.obligation_amount - detail.payment_amount > 0 
		group	by	ao.agreement_no
					,ao.installment_no
					,ao.obligation_type
					,ao.obligation_date

	end ;
	else --(+) sepria 15nov2021 : jika bayar denda backdated, hitung ulang nilai denda sesuai tgl value date bayar
	begin
		declare @obligation table
		(
			code	 nvarchar(50)
			,inst_no int
			,amount	 decimal(18, 2)
		) ;

		if (@p_obligation_type = 'OVDP')
		begin
			declare c_amort cursor local fast_forward read_only for
			select	aa.invoice_no
					,aa.due_date
					,aa.asset_no
					,billing_no
			from	dbo.agreement_asset_amortization aa
					outer apply
			(
				select	isnull(sum(isnull(aap.payment_amount, 0)), 0) 'payment'
				from	dbo.agreement_invoice_payment aap
				where	aap.agreement_no   = aa.agreement_no
						and aap.invoice_no = aa.invoice_no
						and aap.asset_no   = aa.asset_no
			) aap
			where	aa.billing_amount - isnull(aap.payment, 0) > 0
					and cast(aa.due_date as date)			   <= @p_date
					and aa.agreement_no						   = @p_agreement_no ;

			open c_amort ;

			fetch c_amort
			into @invoice_no
				 ,@due_date
				 ,@asset_no
				 ,@installment_no;

			while @@fetch_status = 0
			begin
				set @ovd_days = dbo.xfn_calculate_overdue_days_for_penalty(@due_date, @p_date) ;
				set @amount_penalty = dbo.xfn_calculate_penalty_per_agreement(@p_agreement_no, @p_date, @invoice_no, @asset_no) 

				if (@amount_penalty > 0)
				begin
					if exists
					(
						select	1
						from	dbo.agreement_obligation
						where	agreement_no	   = @p_agreement_no
								and installment_no = @installment_no
					)
					begin
						insert into @obligation
						(
							code
							,inst_no
							,amount
						)
						select	code
								,@installment_no
								,@amount_penalty
						from	dbo.agreement_obligation
						where	agreement_no	   = @p_agreement_no
								and installment_no = @installment_no ;
					end ;
					else
					begin
						insert into @obligation
						(
							code
							,inst_no
							,amount
						)
						select	(@p_agreement_no + cast(@installment_no as nvarchar(2)))
								,@installment_no
								,@amount_penalty ;
					end ;
				end ;

				fetch c_amort
				into @invoice_no
					 ,@due_date
					 ,@asset_no
					 ,@installment_no;
			end ;

			close c_amort ;
			deallocate c_amort ;

			select	ob.agreement_no 'agreement_no'
					--,obl.inst_no 'installment_no'
					,obl.inst_no 'billing_no'
					,obl.inst_no 'installment_no'
					,sum(obl.amount) - sum(isnull(detail.payment_amount, 0)) 'agreement_amount'
					,upper(@p_obligation_type) 'obligation_type'
					,@p_date 'obligation_date'
			from	@obligation obl
					left join dbo.agreement_obligation ob on (
																 ob.code = obl.code
																 and   ob.obligation_type = @p_obligation_type
																 and   ob.agreement_no = @p_agreement_no
															 )
					outer apply
			(
				select	isnull(sum(aop.payment_amount), 0) 'payment_amount'
				from	dbo.agreement_obligation_payment aop
				where	aop.agreement_no	   = ob.agreement_no
						and aop.installment_no = ob.installment_no
			) detail
			where	obl.amount - detail.payment_amount > 0
			group by ob.agreement_no
					,obl.inst_no
			union
			select	ao.agreement_no
					,ao.installment_no 'billing_no'
					,ao.installment_no
					,sum(ao.obligation_amount) - sum(detail.payment_amount) 'agreement_amount'
					,ao.obligation_type
					,ao.obligation_date
			from	dbo.agreement_obligation ao
					outer apply
			(
				select	isnull(sum(aop.payment_amount), 0) 'payment_amount'
				from	dbo.agreement_obligation_payment aop
				where	aop.agreement_no	   = ao.agreement_no
						and aop.installment_no = ao.installment_no
			) detail
			where	ao.agreement_no									 = @p_agreement_no
					and ao.obligation_type							 = @p_obligation_type
					and ao.obligation_date							 <= @p_date
					and ao.obligation_amount - detail.payment_amount > 0
					and ao.code not in
						(
							select	code
							from	@obligation
						) 
			group by ao.agreement_no
					,ao.installment_no
					,ao.obligation_type
					,ao.obligation_date
		end ;
		else if (@p_obligation_type = 'LRAP')
		begin
			select	 ao.agreement_no
					,ao.installment_no 'billing_no'
					,ao.installment_no
					,isnull(sum(ao.obligation_amount - detail.payment_amount),0) 'agreement_amount'
					,ao.obligation_type
					,ao.obligation_date
			from	dbo.agreement_obligation ao
					outer apply
			(
				select	isnull(sum(aop.payment_amount), 0) 'payment_amount'
				from	dbo.agreement_obligation_payment aop
				where	aop.obligation_code = ao.code
			) detail
			where	ao.agreement_no									 = @p_agreement_no
					and ao.obligation_type							 = @p_obligation_type
					--and ao.obligation_date							 <= @p_date
					and ao.obligation_amount - detail.payment_amount > 0 
			group	by	ao.agreement_no
						,ao.installment_no
						,ao.obligation_type
						,ao.obligation_date
		end
	end ;
end ;
