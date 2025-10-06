
CREATE PROCEDURE dbo.xsp_application_exposure_delete
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		  nvarchar(max)
			,@description nvarchar(4000)
			,@client_no	  nvarchar(50) ;

	begin try
		delete	dbo.application_exposure
		where	application_no = @p_application_no ;

		if not exists
		(
			select	1
			from	application_exposure
			where	application_no	  = @p_application_no
					and facility_name = 'OPERATING LEASE'
		)
		begin
			select	@client_no = cm.client_no
			from	dbo.application_main am with (nolock)
					inner join dbo.client_main cm with (nolock) on (cm.code = am.client_code)
			where	am.application_no = @p_application_no ;

			insert into dbo.application_exposure
			(
				application_no
				,relation_type
				,agreement_no
				,agreement_date
				,facility_name
				,amount_finance_amount
				,os_installment_amount
				,installment_amount
				,tenor
				,os_tenor
				,last_due_date
				,ovd_days
				,max_ovd_days
				,ovd_installment_amount
				,description
				,group_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_application_no
					,''
					,am.agreement_external_no
					,am.agreement_date
					,am.facility_name
					,isnull(ass.purchase_price, 0)
					,isnull(ass.net_book, 0) + isnull(aa2.asset_amount, 0) --ai.os_rental_amount
					,isnull(aa.lease_amount, 0)
					,am.periode
					,ai.os_period
					,ai.maturity_date
					,ai.ovd_days
					,ai.max_ovd_days
					,ai.ovd_rental_amount
					,'AGREEMENT - ' + am.agreement_status
					,am.client_name
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.agreement_main am with (nolock)
					inner join dbo.agreement_information ai with (nolock) on (ai.agreement_no = am.agreement_no)
					outer apply
			(
				select	sum(aa.asset_amount) 'asset_amount'
						,sum(aa.lease_rounded_amount) 'lease_amount'
				from	dbo.agreement_asset aa with (nolock)
				where	aa.agreement_no		= am.agreement_no
						and aa.asset_status = 'RENTED'
			) aa
					outer apply
			(
				select	sum(aa.asset_amount) 'asset_amount'
				from	dbo.agreement_asset aa with (nolock)
				where	aa.agreement_no			   = am.agreement_no
						and aa.asset_status		   = 'RENTED'
						and isnull(aa.fa_code, '') = ''
			) aa2
					outer apply
			(
				select	sum(ass.net_book_value_comm) 'net_book'
						,sum(ass.purchase_price) 'purchase_price'
				from	ifinams.dbo.asset ass with (nolock)
				where	ass.agreement_no = am.agreement_no
						and ass.status	 = 'STOCK'
			) ass
			where	client_no = @client_no
					and am.agreement_external_no not in
						(
							select	agreement_no
							from	dbo.application_exposure with (nolock)
							where	application_no = @p_application_no
						)
					and am.agreement_status = 'GO LIVE' ;

			insert into dbo.application_exposure
			(
				application_no
				,relation_type
				,agreement_no
				,agreement_date
				,facility_name
				,amount_finance_amount
				,os_installment_amount
				,installment_amount
				,tenor
				,os_tenor
				,last_due_date
				,ovd_days
				,max_ovd_days
				,ovd_installment_amount
				,description
				,group_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_application_no
					,''
					,am.application_external_no
					,am.application_date
					,'OPERATING LEASE'
					,isnull(isnull(aa.purchase_price, 0) + isnull(aa2.asset_amount, 0), 0)
					,isnull(isnull(aa.purchase_price, 0) + isnull(aa2.asset_amount, 0), 0) --isnull(aa.net_book, 0) + isnull(aa2.asset_amount, 0) --aa.asset_amount
					,isnull(aa.lease_amount, 0)
					,am.periode
					,am.periode
					,aaa.maturity_date
					,0
					,0
					,0
					,'APPLICATION - ' + am.application_status
					,cm.client_name
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_main am with (nolock)
					inner join dbo.client_main cm with (nolock) on (cm.code = am.client_code)
					outer apply
			(
				select	sum(aa.asset_amount) 'asset_amount'
						,sum(ass.purchase_price) 'purchase_price'
						,sum(aa.lease_rounded_amount) 'lease_amount'
						,sum(ass.net_book) 'net_book'
				from	dbo.application_asset aa with (nolock)
						outer apply
				(
					select	sum(ass.net_book_value_comm) 'net_book'
							,sum(ass.purchase_price) 'purchase_price'
					from	ifinams.dbo.asset ass with (nolock)
					where	ass.code	   = aa.fa_code
							and ass.status = 'STOCK'
				) ass
				where	aa.application_no = am.application_no
			) aa
					outer apply
			(
				select	sum(aa.asset_amount) 'asset_amount'
				from	dbo.application_asset aa with (nolock)
				where	aa.application_no		   = am.application_no
						and isnull(aa.fa_code, '') = ''
			) aa2
					outer apply
			(
				select	max(aa.due_date) 'maturity_date'
				from	dbo.application_amortization aa with (nolock)
				where	aa.application_no = am.application_no
			) aaa
			where	client_no = @client_no
					and am.application_external_no not in
						(
							select	agreement_no
							from	dbo.application_exposure with (nolock)
							where	application_no = @p_application_no
						)
					and am.is_simulation	  = '0'
					-- Louis Rabu, 04 September 2024 15.20.46 -- pada FOU hanya calculate yang GO LIVE sehingga ini ttutup dan dignti sama status go live saja
					--		and am.application_status in
					--(
					--	N'ON PROCESS', N'APPROVE', N'GO LIVE'
					--)
					and am.application_status = N'GO LIVE'
					and am.application_no not in
						(
							select	application_no
							from	dbo.agreement_main with (nolock)
						) ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
