CREATE PROCEDURE [dbo].[xsp_application_deviation_getrow]
(
	@p_id bigint
)
as
begin
	select	ad.id
			,ad.application_no
			,ad.deviation_code
			,ad.remarks
			,ad.is_manual
			,ad.position_code
			,ad.position_name
			,md.description 'deviation_desc'
	from	application_deviation ad
			inner join master_deviation md on (md.code = ad.deviation_code)
	where	id = @p_id ;
end ;

