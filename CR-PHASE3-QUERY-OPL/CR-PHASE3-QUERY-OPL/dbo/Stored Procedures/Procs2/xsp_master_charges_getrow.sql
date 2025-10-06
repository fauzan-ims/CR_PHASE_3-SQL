
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE dbo.xsp_master_charges_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,charges_fix_code
			,is_active
	from	master_charges
	where	code = @p_code ;
end ;

