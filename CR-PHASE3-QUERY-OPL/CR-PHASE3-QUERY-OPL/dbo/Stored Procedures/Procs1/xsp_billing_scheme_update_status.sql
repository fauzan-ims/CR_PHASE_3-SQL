CREATE PROCEDURE dbo.xsp_billing_scheme_update_status
(
	@p_code					nvarchar(50)
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @msg nvarchar(max) ;

	begin try
		
		if exists (	select 1 from billing_scheme 
						where code = @p_code 
						and  is_active = '1')
		begin
				
			update	dbo.billing_scheme
			set		is_active		= '0'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code

		end
		else
		begin
			
			if ((
				select	count(distinct  aasset.due_date)
				from	dbo.billing_scheme_detail bsd
				outer apply
				(
					select	min(aaa.due_date) due_date
					from	dbo.agreement_asset_amortization aaa
					where	aaa.agreement_no = bsd.agreement_no
							and aaa.asset_no = bsd.asset_no
							and aaa.due_date >= dbo.xfn_get_system_date()
							
					 
				) aasset
				where	scheme_code = @p_code
				) > 1
			) AND (@p_code NOT in ('BSC.2311.000001','BSC.2402.000007'))
			begin
				set @msg = N'All Due Date must be Equal' ;

				raiserror(@msg, 16, -1) ;
			end ;
				
			update	dbo.billing_scheme
			set		is_active		= '1'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code

		end

		

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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end
