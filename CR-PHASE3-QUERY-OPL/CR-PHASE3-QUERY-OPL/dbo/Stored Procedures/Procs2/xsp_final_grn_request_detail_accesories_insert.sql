
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_accesories_insert]
(
	@p_id									   bigint = 0 output
	,@p_final_grn_request_detail_id			   int
	,@p_application_no						   nvarchar(50)
	,@p_final_grn_request_detail_accesories_id int
	--
	,@p_cre_date							   datetime
	,@p_cre_by								   nvarchar(15)
	,@p_cre_ip_address						   nvarchar(15)
	,@p_mod_date							   datetime
	,@p_mod_by								   nvarchar(15)
	,@p_mod_ip_address						   nvarchar(15)
	,@p_grn_po_detail_id						bigint = 0

)
as
begin
	declare @msg nvarchar(max) 
			,@item_code	NVARCHAR(50);

	begin TRY

		--select	@item_code = item_code 
		--from	dbo.final_grn_request_detail_accesories_lookup 
		--where	id = @p_final_grn_request_detail_accesories_id

		--if not exists
		--(
		--	select	1 
		--	from	dbo.final_grn_request_detail_accesories a
		--	inner join dbo.final_grn_request_detail_accesories_lookup b on  b.id = a.final_grn_request_detail_accesories_id
		--	where	a.final_grn_request_detail_id = @p_final_grn_request_detail_id and b.item_code = @item_code
		--)
		declare @grn_po_detail_id nvarchar(50)

		select	@grn_po_detail_id	= grn_po_detail_id
		from	final_grn_request_detail_accesories_lookup
		where	id = @p_final_grn_request_detail_accesories_id ;

		begin

			insert into dbo.final_grn_request_detail_accesories
			(
				final_grn_request_detail_id
				,application_no
				,final_grn_request_detail_accesories_id
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
				@p_final_grn_request_detail_id
				,@p_application_no
				,@p_final_grn_request_detail_accesories_id
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@grn_po_detail_id
			) ;

			set @p_id = @@identity ;

		END;
		--ELSE
  --      begin
		--	set @msg = 'Cannot entered The same item'
		--	raiserror (@msg, 16, -1)
  --      end

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
