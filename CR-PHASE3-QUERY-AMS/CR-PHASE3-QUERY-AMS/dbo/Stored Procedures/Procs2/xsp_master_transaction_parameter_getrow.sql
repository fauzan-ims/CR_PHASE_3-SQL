CREATE PROCEDURE dbo.xsp_master_transaction_parameter_getrow
(
	@p_id bigint
)
as
begin
	select	mtp.id
			,mtp.transaction_code
			,mt.transaction_name
			,mtp.process_code
			,mtp.order_key
			,mtp.parameter_amount
			,mtp.is_calculate_by_system
			,mtp.is_transaction
			,mtp.is_amount_editable
			,mtp.is_discount_editable
			,mtp.gl_link_code
			,mtp.gl_link_name
			,mtp.discount_gl_link_code
			,mtp.maximum_disc_pct
			,mtp.maximum_disc_amount
			,mtp.is_journal
			,mtp.debet_or_credit
			,mtp.is_discount_jurnal
			,mtp.is_reduce_transaction
			,mtp.is_psak
			,mtp.psak_gl_link_code
			,mtp.is_taxable
	from	master_transaction_parameter			 mtp
			left join dbo.master_transaction		 mt on (mt.code	 = mtp.transaction_code)
			left join dbo.journal_gl_link jgl on (jgl.code = mtp.gl_link_code)
			left join dbo.sys_general_subcode		sgc on (sgc.code = mtp.gl_link_code)
	where	id = @p_id ;
end ;
