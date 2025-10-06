CREATE PROCEDURE dbo.xsp_insurance_register_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @editable	nvarchar(1) = 1 
			,@count		int;

	if exists
	(
		select	1
		from	dbo.insurance_register_period
		where	register_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ;

	select	@count = count (1)
	from	dbo.insurance_register_period
	where	register_code = @p_code

	select	ir.code
			,ir.register_no
			,ir.branch_code
			,ir.branch_name
			,ir.register_status
			,ir.register_name
			,ir.register_qq_name
			,ir.register_object_name
			,ir.register_remarks
			,ir.currency_code
			,ir.insurance_code
			,ir.insurance_type
			,ir.year_period
			,ir.is_renual
			,ir.from_date
			,ir.to_date
			,case ir.insurance_payment_type
				 when 'FTFP' then 'Full Tenor Full Payment'
				 else ir.insurance_payment_type
			 end 'insurance_payment_type'
			,ir.insurance_paid_by
			,ir.source_type
			,mi.insurance_name
			,ir.eff_rate
			,@editable 'editable'
			,@count 'count'
			,ir.register_type
			,ir.policy_code
			,ipm.policy_no
	from	insurance_register ir
			left join dbo.master_insurance mi on (mi.code		 = ir.insurance_code)
			left join dbo.insurance_policy_main ipm on (ipm.code = ir.policy_code)
	where	ir.code = @p_code ;
end ;
