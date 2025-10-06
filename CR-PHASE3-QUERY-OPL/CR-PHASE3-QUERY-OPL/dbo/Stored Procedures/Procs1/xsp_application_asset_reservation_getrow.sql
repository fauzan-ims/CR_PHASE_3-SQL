CREATE procedure [dbo].[xsp_application_asset_reservation_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,employee_code
			,employee_name
			,reserv_date
			,reserv_exp_date
			,status
			,client_name
			,client_phone_area_no
			,client_phone_no
			,remark
			,fa_code
			,fa_name
			,application_no
	from	dbo.application_asset_reservation
	where	id = @p_id ;
end ;
