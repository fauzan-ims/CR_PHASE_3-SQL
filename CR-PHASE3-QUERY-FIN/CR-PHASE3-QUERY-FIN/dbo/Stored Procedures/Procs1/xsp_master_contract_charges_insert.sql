CREATE PROCEDURE [dbo].[xsp_master_contract_charges_insert]
(
	@p_id					bigint		= 0 output
	,@p_main_contract_no	nvarchar(50)
	,@p_charges_code		nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@currency_code nvarchar(3)
			,@facility_name nvarchar(250)
			,@facility_code nvarchar(50) ;

	begin try
		--select	@currency_code = currency_code
		--		,@facility_code = facility_code
		--from	application_main
		--where	application_no = @p_application_no ;

		--if exists
		--(
		--	select	1
		--	from	main_contract_charges
		--	where	main_contract_no	 = @p_main_contract_no
		--			and charges_code = @p_charges_code
		--)
		--begin
		--	set @msg = N'Charges already exist' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		--if not exists
		--(
		--	select	1
		--	from	dbo.master_charges_amount
		--	where	currency_code	  = @currency_code
		--			and charge_code	  = @p_charges_code
		--			and facility_code = @facility_code
		--)
		--begin
		--	select	@facility_name = description
		--	from	dbo.master_facility
		--	where	code = @facility_code ;

		--	set @msg = N'Charges not exist for this facility : ' + @facility_name ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		--if not exists
		--(

		--select 1 from 	dbo.master_charges_amount
		--where	currency_code	  = @currency_code
		--		and charge_code	  = @p_charges_code
		--		and facility_code = @facility_code 
		--		and effective_date <= dbo.xfn_get_system_date()
		--)
		--begin
		
		--	set @msg = N'There are no effective Charges rates or amounts' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

		insert into dbo.master_contract_charges
		(
			main_contract_no
			,charges_code
			,dafault_charges_rate
			,dafault_charges_amount
			,calculate_by
			,charges_rate
			,charges_amount
			,new_calculate_by
			,new_charges_rate
			,new_charges_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_main_contract_no
				,@p_charges_code
				,isnull(charges_rate, 0)
				,isnull(charges_amount, 0)
				,calculate_by
				,isnull(charges_rate, 0)
				,isnull(charges_amount, 0)
				,calculate_by
				,isnull(charges_rate, 0)
				,isnull(charges_amount, 0)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_charges_amount
		where	currency_code	  = 'IDR'
				and charge_code	  = @p_charges_code
				--and facility_code = @facility_code 
				and effective_date <= dbo.xfn_get_system_date()
		
		--update	dbo.application_extention
		--set		is_valid					= '0'
		--		--
		--		,mod_date					= @p_mod_date
		--		,mod_by						= @p_mod_by
		--		,mod_ip_address				= @p_mod_ip_address
		--where	main_contract_no			= @p_main_contract_no

		set @p_id = @@identity ;
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
