CREATE procedure [dbo].[xsp_generate_insurance_expired]
as
begin
	declare @msg			 nvarchar(max)
			,@policy_no		 nvarchar(50)
			,@total_asset	 nvarchar(4)
			,@eff_date		 nvarchar(30)
			,@exp_date		 nvarchar(30)
			,@insurance_name nvarchar(250)
			,@status		 nvarchar(50) ;

	delete dbo.insurance_expired

	declare curr_exp_polis cursor fast_forward read_only for
	select	policy_no
			,asset.total_asset
			,convert(varchar(30), ipm.policy_eff_date, 103)
			,convert(varchar(30), ipm.policy_exp_date, 103)
			,ipm.insured_name
			,ipm.policy_payment_status
	from	dbo.insurance_policy_main ipm
			outer apply
	(
		select		count(ipa.code) 'total_asset'
		from		dbo.insurance_policy_asset ipa
		where		ipa.policy_code = ipm.code
		group by	ipa.policy_code
	)								  asset
	where	cast(ipm.policy_exp_date as date)
	between cast(dbo.xfn_get_system_date() as date) and dateadd(month, 3, cast(dbo.xfn_get_system_date() as date)) ;

	open curr_exp_polis ;

	fetch next from curr_exp_polis
	into @policy_no
		 ,@total_asset
		 ,@eff_date
		 ,@exp_date
		 ,@insurance_name
		 ,@status ;

	while @@fetch_status = 0
	begin
		insert into dbo.insurance_expired
		(
			policy_no
			,total_asset
			,eff_date
			,exp_date
			,insurance_name
			,payment_status
		)
		values
		(
			@policy_no
			,@total_asset
			,@eff_date
			,@exp_date
			,@insurance_name
			,@status
		) ;

		fetch next from curr_exp_polis
		into @policy_no
			 ,@total_asset
			 ,@eff_date
			 ,@exp_date
			 ,@insurance_name
			 ,@status ;
	end ;

	close curr_exp_polis ;
	deallocate curr_exp_polis ;
end ;
