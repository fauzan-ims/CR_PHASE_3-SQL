
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_refund_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mr.code
			,mr.description
			,mr.currency_code
			,mr.facility_code
			,mfc.description 'facility_desc'
			,mr.refund_type
			,mr.fee_code
			,mr.calculate_by
			,mr.refund_amount
			,mr.refund_pct
			,mr.max_refund_amount
			,mr.fn_default_name
			,mr.is_fn_override
			,mr.fn_override_name
			,mr.is_psak
			,mr.is_active
			,mf.description 'fee_desc'
	from	master_refund mr
			left join dbo.master_fee mf on (mf.code = mr.fee_code)
			inner join dbo.master_facility mfc on (mfc.code = mr.facility_code)
	where	mr.code = @p_code ;
end ;

