CREATE PROCEDURE [dbo].[get_IRR_Application] 
	@f_Applicno		nvarchar(20),
	@p_payment		Numeric(18,2),
	@p_amtlease		Numeric(18,2),
	@p_rentalpay	numeric (1,0),
	@f_lsperiod		numeric (3,0),
	@IRR_Return		Numeric(18,15) output
as 
begin

	declare @irrPrev Float set @irrPrev = 0
	declare @irr Float  set @irr = 0.0001
	declare @pvPrev Float
	declare @pv float
	declare @sss numeric (18,13)
	declare @nDimuka numeric (1) set @nDimuka=0
	Select @pvPrev = @p_amtlease
	
	IF @p_rentalpay=1
	BEGIN
		Select @pvPrev = @p_amtlease-@p_payment
		Select @nDimuka=1
	END	

	--select payment,OSPRINCIP,PERIOD into #LS_APPLIAMOR_CURR from LS_APPLIAMOR 
	--where applicno=@f_Applicno AND PERIOD<=(@f_lsperiod-@nDimuka)
	
	select	payment,OSPRINCIP,PERIOD 
	into	#LS_APPLIAMOR_CURR 
	from	LS_APPLIAMOR 
	where	applicno=@f_Applicno 
	AND		PERIOD>=@nDimuka
	order by period
	
	update #LS_APPLIAMOR_CURR set PAYMENT=@pvPrev*-1 where PERIOD=@nDimuka
	
	SELECT	@IRR_Return = [dbo].IRR(period, payment) * 1200
	FROM	#LS_APPLIAMOR_CURR 
	
--	set @pv = (select sum(payment/power(1+@irr,period))from #LS_APPLIAMOR_CURR )

--	while abs(@pv) >=0.00001
--	begin
--		declare @t float
--		set @t = @irrPrev
--		set @irrPrev = @irr
--		set @irr = @irr + (@t-@irr)*@pv/(@pv-@pvPrev)
--		set @pvPrev = @pv
--		set @pv = ( select sum(payment/power(1+@irr,period)) from #LS_APPLIAMOR_CURR )
--	end
--	select @sss = 0.000000000000+@irr

--	Select @IRR_Return= @sss*1200
----select @IRR_Return

	Update LS_APPLICATION Set EFFRATE= @IRR_Return where applicno=@f_Applicno

end



