CREATE PROCEDURE dbo.xsp_master_approval_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,approval_name
			,reff_approval_category_code
			,reff_approval_category_name
			,is_active
	from	master_approval
	where	code = @p_code ;
end ;
