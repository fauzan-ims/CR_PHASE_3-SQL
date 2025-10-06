--created by, Rian at 15/03/2023 

CREATE PROCEDURE [dbo].[xsp_maintenance_detail_update_tax_for_work_order]
(
	@p_id					bigint
	,@p_tax_code			nvarchar(50)
	,@p_tax_name			nvarchar(250)
	,@p_ppn_pct				decimal(9,6)
	,@p_pph_pct				decimal(9,6)
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
AS
BEGIN
	declare @msg				nvarchar(max)
			,@total_amount		decimal(18, 2)
			--,@ppn_amount		decimal(18, 2)
			--,@pph_amount		decimal(18, 2)
			--,@total_ppn_amount	decimal(18, 2)
			--,@total_pph_amount	decimal(18, 2)
			,@ppn_amount		int
			,@pph_amount		int
			,@total_ppn_amount	int
			,@total_pph_amount	int
			,@payment_amount	decimal(18, 2)
			,@sub_total_amount	decimal(18, 2)
			,@service_amount	decimal(18, 2)
			,@maintenance_code	nvarchar(50)
	begin try

		--ambil nilai total amount nya
		select	@total_amount		= total_amount
				,@maintenance_code	= maintenance_code
		from dbo.maintenance_detail
		where	id = @p_id

		--set ppn amount dan pph amount
		set	@ppn_amount = isnull((@p_ppn_pct / 100) * @total_amount, 0)
		set	@pph_amount = isnull((@p_pph_pct / 100) * @total_amount, 0)

		--update data pada tabel maintenance detail
		update	dbo.maintenance_detail
		set		ppn_amount		= @ppn_amount
				,pph_amount		= @pph_amount
				,ppn_pct		= @p_ppn_pct
				,pph_pct		= @p_pph_pct
				,tax_code		= @p_tax_code
				,tax_name		= @p_tax_name
				,payment_amount	= @total_amount + @ppn_amount - @pph_amount  --nilai payment amount didapat dari hasil total amount + ppn amount - pph amount
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	id = @p_id

		select	@total_ppn_amount		= sum(ppn_amount)
				,@total_pph_amount		= sum(pph_amount)
				,@service_amount		= sum(service_fee)
				,@sub_total_amount		= sum(total_amount)
				,@payment_amount		= sum(payment_amount)
		from dbo.maintenance_detail
		where maintenance_code = @maintenance_code

		update dbo.work_order
		set		total_ppn_amount	 = @total_ppn_amount
				,total_pph_amount	 = @total_pph_amount
				,total_amount		 = @sub_total_amount
				,payment_amount		 = @payment_amount
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
		where	maintenance_code	 = @maintenance_code ;

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
END
