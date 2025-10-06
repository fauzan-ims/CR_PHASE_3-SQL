--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_area_blacklist_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ab.code
			,ab.province_code
			,ab.city_code
			,ab.province_name
			,ab.city_name
			,ab.entry_date
			,ab.entry_remarks
			,ab.exit_date
			,ab.exit_remarks
			,ab.is_active
			,sgs.description 'source'
	from	area_blacklist ab
			inner join dbo.sys_general_subcode sgs on (sgs.code = ab.source)
	where	ab.code = @p_code ;
end ;
