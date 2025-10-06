CREATE PROCEDURE [dbo].[xsp_master_insurance_coverage_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mic.code
			,mic.insurance_code
			,mic.coverage_code
			,mc.coverage_name
			,mc.insurance_type
	from	master_insurance_coverage mic
			inner join dbo.master_coverage mc on (mc.code = mic.coverage_code)
	where	mic.code = @p_code ;
end ;


