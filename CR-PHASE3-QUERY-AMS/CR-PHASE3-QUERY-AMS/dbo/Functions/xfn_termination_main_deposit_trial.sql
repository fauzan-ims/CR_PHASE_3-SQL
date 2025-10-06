CREATE FUNCTION dbo.xfn_termination_main_deposit_trial
(
	@p_termination_code nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount				  decimal(18, 2)
			,@termination_approved_amount decimal(18, 2) ;


declare cur_parameter cursor local fast_forward read_only for
select	REFUND_AMOUNT
from	dbo.TERMINATION_DETAIL_ASSET
where	TERMINATION_CODE = @p_termination_code ;

open cur_parameter
fetch cur_parameter 
into @termination_approved_amount

while @@fetch_status = 0
BEGIN
    
	set @return_amount = isnull(@termination_approved_amount, 0) ;

	fetch cur_parameter 
	into @termination_approved_amount

	end
	close cur_parameter
	deallocate cur_parameter

	return @return_amount ;

end ;
