CREATE PROCEDURE dbo.xsp_faktur_allocation_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max);

	begin try
		if exists (select 1 from dbo.faktur_allocation where code = @p_code and status = 'HOLD')
		begin
		-- mengembali status faktur yang assign menjadi new
		update	dbo.faktur_main
		set		status		= 'NEW'
				,invoice_no = null
		where	faktur_no in
				(
					select	substring(faktur_no,5,18)
					from	dbo.faktur_allocation_detail
					where	allocation_code = @p_code
				) ;

		update	dbo.faktur_allocation
		set		status = 'CANCEL'
		where	code = @p_code

		update invoice 
		set faktur_no = ''
		where invoice_no in (
								select	invoice_no
								from	dbo.faktur_allocation_detail
								where	allocation_code = @p_code
							)
		end
		else
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
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

