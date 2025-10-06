
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_charges_amount_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mca.code
			,charge_code
			,effective_date
			,facility_code
			,mf.description 'facility_desc'
			,currency_code
			,calculate_by
			,charges_rate
			,charges_amount
			,fn_default_name
			,is_fn_override
			,fn_override_name
			,case
				 when cast(effective_date as date) < dbo.xfn_get_system_date() then '0'
				 else '1'
			 end 'editable'
	from	master_charges_amount mca
			inner join dbo.master_facility mf on (mf.code = mca.facility_code)
	where	mca.code = @p_code ;
end ;

