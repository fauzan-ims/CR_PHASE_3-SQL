CREATE PROCEDURE [dbo].[xsp_billing_generate_detail_generate]
(
	@p_code						nvarchar(50)
	,@p_as_off_date				datetime
	,@p_client_no				nvarchar(50)	= ''
	,@p_agreement_no			nvarchar(50)	= ''
	,@p_asset_no				nvarchar(50)	= ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin

	declare @agreement_no			nvarchar(50)		
			,@billing_no			int
			,@asset_no				nvarchar(50)
			,@due_date				datetime
			,@billing_date			datetime
			,@billing_amount		decimal(18,2)
			,@description			nvarchar(4000)
			,@msg					nvarchar(max);

	begin try 
		delete dbo.billing_generate_detail
		where generate_code = @p_code
		   
		declare c_billing_generate cursor fast_forward read_only for
		select	asa.agreement_no
				,asa.billing_no
				,asa.asset_no
				,asa.due_date
				,asa.billing_date
				,asa.billing_amount
				,asa.description
		from	dbo.agreement_asset_amortization asa
				inner join agreement_asset ast on (asa.asset_no		 = ast.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no = asa.agreement_no)
		where	-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				(
					agreement_status					= 'GO LIVE'
					or
					(
						agreement_status				= 'TERMINATE'
						and am.termination_status		= 'NORMAL'
					)
				)
				and asa.generate_code is null
				and cast(billing_date as date)			<= cast(@p_as_off_date as date)
				--and ast.handover_status					= 'POST'
				--and ast.asset_status					= 'RENTED'
				and am.client_no						= case @p_client_no
															  when '' then am.client_no
															  else @p_client_no
														  end
				and asa.agreement_no					= case @p_agreement_no
															  when '' then asa.agreement_no
															  else @p_agreement_no
														  end
				and asa.asset_no						= case @p_asset_no
															  when '' then asa.asset_no
															  else @p_asset_no
														  end
				and isnull(am.is_stop_billing, '0')		<> '1'
				and isnull(asa.hold_billing_status, '') <> 'PENDING'
				and asa.asset_no not in
					(
						select	bsd.asset_no
						from	dbo.billing_scheme_detail bsd
								inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
						where	bs.is_active = '1'
					)
				-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				and asa.asset_no not in
					(
						select	et.asset_no
						from	dbo.et_detail et with (nolock)
								inner join dbo.et_main em with (nolock) on (
																			   em.code			= et.et_code
																			   and em.et_status in ('APPROVE', 'ON PROCESS')
																		   )
						where et.is_terminate = '1'
					)
				and asa.billing_amount > 0 --raffy 2025/06/10 billing amount yang nilainya 0 tidak perlu tergenerate invoice nya 
		union
		select	asa.agreement_no
				,asa.billing_no
				,asa.asset_no
				,asa.due_date
				,asa.billing_date
				,asa.billing_amount
				,asa.description
		from	dbo.agreement_asset_amortization asa
				inner join agreement_asset ast on (asa.asset_no		 = ast.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no = asa.agreement_no)
		where	-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				(
					agreement_status					= 'GO LIVE'
					or
					(
						agreement_status				= 'TERMINATE'
						and am.termination_status		= 'NORMAL'
					)
				)
				and asa.generate_code is null
				and cast(billing_date as date)			<= cast(@p_as_off_date as date)
				--and ast.handover_status						= 'POST'
				--and ast.asset_status					= 'RENTED'
				and am.client_no						= case @p_client_no
															  when '' then am.client_no
															  else @p_client_no
														  end
				and asa.agreement_no					= case @p_agreement_no
															  when '' then asa.agreement_no
															  else @p_agreement_no
														  end
				and asa.asset_no						= case @p_asset_no
															  when '' then asa.asset_no
															  else @p_asset_no
														  end
				and isnull(am.is_stop_billing, '0')		<> '1'
				and isnull(asa.hold_billing_status, '') <> 'PENDING'
				and asa.asset_no in
					(
						select	bsd.asset_no
						from	dbo.billing_scheme_detail bsd
								inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
						where	bs.is_active = '1'
					)
				-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				and asa.asset_no not in
					(
						select	et.asset_no
						from	dbo.et_detail et with (nolock)
								inner join dbo.et_main em with (nolock) on (
																			   em.code			= et.et_code
																			   and em.et_status in ('APPROVE', 'ON PROCESS')
																		   )
						where et.is_terminate = '1'
					)
				and asa.billing_amount > 0 --raffy 2025/06/10 billing amount yang nilainya 0 tidak perlu tergenerate invoice nya 
		union
		select	asa.agreement_no
				,asa.billing_no
				,asa.asset_no
				,asa.due_date
				,asa.billing_date
				,asa.billing_amount
				,asa.description
		from	dbo.agreement_asset_amortization asa
				inner join agreement_asset ast on (asa.asset_no		 = ast.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no = asa.agreement_no)
		where	-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				(
					agreement_status					= 'GO LIVE'
					or
					(
						agreement_status				= 'TERMINATE'
						and am.termination_status		= 'NORMAL'
					)
				)
				and asa.generate_code is null
				and cast(billing_date as date)			<= cast(@p_as_off_date as date)
				--and ast.handover_status							= 'POST'
				--and ast.asset_status					= 'RENTED'
				and am.client_no						= case @p_client_no
															  when '' then am.client_no
															  else @p_client_no
														  end
				and asa.agreement_no					= case @p_agreement_no
															  when '' then asa.agreement_no
															  else @p_agreement_no
														  end
				and asa.asset_no						= case @p_asset_no
															  when '' then asa.asset_no
															  else @p_asset_no
														  end
				and isnull(am.is_stop_billing, '0')		<> '1'
				and isnull(asa.hold_billing_status, '') <> 'PENDING'
				and asa.asset_no in
					(
						select	bsd.asset_no
						from	dbo.billing_scheme_detail bsd
								inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
						where	bs.billing_mode_date <= day(@p_as_off_date)
								and bs.is_active	 = '1'
					)
				-- Louis Selasa, 15 Oktober 2024 15.03.06 -- 
				and asa.asset_no not in
					(
						select	et.asset_no
						from	dbo.et_detail et with (nolock)
								inner join dbo.et_main em with (nolock) on (
																			   em.code			= et.et_code
																			   and em.et_status in ('APPROVE', 'ON PROCESS')
																		   )
						where et.is_terminate = '1'
					) 
				and asa.billing_amount > 0 --raffy 2025/06/10 billing amount yang nilainya 0 tidak perlu tergenerate invoice nya ;

		open	c_billing_generate
		fetch next from	c_billing_generate 
		into	@agreement_no	
				,@billing_no	
				,@asset_no		
				,@due_date		
				,@billing_date	
				,@billing_amount
				,@description	
		
		while @@fetch_status = 0
		begin 
			if not exists
			(
				select	1
				from	dbo.billing_generate_detail bgd
						inner join dbo.billing_generate bg on (bg.code = bgd.generate_code)
				where	bgd.agreement_no = @agreement_no
						and bgd.asset_no = @asset_no
						and bgd.billing_no = @billing_no
						and bg.status	 = 'HOLD'
			)
			begin
		
				exec dbo.xsp_billing_generate_detail_insert @p_id				= 0
		    												,@p_generate_code	= @p_code
		    												,@p_agreement_no	= @agreement_no
		    												,@p_asset_no		= @asset_no
		    												,@p_billing_no		= @billing_no
		    												,@p_due_date		= @due_date
		    												,@p_billing_date	= @billing_date
		    												,@p_rental_amount	= @billing_amount
		    												,@p_description		= @description
															--
		    												,@p_cre_date		= @p_mod_date		
		    												,@p_cre_by			= @p_mod_by			
		    												,@p_cre_ip_address	= @p_mod_ip_address	
		    												,@p_mod_date		= @p_mod_date		
		    												,@p_mod_by			= @p_mod_by			
		    												,@p_mod_ip_address	= @p_mod_ip_address	 
			end

		    fetch next from	c_billing_generate 
			into	@agreement_no	
					,@billing_no	
					,@asset_no		
					,@due_date		
					,@billing_date	
					,@billing_amount
					,@description
		
		end
		
		close c_billing_generate
		deallocate c_billing_generate

		--delete dbo.billing_generate_detail
		--where	asset_no in
		--		(
		--			select	bsd.asset_no
		--			from	dbo.billing_scheme_detail bsd
		--					inner join dbo.billing_scheme bs on (bs.code = bsd.scheme_code)
		--			where	bs.billing_mode_date > day(@p_as_off_date)
		--					and bs.is_active	 = '1'
		--		) ;
		
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
end ;
