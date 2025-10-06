CREATE PROCEDURE dbo.xsp_asset_other_upload_insert
(
	@p_fa_upload_id			bigint = 0 output
	,@p_file_name			nvarchar(250)
	,@p_upload_no			nvarchar(50)
	,@p_asset_code			nvarchar(50)
	,@p_licence_no			nvarchar(50)	= ''
	,@p_start_date_license	datetime	= null
	,@p_end_date_license	datetime	= null
	,@p_nominal				decimal	= 0
	,@p_remark				nvarchar(4000)
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
		insert into asset_other_upload
		(
			file_name
			,upload_no
			,asset_code
			,license_no
			,start_date_license
			,end_date_license
			,nominal
			,remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_file_name
			,@p_upload_no
			,@p_asset_code
			,@p_licence_no
			,@p_start_date_license
			,@p_end_date_license
			,@p_nominal
			,@p_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_fa_upload_id = @@identity ;
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
	end catch ;	;
end ;
