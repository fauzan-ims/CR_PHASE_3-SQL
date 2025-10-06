CREATE FUNCTION dbo.xfn_asset_get_installment_no
(
	@p_asset_no nvarchar(50)
)
returns int
as
begin
	declare @installment_no int ;

	select	@installment_no = min(billing_no)
	from	dbo.agreement_asset_amortization
	where	asset_no = @p_asset_no
			and invoice_no is null 
			and billing_no <> 0; --(+) raffy 2025/09/11 ambil selain billing no nya 0

	return isnull(@installment_no, 0) ;
end ;
