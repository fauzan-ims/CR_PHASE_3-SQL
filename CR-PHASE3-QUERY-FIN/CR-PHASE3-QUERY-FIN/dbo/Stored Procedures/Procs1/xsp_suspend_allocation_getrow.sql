CREATE PROCEDURE [dbo].[xsp_suspend_allocation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	
	select	@rows_count = count(1)
	from	dbo.suspend_allocation_detail
	where	suspend_allocation_code = @p_code

	select	sa.code
			,sa.branch_code
			,sa.branch_name
			--,sa.cashier_code
			,sa.allocation_status
			,sa.allocation_trx_date
			,sa.allocation_value_date
			,sa.allocation_orig_amount
			,sa.allocation_currency_code
			,sa.allocation_exch_rate
			,sa.allocation_base_amount
			,sa.allocationt_remarks
			,sa.suspend_code
			,sa.suspend_amount
			,sa.agreement_no
			,sa.suspend_gl_link_code
			,sa.is_received_request
			--,cm.employee_name 'cashier_name'
			,am.agreement_external_no
			,am.client_name
			,am.currency_code
			,jgl.gl_link_name 'suspend_gl_link_name'
			,rev.code 'rev_code' -- (+) Ari 2023-09-08 ket : add view approval for reversal
			,@rows_count 'rows_count'
	from	suspend_allocation sa
			--left join dbo.cashier_main cm on (cm.code = sa.cashier_code)
			left join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
			left join dbo.journal_gl_link jgl on (jgl.code = sa.suspend_gl_link_code)
			--left join dbo.reversal_main rm on (rm.source_reff_code = sa.code) -- (+) Ari 2023-09-08 ket : add view approval for reversal
			outer apply -- (+) Ari 2023-10-23 ket : change, ambil latest reversal
			(
				select	top 1 rev.code 
				from	reversal_main rev
				where	rev.source_reff_code = sa.code
				order	by rev.cre_date desc
			) rev
	where	sa.code = @p_code ;
end ;
