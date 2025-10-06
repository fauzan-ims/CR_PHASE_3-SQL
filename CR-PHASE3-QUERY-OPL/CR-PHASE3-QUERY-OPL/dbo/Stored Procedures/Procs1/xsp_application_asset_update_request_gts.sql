--created by, Rian at 02/05/2023 

CREATE PROCEDURE dbo.xsp_application_asset_update_request_gts
	@p_asset_no		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
as
begin
	declare @msg			 nvarchar(max)
			,@is_request_gts nvarchar(1) 
			,@agreement_no          nvarchar(50)
			,@agreement_external_no nvarchar(50);

	begin try
		select	@is_request_gts = is_request_gts
		from	dbo.application_asset
		where	asset_no = @p_asset_no ;

		if (@is_request_gts = '0')
		begin

			if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no = @p_asset_no
						and purchase_status <> 'REALIZATION'
			)
			begin
				set @msg = 'Data Already On Purchase' ;

				raiserror(@msg, 16, -1) ;
			end ;

			update	dbo.application_asset
			set		is_request_gts		 = '1'
					,purchase_gts_status = 'NONE'
					--
					,mod_date			 = @p_mod_date
					,mod_by				 = @p_mod_by
					,mod_ip_address		 = @p_mod_ip_address
			where	asset_no			 = @p_asset_no ;
		end ;
		else
		begin
			--validasi jika datanya sedang transaksi di asset allocation
			if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no						  = @p_asset_no
						and isnull(purchase_gts_code, '') <> ''
			)
			begin
				set @msg = 'Data Already On Transaction' ;

				raiserror(@msg, 16, -1) ;
			end ;

			update	dbo.application_asset
			set		is_request_gts		 = '0'
					,purchase_gts_status = 'NONE'
					--
					,mod_date			 = @p_mod_date
					,mod_by				 = @p_mod_by
					,mod_ip_address		 = @p_mod_ip_address
			where	asset_no			 = @p_asset_no ;

			-- Louis Kamis, 16 Mei 2024 10.44.12 -- push to handover jika asset yang di cancel request gts ternyata sudah di grn asset utamanya dan kondisi realization sudah post
			if not exists
			(
				select	1
				from	dbo.opl_interface_handover_asset
				where	asset_no = @p_asset_no
						and status <> 'CANCEL'
			)
			begin 
					if exists
					(
						select	1
						from	dbo.realization_detail rd
								inner join dbo.realization rz on (rz.code			= rd.realization_code)
								inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
						where	rd.asset_no			   = @p_asset_no
								and isnull(aa.fa_code, '') <> ''
								and isnull(aa.replacement_fa_code, '') = ''
								and isnull(aa.is_request_gts, '0') = '0'
								and
								(
									aa.purchase_status	  not in ( 'DELIVERY','AGREEMENT')
								)
								and rz.status		   = 'POST'
					)
					begin
						select	@agreement_no = rz.agreement_no
								,@agreement_external_no = rz.agreement_external_no
						from	dbo.realization_detail rd
								inner join dbo.realization rz on (rz.code			= rd.realization_code)
								inner join dbo.application_asset aa on (aa.asset_no = rd.asset_no)
						where	rd.asset_no			   = @p_asset_no
								and isnull(aa.fa_code, '') <> ''
								and isnull(aa.replacement_fa_code, '') = ''
								and isnull(aa.is_request_gts, '0') = '0'
								and
								(
									aa.purchase_status	   not in ( 'DELIVERY','AGREEMENT')
								)
								and rz.status		   = 'POST'

						exec dbo.xsp_application_asset_allocation_proceed @p_asset_no					= @p_asset_no
																			,@p_agreement_no			= @agreement_no
																			,@p_agreement_external_no	= @agreement_external_no
																			--				 
																			,@p_mod_date				= @p_mod_date
																			,@p_mod_by					= @p_mod_by
																			,@p_mod_ip_address			= @p_mod_ip_address
					end ;
			end
		end ;
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
