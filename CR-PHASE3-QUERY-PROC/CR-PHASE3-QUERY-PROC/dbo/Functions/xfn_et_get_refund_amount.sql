create function [dbo].[xfn_et_get_refund_amount]
(
	@p_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @total_amount		 decimal(18, 2)
			,@first_payment_type nvarchar(3) ;

	select	@total_amount = refund_amount
	from	dbo.et_main
	where	code = @p_code ;

	return isnull(@total_amount, 0) ;
end ;
