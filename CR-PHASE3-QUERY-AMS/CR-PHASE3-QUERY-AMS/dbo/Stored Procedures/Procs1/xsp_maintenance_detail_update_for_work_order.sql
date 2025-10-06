CREATE PROCEDURE [dbo].[xsp_maintenance_detail_update_for_work_order]
(
	@p_id					bigint
	,@p_service_fee			decimal(18,2) = 0
	,@p_quantity			int			  = 0
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@ppn_amount		decimal(18,2)
			,@pph_amount		decimal(18,2)
			,@maintenance_code	nvarchar(50)
			,@service_amount	decimal(18,2)
			,@total_amount		decimal(18,2)
			,@payment_amount	decimal(18,2)
			,@ppn_pct			decimal(9, 6)
			,@pph_pct			decimal(9, 6)
			--,@total_ppn_amount	decimal(18, 2)
			--,@total_pph_amount	decimal(18, 2)
			,@total_ppn_amount	int
			,@total_pph_amount	int

	begin try

		--select old data from tabel maintenance detail
		select @maintenance_code	= maintenance_code
				,@ppn_pct			= ppn_pct
				,@pph_pct			= pph_pct
		from dbo.maintenance_detail
		where id = @p_id

		--set ppn amoount dan pph amount
		set	@ppn_amount = isnull(@ppn_pct / 100 * (@p_service_fee * @p_quantity), 0)
		set	@pph_amount = isnull(@pph_pct / 100 * (@p_service_fee * @p_quantity), 0)

		update	maintenance_detail
		set		service_fee			= @p_service_fee
				,ppn_amount			 = @ppn_amount
				,pph_amount			 = @pph_amount
				,quantity			 = @p_quantity
				,total_amount		 = @p_service_fee * @p_quantity --total amount didapat dari serfice fee dikalikan quantity
				,payment_amount		 = (@p_service_fee * @p_quantity) + @ppn_amount - @pph_amount --payment amount didapat dari total amount ditambah PPN dikurangi PPH
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
		from dbo.maintenance_detail
		where maintenance_code = @maintenance_code

		update dbo.work_order
		set		total_ppn_amount	 = @total_ppn_amount
				,total_pph_amount	 = @total_pph_amount
				,total_amount		 = @total_amount
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
end ;
