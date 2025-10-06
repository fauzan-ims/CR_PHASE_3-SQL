CREATE procedure [dbo].[xsp_et_main_info_getrow_external]
(
	@p_client_no nvarchar(50)
)
as
begin
	select	em.code
			,em.branch_code
			,em.branch_name
			,em.et_status
			,em.et_date 'tanggal'
			,am.agreement_no
			,am.client_name
			,ac.collateral_type
			,ac.collateral_name
			,am.client_code
			,em.et_exp_date
			,em.et_amount
			,em.et_remarks 
			,em.received_request_code
			,em.received_voucher_no
			,em.received_voucher_date
	from	dbo.et_main em
			inner join dbo.agreement_main am on (am.agreement_no	  = em.agreement_no)
			left join dbo.agreement_collateral ac on (am.agreement_no = ac.agreement_no)
	where	am.client_code = @p_client_no ;
end ;

