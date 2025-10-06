
CREATE function [dbo].[xfn_get_app_ext_data_net_income]
(
	@p_reff_no nvarchar(50) = null
)
returns decimal(18, 2)
as
begin
	declare @number decimal(18, 2) = 0 ;

	select	@number = net_income
	from	dbo.APPLICATION_SURVEY
	where	application_no = @p_reff_no ;

	return @number ;
end ;
