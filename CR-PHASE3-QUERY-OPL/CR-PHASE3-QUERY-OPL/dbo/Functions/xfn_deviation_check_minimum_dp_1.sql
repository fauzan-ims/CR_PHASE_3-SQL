create function [dbo].[xfn_deviation_check_minimum_dp_1]
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @number decimal(18, 2) = 0
			,@result int;

	select	@number = avg(asset_rv_pct)
	from	dbo.application_asset
	where	application_no = @p_application_no ;

	if @number < 1
	begin
		set @result = '1' ;
	end ;
	else
	begin
		set @result = '0' ;
	end ;

	return @result ;
end ;

