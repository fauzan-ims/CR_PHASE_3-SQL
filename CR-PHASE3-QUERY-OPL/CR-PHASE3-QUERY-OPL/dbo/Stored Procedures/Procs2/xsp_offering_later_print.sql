--Created by, Rian at 30/01/2023 
CREATE PROCEDURE dbo.xsp_offering_later_print
(
	@p_user_id		   nvarchar(50)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @msg					nvarchar(max)
			,@application_date		datetime
			,@application_no		nvarchar(50)
			,@asset_no				nvarchar(50)
			,@client_name			nvarchar(50)
			,@client_address		nvarchar(250)
			,@client_contact_person nvarchar(50)
			,@asset_name			nvarchar(50)
			,@asset_amount			nvarchar(25)
			,@periode				int
			,@currency				nvarchar(3)
			,@billing_amount		decimal(18, 2)
			,@billing_type			nvarchar(50)
			,@ovd_pct				decimal(9, 6)
			,@company_name			nvarchar(50)
			,@rows_count			int			  = 0
			,@print_asset_name		nvarchar(250)
			,@print_asset_amount	nvarchar(25) 
			,@print_no				nvarchar(3) 
			,@temp_asset_name		nvarchar(4000) = ''
			,@temp_asset_amount		nvarchar(4000) = ''
			,@temp_no				nvarchar(4000) = ''
			,@no					int            = 0 ;

	begin try

		--set company name
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP' ;

		select		@periode					= am.periode
					,@billing_type				= (case
														when am.billing_type = 'AMN' then 'Tahun'
														when am.billing_type = 'BIM' then '2 Bulan'
														when am.billing_type = 'MNT' then 'Bulan'
														when am.billing_type = 'QRT' then '3 Bulan'
														else '6 Bulan'
													end
													)
					,@application_date			= am.application_date
					,@currency					= am.currency_code
					,@client_name				= cm.client_name
					,@client_contact_person		= cpi.area_mobile_no + cpi.mobile_no
					,@client_address			= ca.address
		from		dbo.application_main am
					left join dbo.client_main cm on (cm.code							 = am.client_code)
					left join dbo.client_personal_info cpi on (cpi.client_code			 = cm.code)
					left join dbo.client_address ca on (ca.client_code					 = cm.code)
		where		am.application_no = @p_application_no

		--Set billing amoun
		select		@billing_amount = sum(aaa.billing_amount)
		from		dbo.application_main am
					inner join dbo.APPLICATION_AMORTIZATION aaa on (aaa.APPLICATION_NO = am.APPLICATION_NO)
		where		am.application_no = @p_application_no
		and			aaa.installment_no = 1

		--set denda keterlambatan
		select		@ovd_pct = charges_rate
		from		dbo.application_charges
		where		application_no = @p_application_no

		--declare cursor
		declare c_asset cursor for
		select	application_no
				,asset_no
				,asset_name
				,cast(lease_rounded_amount as nvarchar(25))
		from	dbo.application_asset
		where	application_no = @p_application_no ;

		--open cursor
		open c_asset ;

		--fecth cursor
		fetch c_asset
		into	@application_no
				,@asset_no
				,@asset_name
				,@asset_amount ;

		while @@fetch_status = 0
		begin
			set @print_asset_name	= ''
			set @print_asset_amount = ''
			set @print_no			= ''
			set @no += 1

			set @print_asset_name	= @asset_name
			set @print_asset_amount	= @asset_amount

			set @print_no = cast(@no as nvarchar(3))
			set @temp_no = @temp_no + @print_no + char(10) + char(13)
			set @temp_asset_amount = @temp_asset_amount + @print_asset_amount + char(10) + char(13)
			set @temp_asset_name = @temp_asset_name + @print_asset_name + char(10) + char(13)
				
		--fecth cursor selanjutnya
		fetch c_asset
		into	@application_no
				,@asset_no
				,@asset_name
				,@asset_amount ;
		end ;

		--close and deallocate cursor
		close c_asset ;
		deallocate c_asset ;

		--select table 
		select	@periode												as 'PERIODE'
				,@company_name											as 'COMPANY_NAME'
				,@billing_type											as 'BILLING_TYPE'
				,convert(nvarchar(30), @application_date, 103)			as 'APPLICATION_DATE'
				,@currency												as 'CURRENCY'
				,@client_name											as 'CLIENT_NAME'
				,@client_contact_person									as 'CLIENT_CONTACT_PERSON'
				,@client_address										as 'CLIENT_ADDRESS'
				,@billing_amount										as 'BILLING_AMOUNT'
				,application_no											as 'APPLICATION_NO'
				,@temp_no												as 'NO'
				,@ovd_pct												as 'OVD_PCT'
				,@temp_asset_name										as 'ASSET_NAME'
				,@temp_asset_amount										as 'ASSET_AMOUNT'
		from	dbo.application_main am
		where	am.application_no = @p_application_no

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
