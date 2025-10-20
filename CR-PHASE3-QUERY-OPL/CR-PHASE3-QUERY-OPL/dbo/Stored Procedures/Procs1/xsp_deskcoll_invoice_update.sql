CREATE PROCEDURE dbo.xsp_deskcoll_invoice_update
(
	@p_id			   bigint
	,@p_result_code	   nvarchar(50)
	,@p_remark		   nvarchar(4000)
	,@p_promise_date	datetime		 = null	
	,@p_promise_amount	decimal(18,2)	= 0
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@result_code_header	nvarchar(50)
			,@result_desc			nvarchar(250)
			,@promise_date_header	datetime
			,@promise_amount_header	decimal(18,2)

	begin try
	

		select	@result_code_header		= dsm.result_code
				,@promise_date_header	= dsm.result_promise_date
				,@promise_amount_header	= dsm.result_promise_amount
		from	dbo.deskcoll_invoice dsi
				inner join dbo.deskcoll_main dsm on dsm.id = dsi.deskcoll_main_id
		where	dsi.id = @p_id ;

		select @result_desc = result_name from dbo.master_deskcoll_result where code = 'MD004'

		if (@p_result_code = 'MD004')  
		BEGIN
		   if(@result_code_header <> 'MD004') -- validasi jika di invoice janji bayar, tp di headernya bukan janji bayar. 
		   begin
				set @msg = 'Please Update Result At Header To ' + ISNULL(@result_desc,'') + ' First.'
				raiserror(@msg ,16,-1)
		   end

		   if(cast(@p_promise_date as date) < cast(@promise_date_header as date)) -- jika promise date kecil dari yang di header
		   begin
				set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Promise Date','Promise Date At Header')
				raiserror(@msg ,16,-1)
		   end
		end
	
		update	dbo.deskcoll_invoice
		set		result_code		= @p_result_code
				,remark			= @p_remark
				,promise_date	= @p_promise_date
				,promise_amount	= @p_promise_amount
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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