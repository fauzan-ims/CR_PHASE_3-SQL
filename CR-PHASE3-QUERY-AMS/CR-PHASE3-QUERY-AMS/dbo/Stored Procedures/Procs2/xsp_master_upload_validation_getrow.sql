create PROCEDURE [dbo].[xsp_master_upload_validation_getrow]
(
	@p_code nvarchar(50)
)
as
begin

	select	code
			,description
			,sp_name
			,is_active
	from	dbo.master_upload_validation
	where	code = @p_code ;

end ;
