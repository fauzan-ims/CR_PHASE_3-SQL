CREATE PROCEDURE dbo.xsp_work_order_update
(
	@p_code				nvarchar(50)
	,@p_invoice_no		nvarchar(50) = ''
	,@p_faktur_no		nvarchar(50) = null
	,@p_faktur_date		datetime	 = null
	,@p_actual_km		int
	,@p_last_km_service int			 = null
	,@p_work_date		datetime
	,@p_invoice_date	datetime
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			    nvarchar(max)
			,@total_ppn_amount  decimal(18, 2)
			,@maintenance_code  nvarchar(50)
			,@vendor_code	    nvarchar(50)
			,@value1			int
			,@value2			int

	begin try
		select	@total_ppn_amount  = total_ppn_amount
				,@maintenance_code = maintenance_code
				,@vendor_code	   = mnt.vendor_code
		from	dbo.work_order			   wo
				inner join dbo.maintenance mnt on mnt.code = wo.maintenance_code
		where	wo.code = @p_code ;

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'WOINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'WOFKT' ;

		if(@p_invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
		begin
			if(@value1 <> 0)
			begin
				set @msg = N'Invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value1 = 0)
			begin
				set @msg = N'Invoice date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@p_faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			if(@value2 <> 0)
			begin
				set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value2 = 0)
			begin
				set @msg = N'Faktur date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		--if(month(@p_invoice_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Invoice month must be equal than system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end

		if(@p_invoice_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Invoice date must be equal or less than system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		if(@p_faktur_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Faktur date must be equal or less than system date.' ;

			raiserror(@msg, 16, -1) ;
		end

		--if(month(@p_faktur_date) < month(dbo.xfn_get_system_date()))
		--begin
		--	set @msg = N'Faktur month must be equal than system date.' ;

		--	raiserror(@msg, 16, -1) ;
		--end

		if exists
		(
			select	1
			from	dbo.maintenance			  mnt
					inner join dbo.work_order wo on wo.maintenance_code = mnt.code
			where	mnt.vendor_code	  = @vendor_code
					and wo.invoice_no = @p_invoice_no
					and wo.status	  <> 'CANCEL'
					and wo.CODE		  <> @p_code
		)
		begin
			set @msg = N'Invoice no for this vendor already exist.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (len(@p_faktur_no) != 16)
		begin
			set @msg = N'Faktur Number Must be 16 Digits.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	work_order
		set		invoice_no			= @p_invoice_no
				,faktur_no			= @p_faktur_no
				,faktur_date		= @p_faktur_date
				,actual_km			= @p_actual_km
				--,last_km_service	= @p_last_km_service
				,work_date			= @p_work_date
				,invoice_date		= @p_invoice_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code = @p_code ;
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
