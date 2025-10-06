CREATE PROCEDURE [dbo].[xsp_monitoring_gps_getrow]	
(
	@p_id nvarchar(50)
)
as
begin
	select	ast.code
			,ast.item_name
			,av.plat_no
			,av.engine_no
			,av.chassis_no
			,ast.agreement_external_no
			,mg.vendor_name
			,convert(nvarchar(30), mg.first_payment_date, 103) 'paid_date'
			,CONVERT(NVARCHAR(30), handover_bast_date, 103) 'from_period'
			,CONVERT(NVARCHAR(30), maturity_date, 103) 'to_period'
			,mg.status 'gps_status'
            ,mg.first_payment_date,
             mg.grn_date,
             mg.total_paid subcribe_amount_month,
             mg.unsubscribe_date
	from	dbo.monitoring_gps mg
			inner join dbo.asset ast on ast.code = mg.fa_code
			inner join dbo.asset_vehicle		av	on av.asset_code = ast.code
			outer apply (	select	ags.handover_bast_date, isnull(ags.maturity_date, dateadd(month,ags.periode,ags.handover_bast_date)) 'maturity_date'
							from	ifinopl.dbo.agreement_main am 
									inner join ifinopl.dbo.agreement_asset ags on ags.agreement_no = am.agreement_no
							where	am.agreement_no = ast.agreement_no
							and		ags.fa_code = mg.fa_code
							and		ast.asset_no = ags.asset_no
						) am
	where	id = @p_id
end ;
