CREATE PROCEDURE [dbo].[xsp_client_kyc_getrow]
(
	@p_client_code nvarchar(50)
)
as
begin
	select	client_code
			,ao_remark
			,ao_source_fund
			,result_status
			,result_remark 
			,kyc_officer_code
			,kyc_officer_name
	from	client_kyc
	where	client_code = @p_client_code ;
end ;

