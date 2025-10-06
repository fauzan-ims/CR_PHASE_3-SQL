
CREATE procedure [dbo].[xsp_master_depreciation_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,depreciation_code
			,tenor
			,rate
	from	master_depreciation_detail
	where	id = @p_id ;
end ;


