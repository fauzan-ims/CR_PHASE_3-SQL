CREATE PROCEDURE [dbo].[xsp_asset_replacement_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
BEGIN
	
	declare	@msg		nvarchar(max)
			,@platno NVARCHAR(50);

	begin TRY
		SELECT @platno = av.PLAT_NO
		FROM IFINAMS.dbo.SALE_DETAIL sd
			INNER JOIN IFINAMS.dbo.ASSET ass
				ON (ass.CODE = sd.ASSET_CODE)
			INNER JOIN IFINAMS.dbo.ASSET_VEHICLE av
				ON (av.ASSET_CODE = ass.CODE)
		WHERE av.PLAT_NO IN
			  (
				  SELECT asta.FA_REFF_NO_01
				  FROM ASSET_REPLACEMENT_DETAIL ard
					  LEFT JOIN dbo.AGREEMENT_ASSET asta
						  ON (asta.ASSET_NO = ard.OLD_ASSET_NO)
					  --left join dbo.agreement_asset astb on (astb.asset_no = ard.new_asset_code)
					  LEFT JOIN dbo.SYS_GENERAL_SUBCODE sgs
						  ON (sgs.CODE = ard.REASON_CODE)
				  WHERE ard.REPLACEMENT_CODE IN
						(
							SELECT arm.CODE
							FROM ASSET_REPLACEMENT arm
								INNER JOIN dbo.AGREEMENT_MAIN am
									ON (am.AGREEMENT_NO = arm.AGREEMENT_NO)
							WHERE ard.REPLACEMENT_CODE = @p_code
						)
			  );


		IF EXISTS
		(
			SELECT 1
			FROM IFINAMS.dbo.SALE_DETAIL sd
				INNER JOIN IFINAMS.dbo.ASSET ass
					ON (ass.CODE = sd.ASSET_CODE)
				INNER JOIN IFINAMS.dbo.ASSET_VEHICLE av
					ON (av.ASSET_CODE = ass.CODE)
			WHERE av.PLAT_NO IN
				  (
					  SELECT asta.FA_REFF_NO_01
					  FROM ASSET_REPLACEMENT_DETAIL ard
						  LEFT JOIN dbo.AGREEMENT_ASSET asta
							  ON (asta.ASSET_NO = ard.OLD_ASSET_NO)
						  --left join dbo.agreement_asset astb on (astb.asset_no = ard.new_asset_code)
						  LEFT JOIN dbo.SYS_GENERAL_SUBCODE sgs
							  ON (sgs.CODE = ard.REASON_CODE)
					  WHERE ard.REPLACEMENT_CODE IN
							(
								SELECT arm.CODE
								FROM ASSET_REPLACEMENT arm
									INNER JOIN dbo.AGREEMENT_MAIN am
										ON (am.AGREEMENT_NO = arm.AGREEMENT_NO)
								WHERE ard.REPLACEMENT_CODE = @p_code
							)
				  )
		)
		BEGIN
			SET @msg = N'Assets In Old Asset No Are In the Sales Request Process, For Plat No: ' + ISNULL(@platno, '');
			RAISERROR(@msg, 16, 1);

		END;

		if not exists	(
							select	1 
							from	dbo.asset_replacement_detail 
							where	replacement_code = @p_code

						)
		begin
			set @msg = 'Please input Asset Detail List' ;
			raiserror(@msg, 16, 1) ;
        end
        
		if exists
		(
			select	1
			from	dbo.asset_replacement_detail
			where	replacement_code	   = @p_code
			and		isnull(replacement_type,'') = ''
		)
		begin
			set @msg = 'Please input Replacement Type in Asset Detail List' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.asset_replacement_detail
			where	replacement_code	   = @p_code
			and		isnull(reason_code,'') = ''
		)
		begin
			set @msg = 'Please input Reason in Asset Detail List' ;

			raiserror(@msg, 16, 1) ;
		end ;


		if exists
		(
			select	1
			from	dbo.asset_replacement
			where	code			   = @p_code
			and		status <> 'HOLD'
		)
		begin
			set @msg = 'Data already proceed';
			raiserror(@msg, 16, 1) ;
		end ;

		update	dbo.asset_replacement
		set		status	= 'ON PROCESS'
				--
				,mod_date		= @p_mod_date		
				,mod_by			= @p_mod_by			
				,mod_ip_address	= @p_mod_ip_address
		where	code			= @p_code ;

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
