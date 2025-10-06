CREATE PROCEDURE [dbo].[xsp_application_insurance_for_getrate]
(
	@p_application_no  nvarchar(50)
	,@p_tenor		   int
	,@p_insurance_code nvarchar(50)
	,@p_coverage_code  nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max)
			,@multiplier	int = 1
			,@package_code  nvarchar(50)
			,@tenor_tc		int ;
	
	select	@package_code = package_code
			,@tenor_tc = tenor
	from	dbo.application_main am 
			inner join dbo.application_tc at on (at.application_no = am.application_no)
	where	am.application_no = @p_application_no ;
	
		
	if (@p_tenor > (select tenor from dbo.application_tc where application_no = @p_application_no))
	begin
		set @msg = 'Tenor must be less or equal than ' + cast(ceiling(cast(@tenor_tc as decimal(18, 2)) / 12) as nvarchar(50)) + ' Year';
		raiserror(@msg, 16, -1) ;
	end 

	if (isnull(@package_code, '') <> '')
	begin
		if exists (select 1 from dbo.master_package_insurance where package_code = @package_code)
		begin
			if not exists (select 1 from dbo.master_package_insurance where package_code = @package_code and insurance_code = @p_insurance_code)
			begin
				set @msg = 'V;This Insurer is not listed in this package, Please select another insurer'
				raiserror (@msg, 16,1) ;
				return ;
			end
		end
			
		if exists (select 1 from dbo.master_package_coverage where package_code = @package_code)
		begin
			if not exists (select 1 from dbo.master_package_coverage where package_code = @package_code and coverage_code = @p_coverage_code)
			begin
				set @msg = 'V;This Coverage is not listed in this package, Please select another Coverage'
				raiserror (@msg, 16,1) ;
				return ;
			end
		end
	end

	select	@multiplier = multiplier
	from	master_payment_schedule mps
			inner join dbo.application_tc at on (at.payment_schedule_type_code = mps.code)
	where	at.application_no = @p_application_no ;

	select	cpi.gender_code
			,at.interest_eff_rate
			,datediff(yy, cpi.date_of_birth, getdate()) 'age'
			,am.application_date 'eff_date'
			,dateadd(month, (@p_tenor * @multiplier), am.application_date) 'exp_date'
	from	application_main am
			left join dbo.client_personal_info cpi on (cpi.client_code = am.client_code)
			left join dbo.application_tc at on (at.application_no		= am.application_no)
	where	am.application_no = @p_application_no ;
end ;

