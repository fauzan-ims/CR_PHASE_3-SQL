
CREATE procedure [dbo].[xsp_master_depreciation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,depreciation_name
			,is_active
	from	master_depreciation
	where	code = @p_code ;
end ;


