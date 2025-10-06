CREATE PROCEDURE dbo.xsp_receipt_void_post
(
	@p_code					nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)
			,@receipt_code		nvarchar(50)
			,@void_date			datetime

	begin try
	
		if exists (select 1 from dbo.receipt_void where code = @p_code and void_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			update	dbo.receipt_void
			set		void_status			= 'POST'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			declare cur_receipt_void_detail cursor fast_forward read_only for
			
			select	rvd.receipt_code
					,rv.void_date
			from	dbo.receipt_void_detail rvd
					inner join dbo.receipt_void rv on (rv.code = rvd.receipt_void_code)
			where	receipt_void_code = @p_code

			open cur_receipt_void_detail
		
			fetch next from cur_receipt_void_detail 
			into	@receipt_code
					,@void_date

			while @@fetch_status = 0
			begin
				if exists (select 1 from dbo.receipt_main where code = @receipt_code and receipt_status <> 'NEW')
				begin
					set @msg = dbo.xfn_get_msg_err_data_already_proceed();
					raiserror(@msg ,16,-1)
				end
				else
				begin
					update	dbo.receipt_main
					set		receipt_use_date	= @void_date
							,receipt_status		= 'VOID'
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @receipt_code
				end

			fetch next from cur_receipt_void_detail 
				into	@receipt_code
						,@void_date
			
			end
			close cur_receipt_void_detail
			deallocate cur_receipt_void_detail
			
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


