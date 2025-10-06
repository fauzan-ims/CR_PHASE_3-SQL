
CREATE procedure [dbo].[xsp_master_rounding_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	mrd.id
			,mrd.rounding_code
			,mrd.facility_code
			,mrd.rounding_type
			,mrd.rounding_amount
			,mf.description 'facility_desc'
	from	master_rounding_detail mrd
			inner join dbo.master_facility mf on (mf.code = mrd.facility_code)
	where	id = @p_id ;
end ;
