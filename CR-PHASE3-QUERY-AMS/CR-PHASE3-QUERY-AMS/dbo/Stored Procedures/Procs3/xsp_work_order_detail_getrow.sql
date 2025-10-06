
create procedure xsp_work_order_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,work_order_code
			,asset_maintenance_schedule_id
			,service_code
			,service_name
			,service_type
			,service_fee
			,quantity
			,pph_amount
			,ppn_amount
			,total_amount
			,payment_amount
			,tax_code
			,tax_name
			,ppn_pct
			,pph_pct
			,part_number
	from	work_order_detail
	where	id = @p_id ;
end ;
