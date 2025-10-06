CREATE PROCEDURE dbo.xsp_sppa_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,sppa_code
			,sppa_request_code
			,result_status
			,sd.result_date	'result_date'
			,result_total_buy_amount
			,result_policy_no
			,result_reason
			,sm.sppa_status
			,sd.fa_code
			,ass.item_name
			,sd.sum_insured_amount
	from	sppa_detail sd
			inner join dbo.sppa_main sm on (sm.code = sd.sppa_code)
			inner join dbo.asset ass on (ass.code = sd.fa_code)
	where	id = @p_id ;
end ;

