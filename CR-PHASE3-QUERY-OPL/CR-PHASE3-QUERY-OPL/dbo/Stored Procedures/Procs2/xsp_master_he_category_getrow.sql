---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_he_category_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
	from	master_he_category
	where	code = @p_code ;
end ;


