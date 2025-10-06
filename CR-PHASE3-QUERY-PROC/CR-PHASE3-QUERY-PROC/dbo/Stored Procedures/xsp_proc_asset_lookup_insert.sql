
-- Stored Procedure

-- Stored Procedure

CREATE procedure [dbo].[xsp_proc_asset_lookup_insert]
(
	@p_id			   bigint = 0 output
	,@p_asset_code	   nvarchar(50)
	,@p_item_code	   nvarchar(50)
	,@p_item_name	   nvarchar(250)
	,@p_plat_no		   nvarchar(50)
	,@p_engine_no	   nvarchar(50)
	,@p_chasis_no	   nvarchar(50)
	,@p_application_no nvarchar(50)
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
		insert into dbo.proc_asset_lookup
		(
			asset_code
			,item_code
			,item_name
			,plat_no
			,engine_no
			,chasis_no
			,application_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_asset_code
			,@p_item_code
			,@p_item_name
			,@p_plat_no
			,@p_engine_no
			,@p_chasis_no
			,@p_application_no
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
