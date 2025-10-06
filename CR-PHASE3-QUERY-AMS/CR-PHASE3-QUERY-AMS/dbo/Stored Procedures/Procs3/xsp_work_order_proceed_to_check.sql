CREATE PROCEDURE [dbo].[xsp_work_order_proceed_to_check]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@status	   nvarchar(20)
			,@faktur_no	   nvarchar(50)
			,@faktur_date  datetime
			,@value1	   int
			,@value2	   int
			,@invoice_date datetime
			,@ppn_amount   decimal(18, 2)
			,@type			nvarchar(50)
			,@is_approve	nvarchar(1)
			,@approve_date	datetime
			,@is_free		nvarchar(1)

	begin try
		select	@status			= wo.status
				,@faktur_no		= wo.faktur_no
				,@faktur_date	= isnull(wo.faktur_date, '')
				,@invoice_date	= isnull(wo.invoice_date, '')
				,@ppn_amount	= wo.total_ppn_amount
				,@type			= mnt.service_type
				,@is_approve	= isnull(wo.is_claim_approve,'')
				,@approve_date	= isnull(wo.claim_approve_claim_date,'')
				,@is_free		= mnt.free_service
		from	dbo.work_order			   wo
				inner join dbo.maintenance mnt on mnt.code = wo.maintenance_code
		where	wo.code = @p_code ;


		if(@is_free = '0')
		begin
			if(@type = 'CLAIM')
			begin
				if(@is_approve = '')
				begin
					set @msg = N'Please checklist approve by insurance.' ;

					raiserror(@msg, 16, -1) ;
				end
				else
				begin
					if(@approve_date = '')
					begin
						set @msg = N'Please input insurance approve date.' ;

						raiserror(@msg, 16, -1) ;
					end
				end
			end

			select	@value1 = value
			from	dbo.sys_global_param
			where	CODE = 'WOINV' ;

			select	@value2 = value
			from	dbo.sys_global_param
			where	CODE = 'WOFKT' ;

			if (@invoice_date = '')
			begin
				set @msg = N'Please input invoice date.' ;

				raiserror(@msg, 16, -1) ;
			end ;

			if (@faktur_date = '')
			begin
				set @msg = N'Please input faktur date.' ;

				raiserror(@msg, 16, -1) ;
			end ;

			if (@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
			begin
				if (@value1 <> 0)
				begin
					set @msg = N'Invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + N' months.' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@value1 = 0)
				begin
					set @msg = N'Invoice date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;

			if (@faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
			begin
				if (@value2 <> 0)
				begin
					set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + N' months.' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@value2 = 0)
				begin
					set @msg = N'Faktur date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;

			if (@invoice_date > dbo.xfn_get_system_date())
			begin
				set @msg = N'Invoice date must be equal or less than system date.' ;

				raiserror(@msg, 16, -1) ;
			end ;

			if (@faktur_date > dbo.xfn_get_system_date())
			begin
				set @msg = N'Faktur date must be equal or less than system date.' ;

				raiserror(@msg, 16, -1) ;
			end ;

			if (isnull(@faktur_no, '') = '')
			   and	(@ppn_amount > 0)
			begin
				set @msg = N'Faktur Number cant be empty.' ;

				raiserror(@msg, 16, -1) ;
			end ;

			if (@status = 'HOLD')
			begin
				update	dbo.work_order
				set		status			= 'ON CHECK'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @p_code ;
			end ;
			else
			begin
				set @msg = N'Data Already Proceed' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end
		else
		begin
			update	dbo.work_order
			set		status			= 'PAID'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;
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
