CREATE PROCEDURE dbo.xsp_work_order_detail_update_for_work_order
(
	@p_id					bigint
	,@p_service_fee			decimal(18,2) = 0
	,@p_quantity			int			  = 0
	,@p_part_number			nvarchar(50)  = ''
	-- (+) Ari 2023-12-28 ket : ppn & pph bisa di edit sehingga dibawa ke perhitungaan  
	,@p_ppn_amount	   decimal(18, 2) = 0
	,@p_pph_amount	   decimal(18, 2) = 0
	-- (+) Ari 2023-12-28  
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@ppn_amount		int--decimal(18,2)
			,@pph_amount		int--decimal(18,2)
			,@work_order_code	nvarchar(50)
			,@service_amount	decimal(18,2)
			,@total_amount		decimal(18,2)
			,@payment_amount	decimal(18,2)
			,@ppn_pct			decimal(9, 6)
			,@pph_pct			decimal(9, 6)
			,@total_ppn_amount	int--decimal(18, 2)
			,@total_pph_amount	int--decimal(18, 2)
			,@val_ppn_pph	   decimal(18, 2)	-- (+) Ari 2023-12-28  
			-- (+) Ari 2024-01-02  
			,@dpp_amount	   decimal(18, 2)
			,@ppn_before	   decimal(18, 2)
			,@pct_before	   decimal(18, 2)
			,@service_before   decimal(18, 2)
			,@qty_before	   int ;

	begin try

		--select old data from tabel work order detail
		select @work_order_code	= work_order_code
				,@ppn_pct			= ppn_pct
				,@pph_pct			= pph_pct
		from dbo.work_order_detail
		where id = @p_id

		if @p_quantity <= 0
		begin
	
			set @msg = 'Quantity must greater than 0.';
	
			raiserror(@msg, 16, -1) ;
	
		end  ; 

		--set ppn amoount dan pph amount
		--set	@ppn_amount = isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0)
		--set	@pph_amount = isnull(@pph_pct / 100 * (@p_service_fee * @p_quantity), 0)

		-- (+) Ari 2023-12-28 ket : diatas dicomment mengambil ppn dari inputan  
		select	@service_before = service_fee
				,@ppn_before	= ppn_amount
				,@pct_before	= ppn_pct
				,@qty_before	= quantity
		from	work_order_detail
		where	id = @p_id ;

		if (right(@p_service_fee, 2) <> '00')
		begin
			set @msg = N'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (
					isnull(@service_before, 0) = 0
					and isnull(@ppn_pct, 0) = 0
					and isnull(@ppn_before, 0) = 0
				)
		begin
			set @ppn_amount = round(isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
			set @pph_amount = round(isnull(@pph_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
		end ;
		else if (isnull(@p_quantity, 0) <> isnull(@qty_before, 0))
		begin
			set @ppn_amount = round(isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
			set @pph_amount = round(isnull(@pph_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
		end ;
		else
		begin
			if (
				   isnull(@service_before, 0) <> @p_service_fee
				   and	isnull(@ppn_before, 0) = @p_ppn_amount
			   )
			begin
				set @ppn_amount = round(isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
				set @pph_amount = round(isnull(@pph_pct / 100 * (@p_service_fee * @p_quantity), 0), 0) ;
			end ;
			else
			begin
				set @ppn_amount = isnull(@p_ppn_amount, 0) ;
				set @pph_amount = isnull(@p_pph_amount, 0) ;

				--select @dpp_amount = total_amount     
				--from dbo.work_order    
				--where code = @work_order_code    
				set @val_ppn_pph = isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0) ;

				if ((
						isnull(@pph_pct, 0) = 0
						and isnull(@p_pph_amount, 0) <> 0
					)
				   )
				begin
					set @msg = N'Cannot set PPH amount because PPH PCT = 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if ((
							 isnull(@ppn_pct, 0) = 0
							 and isnull(@p_ppn_amount, 0) <> 0
						 )
						)
				begin
					set @msg = N'Cannot set PPN amount because PPN PCT = 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@ppn_amount > @p_service_fee)
				begin
					set @msg = N'PPN cannot bigger than Service Fee ' + convert(nvarchar(50), @p_service_fee) ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (
							(
								@ppn_amount <= 0
								and isnull(@ppn_pct, 0) <> 0
							)
							and
							(
								@pph_amount <= 0
								and isnull(@pph_pct, 0) <> 0
							)
						)
				begin
					set @msg = N'PPN & PPH cannot less than and must be greater than 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (
							@ppn_amount <= 0
							and isnull(@ppn_pct, 0) <> 0
						)
				begin
					set @msg = N'PPN cannot less than and must be greater than 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@ppn_amount > (@val_ppn_pph + 100)) -- (+) Ari ket : kenapa 100 ? request kak sepria     
				begin
					set @msg = N'PPN cannot bigger than ' + convert(nvarchar(50), (@val_ppn_pph + 100)) ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@ppn_amount < (@val_ppn_pph - 100))
				begin
					set @msg = N'PPN cannot less than ' + convert(nvarchar(50), (@val_ppn_pph - 100)) ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (
							@pph_amount <= 0
							and isnull(@pph_pct, 0) <> 0
						)
				begin
					set @msg = N'PPH cannot less than and must be greater than 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@pph_amount > @p_service_fee)
				begin
					set @msg = N'PPH cannot bigger than Service Amount' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (right(@p_ppn_amount, 2) <> '00')
				begin
					set @msg = N'The Comma at the end cannot be anything other than 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (right(@p_pph_amount, 2) <> '00')
				begin
					set @msg = N'The Comma at the end cannot be anything other than 0' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		-- (+) Ari 2023-12-28    
		end ;

		update	dbo.work_order_detail
		set		service_fee			= @p_service_fee
				,ppn_amount			 = @ppn_amount
				,pph_amount			 = @pph_amount
				,quantity			 = @p_quantity
				,total_amount		 = @p_service_fee * @p_quantity --total amount didapat dari serfice fee dikalikan quantity
				,payment_amount		 = (@p_service_fee * @p_quantity) + @ppn_amount - @pph_amount --payment amount didapat dari total amount ditambah PPN dikurangi PPH
				,part_number		 = @p_part_number
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	id = @p_id ;

		select	@total_ppn_amount		= sum(ppn_amount)
				,@total_pph_amount		= sum(pph_amount)
				,@service_amount		= sum(service_fee)
				,@total_amount			= sum(total_amount)
				,@payment_amount		= sum(payment_amount)
		from dbo.work_order_detail
		where work_order_code = @work_order_code

		update dbo.work_order
		set		total_ppn_amount	 = @total_ppn_amount
				,total_pph_amount	 = @total_pph_amount
				,total_amount		 = @total_amount
				,payment_amount		 = @payment_amount
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	code				 = @work_order_code ;
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
