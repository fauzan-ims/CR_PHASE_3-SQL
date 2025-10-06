
CREATE procedure [dbo].[xsp_master_region_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,region_name
			,is_active
	from	master_region
	where	code = @p_code ;
end ;


