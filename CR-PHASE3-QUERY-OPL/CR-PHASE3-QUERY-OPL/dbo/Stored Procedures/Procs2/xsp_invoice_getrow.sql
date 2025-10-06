CREATE PROCEDURE dbo.xsp_invoice_getrow
(
	@p_invoice_no nvarchar(50)
)
as
begin
	declare @count_agreement	nvarchar(1)
			,@agreement_no		nvarchar(50)
			,@total_ovd_amount	nvarchar(1)
			,@total_lrap_amount nvarchar(1) ;

	select	@count_agreement = case
								   when count(distinct agreement_no) > 1 then '1'
								   else '0'
							   end
	from	dbo.invoice_detail
	where	invoice_no = @p_invoice_no ;

	if (@count_agreement = '0')
	begin
		select	top 1
				@agreement_no = agreement_no
		from	dbo.invoice_detail
		where	invoice_no = @p_invoice_no ;

		select	@total_lrap_amount = case
										 when lra_penalty_amount > 0 then '1'
										 else '0'
									 end
		from	dbo.agreement_information
		where	agreement_no = @agreement_no ;

		select	@total_ovd_amount = case
										when ovd_penalty_amount > 0 then '1'
										else '0'
									end
		from	dbo.agreement_information
		where	agreement_no = @agreement_no ;
	end ;

	select	inv.invoice_no
			,inv.invoice_external_no
			,sgs.description 'invoice_type'
			,inv.invoice_date
			,inv.invoice_due_date
			,inv.invoice_name
			,inv.invoice_status
			,inv.client_no
			,inv.client_name
			,inv.client_address
			,inv.client_area_phone_no
			,inv.client_phone_no
			,inv.client_npwp
			,inv.currency_code
			,inv.total_billing_amount
			,inv.total_discount_amount
			,inv.total_ppn_amount
			,inv.total_pph_amount
			,inv.total_amount
			,inv.faktur_no
			,inv.generate_code
			,inv.scheme_code
			,inv.received_reff_no
			,inv.received_reff_date
			,inv.credit_billing_amount
			,inv.credit_ppn_amount
			,inv.credit_pph_amount
			,inv.branch_code
			,inv.branch_name
			,inv.deliver_date
			,inv.payment_pph_date
			,inv.new_invoice_date
			,@agreement_no 'agreement_no'
			,isnull(@total_ovd_amount, '0') 'total_ovd_amount'
			,isnull(@total_lrap_amount, '0') 'total_lrap_amount'
			,isnull(@count_agreement, '0') 'count_agreement'
			,inv.dpp_nilai_lain
	from	invoice inv
			inner join dbo.sys_general_subcode sgs on (sgs.code = inv.invoice_type)
	where	inv.invoice_no = @p_invoice_no ;
end ;
