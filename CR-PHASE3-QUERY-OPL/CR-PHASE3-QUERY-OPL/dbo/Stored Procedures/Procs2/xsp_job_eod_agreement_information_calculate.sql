/*
exec xsp_job_eod_agreement_information_calculate
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
CREATE PROCEDURE [dbo].[xsp_job_eod_agreement_information_calculate]
as
begin
	declare @msg			 nvarchar(max)
			,@agreement_no	 nvarchar(50)
			,@mod_date		 datetime	  = getdate()
			,@mod_by		 nvarchar(15) = 'EOD'
			,@mod_ip_address nvarchar(15) = '127.0.0.1' ;

	begin try
		begin
			declare curagreementinformation cursor fast_forward read_only for
			select	agreement_no
			from	dbo.agreement_main am
					outer apply ---- Louis Kamis, 25 Juli 2024 17.04.48 -- ditambahkan logic untuk re-calculate agreement information berdasarkan asset yang belum return
			(
				select	count(1) 'asset_count'
				from	dbo.agreement_asset aa
				where	am.agreement_no		= aa.agreement_no
						and aa.asset_status <> 'RETURN'
			) aa where aa.asset_count > 0

			open curagreementinformation ;

			fetch next from curagreementinformation
			into @agreement_no ;

			while @@fetch_status = 0
			begin
				exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
														  ,@p_mod_date			= @mod_date		
														  ,@p_mod_by			= @mod_by		
														  ,@p_mod_ip_address	= @mod_ip_address

				exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																	   ,@p_mod_date			= @mod_date
																	   ,@p_mod_by			= @mod_by
																	   ,@p_mod_ip_address	= @mod_ip_address 
				
				fetch next from curagreementinformation
				into @agreement_no ;
			end ;

			close curagreementinformation ;
			deallocate curagreementinformation ;
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
