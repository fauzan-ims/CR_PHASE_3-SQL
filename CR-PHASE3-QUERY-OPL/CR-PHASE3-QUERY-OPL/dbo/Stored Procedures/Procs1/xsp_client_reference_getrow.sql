
CREATE procedure [dbo].[xsp_client_reference_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_code
			,reference_type_code
			,reference_date
			,reference_full_name
			,reference_address
			,reference_identity_no
			,reference_area_phone_no
			,reference_phone_no
			,relationship
	from	client_reference
	where	id = @p_id ;
end ;

