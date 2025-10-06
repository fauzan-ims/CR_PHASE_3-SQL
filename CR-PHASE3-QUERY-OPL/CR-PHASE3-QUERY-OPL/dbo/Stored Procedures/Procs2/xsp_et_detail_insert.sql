CREATE PROCEDURE dbo.xsp_et_detail_insert
(
	@p_id					bigint = 0 output
	,@p_et_code				nvarchar(50)
	,@p_asset_no			nvarchar(50)
	,@p_os_rental_amount	decimal(18, 2) 
	,@p_is_terminate		nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	--if @p_is_terminate = 'T'
	--(+) Rinda 15/01/202118:20:13 notes :	selalu 1 saat awal
		set @p_is_terminate = '1' ;
	--else
	--	set @p_is_terminate = '0' ;

	begin try
		insert into et_detail
		(
			et_code
			,asset_no
			,os_rental_amount 
			,is_terminate
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_et_code
			,@p_asset_no
			,@p_os_rental_amount 
			,@p_is_terminate
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

