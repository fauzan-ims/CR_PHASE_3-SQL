
CREATE procedure xsp_faktur_cancelation_detail_getrow
(
	@p_id					bigint
) 
as
begin

	select	id
			,cancelation_code
			,faktur_no
	from	faktur_cancelation_detail
	where	id = @p_id

end
