CREATE PROCEDURE dbo.xsp_maturity_update
(
	@p_code					nvarchar(50)
	,@p_result				nvarchar(20)	= 'STOP'
	,@p_remark				nvarchar(4000)
	,@p_date				datetime
	,@p_additional_periode	int = 0
	,@p_pickup_date			datetime		= null
	,@p_new_billing_type	nvarchar(50)
	--	
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@maturity_date				datetime
			,@maturity_remark			nvarchar(4000)
			,@asset_no					nvarchar(50)
			,@periode					int
			,@max_or_min_day			int
			,@total_additional_periode	int
			,@max_additional_periode	int
			,@min_maturity_date			datetime
			,@max_maturity_date			datetime
			,@schedule					int
			,@agreement_no				nvarchar(50)

	begin try

		select	@maturity_date = date
				,@maturity_remark = remark
				,@agreement_no = m.agreement_no
		from	dbo.maturity m
		where	m.code = @p_code ;

		select	@schedule = multiplier
		from	dbo.master_billing_type
		where	code = @p_new_billing_type ;

		--select value maximum additional periode dari global param
		select	@max_additional_periode = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MAXEXT'

		--select value max or min
		select	@max_or_min_day = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MTMAXMINDAY' ;

		select	@total_additional_periode = isnull(sum(isnull(additional_periode, 0)), 0)
		from	dbo.maturity
		where	status			 in ('APPROVE', 'POST')
				and agreement_no = @agreement_no ;

		--select	@max_maturity_date = aaa.max_maturity_date
		--		,@min_maturity_date = aaa.min_maturity_date
		--from	dbo.maturity_detail md
		--		inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
		--		outer apply
		--		(
		--			select	dateadd(day, 14, max(due_date)) 'max_maturity_date'
		--					,dateadd(day, -14, max(due_date)) 'min_maturity_date'
		--			from	dbo.agreement_asset_amortization
		--			where	agreement_no = aa.agreement_no
		--					and asset_no = aa.asset_no
		--		) aaa
		--where	md.maturity_code = @p_code 
		--		and aa.asset_status = 'RENTED'

		select	@max_maturity_date = aaa.max_maturity_date	
				,@min_maturity_date = aaa.min_maturity_date
		from	dbo.maturity_detail md
				inner join dbo.agreement_asset aa on (aa.asset_no = md.asset_no)
				outer apply
				(
					select	dateadd(day, 14, maturity_date) 'max_maturity_date' --(+)Raffy 2024/09/10 Validasi diambil berdasarkan maturity date
							,dateadd(day, -14, maturity_date) 'min_maturity_date'
					from	dbo.agreement_information
					where	agreement_no = aa.agreement_no
							--and asset_no = aa.asset_no
				) aaa
		where	md.maturity_code = @p_code 
				and aa.asset_status = 'RENTED'


		--validasi jika additional periode nya melebihi batas maximum
		--if (@p_additional_periode + @total_additional_periode > @max_additional_periode)
		--begin
		--	set	@msg = 'Total Additional must be less than Maximum Additiional Periode : ' + @max_additional_periode
		--	raiserror(@msg, 16, -1)
		--end 
		    
		IF (@p_result <> 'STOP') --Raffy (+)2024/08/29 validasi hanya untuk maturity extend
		begin
			if (@p_additional_periode + @total_additional_periode > @max_additional_periode)
			begin
				set @msg = N'Cannot Proceed Maturity, Additional Periode Reached Maximum Number. Number Additional Periode Left : ' + cast((@max_additional_periode - @total_additional_periode) as varchar(20)) ;

				raiserror(@msg, 16, -1) ;
			end ;
		end;
			
		--validasi jika tanggal estimate pickup date lebih kecil dari sistem date
		--if (@p_pickup_date < dbo.xfn_get_system_date())
		--begin
		--	set	@msg = 'Pickup Date must be greater than System Date'
		--	raiserror(@msg, 16, -1)
		--end
    
		if	(@p_additional_periode % @schedule <> 0)
		begin
			set	@msg = 'Invalid combination Additional Periode and Biling Type'
			raiserror(@msg, 16, -1) ;
		end

		--validasi jika tanggal estimate pickup date lebih kecil/lebih besar dari maturity date
		if (@p_pickup_date < @min_maturity_date)
		begin
			set @msg = N'Pickup Date must be greater or equal to Minimum Maturity Date : ' + convert(nvarchar(25), @min_maturity_date, 103) ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_pickup_date > @max_maturity_date)
		begin
			set @msg = N'Pickup Date must be less or equal to Max Maturity Date : ' + convert(nvarchar(25), @max_maturity_date, 103) ;

			raiserror(@msg, 16, -1) ;
		end ;

		--jalankan calculate
		--if (@p_additional_periode <> 0)
		begin
			--hapus terlebih dahulu data yang staus nya new di tabel maturity amontization history
			delete	dbo.maturity_amortization_history
			where	maturity_code	= @p_code
			and		old_or_new		= 'NEW'

			--update data maturity
			update	dbo.maturity
			set		date				= @p_date
					,remark				= @p_remark
					,additional_periode	= case when @p_result = 'STOP' then 0 else @p_additional_periode end
					,pickup_date		= @p_pickup_date
					,new_billing_type	= @p_new_billing_type
					,result				= @p_result
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
			
			if (@p_result = 'CONTINUE')
			begin
				--update data maturity detail
				update	dbo.maturity_detail
				set		additional_periode	= @p_additional_periode
						,pickup_date		= @p_pickup_date
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	maturity_code		= @p_code ;
			end
			else
			begin
				--update data maturity detail
				update	dbo.maturity_detail
				set		additional_periode	= @p_additional_periode
						,pickup_date		= @p_pickup_date
						,result				= 'STOP'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	maturity_code		= @p_code ;
			end

			declare c_maturity_detail cursor for
			select	asset_no
					,additional_periode
			from	dbo.maturity_detail
			where	maturity_code = @p_code
					and result = 'CONTINUE'

			open c_maturity_detail ;

			fetch c_maturity_detail
			into @asset_no
				 ,@periode ;

			while @@fetch_status = 0
			begin 
			
				exec dbo.xsp_maturity_calculate @p_asset_no			= @asset_no
												,@p_periode			= @periode
												,@p_maturity_code	= @p_code
												,@p_maturity_remark = @maturity_remark
												,@p_maturity_date	= @maturity_date
												,@p_cre_date		= @p_mod_date
												,@p_cre_by			= @p_mod_by
												,@p_cre_ip_address	= @p_mod_ip_address
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
			

				fetch c_maturity_detail
				into @asset_no
					 ,@periode ;
			end ;

			close c_maturity_detail ;
			deallocate c_maturity_detail ;
		end
		--else
		--begin
		--	--hapus data yang staus nya new di tabel maturity amontization history
		--	delete	dbo.maturity_amortization_history
		--	where	maturity_code = @p_code
		--	and		old_or_new = 'NEW'

		--	--update data maturity
		--	update	dbo.maturity
		--	set		date				= @p_date
		--			,remark				= @p_remark
		--			,additional_periode	= @p_additional_periode
		--			,pickup_date		= @p_pickup_date
		--			,new_billing_type	= @p_new_billing_type
		--			,result				= 'STOP'
		--			--
		--			,mod_date			= @p_mod_date
		--			,mod_by				= @p_mod_by
		--			,mod_ip_address		= @p_mod_ip_address
		--	where	code				= @p_code ;

		--	--update data maturity detail
		--	update	dbo.maturity_detail
		--	set		additional_periode	= @p_additional_periode
		--			,pickup_date		= @p_pickup_date
		--			,result				= 'STOP'
		--			--
		--			,mod_date			= @p_mod_date
		--			,mod_by				= @p_mod_by
		--			,mod_ip_address		= @p_mod_ip_address
		--	where	maturity_code		= @p_code ;

		--end
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
