CREATE PROCEDURE dbo.xsp_receipt_register_post
(
	@p_code				nvarchar(50)
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
			,@receipt_no		nvarchar(150)
			,@branch_code		nvarchar(50)
			,@branch_name		nvarchar(250)
			,@void_date			datetime

	begin try
	
		if exists (select 1 from dbo.receipt_register where code = @p_code and register_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin

			declare cur_receipt_register_detail cursor fast_forward read_only for
			
			select	rrd.receipt_no
					,rr.branch_code
					,rr.branch_name
			from	dbo.receipt_register_detail rrd
					inner join dbo.receipt_register rr on (rr.code = rrd.register_code)
			where	register_code = @p_code

			open cur_receipt_register_detail
		
			fetch next from cur_receipt_register_detail 
			into	@receipt_no
					,@branch_code
					,@branch_name

			while @@fetch_status = 0
			begin

				if exists (select 1 from dbo.receipt_main where receipt_no = @receipt_no and receipt_status = 'NEW')
				begin
					close cur_receipt_register_detail
					deallocate cur_receipt_register_detail

					select	@branch_name	= branch_name 
					from	dbo.receipt_main 
					where	receipt_no = @receipt_no 
							and receipt_status = 'NEW'

					set @msg = 'Receipt No : ' + @receipt_no + ' is already registered at branch : ' + @branch_name;
					raiserror(@msg ,16,-1)
				end

				exec dbo.xsp_receipt_main_insert @p_code				= 0 
												 ,@p_branch_code		= @branch_code
												 ,@p_branch_name		= @branch_name
												 ,@p_receipt_status		= N'NEW'
												 ,@p_receipt_use_date	= null
												 ,@p_receipt_no			= @receipt_no
												 ,@p_cashier_code		= null
												 ,@p_max_print_count	= 1 
												 ,@p_print_count		= 0 
												 ,@p_cre_date			= @p_cre_date		
												 ,@p_cre_by				= @p_cre_by			
												 ,@p_cre_ip_address		= @p_cre_ip_address	
												 ,@p_mod_date			= @p_mod_date		
												 ,@p_mod_by				= @p_mod_by			
												 ,@p_mod_ip_address		= @p_mod_ip_address	
				 
				

				fetch next from cur_receipt_register_detail 
				into	@receipt_no
						,@branch_code
						,@branch_name
			
			end
			close cur_receipt_register_detail
			deallocate cur_receipt_register_detail
			
			update	dbo.receipt_register
			set		register_status		= 'POST'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
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


