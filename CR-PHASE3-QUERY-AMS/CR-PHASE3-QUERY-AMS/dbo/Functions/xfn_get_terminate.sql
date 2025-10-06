CREATE FUNCTION dbo.xfn_get_terminate
(
	@p_policy_code		 nvarchar(50)
	,@p_termination_date datetime
)
returns decimal(18, 2)
as
begin
	declare @day					  decimal(7, 3)
			,@days					  decimal(7, 3)
			,@period				  int
			,@proposional_buy_amount  decimal(18, 2)
			,@all_buy				  decimal(18, 2)
			,@outstanding_buy_amount  decimal(18, 2) = 0
			,@day_in_year			  decimal(7, 3)
			,@outstanding_day_in_year int
			,@policy_eff_date		  datetime
			,@policy_exp_date		  datetime
			,@insurance_type		  nvarchar(50)
			,@from_year				  int
			,@termination_amount	  decimal(18, 2)
			,@all					  datetime ;

	select	@policy_eff_date		= policy_eff_date
			,@policy_exp_date		= policy_exp_date
			,@insurance_type		= insurance_type
			,@from_year				= ipm.from_year
	from	dbo.insurance_policy_main ipm
	where	code = @p_policy_code ;

	set @day = datediff(day, @policy_eff_date, @p_termination_date) ;
	set @days = datediff(day, @policy_eff_date, @policy_exp_date) ;
	set @period = ceiling(@day * 1.0 / @days) ;

	if (@period = 0)
	begin
		set @period = 1 ;
	end ;

	set @day_in_year = datediff(day, (dateadd(year, (@period - 1), @policy_eff_date)), (dateadd(year, @period, @policy_eff_date))) ; --jumlah hari dlm setahun

	if ((datediff(day, dateadd(year, (@period - 1), @policy_eff_date), @p_termination_date)) = @day_in_year)
	begin
		set @outstanding_day_in_year = @day_in_year ;
	end ;
	else
	begin
		set @outstanding_day_in_year = @day_in_year - (datediff(day, dateadd(year, (@period - 1), @policy_eff_date), @p_termination_date)) ;
	end ;

	select	@proposional_buy_amount = sum(total_buy_amount) * (@outstanding_day_in_year * 1.0 / @day_in_year)
	from	dbo.insurance_policy_main_period
	where	policy_code		 = @p_policy_code
			and year_periode = @period ; --dipakai

	set @proposional_buy_amount = isnull(@proposional_buy_amount, 0) ;

	select	@outstanding_buy_amount = isnull(sum(total_buy_amount), 0)
	from	dbo.insurance_policy_main_period
	where	policy_code		 = @p_policy_code
			and year_periode > @period ; --sisa

	set @outstanding_buy_amount = isnull(@outstanding_buy_amount, 0) ;
	set @termination_amount = @outstanding_buy_amount + @proposional_buy_amount ;

	return round(@termination_amount, 0, 0) ;
end ;
