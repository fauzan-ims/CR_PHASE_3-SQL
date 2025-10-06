CREATE PROCEDURE dbo.xsp_bank_mutation_getrow_for_close_amount
(
	@p_code				nvarchar(50)
	,@p_from_date		datetime
	,@p_to_date			datetime
	--,@p_amount			decimal(18,2)
)
as
begin
	declare	@msg					nvarchar(max)
			,@before_amount			decimal(18, 2)
			,@innitial_amount		decimal(18, 2)

	select		@before_amount = isnull(sum(orig_amount),0)
	from		bank_mutation_history
	where		bank_mutation_code	=	@p_code
				and cast(transaction_date as date) < cast(@p_from_date as date) 

	select		isnull(sum(orig_amount),0) + isnull(@before_amount,0) 'base_amount'
				,@before_amount 'open_amount'
	from		bank_mutation_history
	where		bank_mutation_code	=	@p_code
				and cast(transaction_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
end ;
