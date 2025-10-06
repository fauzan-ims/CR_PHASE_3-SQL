
create procedure xsp_billing_generate_detail_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,generate_code
			,agreement_no
			,asset_no
			,billing_no
			,due_date
			,rental_amount
			,description
	from	billing_generate_detail
	where	id	= @p_id
end
