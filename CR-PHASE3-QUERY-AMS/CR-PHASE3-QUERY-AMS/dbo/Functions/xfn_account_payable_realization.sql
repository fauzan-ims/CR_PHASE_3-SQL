create function [dbo].[xfn_account_payable_realization]
(
	@p_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount bigint
			,@price_amount decimal(18, 2) ;

	select	@price_amount = public_service_settlement_amount
	from	dbo.register_main
	where	code = @p_code ;

	set @return_amount = isnull(@price_amount, 0) ;

	return @return_amount ;
end ;
