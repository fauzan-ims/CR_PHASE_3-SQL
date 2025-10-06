CREATE FUNCTION dbo.xfn_get_app_ext_data_no_of_employee
(
	@p_reff_no nvarchar(50) = null
)
returns nvarchar(30)
as
begin
	declare @nvarchar nvarchar(30) = N'' ;

	select	@nvarchar = case
						when no_of_employee = 'LESS THAN 25' then '<25'
						when no_of_employee = '25-100' then '25 - 100'
						when no_of_employee = 'GREATER THAN 25' then '>100'
					end
	from	dbo.application_survey
	where	application_no = @p_reff_no ;

	return @nvarchar ;
end ;
