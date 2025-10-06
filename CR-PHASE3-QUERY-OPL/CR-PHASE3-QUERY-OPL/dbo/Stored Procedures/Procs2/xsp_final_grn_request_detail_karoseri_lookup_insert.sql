
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_karoseri_lookup_insert]
(
	@p_id									 bigint = 0 output
	,@p_po_no								 nvarchar(50)
	,@p_grn_code							 nvarchar(50)
	,@p_grn_detail_id						 bigint
	,@p_item_code							 nvarchar(50)
	,@p_item_name							 nvarchar(250)
	,@p_supplier_name						 nvarchar(250)
	,@p_application_no						 nvarchar(50)
	--
	,@p_cre_date							 datetime
	,@p_cre_by								 nvarchar(15)
	,@p_cre_ip_address						 nvarchar(15)
	,@p_mod_date							 datetime
	,@p_mod_by								 nvarchar(15)
	,@p_mod_ip_address						 nvarchar(15)
	,@p_grn_po_detail_id					bigint = 0
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.final_grn_request_detail_karoseri_lookup
		(
			application_no
			,po_no
			,grn_code
			,grn_detail_id
			,item_code
			,item_name
			,supplier_name
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
			@p_application_no
			,@p_po_no
			,@p_grn_code
			,@p_grn_detail_id
			,@p_item_code
			,@p_item_name
			,@p_supplier_name
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
