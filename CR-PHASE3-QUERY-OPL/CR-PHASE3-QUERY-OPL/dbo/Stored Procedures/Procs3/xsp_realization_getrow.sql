CREATE PROCEDURE dbo.xsp_realization_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	rz.code
			,rz.branch_code
			,rz.branch_name
			,rz.status
			,rz.date
			,rz.remark
			,rz.application_no
			,rz.agreement_no
			,rz.delivery_from
			,rz.delivery_pic_code
			,rz.delivery_pic_name
			,rz.delivery_vendor_name 'deliver_by'
			,rz.delivery_vendor_pic_name 'deliver_pic'
			,cm.client_name
			,rz.agreement_date
			,rz.file_name
			,rz.file_path
			,am.application_external_no
			,rz.agreement_external_no
			,rz.result
			,cm.client_no
			-- (+) Ari 2024-01-30 ket : enhancement 
			,am.credit_term 'top'
			,sum(tb.billing_amount) 'summary_rental_amount'
			,am.periode 'tenor'
			-- (+) Ari 2024-01-30
			,rz.file_memo
			,rz.file_path_memo
			,rz.exp_date
	from	realization rz
			inner join dbo.application_main am on (am.application_no = rz.application_no)
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
			-- (+) Ari 2024-01-30 ket : enhancement
			inner join dbo.realization_detail rd on (rd.realization_code = rz.code) 
			inner join dbo.application_asset aas on (aas.application_no = am.application_no and aas.asset_no = rd.asset_no)
			outer apply (
							select	sum(aam.billing_amount) 'billing_amount'
							from	dbo.application_amortization aam
							where	aam.application_no = am.application_no
							and		aam.asset_no = rd.asset_no
							--and		aam.installment_no = 1
						) tb
	where	rz.code = @p_code 
	group by rz.code
			,rz.branch_code
			,rz.branch_name
			,rz.status
			,rz.date
			,rz.remark
			,rz.application_no
			,rz.agreement_no
			,rz.delivery_from
			,rz.delivery_pic_code
			,rz.delivery_pic_name
			,rz.delivery_vendor_name
			,rz.delivery_vendor_pic_name
			,cm.client_name
			,rz.agreement_date
			,rz.file_name
			,rz.file_path
			,am.application_external_no
			,rz.agreement_external_no
			,rz.result
			,cm.client_no
			,am.credit_term
			,am.periode
			,rz.file_memo
			,rz.file_path_memo
			,rz.exp_date
end ;