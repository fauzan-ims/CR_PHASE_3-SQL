
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_insert]
(
	@p_id					 int output
	,@p_final_grn_request_no nvarchar(50)
	,@p_asset_no			 nvarchar(50)
	,@p_delivery_to			 nvarchar(250)
	,@p_year				 nvarchar(50)
	,@p_colour				 nvarchar(50)
	,@p_po_code_asset		 nvarchar(50)
	,@p_grn_code_asset		 nvarchar(50)
	,@p_grn_detail_id_asset	 int
	,@p_supplier_name_asset	 nvarchar(250)
	,@p_grn_receive_date	 datetime
	,@p_status				 nvarchar(50)
	,@p_plat_no				 nvarchar(50)
	,@p_engine_no			 nvarchar(50)
	,@p_chasis_no			 nvarchar(40)
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
	,@p_grn_po_detail_id	bigint =0
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.final_grn_request_detail
		(
			final_grn_request_no
			,asset_no
			,delivery_to
			,year
			,colour
			,po_code_asset
			,grn_code_asset
			,grn_detail_id_asset
			,supplier_name_asset
			,grn_receive_date
			,plat_no
			,engine_no
			,chasis_no
			,status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,grn_po_detail_id
		)
		values
		(
			@p_final_grn_request_no
			,@p_asset_no
			,@p_delivery_to
			,@p_year
			,@p_colour
			,@p_po_code_asset
			,@p_grn_code_asset
			,@p_grn_detail_id_asset
			,@p_supplier_name_asset
			,@p_grn_receive_date
			,@p_plat_no
			,@p_engine_no
			,@p_chasis_no
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_grn_po_detail_id
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
