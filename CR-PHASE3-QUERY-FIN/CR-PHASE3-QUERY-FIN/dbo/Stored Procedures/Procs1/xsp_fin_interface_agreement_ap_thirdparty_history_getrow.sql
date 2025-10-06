create PROCEDURE dbo.xsp_fin_interface_agreement_ap_thirdparty_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,branch_code
			,branch_name
			,reff_code
			,reff_name
			,ap_type
			,ap_thirdparty_code
			,agreement_no
			,transaction_date
			,orig_amount
			,orig_currency_code
			,exch_rate
			,base_amount
			,source_reff_module
			,source_reff_no
			,source_reff_remarks
	from	fin_interface_agreement_ap_thirdparty_history
	where	id = @p_id ;
end ;
