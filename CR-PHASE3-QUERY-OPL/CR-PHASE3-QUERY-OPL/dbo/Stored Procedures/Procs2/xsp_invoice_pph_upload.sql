CREATE PROCEDURE dbo.xsp_invoice_pph_upload
(
	@p_mod_date			datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	/*
		Cre_by		: sepria
		Cre_date	: 2024-07-02
		Cre_Note	: untuk menampung data upload dan munculkan validasi tanpa memproses data lainnya
	*/
	
	declare @msg					nvarchar(max)
			,@remark_validation1	nvarchar(max) = ''
			,@remark_validation2	nvarchar(max) = ''
			,@remark_validation3	nvarchar(max) = ''
			,@remark_validation4	nvarchar(max) = ''
			,@remark_validation 	nvarchar(max) = ''
			,@invoice_no			nvarchar(50)
			,@payment_reff_no		nvarchar(50)
			,@payment_reff_date		datetime	

	begin try
		
		select @remark_validation1 = isnull(stuff((
									  select	distinct ', ' +  ISNULL(invoice_external_no,'')
									  from		dbo.invoice_pph_upload_data
									  where		invoice_external_no in (select inv.invoice_external_no from dbo.invoice inv
																		inner join dbo.invoice_pph invp on invp.invoice_no = inv.invoice_no
																		where invp.settlement_status <> 'HOLD'
																		)
										and		p_user_id = @p_mod_by
									  for xml path('')
								  ), 1, 1, ''
			 					 ),'') ;
		
		select @remark_validation2 =  isnull(stuff((
									  select	distinct ', ' +  ISNULL(invoice_external_no,'')
									  from		dbo.invoice_pph_upload_data
									  where		isnull(payment_reff_no,'') = ''
									  and		p_user_id = @p_mod_by
									  for xml path('')
								  ), 1, 1, ''
			 					 ),'') ;

		select @remark_validation3 = isnull(stuff((
									  select	distinct ', ' +  ISNULL(invoice_external_no,'')
									  from		dbo.invoice_pph_upload_data
									  where		isnull(payment_reff_date,'') = ''
									  and		p_user_id = @p_mod_by
									  for xml path('')
								  ), 1, 1, ''
			 					 ),'') ;

		select @remark_validation4 = isnull(stuff((
								  select	distinct ', ' +  ISNULL(invoice_external_no,'')
								  from		dbo.invoice_pph_upload_data
								  where		cast(payment_reff_date as date)  > cast(dbo.xfn_get_system_date() as date)
								  and		p_user_id = @p_mod_by
								  for xml path('')
							  ), 1, 1, ''
			 				 ),'') ;

		if (isnull(@remark_validation1,'') <> '')
		begin
		    set @remark_validation =  @remark_validation + CHAR(13) + ' 1. Settlement Already proceed for Invoice no.: ' + @remark_validation1
		end

		if (isnull(@remark_validation2,'') <> '')
		begin
		    set @remark_validation =  @remark_validation + CHAR(13) + ' 2. Please Insert Payment Reff No. for Invoice No.: ' + @remark_validation2
		end

		if (isnull(@remark_validation3,'') <> '')
		begin
		    set @remark_validation =  @remark_validation + CHAR(13) + ' 3. Please Insert Payment Reff Date. for Invoice No.: '  + @remark_validation3
		end

		if (isnull(@remark_validation4,'') <> '')
		begin
		    set @remark_validation =  @remark_validation + CHAR(13) + ' 4. Please input Payment Reff Date Less or Equal Than System Date for Invoice No.: ' + @remark_validation4
		end
		
		if (isnull(@remark_validation,'') <> '')
		begin
			set @msg = @remark_validation;
			raiserror(@msg, 16, 1) ;
		end 
		else
        begin
			declare c_jurnal cursor local fast_forward read_only for
			select	inv.invoice_no 
					,a.payment_reff_no
					,a.payment_reff_date
			from	dbo.invoice_pph_upload_data a
					inner join dbo.invoice inv on inv.invoice_external_no = a.invoice_external_no
			where	p_user_id = @p_mod_by

			open c_jurnal
			fetch c_jurnal 
			into @invoice_no
				,@payment_reff_no	
				,@payment_reff_date	

			while @@fetch_status = 0
			begin
			
					exec dbo.xsp_settlement_pph_post @p_invoice_no			= @invoice_no,		
													 @p_payment_reff_no		= @payment_reff_no, 
													 @p_payment_reff_date	= @payment_reff_date,
													 @p_mod_date			= @p_mod_date,      
													 @p_mod_by				= @p_mod_by,        
													 @p_mod_ip_address		= @p_mod_ip_address 

					fetch	c_jurnal 
					into	@invoice_no
							,@payment_reff_no	
							,@payment_reff_date	

			end
			close c_jurnal
			deallocate c_jurnal
            
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
