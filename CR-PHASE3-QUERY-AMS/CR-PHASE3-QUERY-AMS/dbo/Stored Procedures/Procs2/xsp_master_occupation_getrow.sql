CREATE PROCEDURE [dbo].[xsp_master_occupation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,occupation_code
			,occupation_name
			,is_active
	from	master_occupation
	where	code = @p_code ;
end ;


