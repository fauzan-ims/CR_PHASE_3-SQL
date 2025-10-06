
create procedure xsp_faktur_main_getrow
(
	@p_id			bigint
)
as
begin

	select	id
			,faktur_no
			,year
			,status
			,registration_code
			,invoice_no
	from	faktur_main
	where	id = @p_id
end
