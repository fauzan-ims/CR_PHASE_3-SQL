
create procedure xsp_faktur_registration_detail_getrow
(
	@p_id			bigint
) 
as
begin

	select	id
			,registration_code
			,year
			,faktur_no
	from	dbo.faktur_registration_detail
	where	id = @p_id
end
