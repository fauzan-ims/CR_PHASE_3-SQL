CREATE PROCEDURE dbo.xsp_claim_progress_insert
(
	@p_id					   bigint = 0 output
	,@p_claim_code			   nvarchar(50)
	,@p_claim_progress_code	   nvarchar(50)
	,@p_claim_progress_date	   datetime
	,@p_claim_progress_remarks nvarchar(4000)
	--
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max);

	begin try
		--IF (CAST(@p_claim_progress_date AS DATE) > CAST(dbo.xfn_get_system_date() AS DATE))
		--BEGIN
		--	set @msg = 'Progress Date must be less System Date' ;

		--	raiserror(@msg, 16, -1) ;
		--END

		insert into claim_progress
		(
			claim_code
			,claim_progress_code
			,claim_progress_date
			,claim_progress_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_claim_code
			,@p_claim_progress_code
			,@p_claim_progress_date
			,@p_claim_progress_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		update	dbo.claim_main
		set		claim_progress_status = @p_claim_progress_code
		where	code = @p_claim_code ;


		set @p_id = @@identity ;
	end try
	Begin catch
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





