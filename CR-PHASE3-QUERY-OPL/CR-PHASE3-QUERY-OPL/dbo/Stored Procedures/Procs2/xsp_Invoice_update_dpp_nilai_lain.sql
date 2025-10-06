CREATE PROCEDURE dbo.xsp_Invoice_update_dpp_nilai_lain
(
	@p_invoice_no						nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	
	--(+) sepria 06032025: cr dpp ppn 12% coretax
	declare @msg								nvarchar(max)
			,@ppn_pct							decimal(9, 6)
			,@pph_pct							decimal(9, 6)
			,@ppn_pct_coretax					decimal(9,6)
			,@dpp_nilai_lain					decimal(18,2)
			,@total_billing_amount_invoice		decimal(18,2)
			,@ppn_rumus_coretax					decimal(18,2)
			,@total_ppn_amount_invoice_detail	decimal(18,2)
			,@selisih_ppn_amount				decimal(18,2)
			,@count_asset						int = 0
			,@pembagian_minimal_1rp				int
			,@total_sisa_ppn_amount				decimal(18,2)
			,@id_invoice_detail					bigint
            ,@total_billing_amount				decimal(18,2)
			,@total_ppn_after_selisih			decimal(18,2)
			,@total_ppn_amount					decimal(18,2)
			,@total_amount						decimal(18,2)

	begin try
		begin
			select	@ppn_pct = value
			from	dbo.sys_global_param
			where	code = ('RTAXPPN') ;

			select	@pph_pct = value
			from	dbo.sys_global_param
			where	code = ('RTAXPPH') ;

			select  @ppn_pct_coretax = value 
			from dbo.sys_global_param
			where code = ('CRTAXPPN')

						
				select	@total_billing_amount	= sum(billing_amount)
				from	dbo.invoice_detail
				where	invoice_no = @p_invoice_no ;

				select	@total_ppn_amount = total_ppn_amount
				from	dbo.invoice
				where	invoice_no = @p_invoice_no ;

				set @dpp_nilai_lain = round((@total_billing_amount * (@ppn_pct /100) / (@ppn_pct_coretax /100)),0)

				update	dbo.invoice
				set		dpp_nilai_lain			= @dpp_nilai_lain
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	invoice_no = @p_invoice_no ;
				
				------ ppn
				if(@total_ppn_amount <> 0)
				begin
					set @ppn_rumus_coretax = round(@dpp_nilai_lain * (@ppn_pct_coretax /100),0)

					-- bandingin Nilai PPn di Invoice header dan detail
					select	@total_ppn_amount_invoice_detail	= sum(ppn_amount)
							,@count_asset						= count(1)
					from	dbo.invoice_detail
					where	invoice_no = @p_invoice_no

					-- hitung selisih nilai ppn_amount dari rumus coretax dengan total di invoice_detail
					set @selisih_ppn_amount =  isnull(@ppn_rumus_coretax,0) - isnull(@total_ppn_amount_invoice_detail,0)
					
					if(@selisih_ppn_amount <> 0)
					begin
						declare curr_selisih_1rp cursor fast_forward read_only for
						select id
						from dbo.invoice_detail
						where invoice_no = @p_invoice_no
						order by id asc

						open curr_selisih_1rp

						while(@selisih_ppn_amount <> 0)
						begin
							fetch next from curr_selisih_1rp into @id_invoice_detail

							while @@fetch_status = 0
							begin

								if(@selisih_ppn_amount > 0)
								begin
									update	dbo.invoice_detail
									set		ppn_amount = ppn_amount + 1
											,total_amount	= total_amount + 1
									where	id = @id_invoice_detail

									set @selisih_ppn_amount = @selisih_ppn_amount - 1
								end
								else if(@selisih_ppn_amount < 0)
								begin
									update dbo.invoice_detail
									set		ppn_amount		= ppn_amount - 1
											,total_amount	= total_amount - 1
									where	id = @id_invoice_detail

									set @selisih_ppn_amount = @selisih_ppn_amount + 1
								end

								fetch next from curr_selisih_1rp into @id_invoice_detail
							end
						end

						-- Close and deallocate the cursor after exiting the loops
						close curr_selisih_1rp
						deallocate curr_selisih_1rp

						-- update ke header total
						select	@total_amount			= sum(total_amount)
						from	dbo.invoice_detail
						where	invoice_no = @p_invoice_no ;

						update	dbo.invoice
						set		total_ppn_amount		= @ppn_rumus_coretax
								,total_amount			= @total_amount
								--
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	invoice_no = @p_invoice_no ;
					end
				end
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
