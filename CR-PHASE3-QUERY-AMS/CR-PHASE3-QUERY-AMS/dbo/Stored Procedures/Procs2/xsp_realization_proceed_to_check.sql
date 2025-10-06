CREATE PROCEDURE [dbo].[xsp_realization_proceed_to_check]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@status					 nvarchar(20)
			,@faktur_no					 nvarchar(50)
			,@faktur_date				 datetime
			,@order_code				 nvarchar(50)
			,@register_code_for_validate nvarchar(4000)
			,@regis_status				 nvarchar(50)
			,@value1					 int
			,@value2					 int
			,@invoice_date				 datetime
			,@ppn_amount				 decimal(18,2)

	begin try
		select	@status			= payment_status
				,@order_code	= order_code
				,@regis_status	= register_status
				,@invoice_date	= realization_invoic_date
				,@faktur_date	= faktur_date
				,@ppn_amount	= service_ppn_amount
		from	dbo.register_main
		where	code = @p_code ;

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZFKT' ;

		if(@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
		begin
			if(@value1 <> 0)
			begin
				set @msg = N'Realization invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value1 = 0)
			begin
				set @msg = N'Realization invoice date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
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

		if (@order_code = '')
		begin
			set @msg = N'Please check order code.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if(@ppn_amount > 0) and ((@faktur_no = '') or (isnull(@faktur_no,'')=''))
		begin
			set @msg = N'Please Input Faktur No!';
			raiserror(@msg, 16, 1)
		end;

		--if exists
		--(
		--	select	1
		--	from	dbo.register_main
		--	where	order_code			= @order_code
		--			and register_status = 'PENDING'
		--)
		--begin
		--	select	@register_code_for_validate = stuff((
		--													select	distinct
		--															'|' + '(' + av.plat_no + ' - ' + rm.code + ')' collate Latin1_General_CI_AS
		--													from	dbo.register_main			 rm
		--															inner join dbo.asset_vehicle av on av.asset_code = rm.fa_code
		--													where	order_code			= @order_code
		--															and register_status = 'PENDING'
		--													for xml path('')
		--												), 1, 1, ''
		--											   ) ;

		--	set @msg = N'Please receive transaction for ' + @register_code_for_validate + N' first.' ;

		--	raiserror(@msg, 16, -1) ;
		--end ; dicomment raffy (2025/08/28) info mba sep gaada validasi ini di fase 3 dan di prod juga gaada, gatau dibuat, buat apa 

		if(@regis_status = 'PENDING')
		begin
			set @msg = N'Please receive transaction first.' ;

			raiserror(@msg, 16, -1) ;
		end

		if (@status = 'HOLD')
		begin
			update	dbo.register_main
			set		payment_status	= 'ON CHECK'
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
