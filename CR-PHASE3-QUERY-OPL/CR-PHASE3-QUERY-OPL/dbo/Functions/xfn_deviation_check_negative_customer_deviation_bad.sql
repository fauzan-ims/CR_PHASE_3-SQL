CREATE FUNCTION [dbo].[xfn_deviation_check_negative_customer_deviation_bad]
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @string nvarchar(250) = ''
			,@result int;

	select	@string = reff_value_string
	from	dbo.application_external_data
	where	application_no = @p_application_no
			and remark	   = 'DataDeviationNegativeCustObj'
			and reff_name  = 'MrNegCustTypeCode' ;

	if @string = 'BAD'
	begin
		set @result = '1' ;
	end ;
	else
	begin
		set @result = '0' ;
	end ;

	return @result ;
end ;

