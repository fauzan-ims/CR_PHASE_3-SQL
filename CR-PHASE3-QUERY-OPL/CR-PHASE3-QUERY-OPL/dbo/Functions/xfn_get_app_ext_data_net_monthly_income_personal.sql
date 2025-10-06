create function [dbo].[xfn_get_app_ext_data_net_monthly_income_personal]
(
	@p_reff_no nvarchar(50) = null
)
returns decimal(18, 2)
as
begin
	declare @number decimal(18, 2) = 0 ;

	select	@number = reff_value_number
	from	dbo.application_external_data
	where	application_no = @p_reff_no
			and remark	   = 'DataScoringPersonalObj'
			and reff_name  = 'NetMonthlyIncome' ;

	return @number ;
end ;
