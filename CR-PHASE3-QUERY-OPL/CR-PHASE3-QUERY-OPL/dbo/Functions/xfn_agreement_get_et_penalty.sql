CREATE FUNCTION dbo.xfn_agreement_get_et_penalty
(
	@p_reff_no		 nvarchar(50)
	,@p_agreement_no nvarchar(50)
	,@p_date		 datetime
)
returns decimal(18, 2)
as
begin
	--(+) Rinda 11/01/202111:06:29 notes :	
	declare @et_penalty		 decimal(18, 2)
			,@calculate_type nvarchar(50)
			,@charges_rate	 decimal(9, 6)
			,@charges_amount decimal(18, 2)
			,@os_principal	 decimal(18, 2) ;

	select	@calculate_type = calculate_by
			,@charges_amount = charges_amount
			,@charges_rate = charges_rate
	from	dbo.agreement_charges
	where	agreement_no	 = @p_agreement_no
			and charges_code = 'CETP' ;
			
	set @os_principal = dbo.xfn_et_get_os_principal_new(@p_reff_no, @p_agreement_no, @p_date) ;
	--set @os_principal = dbo.xfn_et_get_os_principal(@p_reff_no, @p_agreement_no, @p_date) ;

	if (@calculate_type = 'PCT')
	begin
		set @et_penalty = @os_principal * (@charges_rate / 100) ;
	end ;
	else
	begin
		set @et_penalty = @charges_amount ;
	end ;

	return isnull(round(@et_penalty, 0), 0) ;
end ;
