-- Created, Rian At 19.12.2022

CREATE PROCEDURE [dbo].[xsp_maturity_proceed]
(
	@p_code					NVARCHAR(50)
	--
	,@p_mod_date			DATETIME
	,@p_mod_by				NVARCHAR(15)
	,@p_mod_ip_address		NVARCHAR(15)
)
AS
BEGIN
	declare @msg						  nvarchar(max)
			,@request_code				  nvarchar(50)
			,@branch_code				  nvarchar(50)
			,@branch_name				  nvarchar(250)
			,@req_date					  datetime
			,@agreement_external_no		  nvarchar(50)
			,@reff_dimension_code		  nvarchar(50)
			,@interface_remarks			  nvarchar(4000)
			,@client_name				  nvarchar(250)
			,@dimension_code			  nvarchar(50)
			,@dim_value					  nvarchar(50)
			,@reff_approval_category_code nvarchar(50)
			,@url_path					  nvarchar(250)
			,@path						  nvarchar(250)
			,@approval_path				  nvarchar(4000)
			,@agreement_no				  nvarchar(50)
			,@asset_no					  nvarchar(50)
			,@billing_no				  int
			,@result					  nvarchar(50)
			,@add_periode				  int
			,@max_periode				  int
			,@add_periode_before		  int
			,@opl_status				  nvarchar(15) 
			,@count_continue			  INT
            ,@biling_amount				  DECIMAL(18,2)
			,@invoice_no				  NVARCHAR(50)
			,@max_billing_no			  INT
			,@rental_amount				  DECIMAL(18,2)

	BEGIN try
		
		--Raffy 09.01.2024 (+) Penambahan Validasi untuk schedule yang belum terbilling agar proses maturity tidak bisa dilanjutkan
		select	@agreement_no	= agreement_no
				,@result		= result
				--,@add_periode	= ADDITIONAL_PERIODE
		from	dbo.maturity 
		where	code = @p_code

		select	@add_periode_before = sum(additional_periode)
        from	dbo.maturity
		where	status		 in ('APPROVE', 'POST')
		and		agreement_no = @agreement_no

		select	@add_periode = sum(additional_periode) 
		from	dbo.maturity
		where	agreement_no = @agreement_no
		and		status in ('APPROVE', 'POST', 'HOLD')

		select	@max_periode = value
		from	dbo.sys_global_param
		where	code = 'MAXEXT'

		select	@count_continue = count(1)
		from	dbo.maturity_detail
		where	maturity_code = @p_code
				and result	  = 'CONTINUE' ;
		
		select	@rental_amount =  b.monthly_rental_rounded_amount
		from	dbo.maturity_detail a
		inner join dbo.agreement_asset b on b.asset_no = a.asset_no and a.result = 'CONTINUE'
		where	a.maturity_code = @p_code

		select	top 1 
				 @biling_amount		= a.billing_amount
				,@invoice_no		= a.invoice_no
				,@max_billing_no	= a.BILLING_NO
		from	dbo.agreement_asset_amortization a
		inner	join dbo.maturity_detail b on b.asset_no = a.asset_no and b.result = 'CONTINUE'
		where	b.maturity_code = @p_code
		order by a.billing_no desc

		IF (@rental_amount <> @biling_amount) AND (ISNULL(@invoice_no,'')<>'')
        begin
            set @msg = 'This Asset Cannot Be Extend, Please Cancel Invoice ' + @invoice_no + ' For Amount Prorate On Last Billing';
            raiserror(@msg, 16, -1);
        end;


		--if ((select maturity_date from dbo.maturity where code = @p_code and AGREEMENT_NO not in ('0000570.4.08.08.2021')) < dbo.xfn_get_system_date())
		----if ((select maturity_date from dbo.maturity where code = @p_code) < dbo.xfn_get_system_date())
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'System Date') ;

		--	raiserror(@msg, 16, 1) ;
		--end ;

		if exists
		(
			select	1
			from	dbo.maturity
			where	code		  = @p_code
					and status <> 'HOLD'
		)
		BEGIN
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.maturity
			where	code				   = @p_code
					and isnull(remark, '') = ''
		)
		begin
			set @msg = 'Please input Remark' ;

			raiserror(@msg, 16, -1) ;
		end ;
	
		if not exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no			   = @agreement_no
					and isnull(opl_status, '') = ''
		)
		begin
			select	@opl_status				= opl_status
					,@agreement_external_no = agreement_external_no
			from	dbo.agreement_main
			where	agreement_no = @agreement_no ;

			set @msg = N'Agreement : ' + @agreement_external_no + N' already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.maturity_detail
			where	result			  = 'CONTINUE'
					and maturity_code = @p_code
					and (@add_periode > @max_periode)
		)
		begin
			set @msg = N'Cannot Proceed Maturity, Additional Periode Reached Maximum Number. Number Additional Periode Left : ' + cast((@max_periode - @add_periode_before) as varchar(20)) ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		if exists (select 1 from dbo.maturity_detail where result = 'STOP' and maturity_code = @p_code)
		begin 
			if exists
			(
				select	1
				from	dbo.agreement_asset_amortization aaa
						--inner join dbo.AGREEMENT_ASSET aas on aas.ASSET_NO			= aaa.ASSET_NO
						--									  and  aas.ASSET_STATUS <> 'RETURN'
						inner join dbo.maturity_detail md on (md.asset_no = aaa.asset_no)
				where	--aaa.agreement_no			   = @agreement_no
						md.maturity_code = @p_code
						and md.result = 'STOP'
						and isnull(aaa.invoice_no, '') = ''
			)
			begin
				select	top 1 @msg = N'This Asset : ' + md.asset_no + ' Plat No : '+ isnull(aa.fa_reff_no_01, aa.replacement_fa_reff_no_01) + ' Has an unbilled Schedule' 
				from	dbo.agreement_asset_amortization aaa
						inner join dbo.maturity_detail md on (md.asset_no = aaa.asset_no)
						inner join dbo.agreement_asset aa on (aa.asset_no = aaa.asset_no)
				where	
						md	.maturity_code = @p_code
						and md.result = 'STOP'
						and isnull(aaa.invoice_no, '') = ''

				raiserror(@msg, 16, 1) ;
			end ;
		end ;

		if exists
		(
			select	1
			from	dbo.maturity
			where	code				   = @p_code
					and result			   = 'CONTINUE'
					and additional_periode = 0
		)
		begin
			set @msg = 'Additional Periode must be greater then 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.maturity
			where	code				= @p_code
					and result			= 'CONTINUE'
					and @count_continue = 0
		)
		begin
			set @msg = N'There is no Continue Asset Please Check Maturity Result' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.maturity_detail md
					inner join dbo.maturity m on (m.code = md.maturity_code)
			where	md.maturity_code = @p_code
					and md.result	 = 'STOP'
					and m.pickup_date is null
		)
		begin
			set @msg = N'Please insert Pickup Date.' ;

			raiserror(@msg, 16, -1) ;
		end ;
					
		-- Louis Jumat, 02 Juni 2023 15.28.20 --  
		if exists (
					select	1
					from	dbo.maturity
					where	code = @p_code
					and		result	= 'CONTINUE' 
					)
		begin
			--if exists
			--(
			--	select	1
			--	from	dbo.master_approval
			--	where	code			 = 'MATURITY'
			--			and is_active	 = '1'
			--)
			if exists (select 1 from dbo.maturity_detail where maturity_code = @p_code and result = 'CONTINUE')
			begin
				select	@branch_code = mt.branch_code
						,@branch_name = mt.branch_name
						,@client_name = am.client_name
						,@agreement_external_no = am.agreement_external_no 
				from	dbo.maturity mt
						inner join dbo.agreement_main am on (am.agreement_no = mt.agreement_no)
				where	mt.code = @p_code ;

				update dbo.maturity
				set		status			= 'ON PROCESS'
						,mod_by			= @p_mod_by
						,mod_date		= @p_mod_date
						,mod_ip_address	= @p_mod_ip_address
				where   code			= @p_code

				UPDATE asset
				SET monitoring_status = 'EXTEND PRCS'
				FROM IFINAMS.dbo.ASSET asset
					JOIN dbo.MATURITY_DETAIL matur
						ON matur.ASSET_NO = ASSET.ASSET_NO
					JOIN IFINOPL.dbo.AGREEMENT_ASSET
						ON AGREEMENT_ASSET.ASSET_NO = matur.ASSET_NO
				WHERE matur.MATURITY_CODE = @p_code

				--SELECT asset.MONITORING_STATUS, *
				--FROM IFINAMS.dbo.ASSET asset
				--	JOIN dbo.MATURITY_DETAIL matur
				--		ON matur.ASSET_NO = ASSET.ASSET_NO
				--	JOIN IFINOPL.dbo.AGREEMENT_ASSET
				--		ON AGREEMENT_ASSET.ASSET_NO = matur.ASSET_NO
				--WHERE matur.MATURITY_CODE = @p_code


				set @interface_remarks = 'Approval Maturity Continue Rental ' + @agreement_external_no + ' - ' + @client_name ;
				set @req_date = dbo.xfn_get_system_date() ;


				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'MATURITY' ;
			
				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'MATURITY'

				--set approval path
				set	@approval_path = @path + @p_code

				exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output
																   ,@p_branch_code				= @branch_code
																   ,@p_branch_name				= @branch_name
																   ,@p_request_status			= N'HOLD'
																   ,@p_request_date				= @req_date
																   ,@p_request_amount			= 0
																   ,@p_request_remarks			= @interface_remarks
																   ,@p_reff_module_code			= N'IFINOPL'
																   ,@p_reff_no					= @p_code
																   ,@p_reff_name				= N'MATURITY CONTINUE APPROVAL'
																   ,@p_paths					= @approval_path
																   ,@p_approval_category_code	= @reff_approval_category_code
																   ,@p_approval_status			= N'HOLD'
																   --
																   ,@p_cre_date					= @p_mod_date
																   ,@p_cre_by					= @p_mod_by
																   ,@p_cre_ip_address			= @p_mod_ip_address
																   ,@p_mod_date					= @p_mod_date
																   ,@p_mod_by					= @p_mod_by
																   ,@p_mod_ip_address			= @p_mod_ip_address ;
					
				declare master_approval_dimension cursor for
				select  reff_dimension_code 
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'MATURITY'

				open master_approval_dimension		
				fetch next from master_approval_dimension
				into @reff_dimension_code 
					 ,@dimension_code
						
				while @@fetch_status = 0

				begin 

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code	 = @dimension_code
															  ,@p_reff_code	 = @p_code
															  ,@p_reff_table = 'MATURITY'
															  ,@p_output	 = @dim_value output ;
 
					exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id					= 0
																				 ,@p_request_code		= @request_code
																				 ,@p_dimension_code		= @reff_dimension_code
																				 ,@p_dimension_value	= @dim_value
																				 --
																				 ,@p_cre_date			= @p_mod_date
																				 ,@p_cre_by				= @p_mod_by
																				 ,@p_cre_ip_address		= @p_mod_ip_address
																				 ,@p_mod_date			= @p_mod_date
																				 ,@p_mod_by				= @p_mod_by
																				 ,@p_mod_ip_address		= @p_mod_ip_address ;
						

				fetch next from master_approval_dimension
				into @reff_dimension_code
					,@dimension_code
				end
						
				close master_approval_dimension
				deallocate master_approval_dimension 
			end
			else
			begin
				set @msg = 'Please setting Master Approval';
				raiserror(@msg, 16, 1) ;
			end ; 
		end
		else
		begin
			update	dbo.maturity
			set		status				= 'APPROVE'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			update	dbo.agreement_asset
			set		asset_status		= 'TERMINATE'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_no in
					(
						select	asset_no
						from	dbo.maturity_detail
						where	maturity_code = @p_code
								and result = 'STOP'
					) ;
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


