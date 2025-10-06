CREATE FUNCTION dbo.xfn_agreement_get_deposit_other
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
returns decimal(18, 2)
as
begin
	--(+) Rinda 11/01/202111:06:29 notes :	
	declare @deposit_installment decimal(18, 2) ;

	set @deposit_installment = dbo.xfn_get_agreement_deposit_data(@p_agreement_no, 'OTHER') ;

	return isnull(@deposit_installment, 0) ;
end ;
