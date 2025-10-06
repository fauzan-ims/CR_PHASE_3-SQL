CREATE PROCEDURE dbo.xsp_unsubscribe_request_gps_getrow	
(
	@p_code nvarchar(50)
)
as
begin
	select request_no,
           fa_code,
		   av.plat_no,
		   av.engine_no,
		   av.chassis_no,
		   a.agreement_external_no,
		   a.item_name,
           gur.request_date,
		   a.gps_received_date 'grn_date',
           source_reff_no 'source_transaction_no',
           source_reff_name 'source_transaction_name',
           gur.remark,
           gur.status,
           gur.branch_code,
           gur.branch_name,
		   gur.unsubscribe_date,
		   gur.reason_unsubscribe
		   ,gur.unsubscribe_date
		   ,a.gps_vendor_name	'vendor'
	from dbo.gps_unsubcribe_request gur
	inner join dbo.asset a on a.code = gur.fa_code
	inner join dbo.asset_vehicle av on av.asset_code = a.code
	where gur.request_no = @p_code
end ;
