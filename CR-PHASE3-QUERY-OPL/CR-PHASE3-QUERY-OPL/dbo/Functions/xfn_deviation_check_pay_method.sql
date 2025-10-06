CREATE function [dbo].[xfn_deviation_check_pay_method]
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @number decimal(18, 2) = 0
			,@result int;

	select	@number = credit_term
	from	dbo.application_main
	where	application_no = @p_application_no ;

	if @number > 60
	begin
		set @result = '1' ;
	end ;
	else
	begin
		set @result = '0' ;
	end ;

	return @result ;
end ;
