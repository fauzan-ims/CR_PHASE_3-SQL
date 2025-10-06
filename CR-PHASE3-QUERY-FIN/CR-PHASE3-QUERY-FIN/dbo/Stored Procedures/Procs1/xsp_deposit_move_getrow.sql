CREATE PROCEDURE [dbo].[xsp_deposit_move_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	dm.code
			,dm.branch_code
			,dm.branch_name
			,dm.move_status
			,dm.move_date
			,dm.move_remarks
			,dm.from_deposit_code
			,dm.from_agreement_no
			,dm.from_deposit_type_code
			,dm.from_amount
			-- Louis Senin, 30 Juni 2025 16.52.51 -- 
			--,dm.to_agreement_no
			--,dm.to_deposit_type_code
			--,dm.to_amount
			-- Louis Senin, 30 Juni 2025 16.52.51 -- 
			,amf.agreement_external_no 'from_agreement_external_no'
			,amf.client_name 'from_client_name'
			,amf.client_code 'from_client_code'
			-- Louis Senin, 30 Juni 2025 16.52.51 -- 
			--,amt.agreement_external_no 'to_agreement_external_no'
			--,amt.client_name 'to_client_name'
			-- Louis Senin, 30 Juni 2025 16.52.51 -- 
			,amf.currency_code 'from_currency_code'
			,dm.total_to_amount -- Louis Senin, 30 Juni 2025 18.48.49 --
	from	deposit_move dm
			inner join dbo.agreement_main amf on (amf.agreement_no = dm.from_agreement_no)
			--inner join dbo.agreement_main amt on (amt.agreement_no = dm.to_agreement_no) -- Louis Senin, 30 Juni 2025 16.52.51 -- 
	where	code = @p_code ;
end ;
