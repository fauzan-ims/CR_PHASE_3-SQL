create FUNCTION [dbo].[xfn_reverse_asset_depre]
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = depreciation_amount 
	from dbo.temp_asset_schedule_commercial
	where id = @p_id

	return @amount
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xfn_reverse_asset_depre] TO [ims-raffyanda]
    AS [dbo];

