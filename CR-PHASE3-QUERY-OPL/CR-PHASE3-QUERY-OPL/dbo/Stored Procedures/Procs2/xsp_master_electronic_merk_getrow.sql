---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure [dbo].[xsp_master_electronic_merk_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
	from	master_electronic_merk
	where	code = @p_code ;
end ;


