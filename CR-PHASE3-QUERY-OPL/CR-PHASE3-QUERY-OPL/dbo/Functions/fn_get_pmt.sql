 
create function dbo.fn_get_pmt
(
	@InterestRate  NUMERIC(18,15), --Rate is the interest rate per period.
	@Nper          INT,           --Nper is the total number of payment
								   --periods in an annuity.
	@Pv            NUMERIC(18,4), --Pv is the present value, or the
								   --lump-sum amount that a series of
								   --future payments is worth right now.
								   --If pv is omitted, it is assumed to be
								   --0 (zero). PV must be entered as a
								   --negative number.
	@Fv            NUMERIC(18,4), --Fv is the future value, or the
								   --lump-sum amount that a series of
								   --future payments is worth right now.
								   --If pv is omitted, it is assumed to
								   --be 0 (zero). PV must be entered as a
								   --negative number.
	@Type           BIT            --Type is the number 0 or 1 and
								   --indicates when payments are due.
								   --If type is omitted, it is assumed
								   --to be 0 which represents at the end
								   --of the period.
								   --If payments are due at the beginning
								   --of the period, type should be 1.
)
RETURNS NUMERIC(18,2) --float
AS
  begin
    declare  @value numeric(18,2)
    select @value = case
    when @type=0
    then convert(float,@interestrate / 100)
    /(power(convert(float,(1 + @interestrate / 100)),@nper)-1)
    * -(@pv*power(convert(float,(1 + @interestrate / 100)),@nper)
    +@fv)
 
    when @type=1
    then convert(float,@interestrate / 100) /
    (power(convert(float,(1 + @interestrate / 100)),@nper)-1)
    * -(@pv*power(convert(float,(1 + @interestrate / 100)),@nper)
    +@fv)
    /(1 + convert(float,(@interestrate / 100)))
 
  end
    return @value
  end


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[fn_get_pmt] TO [ims-raffyanda]
    AS [dbo];

