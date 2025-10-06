CREATE PROCEDURE dbo.xsp_wo_transaction_generate
(
	@p_wo_code		   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_wo_date		   datetime
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
			,@transaction_code		nvarchar(50)
			,@transaction_amount	decimal(18, 2)
			,@order_key				int
			,@is_transaction		nvarchar(1)
			,@asset_no				nvarchar(50)

	begin try  
		delete dbo.write_off_transaction
		where	wo_code = @p_wo_code ;
		 
		declare transactionparameter cursor fast_forward read_only for
		select	transaction_code 	 	
				,order_key				 
				,is_transaction		
		from	dbo.master_transaction_parameter 
		where process_code = 'WO';

		open transactionParameter ;

		fetch next from transactionParameter
		into @transaction_code		 
			 ,@order_key				 
			 ,@is_transaction		 

		while @@fetch_status = 0
		begin
			
			exec dbo.xsp_agreement_main_getamount @p_agreement_no			= @p_agreement_no
													,@p_reff_no				= @p_wo_code
													,@p_transaction_type	= 'WO'
													,@p_transaction_code	= @transaction_code
													,@p_date				= @p_wo_date 
													,@p_transaction_amount	= @transaction_amount output;
													
			exec dbo.xsp_write_off_transaction_insert @p_id						= 0
														,@p_wo_code				= @p_wo_code
														,@p_transaction_code	= @transaction_code
														,@p_transaction_amount	= @transaction_amount
														,@p_is_transaction		= @is_transaction
														,@p_order_key			= @order_key
														,@p_cre_date			= @p_cre_date	   
														,@p_cre_by				= @p_cre_by		   
														,@p_cre_ip_address		= @p_cre_ip_address 
														,@p_mod_date			= @p_mod_date	   
														,@p_mod_by				= @p_mod_by		   
														,@p_mod_ip_address		= @p_mod_ip_address 
														
			set @transaction_amount = 0 
			 
			fetch next from transactionParameter
			into @transaction_code		 
				 ,@order_key				 
				 ,@is_transaction	
		end ;

		close transactionParameter ;
		deallocate transactionParameter ; 
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

