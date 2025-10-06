/*
exec dbo.xsp_write_off_invoice_insert @p_write_off_code = N'' -- nvarchar(50)
									  ,@p_agreement_no = N'' -- nvarchar(50)
									  ,@p_cre_date = '2023-06-19 09.26.59' -- datetime
									  ,@p_cre_by = N'' -- nvarchar(15)
									  ,@p_cre_ip_address = N'' -- nvarchar(15)
									  ,@p_mod_date = '2023-06-19 09.26.59' -- datetime
									  ,@p_mod_by = N'' -- nvarchar(15)
									  ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Senin, 19 Juni 2023 16.26.43 -- 
CREATE procedure dbo.xsp_write_off_invoice_insert
(
	@p_write_off_code  nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_write_off_date datetime
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
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50) ;

	begin try
		declare currinvoice cursor fast_forward read_only for
		select distinct
				inv.invoice_no
		from	dbo.invoice inv
				inner join dbo.invoice_detail invd on (invd.invoice_no = inv.invoice_no)
		where	invd.agreement_no	   = @p_agreement_no
				and inv.invoice_status = 'POST' ;

		open currinvoice ;

		fetch next from currinvoice
		into @invoice_no ;

		while @@fetch_status = 0
		begin
			insert into dbo.write_off_invoice
			(
				write_off_code
				,invoice_no
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_write_off_code
				,@invoice_no
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			fetch next from currinvoice
			into @invoice_no ;
		end ;

		close currinvoice ;
		deallocate currinvoice ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
