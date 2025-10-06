--Created by Rian at 14/03/2023

CREATE PROCEDURE [dbo].[xsp_reversal_main_reject] 
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg			nvarchar(max)
			,@source_no		nvarchar(50)

	begin try

		--select terlebih dahulu source code nya 
		select	@source_no = source_reff_code
		from	dbo.reversal_main
		where	code = @p_code

		--cek asal datanya melalui source code nya
		--1. jika source code nya ada di tabel received transaction maka lakukan update data pada tabel receive transaction ubah status nya menjadi paid lagi
		if exists 
		(
			select	1
			from	received_transaction
			where	code = @source_no
		)
		begin

			--update status di tabel reversal main menjadi reject
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel received transaction kembalikan menjadi paid
			update	dbo.received_transaction
			set		received_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end

		--2. jika source code nya ada di tabel payment voucher maka lakukan update data pada tabel paynebt vouche ubah status nya menjadi paid lagi
		else if exists
		(
			select	1
			from	dbo.payment_voucher
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi reject
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel payment voucher kembalikan menjadi paid
			update	dbo.payment_voucher
			set		payment_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end

		--3. jika source code nya ada di tabel cashire transaction maka lakukan update data pada tabel cashier transaction ubah status nya menjadi paid lagi
		else if exists
		(
			select	1
			from	cashier_transaction
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi reject
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel cashier transaction kembalikan menjadi paid
			update	dbo.cashier_transaction
			set		cashier_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end

		--4. jika source code nya ada di tabel payment transaction maka lakukan update data pada tabel payment transaction ubah status nya menjadi paid lagi
		else if exists
		(
			select	1
			from	payment_transaction
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi reject
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel payment transaction kembalikan menjadi paid
			update	dbo.payment_transaction
			set		payment_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end

		--5. jika source code nya ada di tabel received voucher maka lakukan update data pada tabel received voucher ubah status nya menjadi paid lagi
		else if exists
		(
			select	1
			from	received_voucher
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi reject
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel received voucher kembalikan menjadi paid
			update	dbo.received_voucher
			set		received_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		END
        else if exists
		(
			select	1
			from	dbo.suspend_allocation
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi REJECT
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel suspend_allocation kembalikan menjadi paid
			update	dbo.suspend_allocation
			set		allocation_status	= 'APPROVE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end
        
		else if exists
		(
			select	1
			from	dbo.deposit_allocation
			where	code = @source_no
		)
		begin
			--update status di tabel reversal main menjadi REJECT
			update	dbo.reversal_main
			set		reversal_status		= 'REJECT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			--update status di tabel deposit_allocation kembalikan menjadi paid
			update	dbo.deposit_allocation
			set		allocation_status	= 'APPROVE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @source_no
		end
		else
		begin
			set @msg = 'Data Not Found'
			raiserror(@msg, 16, -1)
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
