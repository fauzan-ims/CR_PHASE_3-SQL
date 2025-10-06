
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_delivery_result_update]
(
	@p_code						nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_register_date			datetime
	,@p_register_status			nvarchar(20)
	--,@p_register_process_by	 nvarchar(50)
	,@p_register_remarks		nvarchar(4000)	= ''
	--,@p_delivery_date			datetime		
	--,@p_delivery_receive_by		nvarchar(250)
	--,@p_delivery_remarks		nvarchar(4000)
	,@p_stnk_no					nvarchar(50)	= null
	,@p_stnk_tax_date			datetime		= null
	,@p_stnk_expired_date		datetime		= null
	,@p_keur_no					nvarchar(50)	= null
	,@p_keur_date				datetime		= NULL
	,@p_keur_expired_date		datetime		= null
	,@p_receive_date			datetime		= null
	,@p_receive_by				nvarchar(250)	= null
	,@p_receive_remarks			nvarchar(4000)	= null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if (@p_receive_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Receive Date must be less than System Date.'
			raiserror(@msg, 16, -1)
		end


		if exists
		(
			select	1
			from	dbo.register_main rm 
			inner join dbo.register_detail rd on rd.register_code = rm.code
			where	rd.service_code in 	(N'PBSPSTN')
					and	rm.code = @p_code

		)
		BEGIN
        if ((isnull(@p_stnk_tax_date,'')='') or (ISNULL(@p_stnk_expired_date,'')=''))
			begin
				SET @msg = 'Please input STNK Date And STNK Expired Date'
				raiserror(@msg, 16, -1)
			end
		end


		if exists
		(
			select	1
			from	dbo.register_main rm 
			inner join dbo.register_detail rd on rd.register_code = rm.code
			where	rd.service_code in 	(N'PBSPKEUR')
					and	rm.code = @p_code

		)
		begin
			if (isnull(@p_keur_expired_date,'')='')
			BEGIN
				SET @msg = 'Please input Keur Expired Date'
				raiserror(@msg, 16, -1)
			END
		END

		update	register_main
		set		branch_name					= @p_branch_name
				,register_date				= @p_register_date
				,register_status			= @p_register_status
				--,register_process_by		= @p_register_process_by
				,register_remarks			= @p_register_remarks
				--,delivery_date				= @p_delivery_date
				--,delivery_receive_by		= @p_delivery_receive_by
				--,delivery_remarks			= @p_delivery_remarks
				,receive_date				= @p_receive_date
				,receive_by					= @p_receive_by
				,receive_remarks			= @p_receive_remarks
				,stnk_no					= @p_stnk_no
				,stnk_tax_date				= @p_stnk_tax_date
				,stnk_expired_date			= @p_stnk_expired_date
				,keur_no					= @p_keur_no
				,keur_date					= @p_keur_date
				,keur_expired_date			= @p_keur_expired_date			
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
