CREATE PROCEDURE dbo.xsp_warning_letter_print
(
	@p_letter_no						nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@letter_type			nvarchar(20)
			,@letter_no				nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@delivery_code			nvarchar(50)
			,@agreement_external_no	nvarchar(50)
			,@installment_no 		int

	select	@letter_type				= letter_type
			,@agreement_no				= wl.agreement_no
			,@agreement_external_no		= am.agreement_external_no
			,@installment_no			= installment_no 
			,@delivery_code				= wl.delivery_code
	from	dbo.warning_letter wl
			inner join dbo.agreement_main am on (am.agreement_no = wl.agreement_no)
	where	wl.LETTER_NO = @p_letter_no

	begin try
		if(@letter_type = 'SOMASI' OR @letter_type = 'SP2')
		begin
			if exists (
						select 1 from warning_letter wl
						where wl.agreement_no = @agreement_no 
							--and wl.installment_no = @installment_no
							and wl.letter_type = 'SP1'
							and letter_status not in ('CANCEL','REQUEST')
							and	isnull(wl.delivery_code,'') <> @delivery_code
							and wl.print_count <= 0
					)
				begin
						set @msg = 'Please print SP1 first';
						raiserror(@msg ,16,-1)
				end
		end

		if(@letter_type = 'SOMASI')
		begin
			if exists (
						select 1 from warning_letter wl
						where wl.agreement_no = @agreement_no 
							--and wl.installment_no = @installment_no
							and wl.letter_type = 'SP2'
							and letter_status not in ('CANCEL','REQUEST')
							and	isnull(wl.delivery_code,'') <> @delivery_code
							and wl.print_count <= 0
					)
				begin
						set @msg = 'Please print SP2 first';
						raiserror(@msg ,16,-1)
				end
		end

	update	warning_letter
	set		letter_status	= 'PRINT'
			,last_print_by	= @p_mod_by
			,print_count	= print_count +1
			--
			,mod_date		= @p_mod_date		
			,mod_by			= @p_mod_by			
			,mod_ip_address	= @p_mod_ip_address	
	where	LETTER_NO		= @p_letter_no


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
