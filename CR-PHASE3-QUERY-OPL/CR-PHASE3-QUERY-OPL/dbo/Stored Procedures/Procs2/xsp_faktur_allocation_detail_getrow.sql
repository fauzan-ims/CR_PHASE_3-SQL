
create procedure xsp_faktur_allocation_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,allocation_code
			,invoice_no
			,faktur_no
	from	faktur_allocation_detail
	where	id = @p_id ;
end ;
