create procedure xsp_document_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,document_code
			,document_status
			,movement_type
			,movement_location
			,movement_from
			,movement_to
			,movement_by
			,movement_date
			,movement_return_date
			,locker_position
			,locker_code
			,drawer_code
			,row_code
			,remarks
	from	document_history
	where	id = @p_id ;
end ;
