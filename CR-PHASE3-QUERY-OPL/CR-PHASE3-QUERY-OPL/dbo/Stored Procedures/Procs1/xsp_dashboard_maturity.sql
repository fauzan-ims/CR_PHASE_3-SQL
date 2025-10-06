CREATE PROCEDURE dbo.xsp_dashboard_maturity
(
	@p_user_id	nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max) 
			--,@p_user_id			nvarchar(50)
	

	begin try

	
				
		--select	count(am.agreement_external_no) 'total_data'
		--		,'Maturity 1 s.d 7' 'reff_name'
		--from	agreement_main am
				 
		--		outer apply
		--		(
		--			select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
		--					,max(due_date) 'maturity_date'
		--			from	dbo.agreement_asset_amortization
		--			where	agreement_no = am.agreement_no
		--		) aaa
		--where	am.maturity_code is null
		--		and am.agreement_status = 'go live'
		--		and am.marketing_code = @p_user_id
		--		and (aaa.maturity_days between 0 and 7)
		--						union all
		select	count(am.agreement_external_no) 'total_data'
				,'Maturity 8 s.d 14' 'reff_name'
		from	agreement_main am
				 
				outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aaa
		where	am.maturity_code is null
				and am.agreement_status = 'go live'
				and am.MARKETING_CODE = @p_user_id
				and (aaa.maturity_days between 8 and 14)
												union all
		select	count(am.agreement_external_no) 'total_data'
				,'Maturity 14 s.d 21' 'reff_name'
		from	agreement_main am
				 
				outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aaa
		where	am.maturity_code is null
				and am.agreement_status = 'go live'
				and am.MARKETING_CODE = @p_user_id
				and (aaa.maturity_days between 14 and 21)
				union all
		select	count(am.agreement_external_no) 'total_data'
				,'Maturity 22 s.d 30' 'reff_name'
		from	agreement_main am
				 
				outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aaa
		where	am.maturity_code is null
				and am.agreement_status = 'go live'
				and am.MARKETING_CODE = @p_user_id
				and (aaa.maturity_days between 22 and 30)
				union all
		select	count(am.agreement_external_no) 'total_data'
				,'Maturity 31 s.d 60' 'reff_name'
		from	agreement_main am
				 
				outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aaa
		where	am.maturity_code is null
				and am.agreement_status = 'go live'
				and am.MARKETING_CODE = @p_user_id
				and (aaa.maturity_days between 31 and 60)
				union all
		select	count(am.agreement_external_no) 'total_data'
				,'Maturity 61 s.d 90' 'reff_name'
		from	agreement_main am
				 
				outer apply
				(
					select	datediff(day, dbo.xfn_get_system_date(), max(due_date)) 'maturity_days'
							,max(due_date) 'maturity_date'
					from	dbo.agreement_asset_amortization
					where	agreement_no = am.agreement_no
				) aaa
		where	am.maturity_code is null
				and am.agreement_status = 'go live'
				and am.MARKETING_CODE = @p_user_id
				and (aaa.maturity_days between 61 and 90)

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
