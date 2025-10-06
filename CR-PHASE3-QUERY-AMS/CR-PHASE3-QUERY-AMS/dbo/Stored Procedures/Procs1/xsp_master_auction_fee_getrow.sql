CREATE PROCEDURE dbo.xsp_master_auction_fee_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	maf.code
			,maf.auction_fee_name
			,maf.transaction_code
			,mtr.transaction_name
			,maf.is_taxable
			,maf.is_active
	from	master_auction_fee maf
	inner join dbo.master_transaction mtr on mtr.code = maf.transaction_code
	where	maf.code = @p_code ;
end ;
