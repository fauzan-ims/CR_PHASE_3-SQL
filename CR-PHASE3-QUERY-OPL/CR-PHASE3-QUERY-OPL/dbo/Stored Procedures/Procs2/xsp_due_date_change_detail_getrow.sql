--created by, Rian at 04/05/2023	

CREATE procedure dbo.xsp_due_date_change_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,due_date_change_code
			,asset_no
			,os_rental_amount
			,old_due_date_day
			,new_due_date_day
			,at_installment_no
			,is_change
	from	dbo.due_date_change_detail
	where	id = @p_id ;
end ;
