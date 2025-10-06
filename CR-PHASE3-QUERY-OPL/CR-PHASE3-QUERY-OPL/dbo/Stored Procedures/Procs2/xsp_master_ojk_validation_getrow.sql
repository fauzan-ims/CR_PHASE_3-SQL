
CREATE procedure [dbo].[xsp_master_ojk_validation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,ojk_function
			,is_active
	from	master_ojk_validation
	where	code = @p_code ;
end ;
