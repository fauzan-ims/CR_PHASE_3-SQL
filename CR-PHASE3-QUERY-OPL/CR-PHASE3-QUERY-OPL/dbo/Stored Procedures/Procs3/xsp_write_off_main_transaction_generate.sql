/*
    alterd : Rinda, 16 Nopember 2020
*/
CREATE PROCEDURE dbo.xsp_write_off_main_transaction_generate
(
	@p_code						nvarchar(50)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg						nvarchar(max)
			,@gl_link_code				nvarchar(50)
			,@order_key					int
			,@is_transaction			nvarchar(1)
			,@is_amount_editable		nvarchar(1)
			,@is_disc_editable			nvarchar(1)
			,@wo_type					nvarchar(50)
			,@agreement_sub_status		nvarchar(50)
			,@os_princ_amount			decimal(18,2)
			
			select	@wo_type					= wo_type
					,@agreement_sub_status		= am.agreement_sub_status
			from	dbo.write_off_main wo
					inner join dbo.agreement_main am on (am.agreement_no = wo.agreement_no)
			where	code		= @p_code

	begin try
		declare c_mt cursor local fast_forward read_only for
		select  mt.code
				,mtp.order_key
				,mtp.is_transaction
		from	dbo.master_transaction mt with(nolock)
				inner join dbo.master_transaction_parameter mtp with(nolock) on (mtp.transaction_code = mt.code)
		where	mtp.process_code ='WO'

		open c_mt
		fetch c_mt
		into @gl_link_code
			,@order_key
			,@is_transaction

		while @@fetch_status = 0
		begin
			
			EXEC dbo.xsp_write_off_transaction_insert @p_id						= 0
													,@p_wo_code					= @p_code
													,@p_transaction_code		= @gl_link_code
													,@p_transaction_amount		= 0
													,@p_is_transaction			= @is_transaction
													,@p_order_key				= @order_key
													,@p_cre_date				= @p_mod_date
													,@p_cre_by					= @p_mod_by
													,@p_cre_ip_address			= @p_mod_ip_address
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address
			
			fetch c_mt
			into @gl_link_code
				,@order_key
				,@is_transaction
		end
		close c_mt
		deallocate c_mt
		
		
		if (@wo_type ='WO_COLL')
		begin
			if (@agreement_sub_status ='WO')
			begin
				update dbo.write_off_transaction 
				set		transaction_amount	= 0 
				where	wo_code				= @p_code
				and		transaction_code	= 'OS_INST'	
			end
            else
			begin
				update dbo.write_off_transaction 
				set		transaction_amount	= 0 
				where	wo_code				= @p_code
				and		transaction_code	= 'AR_WO'	
			end
            
		end
        else
		begin
			update dbo.write_off_transaction 
			set		transaction_amount	= 0 
			where	wo_code				= @p_code
			and		transaction_code	= 'DOUBFUL'	
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
	


