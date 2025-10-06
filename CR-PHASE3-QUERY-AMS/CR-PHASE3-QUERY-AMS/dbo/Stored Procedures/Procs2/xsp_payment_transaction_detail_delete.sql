CREATE PROCEDURE dbo.xsp_payment_transaction_detail_delete
(
	@p_id nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@code_payment_request	nvarchar(50)
			,@payment_trx_code		nvarchar(50)
			,@payment_amount		decimal(18,2)
			,@remark				nvarchar(4000)
			,@remarks				nvarchar(4000)
			,@payment_source		nvarchar(50)
			,@payment_to			nvarchar(250)

	begin try
		select @code_payment_request	= payment_request_code
				,@payment_trx_code		= ptd.payment_transaction_code
				,@payment_source		= pr.payment_source
				,@payment_to			= payment_to
		from dbo.payment_transaction_detail ptd
		left join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
		where id = @p_id

		delete payment_transaction_detail
		where	id = @p_id;

		if not exists(select 1 from dbo.payment_transaction_detail where payment_transaction_code = @payment_trx_code)
		begin

			update dbo.payment_transaction
			set		payment_status		= 'CANCEL'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code	= @payment_trx_code

        end

		update dbo.payment_request
		set		payment_status		= 'HOLD'
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code	= @code_payment_request
		

		select @payment_amount = isnull(sum(orig_amount),0) 
		from dbo.payment_transaction_detail
		where payment_transaction_code = @payment_trx_code

		if(@payment_source = 'WORK ORDER')
		begin

			select	@remark = stuff((
					  select	distinct
								',' + mnt.spk_no + ' - ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.work_order				  wo on (wo.code		 = pr.payment_source_no)
								inner join dbo.maintenance				  mnt on (mnt.code		 = wo.maintenance_code)
								inner join dbo.asset_vehicle			  avh on (mnt.asset_code = avh.asset_code)
					  where		ptr.code = @payment_trx_code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment work order for : ' + @remark
		end
		else if (@payment_source = 'REALIZATION FOR PUBLIC SERVICE')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = pr.payment_source_no)
								inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
					  where		ptr.code = @payment_trx_code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment Realization public service for : ' + @payment_to + ' - '  + @remark
		end
		else if (@payment_source = 'DP ORDER PUBLIC SERVICE')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + avh.plat_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.order_main om on (om.code collate latin1_general_ci_as = pr.payment_source_no)
								inner join dbo.order_detail od on (od.order_code = om.code)
								inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = od.register_code)
								inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
					  where		ptr.code = @payment_trx_code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment DP order to bureau for : ' + @payment_to + ' - ' + @remark
		end
		else if (@payment_source = 'POLICY')
		begin
			select	@remark = stuff((
					  select	distinct
								', ' + ipm.policy_no
					  from		dbo.payment_transaction					  ptr
								inner join dbo.payment_transaction_detail ptrd on (ptr.code		 = ptrd.payment_transaction_code)
								inner join dbo.payment_request			  pr on (pr.code		 = ptrd.payment_request_code)
								inner join dbo.insurance_policy_main ipm on (ipm.code = pr.payment_source_no)
								--inner join dbo.insurance_policy_asset ipa on (ipm.code = ipa.policy_code)
								--inner join dbo.asset_vehicle			  avh on (ipa.fa_code = avh.asset_code)
					  where		ptr.code = @payment_trx_code
					  for xml path('')
				  ), 1, 1, ''
				 ) ;

			set @remarks = 'Payment policy insurance for : ' + @payment_to + ' - '  + @remark
		end

		update dbo.payment_transaction
		set		payment_amount		= @payment_amount
				,remark				= @remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code = @payment_trx_code

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
