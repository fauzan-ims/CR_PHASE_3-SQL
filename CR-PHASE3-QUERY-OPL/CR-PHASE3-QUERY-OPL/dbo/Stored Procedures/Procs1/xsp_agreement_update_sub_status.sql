CREATE PROCEDURE [dbo].[xsp_agreement_update_sub_status]
(
	@p_invoice_no			nvarchar(50)
	,@p_is_paid				nvarchar(1)	 = '0'
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@agreement_no nvarchar(50) ;

	begin try
		-- update agreement status
			declare invoicedetail cursor fast_forward read_only for
			select	distinct
					agreement_no
			from	dbo.invoice_detail with (nolock)
			where	invoice_no = @p_invoice_no ;

			open invoicedetail ;

			fetch next from invoicedetail
			into @agreement_no ;

			while @@fetch_status = 0
			begin
				if (@p_is_paid = '0')
				begin
					update	dbo.agreement_main
					set		agreement_sub_status = 'INCOMPLETE'
							--
							,mod_date			 = @p_mod_date		
							,mod_by				 = @p_mod_by			
							,mod_ip_address		 = @p_mod_ip_address
					where	agreement_no		 = @agreement_no
				end	
				else
				begin 
					if not exists
					(
						select	1
						from	dbo.agreement_asset aa with (nolock)
								inner join dbo.agreement_asset_amortization aaa with (nolock) on (aaa.asset_no = aa.asset_no)
						where	aa.agreement_no = @agreement_no
								and aaa.invoice_no is null
								and aa.asset_status = 'RENTED'
					)
					begin  
						if not exists
						(
							select	1
							from	dbo.invoice inv with (nolock)
									inner join dbo.invoice_detail invd with (nolock) on (invd.invoice_no = inv.invoice_no)
							where	invd.agreement_no	   = @agreement_no
									and inv.invoice_status = 'POST'
						)
						begin  
							if not exists (select 1 from dbo.additional_invoice_request with (nolock) where agreement_no = @agreement_no and status not in ('PAID','CANCEL'))
							begin 
								if not exists
								(
									select	1
									from	dbo.additional_invoice ai with (nolock)
											inner join dbo.additional_invoice_detail aid with (nolock) on (aid.additional_invoice_code = ai.code)
									where	aid.agreement_no = @agreement_no
											and ai.invoice_status	 in ('HOLD')
								)
								begin
									begin
										update	dbo.agreement_main
										set		agreement_sub_status	= 'COMPLETE'
												-- 
												,mod_date				= @p_mod_date
												,mod_by					= @p_mod_by
												,mod_ip_address			= @p_mod_ip_address
										where	agreement_no			= @agreement_no ;
									end
								end ;
							end
						end ;
					end ;
				end
				fetch next from invoicedetail
				into @agreement_no ;
			end ;

			close invoicedetail ;
			deallocate invoicedetail ;
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
