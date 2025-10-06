CREATE PROCEDURE [dbo].[xsp_deposit_allocation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	
	select	@rows_count = count(1)
	from	dbo.deposit_allocation_detail
	where	deposit_allocation_code = @p_code

	select	da.code
			,da.branch_code
			,da.branch_name
			--,da.cashier_code
			,da.allocation_status
			,da.allocation_trx_date
			,da.allocation_value_date
			,da.allocation_orig_amount
			,da.allocation_currency_code
			,da.allocation_exch_rate
			,da.allocation_base_amount
			,da.allocationt_remarks
			,da.agreement_no
			,da.deposit_code
			,da.deposit_amount
			,da.deposit_gl_link_code
			,da.is_received_request
			,da.reversal_code
			,da.reversal_date
			--,cm.employee_name 'cashier_name'
			,am.agreement_external_no
			,am.client_name
			,am.currency_code
			,jgl.gl_link_name 'deposit_gl_link_name'
			,da.deposit_type
			,rev.code 'rev_code' -- (+) Ari 2023-09-08 ket : add view approval for reversal
	from	deposit_allocation da
			left join dbo.agreement_main am on (am.agreement_no = da.agreement_no)
			left join dbo.journal_gl_link jgl on (jgl.code = da.deposit_gl_link_code)
			--left join dbo.reversal_main rm on (rm.source_reff_code = da.code) -- (+) Ari 2023-09-08 ket : add view approval for reversal
			outer apply -- (+) Ari 2023-10-23 ket : change, ambil latest reversal
			(
				select	top 1 rev.code 
				from	reversal_main rev
				where	rev.source_reff_code = da.code
				order	by rev.cre_date desc
			) rev
	where	da.code = @p_code ;
end ;
