
CREATE FUNCTION [dbo].[xfn_wo_invoice_ar_not_due]
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin

	-- Hari - 17.Jul.2023 12:15 PM --	mendapatkan nilai ar yang due, invoice payment always full
	declare @os_installment decimal(18, 2) ;

	select	@os_installment = isnull(sum(ai.ar_amount),0)
	from	dbo.agreement_invoice  ai
			inner join dbo.invoice inv on ai.invoice_no = inv.invoice_no
	where	ai.agreement_no					= @p_agreement_no
			and inv.invoice_status			= 'POST'
			and isnull(inv.is_journal, '0') = '0' ;

	return isnull(@os_installment, 0) ;
end ;
