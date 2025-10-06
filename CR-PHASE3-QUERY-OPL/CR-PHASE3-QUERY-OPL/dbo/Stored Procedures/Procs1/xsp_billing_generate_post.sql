CREATE PROCEDURE dbo.xsp_billing_generate_post
(
	@p_code					   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@invoice_no	nvarchar(50);

	begin try 
	
		if not exists
		(
			select	1
			from	dbo.billing_generate_detail
			where	generate_code			   = @p_code
		)
		begin
			SET @msg = 'There is no data Rental Due in this As Of Date ';
			raiserror(@msg, 16, 1) ;
		 end

		if exists
		(
			select	1
			from	dbo.billing_generate
			where	code			   = @p_code
			and		status = 'HOLD'
		)
		BEGIN

		if not exists --(+) raffy 2025/05/06 penambahan pengecekkan jika asset dalam proses et, invoice tidak bisa tergenerate
            (
				SELECT	1
				FROM	dbo.billing_generate_detail bgd
				INNER JOIN dbo.et_main em ON em.agreement_no = bgd.agreement_no
				inner join dbo.et_detail ed on ed.et_code = em.code and ed.asset_no = bgd.asset_no
				where	generate_code = @p_code
				and		em.et_status not in ('CANCEL','EXPIRED')
				and		ed.is_terminate = '1'
			)
			begin

			-- process billing with billing scheme
				BEGIN
					exec dbo.xsp_billing_generate_invoice_by_scheme @p_code				= @p_code				
																	--
																	,@p_mod_date		= @p_mod_date		
																	,@p_mod_by			= @p_mod_by			
																	,@p_mod_ip_address	= @p_mod_ip_address
				end
				-- process billing to invoice
									 

				begin
					exec dbo.xsp_billing_generate_invoice_by_non_scheme @p_code				= @p_code				
																		--
																		,@p_mod_date		= @p_mod_date		
																		,@p_mod_by			= @p_mod_by			
																		,@p_mod_ip_address	= @p_mod_ip_address
				
				end
				

			-- Hari - 20.Sep.2023 09:24 AM --	change to new function
			---- process billing with billing scheme
			--	begin
			--		exec dbo.xsp_billing_generate_with_scheme @p_code			 = @p_code				
			--												  --
			--												  ,@p_mod_date		 = @p_mod_date		
			--												  ,@p_mod_by		 = @p_mod_by			
			--												  ,@p_mod_ip_address = @p_mod_ip_address
			--	end
			--	-- process billing to invoice
			--	begin
					
	
			--		exec dbo.xsp_billing_generate_invoice @p_code			 = @p_code				
			--											  --
			--											  ,@p_mod_date		 = @p_mod_date		
			--											  ,@p_mod_by		 = @p_mod_by			
			--											  ,@p_mod_ip_address = @p_mod_ip_address
				
			--	end

				-- update agreement status
				begin
					select	@invoice_no = invoice_no
					from	dbo.invoice
					where	generate_code = @p_code ; 

					exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @invoice_no
															 ,@p_mod_date		= @p_mod_date		
															 ,@p_mod_by			= @p_mod_by			
															 ,@p_mod_ip_address = @p_mod_ip_address
					
				end

				update	dbo.billing_generate
				set		status					= 'POST'
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	code					= @p_code ;
			end;
			ELSE
            BEGIN
				set @msg = 'Data cannot be post, early termination progress for one or more assets';
				raiserror(@msg, 16, 1) ;
			end
		end ;
		else
		begin
			set @msg = 'Data already post';
			raiserror(@msg, 16, 1) ;
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





