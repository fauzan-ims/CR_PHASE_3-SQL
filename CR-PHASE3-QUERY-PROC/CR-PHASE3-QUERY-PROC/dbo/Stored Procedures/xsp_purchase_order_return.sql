CREATE PROCEDURE [dbo].[xsp_purchase_order_return]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@id bigint ;

	begin try

		--if exists
		--(
		--	select	1
		--	from	dbo.purchase_order
		--	where	code	   = @p_code
		--			and status = 'ON PROCESS'
		--)
		--begin
		--	update	dbo.purchase_order
		--	set		status			= 'HOLD'
		--			--
		--			,mod_date		= @p_mod_date
		--			,mod_by			= @p_mod_by
		--			,mod_ip_address = @p_mod_ip_address
		--	where	code			= @p_code ;
		--end ;
		--else
		--begin
		--	set @msg = 'Data already process' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;
		if exists
		(
			select	1
			from	dbo.purchase_order
			where	code	   = @p_code
					and status = 'APPROVE'
		)
		begin
			if not exists
			(
				select	1
				from	dbo.GOOD_RECEIPT_NOTE
				where	PURCHASE_ORDER_CODE = @p_code
						and STATUS			<> 'CANCEL'
			)
			begin
				update	dbo.purchase_order
				set		status			= 'HOLD'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code = @p_code ;

				--declare cursor_name cursor fast_forward read_only for
				--select	supplier_selection_detail_id
				--from	dbo.purchase_order_detail
				--where	po_code = @p_code ;

				--open cursor_name ;

				--fetch next from cursor_name
				--into @id ;

				--while @@fetch_status = 0
				--begin
				--	update	dbo.supplier_selection_detail
				--	set		supplier_selection_detail_status	= 'HOLD'
				--			--
				--			,mod_date							= @p_mod_date
				--			,mod_by								= @p_mod_by
				--			,mod_ip_address						= @p_mod_ip_address
				--	where	id = @id ;

				--	fetch next from cursor_name
				--	into @id ;
				--end ;

				--close cursor_name ;
				--deallocate cursor_name ;
			end ;
			else
			begin
				set @msg = N'Data already exist in Good Receipt Note.' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else
		begin
			set @msg = N'Data already process' ;

			raiserror(@msg, 16, 1) ;
		end ;
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
