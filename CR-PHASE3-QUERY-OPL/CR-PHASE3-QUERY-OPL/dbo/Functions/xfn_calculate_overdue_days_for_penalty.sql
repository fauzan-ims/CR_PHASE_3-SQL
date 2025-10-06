CREATE FUNCTION dbo.xfn_calculate_overdue_days_for_penalty
(
	@p_due_date		datetime
	,@p_eod_date	datetime
)
returns int
AS
BEGIN 
	declare @work_days		int
            ,@day			int
            ,@total_day		int

	select	@work_days = value
	from	dbo.sys_global_param
	where	code = 'WKD'

	set @total_day = 0

	while @p_eod_date >= @p_due_date
	begin
    
		set @day = 0
		if (@work_days = 6 ) 
		begin
			if datepart(dw,@p_eod_date) not in (1) 
			begin
				set @day = 1
			end
		end	
		else if (@work_days = 5 ) 	
		begin
			if datepart(dw,@p_eod_date) not in (1,7) 
			begin
				set @day = 1
			end
		end
		else
		begin
			set @day = 1
		end

		if cast(@p_due_date as date) = cast(@p_eod_date as date) 
		begin
			set @day = 0
		end

		set @total_day= @total_day + @day
		set @p_eod_date = dateadd(day,-1,@p_eod_date)
		 
	end

	return @total_day
end


