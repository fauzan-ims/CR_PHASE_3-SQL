create PROCEDURE dbo.xsp_master_public_service_branch_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,public_service_code
			,branch_code
			,branch_name
	from	master_public_service_branch
	where	code = @p_code ;
end ;
