
CREATE function [dbo].[xfn_rules_check_maximun_plafond_limit]
(
	@p_application_no nvarchar(50)
)
returns nvarchar(max)
as
begin
	declare @number					decimal(18, 2) = 0
			,@result				nvarchar(max)
			,@rental_amount			decimal(18, 2)
			,@os_installment_amount decimal(18, 2)
			,@os_rental_amount		decimal(18, 2)
			,@total_rental_amount	decimal(18, 2)
			,@client_no				nvarchar(50) ;

	select	@rental_amount = rental_amount
			,@client_no = cm.client_no
	from	dbo.application_main am
			inner join dbo.client_main cm on (cm.code = am.client_code)
	where	application_no = @p_application_no ;

	select	@os_installment_amount = os_installment_amount
	from	dbo.application_exposure
	where	application_no = @p_application_no ;

	select	@os_rental_amount = ai.os_rental_amount
	from	dbo.agreement_main am
			inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
	where	client_no			 = @client_no
			and agreement_status = 'GO LIVE' ;

	set @total_rental_amount = isnull(@rental_amount, 0) + isnull(@os_rental_amount, 0) + isnull(@os_installment_amount, 0) ;

	--select	@number = reff_value_number
	--from	dbo.application_external_data
	--where	application_no = @p_application_no
	--		and remark	   = 'Plafond'
	--		and reff_name  = 'PlafondMax' ;

	--select	@number = reff_value_number
	--from	dbo.application_external_data
	--where	application_no = @p_application_no
	--		and remark	   = 'Plafond'
	--		and reff_name  = 'PlafondMax' ;

	select	@number = reff_value_number
	from	dbo.application_external_data
	where	application_no = @p_application_no
			and remark	   = 'Plafond'
			and reff_name  = 'PlafondMax' ;

	if @total_rental_amount >= 90000000000
	begin
		if (@rental_amount > @number)
		begin
			set @result = 'Insufficient plafond limit. Outstanding Credit + New Credit is : Rp.' +  convert(varchar, cast(@total_rental_amount as money), 1);
		end ;
	end ;
	else
	begin
		set @result = '' ;
	end ;

	return @result ;
end ;
