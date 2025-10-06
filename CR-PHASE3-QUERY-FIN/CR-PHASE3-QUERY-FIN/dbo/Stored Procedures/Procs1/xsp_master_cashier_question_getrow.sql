
create procedure xsp_master_cashier_question_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
	from	master_cashier_question
	where	code = @p_code ;
end ;
