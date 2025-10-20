CREATE PROCEDURE dbo.xsp_invoice_delivery_done
(
	@p_code			   NVARCHAR(50)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg			  NVARCHAR(MAX)
			,@invoice_no	  nvarchar(50)
			,@delivery_status nvarchar(20)
			,@delivery_date	  datetime
			,@status		  nvarchar(10)
			,@log_remarks	  nvarchar(4000)
			,@agreement_no	  nvarchar(50)
			,@asset_no		  nvarchar(50) ;

	begin try
		-- jika masih ada data yang belum di proses,
		--if exists
		--(
		--	select	1
		--	from	invoice_delivery_detail
		--	where	delivery_code		= @p_code
		--			and delivery_status = 'HOLD'
		--)
		--begin
		--	set @msg = 'Please completed pending Delivery.' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;

		if exists
		(
			select	1
			from	dbo.invoice_delivery
			where	code	   = @p_code
					and status = 'ON PROCESS'
		)
		begin
			update	dbo.invoice_delivery
			set		status = 'DONE'
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already Done.' ;
			raiserror(@msg, 16, 1) ;
		end ;

		if exists (select 1 from dbo.invoice_delivery where isnull(delivery_result,'') = '' and code = @p_code)
		begin
		    set @msg = 'Please Input Result.' ;
			raiserror(@msg, 16, 1) ;
		end

		-- looping proses done
		declare c_agreement_log cursor for
		select	idd.invoice_no	
				,idd.delivery_date				
				,ind.agreement_no		
				,ind.asset_no
				,id.delivery_result			
		from	dbo.invoice_delivery_detail idd
				inner join dbo.invoice_delivery id on id.code = idd.delivery_code
				left join dbo.invoice_detail ind on (ind.invoice_no = idd.invoice_no)
		where	delivery_code = @p_code ;

		open c_agreement_log ;

		fetch c_agreement_log
		into @invoice_no
			 ,@delivery_date
			 ,@agreement_no
			 ,@asset_no
			 ,@delivery_status ;

		while @@fetch_status = 0
		begin
			-- jika status sudah delivery, maka log akan di generate di tabel agreement_log dg status succeed
			if (@delivery_status = 'ACCEPTED')
			begin
				set @log_remarks = 'Delivery Succeed Invoice No: ' + @invoice_no ;

				exec dbo.xsp_agreement_log_insert @p_agreement_no		= @agreement_no
												  ,@p_asset_no			= @asset_no
												  ,@p_log_source_no		= @p_code
												  ,@p_log_date			= @delivery_date
												  ,@p_log_remarks		= @log_remarks
												  ,@p_cre_date			= @p_cre_date
												  ,@p_cre_by			= @p_cre_by
												  ,@p_cre_ip_address	= @p_cre_ip_address
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address ;

				update	dbo.invoice
				set		deliver_date	= @delivery_date
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	invoice_no		= @invoice_no ;
			end ;
			else
			-- jika status not delivery, maka log akan di generate di tabel agreement_log dg status failed
			begin
				set @log_remarks = 'Delivery Failed Invoice No: ' + @invoice_no ;

				exec dbo.xsp_agreement_log_insert @p_agreement_no		= @agreement_no
												  ,@p_asset_no			= @asset_no
												  ,@p_log_source_no		= @p_code
												  ,@p_log_date			= @delivery_date
												  ,@p_log_remarks		= @log_remarks
												  ,@p_cre_date			= @p_cre_date
												  ,@p_cre_by			= @p_cre_by
												  ,@p_cre_ip_address	= @p_cre_ip_address
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address ;

				-- kemudian, update tb.invoice 
				update	dbo.invoice
				set		deliver_code = null
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	invoice_no = @invoice_no ;
			end ;

			fetch next from c_agreement_log
			into  @invoice_no
				 ,@delivery_date
				 ,@agreement_no
				 ,@asset_no
				 ,@delivery_status ;
		end ;

		close c_agreement_log ;
		deallocate c_agreement_log ;

		
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