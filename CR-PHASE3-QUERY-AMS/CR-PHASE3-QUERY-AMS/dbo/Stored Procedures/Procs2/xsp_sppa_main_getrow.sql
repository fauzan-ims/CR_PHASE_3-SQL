CREATE PROCEDURE dbo.xsp_sppa_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	sm.code
			,sppa_branch_code
			,sppa_branch_name
			,sppa_date
			,sppa_status
			,sppa_remarks
			,insurance_code
			,mi.insurance_name
			,file_name
			,paths
			,sppa_detail.result_total_buy_amount
	from	sppa_main sm
			inner join dbo.master_insurance mi on (mi.code = sm.insurance_code)
			outer apply (select sum(result_total_buy_amount) 'result_total_buy_amount' from dbo.sppa_detail sd where sd.sppa_code = sm.code) sppa_detail
	where	sm.code = @p_code ;
end ;

