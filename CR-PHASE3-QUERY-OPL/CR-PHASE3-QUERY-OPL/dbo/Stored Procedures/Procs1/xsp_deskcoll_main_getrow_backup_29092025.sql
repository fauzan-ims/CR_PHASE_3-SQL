CREATE PROCEDURE dbo.xsp_deskcoll_main_getrow_backup_29092025
(
	@p_id bigint
)
as
begin
	select	dmn.id
			,dmn.client_name
			,dmn.desk_date
			,dmn.desk_status
			,dmn.deskcoll_staff_name		'desk_collector_name'
			,dmn.posting_by_name			'posting_by'
			,dmn.posting_date
			,total_agreement_count
			,total_asset_count
			,total_monthly_rental_amount
	from	deskcoll_main dmn
			outer apply (	select	count(distinct ags.agreement_no)		'total_agreement_count'
									,count(distinct ags.asset_no)			'total_asset_count'
									,sum(ags.monthly_rental_rounded_amount)	'total_monthly_rental_amount'
							from	dbo.deskcoll_invoice di
									inner join dbo.invoice_detail inv on inv.invoice_no = di.invoice_no
									left join dbo.agreement_asset ags on ags.asset_no = inv.asset_no
							where	di.deskcoll_main_id = dmn.id
						) di
	where	id = @p_id ;
end ;
