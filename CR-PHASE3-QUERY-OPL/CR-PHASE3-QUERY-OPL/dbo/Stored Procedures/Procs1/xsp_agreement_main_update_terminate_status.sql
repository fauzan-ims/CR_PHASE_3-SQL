-- Louis Jumat, 07 Juli 2023 20.46.41 -- 
CREATE PROCEDURE [dbo].[xsp_agreement_main_update_terminate_status]
(
	@p_agreement_no		 nvarchar(50)
	,@p_termination_date datetime
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try 
		if not exists
		(
			select	1
			from	dbo.agreement_asset
			where	agreement_no	 = @p_agreement_no
					and asset_status = 'RENTED'
		)
		begin 
			if not exists
			(
				select	1
				from	dbo.agreement_asset aa
						inner join dbo.agreement_asset_amortization aaa on (aaa.asset_no = aa.asset_no)
				where	aa.agreement_no = @p_agreement_no
						and aaa.invoice_no is null
						and aa.asset_status = 'RENTED'
			)
			begin  
				if not exists
				(
					select	1
					from	dbo.invoice inv
							inner join dbo.invoice_detail invd on (invd.invoice_no = inv.invoice_no)
					where	invd.agreement_no	   = @p_agreement_no
							and inv.invoice_status = 'POST'
				)
				begin  
					if not exists (select 1 from dbo.additional_invoice_request where agreement_no = @p_agreement_no and status not in ('PAID','CANCEL'))
					begin 
						if not exists
						(
							select	1
							from	dbo.additional_invoice ai
									inner join dbo.additional_invoice_detail aid on (aid.additional_invoice_code = ai.code)
							where	aid.agreement_no = @p_agreement_no
									and ai.invoice_status	 in ('HOLD')
						)
						begin 
							if exists
							(
								select	1
								from	dbo.agreement_main
								where	agreement_no							 = @p_agreement_no
										and isnull(termination_status, 'NORMAL') <> 'NORMAL'
							)
							begin
								update	dbo.agreement_main
								set		agreement_status		= 'TERMINATE'
										,agreement_sub_status	= 'COMPLETE' --isnull(termination_status, 'NORMAL')
										,termination_status		= isnull(termination_status, 'NORMAL')
										,termination_date		= @p_termination_date
										-- 
										,mod_date				= @p_mod_date
										,mod_by					= @p_mod_by
										,mod_ip_address			= @p_mod_ip_address
								where	agreement_no			= @p_agreement_no ;
							end ;
							else if exists
							(
								select	1
								from	dbo.agreement_information
								where	agreement_no	  = @p_agreement_no
										and maturity_date < dbo.xfn_get_system_date()
							)
							begin
								update	dbo.agreement_main
								set		agreement_status		= 'TERMINATE'
										,agreement_sub_status	= 'COMPLETE'--isnull(termination_status, 'NORMAL')
										,termination_status		= isnull(termination_status, 'NORMAL')
										,termination_date		= @p_termination_date
										-- 
										,mod_date				= @p_mod_date
										,mod_by					= @p_mod_by
										,mod_ip_address			= @p_mod_ip_address
								where	agreement_no			= @p_agreement_no ;
							end 
							else
							begin
								update	dbo.agreement_main
								set		agreement_sub_status	= 'COMPLETE'--isnull(termination_status, 'NORMAL')
										,termination_status		= isnull(termination_status, 'NORMAL')
										,termination_date		= @p_termination_date
										-- 
										,mod_date				= @p_mod_date
										,mod_by					= @p_mod_by
										,mod_ip_address			= @p_mod_ip_address
								where	agreement_no			= @p_agreement_no ;
							end
						end ;
					end
				end ;
			end ;
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

