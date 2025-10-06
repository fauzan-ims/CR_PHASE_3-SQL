CREATE procedure [dbo].[xsp_application_refund_get_rate_and_get_amount]
(
	@p_application_no	nvarchar(50) 
	,@p_rate			decimal(9, 6) = 0 output
	,@p_amount			decimal(18, 2) = 0 output
)
as
begin
	set @p_rate = 5
	set @p_amount = 200000
end

