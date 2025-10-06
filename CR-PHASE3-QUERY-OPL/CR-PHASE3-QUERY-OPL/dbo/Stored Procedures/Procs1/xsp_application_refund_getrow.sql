CREATE PROCEDURE [dbo].[xsp_application_refund_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	ar.code
			,ar.application_no
			,ar.refund_code
			,ar.fee_code
			,ar.refund_rate
			,ar.refund_amount
			,ar.is_auto_generate
			,mr.description 'refund_desc'
			,mf.description 'fee_name'
			,ar.currency_code
	from	application_refund ar
			left join master_refund mr on (mr.code = ar.refund_code)
			left join master_fee mf on (mf.code = ar.fee_code)
	where	ar.code = @p_code ;
end ;

