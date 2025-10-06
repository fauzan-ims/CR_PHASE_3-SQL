--Created, Rian 21/12/2022

CREATE PROCEDURE [dbo].[xsp_maturity_detail_getrow]
(
	@p_id nvarchar(50)
)
as
begin
	select		md.id
				,md.maturity_code
				,md.asset_no
				,md.result
				,md.additional_periode
				,md.remark
				,aaa.maturity_date 'date'
				,aa.monthly_rental_rounded_amount
	from		dbo.maturity_detail md
	inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
	outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = aa.agreement_no
				) aaa
	where		id = @p_id ;
end ;
