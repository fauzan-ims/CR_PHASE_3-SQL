
CREATE procedure [dbo].[xsp_client_kyc_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_code
			,member_type
			,member_code
			,member_name
			,is_pep
			,remarks_pep
			,is_slik
			,remarks_slik
			,is_dtto
			,remarks_dtto
			,is_proliferasi
			,remarks_proliferasi
			,is_npwp
			,remarks_npwp
			,is_dukcapil
			,remarks_dukcapil
			,is_jurisdiction
			,remarks_jurisdiction
			,remarks
	from	client_kyc_detail
	where	id = @p_id ;
end ;

