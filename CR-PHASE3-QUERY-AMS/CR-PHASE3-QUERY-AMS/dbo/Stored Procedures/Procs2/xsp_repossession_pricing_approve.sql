CREATE PROCEDURE dbo.xsp_repossession_pricing_approve
(
	@p_code				nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@repossession_code		nvarchar(50)
			,@approve_amount		nvarchar(50)
			,@request_amount		nvarchar(50)
			,@remark				nvarchar(4000);

	begin try
		if not exists	(	
							select	1 
							from	dbo.repossession_pricing_detail 
							where	pricing_code = @p_code
						)
		begin
			set @msg = 'Please input Repossession data';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.repossession_pricing where code = @p_code and transaction_status = 'ON PROCESS')
		begin
			declare repo_pricing cursor for

				select 	rpd.repossession_code
						,rpd.approve_amount
				from	ifinrep.dbo.repossession_pricing_detail rpd
				where	rpd.pricing_code = @p_code

			open repo_pricing		
			fetch next from repo_pricing 
			into @repossession_code				
				,@approve_amount
			
			while @@fetch_status = 0

			begin
					select	@request_amount					= request_amount
					from	dbo.repossession_pricing_detail
					where	pricing_code					= @p_code

					update	dbo.repossession_main
					set		pricing_amount					= @approve_amount
							,repossession_status_process	= ''
							,sell_request_amount			= @request_amount
							--
							,mod_date						= @p_mod_date		
							,mod_by							= @p_mod_by			
							,mod_ip_address					= @p_mod_ip_address
					where	code							= @repossession_code

			fetch next from repo_pricing 
			into @repossession_code				
				,@approve_amount
			end
		
			close repo_pricing
			deallocate repo_pricing

			update	dbo.repossession_pricing
			set		transaction_status			= 'APPROVE'
					--
					,mod_date					= @p_mod_date		
					,mod_by						= @p_mod_by			
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @p_code

		end
		else
		begin
			set @msg = 'Data already process';
			raiserror(@msg,16,1) ;
		end
	end try
	Begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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

