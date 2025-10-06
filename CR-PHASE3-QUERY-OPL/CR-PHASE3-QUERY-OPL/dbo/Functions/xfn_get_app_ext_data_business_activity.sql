

CREATE FUNCTION [dbo].[xfn_get_app_ext_data_business_activity]
(
	@p_reff_no nvarchar(50) = null
)
returns nvarchar(30)
as
begin
	declare @nvarchar nvarchar(30) = N'' ;

	select	@nvarchar = economic_sector_evaluation
	from	dbo.application_survey
	where	application_no = @p_reff_no ;

	return @nvarchar ;
end ;
