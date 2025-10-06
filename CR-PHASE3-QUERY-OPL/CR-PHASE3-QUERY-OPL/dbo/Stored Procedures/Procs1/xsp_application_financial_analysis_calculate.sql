CREATE PROCEDURE dbo.xsp_application_financial_analysis_calculate
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@DI				 decimal(18, 2) = 0
			,@DBR				 decimal(9, 6)	= 0
			,@DSR				 decimal(9, 6)	= 0
			,@IDIR				 decimal(9, 6)	= 0
			,@income_amount		 decimal(18, 2)
			,@expense_amount	 decimal(18, 2)
			,@installment_amount decimal(18, 2) ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_financial_analysis_income afai
					inner join dbo.application_financial_analysis afa on (afa.code = afai.application_financial_analysis_code)
			where	application_no				= @p_application_no
					having sum(afai.income_amount) > 0
			union
			select	1
			from	dbo.application_financial_analysis_expense afae
					inner join dbo.application_financial_analysis afa on (afa.code = afae.application_financial_analysis_code)
			where	application_no				 = @p_application_no
					having sum(afae.expense_amount) > 0
		)
		begin
			select	@income_amount = sum(afi.income_amount)
			from	application_financial_analysis_income afi
					inner join dbo.application_financial_analysis afa on (afa.code = afi.application_financial_analysis_code)
			where	afa.application_no = @p_application_no ;

			-- hanya mengambil expense yg angsuran nya perbulan (cicilan)
			select	@expense_amount = sum(afe.expense_amount)
			from	application_financial_analysis_expense afe
					inner join dbo.application_financial_analysis afa on (afa.code		= afe.application_financial_analysis_code)
					inner join dbo.sys_general_subcode sgs on (
																  sgs.code				= afe.expense_type
																  and  sgs.general_code = 'FAETI'
															  )
			where	afa.application_no = @p_application_no ;

			select	@installment_amount = rental_amount
			from	dbo.application_main
			where	application_no = @p_application_no ;

			if (@income_amount is null)
			begin
				set @income_amount = 0 ;
			end ;

			if (@expense_amount is null)
			begin
				set @expense_amount = 0 ;
			end ;

			if (@installment_amount is null)
			begin
				set @installment_amount = 0 ;
			end ;
			
			set @DI = @income_amount - @expense_amount - @installment_amount ;
			if (@DI <= 0)
			begin
				set @IDIR = 0 ;
			end ;
			else
			begin
				set @IDIR = (@expense_amount + @installment_amount) / @DI * 100.0 ;
			end ;
			
			if (@income_amount = 0)
			begin
				set @DBR = @installment_amount / (@income_amount + 1) * 100.0 ;
				set @DSR = (@installment_amount + @expense_amount) / (@income_amount + 1) ;
			end ;
			else
			begin
				if (@installment_amount / @income_amount * 100.0 > 999.99)
				begin
					set @DBR = 999.99 ;
				end
				else
				begin
					set @DBR = @installment_amount / @income_amount * 100.0 ;
				end

				if (( @installment_amount+@expense_amount/@income_amount) < 100)
				begin
					set @dsr = (@installment_amount + @expense_amount) / @income_amount ;
				end
				else
                begin
					set @dsr = 0;
				end
			end ;
			
		--Remark
		--DI = Sisa penghasilan bersih dari usaha Non gaji – Angsuran Pinjaman Exiting – Angsuran pinjaman Now, menghasilkan Seberapa (Rp) banyak keuntungan bersih usaha.
		--IDIR = Angsuran Pinjaman Exiting + Angsuran Pinjaman Now / DI x 100 maksimal 80% sd 70%
		--DBR = Angsuran Pinjaman Now / Laba Kotor Usaha x100 Maksimal 25% Sd 20%
		--DSR = Angsuran Pinjaman Now + Angsuran pinjaman Exiing / Laba kotor usaha x100 Maksimal 40% sd 35%
		end ;

		update dbo.application_financial_analysis
		set		dsr_pct			= @DSR
				,idir_pcT		= @IDIR
				,dbr_pct		= @DBR
				--
				,mod_date		= @p_mod_date		
				,mod_by			= @p_mod_by			
				,mod_ip_address	= @p_mod_ip_address
		where	application_no	= @p_application_no		
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




