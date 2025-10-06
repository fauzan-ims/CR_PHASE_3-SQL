CREATE PROCEDURE dbo.xsp_master_transaction_parameter_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,mtp.company_code
			,transaction_code
			,mt.transaction_name
			,process_code
			,order_key
			,parameter_amount
			,is_calculate_by_system
			,is_transaction
			,is_amount_editable
			,is_discount_editable
			,gl_link_code
			,mtp.gl_link_name
			,discount_gl_link_code
			,mtp.discount_gl_link_name
			,maximum_disc_pct
			,maximum_disc_amount
			,is_journal
			,debet_or_credit
			,is_discount_jurnal
			,is_reduce_transaction
			,is_psak
			,psak_gl_link_code
			,mtp.psak_gl_link_name
	from	master_transaction_parameter mtp
	left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
	--left join dbo.journal_gl_link jgl on (jgl.code = mtp.gl_link_code)
	where	id = @p_id ;
end ;
