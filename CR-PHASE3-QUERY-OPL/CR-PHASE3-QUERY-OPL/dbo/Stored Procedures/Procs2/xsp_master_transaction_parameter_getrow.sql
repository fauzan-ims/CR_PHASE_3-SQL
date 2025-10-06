CREATE PROCEDURE dbo.xsp_master_transaction_parameter_getrow
(
	@p_id bigint
)
as
begin
	select	mtp.id
			,mtp.transaction_code
			,mtp.process_code
			,mt.transaction_name
			,mtp.order_key
			,mtp.parameter_amount
			,mtp.is_calculate_by_system
			,mtp.is_transaction
			,mtp.is_amount_editable
			,mtp.is_discount_editable
			,mtp.gl_link_code
			,jgla.gl_link_name
			,mtp.discount_gl_link_code
			,jglb.gl_link_name 'discount_gl_link_name'
			,mtp.maximum_disc_pct
			,mtp.maximum_disc_amount
			,mtp.is_journal				
			,mtp.debet_or_credit		
			,mtp.is_discount_jurnal		
	from	master_transaction_parameter mtp
			inner join dbo.master_transaction mt on (mtp.transaction_code = mt.code)
			left join dbo.journal_gl_link jgla on (jgla.code			  = mtp.gl_link_code)
			left join dbo.journal_gl_link jglb on (jglb.code			  = mtp.discount_gl_link_code)
	where	id = @p_id ;

end ;
