
CREATE FUNCTION dbo.xfn_deviation_check_business_employee_period_company
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @number decimal(18, 2) = 0
			,@result int;

	select	@number =  reff_value_number
	from	dbo.application_external_data
	where	application_no = @p_application_no
			and remark	   = 'DataDeviationBusinessEmpPeriodObj'
			and reff_name  = 'PeriodMonth' ;

	if @number < 6
	begin
		set @result = '1' ;
	end ;
	else
	begin
		set @result = '0' ;
	end ;

	return @result ;
end ;

