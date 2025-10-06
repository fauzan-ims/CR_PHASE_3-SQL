
CREATE procedure [dbo].[xsp_master_fee_amount_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mfa.code
			,mfa.fee_code
			,mfa.effective_date
			,mfa.facility_code
			,mfa.currency_code
			,mfa.calculate_by
			,mfa.calculate_base
			,mfa.calculate_from
			,mfa.fee_rate
			,mfa.fee_amount
			,mfa.fn_default_name
			,mfa.is_fn_override
			,mfa.fn_override_name
			,mf.description 'facility_desc'
			,case
				 when cast(mfa.effective_date as date) < dbo.xfn_get_system_date() then '0'
				 else '1'
			 end 'editable'
	from	master_fee_amount mfa
			inner join dbo.master_facility mf on (mf.code = mfa.facility_code)
	where	mfa.code = @p_code ;
end ;

