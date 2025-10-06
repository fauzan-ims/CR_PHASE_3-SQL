CREATE PROCEDURE dbo.xsp_et_transaction_generate
(
	@p_et_code		   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_et_date		   datetime
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
			,@disc_pct				decimal(9, 6)
			,@disc_amount			decimal(18, 2)
			,@order_key				int
			,@is_amount_editable	nvarchar(1)
			,@is_discount_editable  nvarchar(1)
			,@is_transaction		nvarchar(1) 

	begin try  
		delete dbo.et_transaction
		where	et_code = @p_et_code ;

		declare transactionparameter cursor fast_forward read_only for
		select	transaction_code 
				,maximum_disc_pct				
				,maximum_disc_amount	 	
				,order_key				
				,is_amount_editable	
				,is_discount_editable  
				,is_transaction		
		from	dbo.master_transaction_parameter with (nolock)
		where process_code = 'ET';

		open transactionParameter ;

		fetch next from transactionParameter
		into @transaction_code		 
			 ,@disc_pct				 
			 ,@disc_amount			 
			 ,@order_key				 
			 ,@is_amount_editable	 
			 ,@is_discount_editable   
			 ,@is_transaction		 

		while @@fetch_status = 0
		begin
			set @transaction_amount = 0 
			  
			exec dbo.xsp_agreement_main_getamount @p_agreement_no			 = @p_agreement_no
													,@p_reff_no				 = @p_et_code
													,@p_transaction_type	 = 'ET'
													,@p_transaction_code	 = @transaction_code
													,@p_date				 = @p_et_date 
													,@p_transaction_amount	 = @transaction_amount output;
 
			exec dbo.xsp_et_transaction_insert @p_id					 = 0
												,@p_et_code				 = @p_et_code
												,@p_transaction_code	 = @transaction_code
												,@p_transaction_amount	 = @transaction_amount
												,@p_disc_pct			 = @disc_pct		
												,@p_disc_amount			 = @disc_amount
												,@p_total_amount		 = @transaction_amount
												,@p_order_key			 = @order_key
												,@p_is_amount_editable	 = @is_amount_editable	 
												,@p_is_discount_editable = @is_discount_editable   
												,@p_is_transaction		 = @is_transaction	
												,@p_cre_date			 = @p_cre_date	   
												,@p_cre_by				 = @p_cre_by		   
												,@p_cre_ip_address		 = @p_cre_ip_address 
												,@p_mod_date			 = @p_mod_date	   
												,@p_mod_by				 = @p_mod_by		   
												,@p_mod_ip_address		 = @p_mod_ip_address 

			fetch next from transactionParameter
			into @transaction_code		 
				 ,@disc_pct				 
				 ,@disc_amount			 
				 ,@order_key				 
				 ,@is_amount_editable	 
				 ,@is_discount_editable   
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



