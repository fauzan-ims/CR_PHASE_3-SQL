CREATE PROCEDURE dbo.xsp_repossession_letter_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) 
			,@agreement_no		nvarchar(50);

	begin try

		if exists (select 1 from dbo.repossession_letter where code = @p_code and letter_status = 'HOLD')
		begin    
			select	@agreement_no = agreement_no 
			from	dbo.repossession_letter 
			where	code = @p_code

			update	dbo.repossession_letter
			set		letter_status	= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			update	dbo.agreement_information 
			set		skt_status		= NULL
					 --
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
            where	agreement_no = @agreement_no
		end
		else
		begin
			set @msg = 'Data already proceed';
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

