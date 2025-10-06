CREATE PROCEDURE dbo.xsp_master_insurance_branch_insert
(
	@p_id			   bigint = 0 output
	,@p_insurance_code nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from master_insurance_branch where insurance_code = @p_insurance_code and branch_code = @p_branch_code )
		begin
			SET @msg = 'Branch already exist';
			raiserror(@msg, 16, -1) ;
		end
		insert into master_insurance_branch
		(
			insurance_code
			,branch_code
			,branch_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_insurance_code
			,@p_branch_code
			,@p_branch_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		EXEC dbo.xsp_master_insurance_update_invalid @p_code			= @p_insurance_code                   
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by 
													,@p_mod_ip_address	= @p_mod_ip_address
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




