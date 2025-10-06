
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_delivery_update]
(
	@p_code						nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_register_date			datetime
	,@p_register_status			nvarchar(20)
	,@p_register_remarks		nvarchar(4000)	= ''
	,@p_delivery_date			datetime
	,@p_delivery_receive_by		nvarchar(250)
	,@p_delivery_remarks		nvarchar(4000)	= ''
	,@p_stnk_no					nvarchar(50)	= null
	,@p_stnk_tax_date			datetime		= null
	,@p_stnk_expired_date		datetime		= null
	,@p_keur_no					nvarchar(50)	= null
	,@p_keur_tax_date			datetime		= null
	,@p_keur_expired_date		datetime		= null
	,@p_delivery_to_name		nvarchar(250)	= null
	,@p_delivery_to_phone_area	nvarchar(4)		= null
	,@p_delivery_to_phone_no	nvarchar(15)	= null
	,@p_delivery_to_address		nvarchar(4000)	= null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if (@p_delivery_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Delivery Date must be less than System Date.'
			raiserror(@msg, 16, -1)
		end


		if exists
		(
			select	1
			from	dbo.register_main rm 
			inner join dbo.register_detail rd on rd.register_code = rm.code
			where	rd.service_code in 	(N'PBSPSTN')
					and isnull(rm.stnk_tax_date,'') = ''
					and	isnull(rm.stnk_expired_date,'') = ''
					and isnull(@p_stnk_expired_date,'') = ''
					and isnull(@p_stnk_tax_date,'')=''
					and	rm.code = @p_code

		)
		begin
			SET @msg = 'Please input STNK Date And STNK Expired Date'
			raiserror(@msg, 16, -1)
		end

		if (isnull(@p_keur_expired_date,'')='')
		begin
			--if exists
			--(
			--	select	1
			--	from	dbo.register_main rm 
			--	inner join dbo.register_detail rd on rd.register_code = rm.code
			--	where	rd.service_code in 	('PBSPKEUR')
			--			and	isnull(rm.keur_expired_date,'') = ''
			--			and	rm.code = @p_code

			--)
			--begin
				SET @msg = 'Please input Keur Expiredd Date'
				raiserror(@msg, 16, -1)
			--END
		end

		UPDATE	register_main
		SET		branch_name					= @p_branch_name
				,register_date				= @p_register_date
				,register_status			= @p_register_status
				,register_remarks			= @p_register_remarks
				,delivery_date				= @p_delivery_date
				,delivery_receive_by		= @p_delivery_receive_by
				,delivery_remarks			= @p_delivery_remarks
				,stnk_no					= @p_stnk_no
				,stnk_tax_date				= @p_stnk_tax_date
				,stnk_expired_date			= @p_stnk_expired_date
				,keur_no					= @p_keur_no
				,keur_date					= @p_keur_tax_date
				,keur_expired_date			= @p_keur_expired_date
				,delivery_to_name			= @p_delivery_to_name
				,delivery_to_phone_area		= @p_delivery_to_phone_area
				,delivery_to_phone_no		= @p_delivery_to_phone_no
				,delivery_to_address		= @p_delivery_to_address
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
