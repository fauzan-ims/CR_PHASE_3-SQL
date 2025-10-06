
CREATE procedure [dbo].[xsp_master_rounding_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,currency_code
			,rounding_type
			,rounding_amount
	from	master_rounding
	where	code = @p_code ;
end ;
