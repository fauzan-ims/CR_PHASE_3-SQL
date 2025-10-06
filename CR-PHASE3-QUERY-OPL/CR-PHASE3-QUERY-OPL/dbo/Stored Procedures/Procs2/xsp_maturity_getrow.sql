--Created, Rian 19/12/2022

CREATE procedure [dbo].[xsp_maturity_getrow]
(
	@p_code nvarchar(50)
)
as
begin 
	select	ma.code
			,ma.branch_code
			,ma.branch_name
			,am.agreement_external_no
			,ma.agreement_no
			,ma.date
			,ma.status
			,ma.remark
			,am.client_name
			,ma.result
			,ma.additional_periode
			,ma.pickup_date
			,ma.file_name
			,ma.file_paths
			,mbt.description 'old_billing_type_desc'
			,ma.new_billing_type
			,mbt2.description 'new_billing_type_desc'
			,ma2.additional_periode 'total_extend_periode'
	from	dbo.maturity ma
			inner join dbo.agreement_main am on (am.agreement_no = ma.agreement_no)
			left join dbo.master_billing_type mbt on (mbt.code = am.billing_type)
			left join dbo.master_billing_type mbt2 on (mbt2.code = ma.new_billing_type)
			outer apply
	(
		select	isnull(sum(isnull(additional_periode, 0)), 0) 'additional_periode'
		from	dbo.maturity ma2
		where	agreement_no = ma.AGREEMENT_NO
				and status in
	(
		'APPROVE', 'POST'
	)
	) ma2
	where	ma.code = @p_code ;
end ;
