
CREATE function dbo.xfn_deviation_check_dsr_dev
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @number				 decimal(18, 2) = 0
			,@result			 int
			,@installment_amount decimal(18, 2) = 0
			,@rental_amount		 decimal(18, 2) = 0
			,@monthly_sales		 decimal(18, 2) = 0 ;

	select	@installment_amount = sum(installment_amount)
	from	dbo.application_exposure
	where	application_no = @p_application_no ;

	select	@rental_amount = rental_amount
	from	dbo.application_main
	where	application_no = @p_application_no ;

	select	@monthly_sales = monthly_sales
	from	dbo.application_survey
	where	application_no = @p_application_no ;

	if (@monthly_sales > 0)
	begin
		set @number = ((@installment_amount + @rental_amount) / @monthly_sales) * 100 ;
	end ;
	else
	begin
		set @number = (@installment_amount + @rental_amount) ;
	end ;
	 
	if @number > 30
	begin
		set @result = '1' ;
	end ;
	else
	begin
		set @result = '0' ;
	end ;

	return @result ;
end ;
