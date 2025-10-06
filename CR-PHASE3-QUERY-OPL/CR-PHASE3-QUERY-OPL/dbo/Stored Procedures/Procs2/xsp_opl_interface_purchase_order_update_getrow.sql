--created by, Rian at 30/05/2023 

CREATE procedure xsp_opl_interface_purchase_order_update_getrow
(
	@p_id	bigint
)
as
begin
	select	id
		   ,purchase_code
		   ,po_code
		   ,eta_po_date
		   ,supplier_code
		   ,supplier_name
		   ,unit_from
		   ,settle_date
		   ,job_status
		   ,failed_remarks
	from	dbo.opl_interface_purchase_order_update
	where	id = @p_id ;
end
