CREATE PROCEDURE dbo.xsp_deposit_release_detail_insert
(
	@p_id					 bigint = 0 output
	,@p_deposit_release_code nvarchar(50)
	,@p_deposit_code		 nvarchar(50)
	,@p_deposit_type		 nvarchar(15)
	,@p_deposit_amount		 decimal(18, 2)
	--,@p_release_amount		 decimal(18, 2)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@transaction_code		nvarchar(50) 
			,@transaction_name		nvarchar(250) 
			,@sum_amount			decimal(18, 2) 
			,@deposit_amount		decimal(18, 2)
			,@release_amount		decimal(18, 2) 
			,@agreement_no			nvarchar(50)
			,@status				nvarchar(20);

	begin try
		select @agreement_no = agreement_no 
		from deposit_release
		where code = @p_deposit_release_code

		--set @status = dbo.xfn_get_status(@p_deposit_code)
		--if @status is not null
		--begin
		--	set @msg = 'This deposit already used in ' + @status;
		--	raiserror(@msg, 16, -1) ;
		--end

		if (isnull(@p_deposit_code, '') <> '')
		begin
			set @status = dbo.xfn_get_status(@p_deposit_code)
		end

		if @status is not null
		begin
			set @msg = 'This deposit already used in ' + @status;
			raiserror(@msg, 16, -1) ;
		end

		insert into deposit_release_detail
		(
			deposit_release_code
			,deposit_code
			,deposit_type
			,deposit_amount
			,release_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_deposit_release_code
			,@p_deposit_code
			,@p_deposit_type
			,@p_deposit_amount
			,@p_deposit_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select	@sum_amount		= sum(release_amount)
		from	dbo.deposit_release_detail
		where	deposit_release_code = @p_deposit_release_code

		update	dbo.deposit_release
		set		release_amount	= @sum_amount
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_deposit_release_code

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
