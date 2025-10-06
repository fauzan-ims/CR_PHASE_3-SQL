CREATE PROCEDURE [dbo].[xsp_realization_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	rd.id
			,rd.realization_code
			,rd.asset_no
			,aa.asset_name
			,aa.asset_year
			,aa.asset_condition
			,aa.unit_code
			,aa.fa_code
			,aa.fa_name
			,aa.billing_to
			,aa.billing_to_name
			,aa.billing_to_area_no
			,aa.billing_to_phone_no
			,aa.billing_to_address
			,aa.billing_type
			,aa.billing_to_npwp
			,aa.deliver_to
			,aa.deliver_to_name
			,aa.deliver_to_area_no
			,aa.deliver_to_phone_no
			,aa.deliver_to_address
			,aa.billing_to_faktur_type
			,aa.billing_mode_date 
			,rz.status
	from	realization_detail rd
			inner join dbo.realization rz on (rz.code = rd.realization_code)
			inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
			left join dbo.sys_general_subcode sgs on (sgs.code	= aa.billing_to_faktur_type)
	where	id = @p_id ;
end ;
