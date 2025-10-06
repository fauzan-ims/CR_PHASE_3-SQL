CREATE FUNCTION [dbo].[xfn_account_payable_work_order]
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @return_amount bigint
			,@price_amount decimal(18, 2) ;

	select	@price_amount = payment_amount
	from	dbo.work_order_detail
	where	id = @p_id ;

	set @return_amount = isnull(@price_amount, 0) ;

	return @return_amount ;
end ;
