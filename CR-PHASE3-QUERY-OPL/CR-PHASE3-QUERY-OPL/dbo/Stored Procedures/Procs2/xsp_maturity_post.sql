CREATE PROCEDURE [dbo].[xsp_maturity_post]
(
	@p_code			   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@asset_no		  nvarchar(50)
			,@periode		  int
			,@maturity_remark nvarchar(400)
			,@maturity_date	  datetime
			,@result		  nvarchar(50) 
			,@rental_amount	  DECIMAL(18,2)
			,@invoice_no	  NVARCHAR(50)
			,@biling_amount	  DECIMAL(18,2)
			,@max_billing_no  INT;;

	begin try

		--select data result
		select	@result = result
		from	dbo.maturity
		where	code = @p_code ;

		--validasi terlebih dahulu status nya
		if exists
		(
			select	1
			from	dbo.maturity
			where	code	   = @p_code
					and status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Data Already Proceed ' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists (select 1 from dbo.maturity_detail where result = 'STOP')
		begin
			--update status di maturity
			update	dbo.maturity
			set		status			= 'APPROVE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code ;
		end
		else
		begin
			--update status di maturity
			update	dbo.maturity
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code = @p_code ;
		end

		--update asset menjadi terminate karena asset akan di stop rentalnya
		update	dbo.agreement_asset
		set		asset_status		= 'TERMINATE'
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	asset_no in
				(
					select	asset_no
					from	dbo.maturity_detail
					where	maturity_code = @p_code
							and result = 'STOP'
				) ;

		if exists
		(
			select	1
			from	dbo.maturity_detail
			where	maturity_code = @p_code
					and result	  = 'CONTINUE'
		)
		--if (@result = 'CONTINUE')
		begin

			select	@rental_amount =  b.monthly_rental_rounded_amount
			from	dbo.maturity_detail a
			inner join dbo.agreement_asset b on b.asset_no = a.asset_no and a.result = 'CONTINUE'
			where	a.maturity_code = @p_code

			select	top 1 
					 @biling_amount		= a.billing_amount
					,@invoice_no		= a.invoice_no
					,@max_billing_no	= a.BILLING_NO
					,@asset_no			= a.ASSET_NO
			from	dbo.agreement_asset_amortization a
			inner	join dbo.maturity_detail b on b.asset_no = a.asset_no and b.result = 'CONTINUE'
			where	b.maturity_code = @p_code
			order by a.billing_no desc

			if (@rental_amount <> @biling_amount)
			begin
					delete	dbo.agreement_asset_amortization
					where	agreement_no	= @p_agreement_no
					and		asset_no		= @asset_no
					and		billing_no		= @max_billing_no
			end

			--2024/03/12 Raffy (+) Update tanggal maturity jika di extend	
			select	@periode = additional_periode
			from	dbo.maturity
			where	code = @p_code ;

			update	dbo.agreement_main
			set		agreement_status		= 'GO LIVE'
					,agreement_sub_status	= ''
					,termination_date		= null
					,termination_status		= null 
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	agreement_no			= @p_agreement_no ;

			update	dbo.agreement_information
			set		maturity_date	= dateadd(month, @periode, maturity_date)
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	agreement_no = @p_agreement_no ;

			--2024/03/12 Raffy (+) Update tanggal maturity jika di extend	

			--insert data ke agrement
			insert into dbo.agreement_asset_amortization
			(
				agreement_no
				,billing_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				,invoice_no
				,generate_code
				,hold_billing_status
				,hold_date
				,reff_code
				,reff_remark
				,reff_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@p_agreement_no
					,installment_no
					,asset_no
					,due_date
					,billing_date
					,billing_amount
					,description
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.maturity_amortization_history
			where	maturity_code  = @p_code
					and old_or_new = 'NEW' ;
		end ;
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
