CREATE PROCEDURE [dbo].[xsp_asset_replacement_update]
(
	@p_code						nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_date					datetime
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_remark					nvarchar(4000)
	,@p_status					nvarchar(10)
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
BEGIN

	declare @msg nvarchar(max) 
	DECLARE @platno NVARCHAR(200); 


	begin try
		
		if(@p_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be less or equal than System Date' ;

			raiserror(@msg, 16, 1) ;
		end

		--14/12/2022 Rian, Menambah validasi untuk agreement yang sedang di proses
		if exists (select 1 from asset_replacement where code <> @p_code and agreement_no = @p_agreement_no and status in
						(
							'HOLD'--, 'ON PROCESS'
						))
		begin
			set @msg = 'Data already Proceed or Post' ;
			raiserror(@msg, 16, 1) ;
		END
        


		update	asset_replacement
		set		agreement_no	= @p_agreement_no
				,date			= @p_date
				,branch_code	= @p_branch_code
				,branch_name	= @p_branch_name
				,remark			= @p_remark
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code	= @p_code

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
