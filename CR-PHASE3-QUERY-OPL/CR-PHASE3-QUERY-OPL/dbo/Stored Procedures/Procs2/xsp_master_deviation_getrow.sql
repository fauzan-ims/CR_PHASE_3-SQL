
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_deviation_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	md.code
			,md.description
			,md.function_name
			,md.facility_code
			,md.type
			,mf.description 'facility_desc'
			,md.position_code
			,md.position_name
			,md.is_manual
			,md.is_active
			,md.is_fn_override
			,md.fn_override_name
	from	master_deviation md
			inner join dbo.master_facility mf on (mf.code = md.facility_code)
	where	md.code = @p_code ;
end ;

