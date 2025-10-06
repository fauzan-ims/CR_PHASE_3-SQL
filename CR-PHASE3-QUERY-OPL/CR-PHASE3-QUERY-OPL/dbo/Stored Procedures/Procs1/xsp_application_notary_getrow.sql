CREATE PROCEDURE [dbo].[xsp_application_notary_getrow]
(
	@p_id			   bigint
	,@p_application_no nvarchar(50)
)
as
begin
	select	id
			,an.application_no
			,an.notary_service_code
			,an.fee_admin_amount
			,an.fee_bnbp_amount
			,an.notary_fee_amount
			,an.total_notary_amount
			,an.remarks
			,an.notary_service_name
			,an.currency_code
	from	application_notary an
	where	id				   = @p_id
			and application_no = @p_application_no ;
end ;

