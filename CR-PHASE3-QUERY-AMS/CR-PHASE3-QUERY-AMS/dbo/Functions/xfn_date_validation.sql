CREATE FUNCTION dbo.xfn_date_validation
(@p_date datetime)
returns int
as
begin
	
	declare @is_valid	int = 1
			,@max_day	int
			,@sys_date	datetime
			,@max_date	nvarchar(30)
			,@max_month	datetime

	select @max_day = cast(value as int) from sys_global_param where code = 'MDT'
	select @sys_date = dbo.xfn_get_system_date()
	set @max_date = cast(year(@sys_date) as char(4)) + '-' + right(convert(char(6),@sys_date,112),2) + '-' +  cast(@max_day as char(2))
	set @max_month = dateadd(month, -1, dbo.xfn_get_system_date());

	if datediff(month,@p_date,@max_date) > 1
	begin
		set @is_valid = 0
	end

	if ((@sys_date > @max_date) and (@p_date < @sys_date)) and datediff(month,@p_date,@max_date) <> 0
	begin
		set @is_valid = 0
	end
		
    return @is_valid;

end
