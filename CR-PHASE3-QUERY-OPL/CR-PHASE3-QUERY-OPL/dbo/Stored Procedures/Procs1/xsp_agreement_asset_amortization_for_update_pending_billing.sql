CREATE PROCEDURE dbo.xsp_agreement_asset_amortization_for_update_pending_billing
(
	@p_agreement_no				nvarchar(50)
	,@p_asset_no				nvarchar(50)
	,@p_billing_no				int
	,@p_hold_billing_status		nvarchar(10) = ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@hold_billing_status_before	nvarchar(50)
			,@system_date					datetime
			,@remark						nvarchar(4000)
	begin try

		--set system date
		set	@system_date = dbo.xfn_get_system_date()

		--select hold billing staus yang lama
		select	@hold_billing_status_before = hold_billing_status
		from	dbo.agreement_asset_amortization
		where	agreement_no	= @p_agreement_no
		and		asset_no		= @p_asset_no
		and		billing_no		= @p_billing_no	

		select @hold_billing_status_before , @p_hold_billing_status

		if (isnull(@hold_billing_status_before, '') <> @p_hold_billing_status)
		begin

			--update data di tabel agreement amortization
			update	dbo.agreement_asset_amortization 
			set		hold_billing_status = @p_hold_billing_status
					,hold_date			= @system_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	agreement_no		= @p_agreement_no
			and		asset_no			= @p_asset_no
			and		billing_no			= @p_billing_no 

			if	(isnull(@hold_billing_status_before, '') = '')
			begin 
				set @remark = 'Pending Billing for rental billing no ' + convert(varchar(5),@p_billing_no)
			end
			else
			begin
				set @remark = 'Release Billing for rental billing no ' + convert(varchar(5),@p_billing_no)
			end

			exec dbo.xsp_agreement_log_insert @p_agreement_no		= @p_agreement_no
											  ,@p_log_date			= @system_date
											  ,@p_asset_no			= @p_asset_no
											  ,@p_log_source_no		= '-'
								 			  ,@p_log_remarks		= @remark
											  ,@p_cre_date			= @p_mod_date
											  ,@p_cre_by			= @p_mod_by
											  ,@p_cre_ip_address	= @p_mod_ip_address
											  ,@p_mod_date			= @p_mod_date
											  ,@p_mod_by			= @p_mod_by
											  ,@p_mod_ip_address	= @p_mod_ip_address
			
		end 
		if (@p_hold_billing_status = 'PENDING')
		begin
			--update agreement main
			update dbo.agreement_main
			set		is_pending_billing	= '1'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	agreement_no		= @p_agreement_no
		end

		if not exists
		(
			select	1
			from	dbo.agreement_asset_amortization
			where	agreement_no = @p_agreement_no
					and isnull(hold_billing_status, '') <> '' 
		)
		begin
			--update agreement main
			update dbo.agreement_main
			set		is_pending_billing	= '0'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	agreement_no		= @p_agreement_no
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
