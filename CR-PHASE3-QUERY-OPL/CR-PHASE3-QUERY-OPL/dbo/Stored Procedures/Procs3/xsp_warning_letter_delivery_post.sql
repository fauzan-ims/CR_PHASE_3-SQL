CREATE PROCEDURE dbo.xsp_warning_letter_delivery_post
(
	@p_code						nvarchar(50)
    --
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	
	declare @msg					nvarchar(max)
			,@letter_no				nvarchar(50)
			,@letter_no_sp1			nvarchar(50)
			,@letter_type			nvarchar(3)
			,@delivery_date			datetime
			,@agreement_no			nvarchar(50)
			,@client_name			nvarchar(250)
			,@agreement_external_no	nvarchar(50)
			,@installment_no 		int

	begin TRY

		if exists (select 1 from dbo.warning_letter_delivery where code = @p_code and delivery_status  <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
        
		if not exists (select 1 from dbo.warning_letter_delivery_detail where delivery_code = @p_code)
		begin
			set @msg = 'Please Input detail';
			raiserror(@msg ,16,-1)
		end

		if exists	(
						select 1 from dbo.warning_letter_delivery_detail wld
						inner join dbo.warning_letter wl on (wl.delivery_code = wld.delivery_code)
						where wld.delivery_code = @p_code and wl.print_count <= 0
					)
		begin
			select top 1 @letter_no = wl.letter_no
					,@letter_type	= wl.letter_type 
			from dbo.warning_letter_delivery_detail wld
			inner join dbo.warning_letter wl on (wl.delivery_code = wld.delivery_code)
			where wld.delivery_code = @p_code and wl.print_count <= 0

			set @msg = 'Letter No : ' + @letter_no + ' - ' + @letter_type + ' not printed yet';
			raiserror(@msg ,16,-1)
		end

		declare cur_warning_letter cursor fast_forward read_only for
			
		select		letter_type
					,wl.agreement_no
					,am.agreement_external_no
					,am.client_name
					,installment_no 
					,wl.letter_no
		from		dbo.warning_letter wl
					inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
		where		isnull(wl.delivery_code,'') = @p_code

		open cur_warning_letter
		
		fetch next from cur_warning_letter 
		into	@letter_type
				,@agreement_no
				,@agreement_external_no
				,@client_name
				,@installment_no
				,@letter_no

		while @@fetch_status = 0
		begin
				if(@letter_type = 'SOMASI' OR @letter_type = 'SP2')
				begin
					if exists (
								select * from warning_letter wl
								where wl.agreement_no = @agreement_no 
									--and wl.installment_no = @installment_no
									and wl.letter_type = 'SP1'
									and letter_status not in ('DELIVERED','CANCEL')
									and	isnull(wl.delivery_code,'') <> @p_code
							)
						begin
								select	@letter_no_sp1 = wl.letter_no 
								from	warning_letter wl
								where	wl.agreement_no = @agreement_no 
									--and wl.installment_no = @installment_no
									and wl.letter_type = 'SP1'
									and letter_status not in ('DELIVERED','CANCEL')
									and	isnull(wl.delivery_code,'') <> @p_code

								close cur_warning_letter
								deallocate cur_warning_letter
								set @msg = 'Letter No : ' + @letter_no_sp1 + ' - SP1 with Agreement No : ' + @agreement_external_no + ' - ' + @client_name + ' not DELIVERED yet' ;
								raiserror(@msg ,16,-1);
						end
				end

				if(@letter_type = 'SOMASI')
				begin
					if exists (
								select 1 from warning_letter wl
								where wl.agreement_no = @agreement_no 
									--and wl.installment_no = @installment_no
									and wl.letter_type = 'SP2'
									and letter_status not in ('DELIVERED','CANCEL')
									and	isnull(wl.delivery_code,'') <> @p_code
							)
						begin
								select	@letter_no_sp1 = wl.letter_no 
								from	warning_letter wl
								where	wl.agreement_no = @agreement_no 
									--and wl.installment_no = @installment_no
									and wl.letter_type = 'SP2'
									and letter_status not in ('DELIVERED','CANCEL')
									and	isnull(wl.delivery_code,'') <> @p_code

								close cur_warning_letter
								deallocate cur_warning_letter
								set @msg = 'Letter No : ' + @letter_no_sp1 + ' - SP2 with Agreement No : ' + @agreement_external_no + ' - ' + @client_name + ' not DELIVERED yet' ;
								raiserror(@msg ,16,-1);
						end
				end


				fetch next from cur_warning_letter 
				into	@letter_type
						,@agreement_no
						,@agreement_external_no
						,@client_name
						,@installment_no
						,@letter_no
			
			end
		close cur_warning_letter
		deallocate cur_warning_letter
			
		select	@delivery_date	= delivery_date 
		from	dbo.warning_letter_delivery
		where	code = @p_code

		update	dbo.warning_letter_delivery
		set		delivery_status			= 'ON PROCESS'
				--
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code

		update dbo.warning_letter
		set		delivery_date			= @delivery_date
				,mod_date				= @p_mod_date		
				,mod_by					= @p_mod_by			
				,mod_ip_address			= @p_mod_ip_address
		where	delivery_code			= @p_code

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
end   
