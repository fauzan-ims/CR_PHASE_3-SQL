
create procedure dbo.xsp_master_billing_type_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,multiplier
			,is_active
	from	master_billing_type
	where	code = @p_code ;
end ;
