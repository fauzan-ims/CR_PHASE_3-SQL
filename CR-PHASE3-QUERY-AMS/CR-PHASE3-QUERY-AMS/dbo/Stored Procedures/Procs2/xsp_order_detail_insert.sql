CREATE PROCEDURE dbo.xsp_order_detail_insert
(
	@p_id			   bigint = 0 output
	,@p_order_code	   nvarchar(50)
	,@p_register_code  nvarchar(50)
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
	declare @msg						nvarchar(max)
			,@dp_from_customer_amount	decimal(18, 2)
			,@remark					nvarchar(4000)

	begin try
		--select	@dp_from_customer_amount = dp_from_customer_amount
		--from	dbo.register_main
		--where	code = @p_register_code ;

		insert into order_detail
		(
			order_code
			,register_code
			--,dp_from_customer_amount
			--,dp_to_public_service_pct
			,dp_to_public_service
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_order_code
			,@p_register_code
			--,@dp_from_customer_amount
			--,0
			,0
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		--select	@remark = stuff((
		--			  select	distinct
		--						', ' + avh.plat_no + '/' + avh.engine_no + '/' + avh.chassis_no
		--			  from		 dbo.order_detail od
		--						inner join dbo.register_main rmn on (rmn.code collate latin1_general_ci_as = od.register_code)
		--						inner join dbo.asset_vehicle			  avh on (rmn.fa_code = avh.asset_code)
		--			  where		od.order_code = @p_order_code
		--			  for xml path('')
		--		  ), 1, 1, ''
		--		 ) ;

		-- (+) Ari 2023-11-21 ket : get only no pol

		SELECT	@remark = STUFF((
						  SELECT	DISTINCT
									', ' + avh.plat_no 
						  from		dbo.order_detail od WITH (NOLOCK)
									INNER JOIN dbo.register_main rmn WITH (NOLOCK) ON (rmn.code COLLATE latin1_general_ci_as = od.register_code)
									INNER JOIN dbo.asset_vehicle avh WITH (NOLOCK) ON (rmn.fa_code = avh.asset_code)
						  WHERE		od.order_code = @p_order_code
						  FOR XML PATH('')
					  ), 1, 1, ''
					 ) ;

		update dbo.order_main
		set		asset			 = ISNULL(@remark,'')
				--
				,mod_date		 = @p_mod_date
				,mod_by			 = @p_mod_by
				,mod_ip_address	 = @p_cre_ip_address
		where	code = @p_order_code

		update	dbo.register_main
		set		order_code		 = @p_order_code
				,order_status	 = 'HOLD'
				,register_status = 'ORDER'
				--
				,mod_date		 = @p_mod_date
				,mod_by			 = @p_mod_by
				,mod_ip_address	 = @p_cre_ip_address
		where	code = @p_register_code

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


