
create procedure dbo.xsp_asset_delivery_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,branch_code
		   ,branch_name
		   ,status
		   ,date
		   ,remark
		   ,deliver_to_name
		   ,deliver_to_area_no
		   ,deliver_to_phone_no
		   ,deliver_to_address
		   ,deliver_from
		   ,deliver_by
		   ,deliver_pic
		   ,employee_code
		   ,employee_name 
	from	asset_delivery
	where	code = @p_code ;
end ;
