--created by, Rian at 26/05/2023 

CREATE PROCEDURE dbo.xsp_application_main_update_after_simulation
(
	@p_application_no	   nvarchar(50)
	,@p_client_type		   nvarchar(50)	 = null
	,@p_date_of_birth	   datetime		 = null
	,@p_est_date		   datetime		 = null
	,@p_full_name		   nvarchar(250) = null
	,@p_mother_maiden_name nvarchar(250) = null
	,@p_id_no			   nvarchar(50)	 = null
	,@p_place_of_birth	   nvarchar(250) = null
	,@p_document_type	   nvarchar(10)	 = null
	,@p_client_group_code  nvarchar(50)	 = null
	,@p_client_group_name  nvarchar(250) = null
	,@p_client_code		   nvarchar(250) = null
	--
	,@p_cre_date		   datetime
	,@p_cre_by 			   nvarchar(15)
	,@p_cre_ip_address 	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @client_code			 nvarchar(50)
			,@get_application_no	 nvarchar(50)
			,@client_name			 nvarchar(250)
			,@msg					 nvarchar(max)
			,@client_no				 nvarchar(50)
			,@asset_no				 nvarchar(50)
			,@fa_code				 nvarchar(50)
			,@agreement_external_no	 nvarchar(50)
			,@apk_date				 datetime -- (+) Ari 2023-10-13 ket : get apk date
                                         
	begin try
		 
		select	@client_name = client_name
				,@client_no = client_no
		from	dbo.client_main
		where	code = @p_client_code ;

		--validasi continue Rental jika client no <> @p_client_no
		if exists
		(
			select	1
			from	ifinams.dbo.asset a  with (nolock)
					inner join dbo.application_asset aa  with (nolock) on (aa.fa_code = a.code)
			where	aa.application_no			= @p_application_no
					and isnull(a.re_rent_status, '') = 'CONTINUE'
					and isnull(a.client_no, '') <> ''
		)
		begin
			if exists
			(
				select	1
				from	ifinams.dbo.asset a  with (nolock)
						inner join dbo.application_asset aa  with (nolock) on (aa.fa_code = a.code)
				where	aa.application_no			= @p_application_no
						and isnull(a.re_rent_status, '') = 'CONTINUE'
						and isnull(a.client_no, '') <> @client_no
			)
			begin
				select @msg = N'Fixed Asset : ' + a.code + N' is already booked for Client : ' + a.client_name
				from	ifinams.dbo.asset a  with (nolock)
						inner join dbo.application_asset aa  with (nolock) on (aa.fa_code = a.code)
				where	aa.application_no			= @p_application_no
						and isnull(a.re_rent_status, '') = 'CONTINUE'
						and isnull(a.client_no, '') <> @client_no

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		
		if exists
		(
			select	1
			from	dbo.application_asset aa
			where   isnull(aa.fa_code, '') in
					(
						select	aas.fa_code
						from	dbo.application_asset aas
								inner join dbo.application_main am on (am.application_no = aas.application_no)
						where	aas.fa_code			 = aa.fa_code
								and am.is_simulation = '0'
								and am.application_status not in
								(
									'CANCEL', 'REJECT'
								)
								and (aas.purchase_status <> 'AGREEMENT' or aas.purchase_gts_status <> 'AGREEMENT')
					)
					and	aa.application_no = @p_application_no
		)
		begin
			select	@agreement_external_no = ass.application_external_no
					,@fa_code = isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01)
			from	dbo.application_asset aa
					outer apply
					(
						select	top 1 aas.fa_code
								,am.application_external_no
						from	dbo.application_asset aas
								inner join dbo.application_main am on (am.application_no = aas.application_no)
						where	aas.fa_code			 = aa.fa_code
								and am.is_simulation = '0'
								and am.application_status not in
								(
									'CANCEL', 'REJECT'
								)
								and (aas.purchase_status <> 'AGREEMENT' or aas.purchase_gts_status <> 'AGREEMENT')
					) ass
			where	isnull(ass.application_external_no,'')<>''
			and   aa.application_no = @p_application_no ;

			set @msg = N'Fixed Asset : ' + isnull(@fa_code,'') + N' already in Application : ' + isnull(@agreement_external_no,'') --2025/01/08 penambahan isnull

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	ifinams.dbo.asset a  with (nolock)
					inner join dbo.application_asset aa  with (nolock) on (aa.fa_code = a.code)
			where	aa.application_no			= @p_application_no
					and isnull(a.re_rent_status, '') = ''
		)
		begin
			if exists
			(
				select	1
				from	dbo.application_asset aa with (nolock)
				where	aa.application_no			= @p_application_no
						and isnull(aa.fa_code,'') in (
														select	aas.fa_code 
														from	dbo.agreement_asset aas  with (nolock)
														inner	join dbo.agreement_main aam  with (nolock) on (aam.agreement_no = aas.agreement_no)
														where	aas.fa_code = aa.fa_code
														and		aas.asset_status <> 'RETURN'
													 )
			)
			begin 

				--select	top 1
				--		@agreement_external_no = aas.agreement_external_no
				--		,@fa_code = isnull(aas.fa_reff_no_01, aas.replacement_fa_reff_no_01)
				--from	dbo.application_asset aa  with (nolock)
				--		outer apply
				--		(
				--			select	aam.agreement_external_no
				--					,aas.fa_reff_no_01
				--					,aas.replacement_fa_reff_no_01
				--			from	dbo.agreement_asset aas  with (nolock)
				--					inner join dbo.agreement_main aam  with (nolock) on (aam.agreement_no = aas.agreement_no)
				--			where	aas.fa_code			 = aa.fa_code
				--					and aas.asset_status <> 'RETURN'
				--		) aas
				--where	aa.application_no = @p_application_no ;

				--set @msg = N'Fixed Asset : ' + isnull(@fa_code,'') + N' already in Application : ' + isnull(@agreement_external_no,'')

				--raiserror(@msg, 16, -1) ;
				--(+)raffy 2025/05/17 perubahan pengambilan agreement dan fa code 
				select	TOP 1
						@agreement_external_no = aam.agreement_external_no
						,@fa_code = ISNULL(aas.fa_reff_no_01,aas.replacement_fa_reff_no_01)
				from	dbo.agreement_asset aas  with (nolock)
						inner join dbo.agreement_main aam  with (nolock) on (aam.agreement_no = aas.agreement_no)
				where	aas.asset_status <> 'RETURN'
						and aas.fa_code	in 
						(
							select	fa_code 
							from	dbo.application_asset 
							where	application_no = @p_application_no
						)

				set @msg = N'Fixed Asset : ' + ISNULL(@fa_code,'') + N' already in Agreement : ' + ISNULL(@agreement_external_no,'') 

				raiserror(@msg, 16, -1) ;
			end ;
		end ;
		--else 
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset aa
		--			inner join dbo.application_main am on (am.application_no = aa.application_no)
		--	where	--aa.fa_code			 = @fa_code
		--			--and
		--			am.is_simulation = '0'
		--			and am.application_status not in
		--											 (
		--												 'CANCEL', 'REJECT'
		--											 )
		--			-- (+) Ari 2024-01-23 ket : jika sudah di kembalikan, kondisi di applikasi belum cukup sehingga ditambahkan kondisi pengecekan apakah asset sudah direturn
		--			and	isnull(aa.fa_code,'') in (
		--												select	aas.fa_code 
		--												from	dbo.agreement_asset aas
		--												inner	join dbo.agreement_main aam on (aam.agreement_no = aas.agreement_no)
		--												where	aam.application_no = aa.application_no
		--												and		aas.fa_code = aa.fa_code
		--												and		aas.asset_status <> 'RETURN'
		--										 )
		--)
		--begin
		--	set @msg = N'Fixed Asset : ' + @fa_code + N' already in Application : ' +
		--			   (
		--				   select	top 1
		--							am.application_external_no
		--				   from		dbo.application_asset aa
		--							inner join dbo.application_main am on (am.application_no = aa.application_no)
		--				   where	aa.fa_code			 = @fa_code
		--							and am.is_simulation = '0'
		--							and am.application_status not in
		--															(
		--																'CANCEL', 'REJECT'
		--															)	
		--			   ) ;

		--	raiserror(@msg, 16, -1) ;
		--end  ; 

			update	dbo.application_main
			set		application_status	= 'HOLD'
					,level_status		= 'ENTRY'
					,client_code		= isnull(@p_client_code, @client_code)
					,client_name		= isnull(@client_name, @p_full_name)
					,is_simulation		= '0'
					,return_count		= 0
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no;
			

			update	dbo.application_information
			set		application_flow_code	= null
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	application_no			= @p_application_no ;
			
			if not exists
			(
				select	1
				from	application_exposure
				where	application_no	  = @p_application_no
						and facility_name = 'OPERATING LEASE'
			)
			begin
				select	@client_no = cm.client_no
				from	dbo.application_main am
						inner join dbo.client_main cm on (cm.code = am.client_code)
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
						,am.agreement_no
						,am.agreement_date
						,am.facility_name
						,isnull(ass.purchase_price, 0)
						,isnull(ass.net_book, 0) + isnull(aa2.asset_amount, 0)--ai.os_rental_amount
						,isnull(aa.lease_amount, 0)
						,am.periode
						,ai.os_period
						,ai.maturity_date
						,ai.ovd_days
						,ai.max_ovd_days
						,ai.ovd_rental_amount
						,'AGREEMENT - ' + am.agreement_status
						--
						,@p_mod_date	  
						,@p_mod_by		  
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.agreement_main am
						inner join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
						outer apply
						(
							select	sum(aa.asset_amount) 'asset_amount'
									,sum(aa.lease_rounded_amount) 'lease_amount'
							from	dbo.agreement_asset aa
							where	aa.agreement_no = am.agreement_no
							and aa.asset_status = 'RENTED'
						) aa
						outer apply
						(
							select	sum(aa.asset_amount) 'asset_amount'
							from	dbo.agreement_asset aa
							where	aa.agreement_no = am.agreement_no
									and aa.asset_status = 'RENTED'
									and isnull(aa.fa_code, '') = ''
						) aa2
								outer apply
						(
							select	sum(ass.net_book_value_comm) 'net_book'
									,sum(ass.purchase_price) 'purchase_price'
							from	ifinams.dbo.asset ass
							where	ass.agreement_no = am.agreement_no
									and ass.status = 'STOCK'
						) ass
				where	client_no				= @client_no
						and am.agreement_no not in
							(
								select	agreement_no
								from	dbo.application_exposure
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
						,am.application_no
						,am.application_date
						,'OPERATING LEASE'
						,isnull(isnull(aa.purchase_price, 0) + isnull(aa2.asset_amount, 0), 0)
						,isnull(aa.net_book, 0) + isnull(aa2.asset_amount, 0) --aa.asset_amount
						,isnull(aa.lease_amount, 0)
						,am.periode
						,am.periode
						,aaa.maturity_date
						,0
						,0
						,0
						,'APPLICATION - ' + am.application_status
						--
						,@p_mod_date	  
						,@p_mod_by		  
						,@p_mod_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_main am
						inner join dbo.client_main cm on (cm.code = am.client_code)
						outer apply
						(
							select	sum(aa.asset_amount) 'asset_amount'
									,sum(ass.purchase_price)  'purchase_price'
									,sum(aa.lease_rounded_amount) 'lease_amount'
									,sum(ass.net_book) 'net_book'
							from	dbo.application_asset aa
									outer apply
									(
										select	sum(ass.net_book_value_comm) 'net_book'
												,sum(ass.purchase_price) 'purchase_price'
										from	ifinams.dbo.asset ass
										where	ass.code = aa.fa_code
												and ass.status = 'STOCK'
									) ass
							where	aa.application_no = am.application_no

						) aa
						outer apply
						(
							select	sum(aa.asset_amount) 'asset_amount'
							from	dbo.application_asset aa
							where	aa.application_no = am.application_no 
									and isnull(aa.fa_code, '') = ''
						) aa2
								outer apply
						(
							select	max(aa.due_date) 'maturity_date'
							from	dbo.application_amortization aa
							where	aa.application_no = am.application_no
						) aaa
							
				where	client_no = @client_no
						and am.application_no not in
							(
								select	agreement_no
								from	dbo.application_exposure
								where	application_no = @p_application_no
							)
						and am.is_simulation = '0'
						and am.application_status in
						(
							N'ON PROCESS', N'APPROVE', N'GO LIVE'
						) 
						and am.application_no not in (select application_no from dbo.agreement_main with (nolock))
			end ;

			--insert deviation & rules
			exec dbo.xsp_application_rules_and_deviation_validate @p_application_no		= @p_application_no
																  ,@p_cre_date			= @p_mod_date
																  ,@p_cre_by			= @p_mod_by
																  ,@p_cre_ip_address	= @p_mod_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address;

			--for update fixe asset status to Reserved when asset condition is USED
			declare currapplicationasset cursor fast_forward read_only for
			select	asset_no
					,fa_code
			from	dbo.application_asset
			where	application_no		= @p_application_no
			and		unit_source			= 'STOCK'
			--and asset_condition = 'USED' ;

			open currapplicationasset ;

			fetch next from currapplicationasset
			into @asset_no 
				 ,@fa_code ;

			while @@fetch_status = 0
			begin

				exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
																,@p_rental_reff_no	= @asset_no
																,@p_rental_status	= 'RESERVED'
																,@p_reserved_by		= null
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
				
				fetch next from currapplicationasset
				into @asset_no 
					 ,@fa_code ;
			end ;

			close currapplicationasset ;
			deallocate currapplicationasset ;
 

			select		@client_name			 = isnull(cm.client_name,'') 
						,@client_code			 = isnull(am.client_code,'')
						,@apk_date				 = am.application_date -- (+) Ari 2023-10-12 ket : get application date
			from		dbo.application_main am
			inner join	dbo.client_main cm on (cm.code = am.client_code)
			left join	dbo.client_address ca1 on (ca1.client_code = cm.code and ca1.is_legal = '1')
			left join	dbo.client_address ca2 on (ca2.client_code = cm.code and ca2.is_residence = '1')
			where		application_no = @p_application_no

			select	@p_est_date = est_date
			from	dbo.client_corporate_info
			where	client_code = @client_code ;

			-- (+) Ari 2023-10-12 
			declare  @get_application_date	datetime
					,@interval_day			int 
					,@getdate_can_RO		datetime 


			-- (+) Ari 2023-10-12 ket : get client no
			select	@client_no = client_no
			from	dbo.client_main 
			where	code = @client_code
						
			--(+) Ari 2023-10-12 ket : get application no & application date latest dengan client yg sama (existing)
			select	top 1 
					 @get_application_no = am.application_no 
					 ,@get_application_date = am.golive_date
			from	dbo.client_main cm
			inner	join dbo.application_main am on (am.client_code = cm.code)
			where	cm.client_no = @client_no
			and		am.application_no <> @p_application_no
			and		am.application_status = 'GO LIVE'
			order	by am.golive_date desc, am.cre_date   desc

			--(+) Ari 2023-10-12 ket : get interval
			select	@interval_day = value
			from	dbo.sys_global_param 
			where	code = 'SVYVLDT'

			set	@interval_day = -1 * @interval_day
			
			set @getdate_can_RO  = dateadd(day, @interval_day, @apk_date)
			
			--copy financial recap
			begin
				if not exists
				(
					select	1
					from	dbo.application_financial_recapitulation
					where	application_no = @p_application_no
				)
				begin
					if not exists
					(
						select	1
						from	dbo.application_financial_analysis
						where	application_no = @p_application_no
					)
					begin
					
						exec dbo.xsp_application_financial_recapitulation_copy  @p_client_no		= @client_no
																				,@p_application_no	= @p_application_no
																				,@p_cre_date		= @p_cre_date
																				,@p_cre_by			= @p_cre_by
																				,@p_cre_ip_address	= @p_cre_ip_address 
																				,@p_mod_date		= @p_mod_date
																				,@p_mod_by			= @p_mod_by
																				,@p_mod_ip_address	= @p_mod_ip_address
					end ;
				end ;
			end ;
			
			----copy survey
			--begin

				if not exists(select 1 from dbo.application_survey where application_no = @p_application_no)
				begin 
					-- Louis Selasa, 02 April 2024 18.49.13 -- inser survey tanpa memperhatikan kapan terakhir survey dilakukan
					exec dbo.xsp_application_survey_copy_without_limitation @p_client_no		= @client_no
																			,@p_application_no	= @p_application_no
																			,@p_cre_date		= @p_cre_date
																			,@p_cre_by			= @p_cre_by
																			,@p_cre_ip_address	= @p_cre_ip_address 
																			,@p_mod_date		= @p_mod_date
																			,@p_mod_by			= @p_mod_by
																			,@p_mod_ip_address	= @p_mod_ip_address 
				
					----if(@apk_date between @getdate_can_RO and  @get_application_date) -- (+) Ari 2023-10-13 ket : jika tanggal dari applikasi client yg existing ada pada jangkauan settingan (interval day 90 settingan default dari parameter) maka inject survey, copy dengan yg existing
					if(@get_application_date >= @getdate_can_RO) -- (+) Ari 2024-02-01 ket : jika tanggal applikasi lama lebih besar dengan maximal tanggal Repeat Order nya maka generate data existing
					begin
						exec dbo.xsp_application_survey_copy_with_limitation @p_client_no			= @client_no
																			 ,@p_application_no		= @p_application_no
																			 ,@p_old_application_no = @get_application_no
																			 ,@p_cre_date			= @p_cre_date
																			 ,@p_cre_by				= @p_cre_by
																			 ,@p_cre_ip_address		= @p_cre_ip_address 
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address 
					end 
				end
			--end ;
	
			----copy application doc
			begin
				exec dbo.xsp_application_doc_copy @p_client_no			= @client_no
												  ,@p_application_no	= @p_application_no
												  ,@p_cre_date			= @p_cre_date
												  ,@p_cre_by			= @p_cre_by
												  ,@p_cre_ip_address	= @p_cre_ip_address 
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address
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
