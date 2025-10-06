
create procedure dbo.xsp_credit_note_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
		   ,credit_note_code
		   ,invoice_no
		   ,invoice_detail_id
		   ,adjustment_amount
	from	credit_note_detail 
	where	id = @p_id ;
end ;
