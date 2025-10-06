CREATE PROCEDURE dbo.invoice_delivery_post
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@invoice_no	nvarchar(50)
			,@delivery_date	datetime

	begin try
		if exists (select 1 from dbo.invoice_delivery where code = @p_code and status = 'ON PROCESS')
		begin

			declare c_invoice_delivery_detail cursor for
			select	invoice_no
					,delivery_date
			from	dbo.invoice_delivery_detail
			where	delivery_code		= @p_code
					and delivery_status = 'DELIVER' ;

			open	c_invoice_delivery_detail

			fetch	c_invoice_delivery_detail
			into	@invoice_no
					,@delivery_date

			while @@fetch_status = 0
			begin
				

				update	dbo.invoice
				set		deliver_date	= @delivery_date
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	invoice_no		= @invoice_no ;

				fetch	c_invoice_delivery_detail
				into	@invoice_no
						,@delivery_date
			end

			close		c_invoice_delivery_detail
			deallocate	c_invoice_delivery_detail

			update	dbo.invoice_delivery
			set		status			= 'DONE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code
		end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
		end ;
	end try
	Begin catch
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

