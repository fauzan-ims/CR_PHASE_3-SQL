CREATE PROCEDURE dbo.xsp_additional_invoice_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	anv.code
			,anv.invoice_type
			,sgs.description 'invoice_type_name'
			,anv.invoice_date
			,anv.invoice_due_date
			,anv.invoice_name
			,anv.invoice_status
			,anv.client_no 
			,anv.client_name 'billing_to_name'
			,anv.client_address
			,anv.client_area_phone_no
			,anv.client_phone_no
			,anv.client_npwp 
			,anv.currency_code
			,anv.total_billing_amount
			,anv.total_discount_amount
			,anv.total_ppn_amount
			,anv.total_pph_amount
			,anv.total_amount
			,anv.branch_code
			,anv.branch_name
			,am.client_name 'agreement_client_name' -- (+) Ari 2023-09-04 ket : add agreement_client_name
			,anv.client_name 'npwp_name'
			,anv.client_address 'npwp_address'
	from	additional_invoice anv
			inner join dbo.sys_general_subcode sgs on (sgs.code = anv.invoice_type)
			left join dbo.agreement_main am on (am.client_no = anv.client_no)
	where	anv.code = @p_code ;
end ;
