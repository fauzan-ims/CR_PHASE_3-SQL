CREATE PROCEDURE dbo.xsp_procurement_unpost
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@quotation_review_code nvarchar(50)
			,@selection_code		nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.quotation_review_detail	   qrd
					left join dbo.quotation_review qr on (qr.code collate Latin1_General_CI_AS = qrd.quotation_review_code)
			where	reff_no		  = @p_code
					and qr.status = 'HOLD'
		)
		begin
			select		@quotation_review_code = quotation_review_code
			--,@count_quotation_review_detail = count(quotation_review_code)
			from		dbo.quotation_review_detail
			where		reff_no = @p_code
			group by	quotation_review_code ;

			-- delete detail
			delete	dbo.quotation_review_detail
			where	reff_no = @p_code ;

			-- delete header
			delete	dbo.quotation_review
			where	code = @quotation_review_code ;
		--end ;
		end ;
		--else
		--begin
		--	set @msg = 'Data already useddddddd.';
		--	raiserror(@msg ,16,-1);
		--end
		else if exists
		(
			select	1
			from	dbo.supplier_selection_detail	 ssd
					left join dbo.supplier_selection ss on (ss.code = ssd.selection_code)
			where	reff_no		  = @p_code
					and ss.status = 'HOLD'
		)
		begin
			select	@selection_code = selection_code
			--,@count_supplier_selection_detail = count(supplier_code)
			from	dbo.supplier_selection_detail
			where	reff_no = @p_code ;

			-- delete detail
			delete	dbo.supplier_selection_detail
			where	reff_no = @p_code ;

			if not exists
			(
				select	1
				from	dbo.supplier_selection_detail
				where	selection_code = @selection_code
			)
			begin
				delete dbo.supplier_selection_document
				where supplier_selection_code  = @selection_code

				-- delete header
				--delete	dbo.supplier_selection
				--where	code = @selection_code ;

				update	dbo.supplier_selection
				set		status			= 'CANCEL'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code = @selection_code ;
			end ;
		end ;
		else
		begin
			set @msg = N'Data already used.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	procurement
		set		status				= 'HOLD'
				,purchase_type_code = ''
				,purchase_type_name = ''
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code = @p_code ;
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
