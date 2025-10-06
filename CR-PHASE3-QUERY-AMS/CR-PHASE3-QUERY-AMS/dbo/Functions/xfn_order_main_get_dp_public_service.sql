CREATE FUNCTION [dbo].[xfn_order_main_get_dp_public_service]
(
	@p_id bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@dp_amount	decimal(18, 2)

		--select	@dp_amount	= abs(order_amount) 
		--from	dbo.order_main
		--where	code = @p_id
		select	@dp_amount	= abs(dp_to_public_service) 
		from	dbo.order_detail
		where	id = @p_id 

	set @return_amount = isnull(@dp_amount,0)

	return @return_amount
end
