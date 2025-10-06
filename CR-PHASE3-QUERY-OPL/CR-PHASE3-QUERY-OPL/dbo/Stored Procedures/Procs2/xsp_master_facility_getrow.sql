CREATE PROCEDURE dbo.xsp_master_facility_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,facility_type
			,deskcoll_min
			,deskcoll_max
			,sp1_days
			,sp2_days
			,somasi_days
			,aging_days1
			,aging_days2
			,aging_days3
			,aging_days4
			,is_active
	from	master_facility
	where	code = @p_code ;
end ;
