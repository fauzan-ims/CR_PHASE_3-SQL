CREATE FUNCTION [dbo].[xfn_get_et_penalty_progressive_by_asset]
(
	@p_asset_no nvarchar(50)
	, @p_date	datetime
)
returns decimal(18, 2)
as
begin

	declare   @propotional_days					decimal(18, 2)
			, @total_days						decimal(18, 2)
			, @due_date							datetime
			, @total_billing_amount				decimal(18, 2) = 0
			, @penalty_progressive_amount		decimal(18, 2) = 0
			, @interim_rental					decimal(18, 0) 
			, @next_duedate						datetime 
			, @billing_no						int
			, @billing_no_max					int
			, @penalty							decimal(18, 2) = 30
			, @termdate							datetime
			, @duedate							datetime
			, @periode							decimal(18, 2)
			, @handover_to_et					decimal(18, 2)
			, @et_to_matur						decimal(18, 2)
			, @daily_term						decimal(18, 2)

			select	top 1 
					 @duedate			= DUE_DATE
					,@termdate			= ET_DATE
					,@handover_to_et	= datediff(month,HANDOVER_BAST_DATE,ET_DATE)
					,@et_to_matur		= datediff(month,ET_DATE,AGREEMENT_INFORMATION.MATURITY_DATE)
					,@periode			= datediff(day, DUE_DATE, dateadd(month, 1, DUE_DATE))
					,@daily_term		= datediff(day, ET_DATE, dateadd(month, 1, DUE_DATE))
			from	dbo.ET_MAIN
					join dbo.ET_DETAIL on ET_DETAIL.ET_CODE		= ET_MAIN.CODE
					join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.ASSET_NO = ET_DETAIL.ASSET_NO
					join dbo.AGREEMENT_INFORMATION on AGREEMENT_INFORMATION.AGREEMENT_NO = AGREEMENT_ASSET.AGREEMENT_NO
					join dbo.AGREEMENT_ASSET_AMORTIZATION on AGREEMENT_ASSET_AMORTIZATION.ASSET_NO = AGREEMENT_ASSET.ASSET_NO
					where ET_STATUS = 'APPROVE'
					and AGREEMENT_ASSET.ASSET_NO = '0000001.4.38.06.2022-1'
					and DUE_DATE < ET_DATE
					order by DUE_DATE desc


			if (@handover_to_et <= 24)
			BEGIN
			select	@penalty_progressive_amount = ((MONTHLY_RENTAL_ROUNDED_AMOUNT-(@daily_term/PERIODE*MONTHLY_RENTAL_ROUNDED_AMOUNT)+@et_to_matur*MONTHLY_RENTAL_ROUNDED_AMOUNT)*30/100)-(3*MONTHLY_RENTAL_ROUNDED_AMOUNT)
			from	dbo.ET_MAIN
					join dbo.ET_DETAIL on ET_DETAIL.ET_CODE		= ET_MAIN.CODE
					join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.ASSET_NO = ET_DETAIL.ASSET_NO
					join dbo.AGREEMENT_INFORMATION on AGREEMENT_INFORMATION.AGREEMENT_NO = AGREEMENT_ASSET.AGREEMENT_NO
					where AGREEMENT_ASSET.ASSET_NO = @p_asset_no
					and ET_STATUS = 'APPROVE'
			end
			else if (@handover_to_et > 24 and @handover_to_et <= 36)
			BEGIN
			select	@penalty_progressive_amount = ((MONTHLY_RENTAL_ROUNDED_AMOUNT-(@daily_term/PERIODE*MONTHLY_RENTAL_ROUNDED_AMOUNT)+@et_to_matur*MONTHLY_RENTAL_ROUNDED_AMOUNT)*30/100)-(2*MONTHLY_RENTAL_ROUNDED_AMOUNT)
			from	dbo.ET_MAIN
					join dbo.ET_DETAIL on ET_DETAIL.ET_CODE		= ET_MAIN.CODE
					join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.ASSET_NO = ET_DETAIL.ASSET_NO
					join dbo.AGREEMENT_INFORMATION on AGREEMENT_INFORMATION.AGREEMENT_NO = AGREEMENT_ASSET.AGREEMENT_NO
					where AGREEMENT_ASSET.ASSET_NO = @p_asset_no
					and ET_STATUS = 'APPROVE'
			end
			else if (@handover_to_et > 36 and @handover_to_et <= 60)
			BEGIN
			select	@penalty_progressive_amount = ((MONTHLY_RENTAL_ROUNDED_AMOUNT-(@daily_term/PERIODE*MONTHLY_RENTAL_ROUNDED_AMOUNT)+@et_to_matur*MONTHLY_RENTAL_ROUNDED_AMOUNT)*30/100)-(2*MONTHLY_RENTAL_ROUNDED_AMOUNT)
			from	dbo.ET_MAIN
					join dbo.ET_DETAIL on ET_DETAIL.ET_CODE		= ET_MAIN.CODE
					join dbo.AGREEMENT_ASSET on AGREEMENT_ASSET.ASSET_NO = ET_DETAIL.ASSET_NO
					join dbo.AGREEMENT_INFORMATION on AGREEMENT_INFORMATION.AGREEMENT_NO = AGREEMENT_ASSET.AGREEMENT_NO
					where AGREEMENT_ASSET.ASSET_NO = @p_asset_no
					and ET_STATUS = 'APPROVE'
			end

	return isnull(@penalty_progressive_amount, 0) ;
end ;
