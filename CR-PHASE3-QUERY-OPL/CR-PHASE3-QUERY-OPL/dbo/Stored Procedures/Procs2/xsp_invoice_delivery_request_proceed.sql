/*
	created : arif / 12 des 2022
*/

CREATE PROCEDURE dbo.xsp_invoice_delivery_request_proceed
(
	@p_invoice_no	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(50)
			,@code					nvarchar(50)
			,@invoice_delivery_code nvarchar(50)
			,@date					datetime
			,@client_name			nvarchar(250)
			,@client_no				nvarchar(50) 
			,@client_address		nvarchar(4000)

	begin try
		-- Louis Rabu, 02 Juli 2025 15.10.16 --
		--select	@invoice_delivery_code = code
		--from	invoice_delivery
		--where	branch_code = @branch_code ; 
		--if (@invoice_delivery_code != null)
		--begin
		--	set @msg = 'Data already procceed.' ;
		--	raiserror(@msg, 16, -1) ;
		--end ;
		if exists
		(
			select	1
			from	dbo.invoice inv
					inner join dbo.invoice_delivery ind on ind.code = inv.deliver_code
			where	invoice_no = @p_invoice_no
			and		ind.status in ('HOLD','ON PROCESS')
		)
		begin
			set @msg = N'Data already procceed.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		-- Louis Rabu, 02 Juli 2025 15.10.16 --

		select	@branch_code	= branch_code
				,@branch_name	= branch_name
				,@client_name	= client_name
				,@client_no		= client_no
				,@client_address = client_address
		from	dbo.invoice
		where	invoice_no		= @p_invoice_no ;

		if not exists
		(
			select	1
			from	invoice_delivery
			where	branch_code = @branch_code
					-- Louis Rabu, 02 Juli 2025 14.50.00 -- 
					and client_no = @client_no
					and client_address = @client_address
					-- Louis Rabu, 02 Juli 2025 14.50.00 -- 
					and status	= 'HOLD'
		)
		BEGIN
			SELECT 'if not exists'
			SET @date = dbo.xfn_get_system_date() ;

			exec dbo.xsp_invoice_delivery_insert @p_code				= @invoice_delivery_code output
												 ,@p_branch_code		= @branch_code
												 ,@p_branch_name		= @branch_name
												 ,@p_status				= 'HOLD'
												 ,@p_date				= @date
												 ,@p_method				= 'INTERNAL'
												 ,@p_employee_code		= null
												 ,@p_employee_name		= null
												 ,@p_external_pic_name	= ''
												 ,@p_email				= ''
												 ,@p_remark				= 'Delivery Invoice'
												 ,@p_client_no			= @client_no		
												 ,@p_client_address		= @client_address
												 ,@p_delivery_result	= 'Accepted' 
												 ,@p_cre_date			= @p_cre_date
												 ,@p_cre_by				= @p_cre_by
												 ,@p_cre_ip_address		= @p_cre_ip_address
												 ,@p_mod_date			= @p_mod_date
												 ,@p_mod_by				= @p_mod_by
												 ,@p_mod_ip_address		= @p_mod_ip_address ;
		end ;
		else
		begin
			select	@invoice_delivery_code = code
			from	invoice_delivery
			where	branch_code = @branch_code
					-- Louis Rabu, 02 Juli 2025 14.50.00 -- 
					and client_no = @client_no
					and client_address = @client_address
					-- Louis Rabu, 02 Juli 2025 14.50.00 -- 
					and status	= 'HOLD'
		end ;

		-- insert ke delivery detail
		exec dbo.xsp_invoice_delivery_detail_insert @p_id				= 0
													,@p_delivery_code	= @invoice_delivery_code
													,@p_invoice_no		= @p_invoice_no
													,@p_delivery_status = N'HOLD'
													,@p_delivery_date	= null
													,@p_delivery_remark = ''
													,@p_receiver_name	= null
													,@p_file_name		= null
													,@p_file_path		= null
													,@p_cre_date		= @p_cre_date
													,@p_cre_by			= @p_cre_by
													,@p_cre_ip_address	= @p_cre_ip_address
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address ;

		-- update invoice menggunakan delivery code
		update	dbo.invoice
		set		deliver_code = @invoice_delivery_code
		where	invoice_no = @p_invoice_no ;
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