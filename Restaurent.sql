USE [TTDC_Restaurant]
GO
/****** Object:  StoredProcedure [dbo].[addAddOnsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addAddOnsData](
								@AddOnsName VARCHAR(100),
								@CreatedBy INT,
								@ImageLink NVARCHAR(150),
								@RestaurantId INT,
								@AddOnsType VARCHAR(10)=NULL,
								@Tariff DECIMAL(9,2)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM AddOns WHERE AddOnsName = @AddOnsName)
		BEGIN
			INSERT INTO AddOns(AddOnsName,ActiveStatus,CreatedBy,ImageLink,RestaurantId,AddOnsType,Tariff) 
			VALUES (@AddOnsName,'A',@CreatedBy,@ImageLink,@RestaurantId,@AddOnsType,@Tariff)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'AddOns name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addAddOnsMapData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addAddOnsMapData](@FoodId INT,
									@AddOnsId NVARCHAR(100),
									@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT AddOnsMap.FoodId FROM AddOnsMap WHERE FoodId=@FoodId)
		BEGIN
			INSERT INTO AddOnsMap(FoodId,AddOnsId,CreatedBy)
			VALUES(@FoodId,@AddOnsId,@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		 END
				
		
	ELSE
		BEGIN
			SELECT 'Trying to add duplicate record.',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addAllItems]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addAllItems](@RestaurantId INT,
								      @CreatedBy INT,
								      @FoodItems NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @subFoodId INT;

	DECLARE	@tempTab TABLE(FoodId INT							
							);
	BEGIN TRAN


	 INSERT INTO @tempTab SELECT FoodId
							FROM OPENJSON(@FoodItems)
								WITH (FoodId INT '$.FoodId'	
										)
		IF @@ROWCOUNT > 0
			BEGIN
			DECLARE allItemsCursor CURSOR FAST_FORWARD FOR
			SELECT * FROM @tempTab
				OPEN allItemsCursor
				FETCH NEXT FROM allItemsCursor INTO @subFoodId
				WHILE @@FETCH_STATUS = 0
					BEGIN
						IF NOT EXISTS (SELECT * FROM AllItems WHERE FoodId=@subFoodId AND RestaurantId=@RestaurantId AND ActiveStatus='A')
							BEGIN
								INSERT INTO AllItems (RestaurantId,FoodId,ActiveStatus,CreatedBy,CreatedDate) 
										VALUES (@RestaurantId,@subFoodId,'A',@CreatedBy,GETDATE())
								IF @@ROWCOUNT=0
									BEGIN
										SELECT 'Data Not Added', 0
										IF @@ROWCOUNT=0
										BEGIN
											ROLLBACK
										END
									END
							END
										


						FETCH NEXT FROM allItemsCursor INTO @subFoodId
					END
					CLOSE allItemsCursor
					DEALLOCATE allItemsCursor
			IF @@TRANCOUNT > 0
				BEGIN
					SELECT 'Data Added Successfully', 1
					COMMIT
				END
				
					
				
					
			END
		ELSE
			BEGIN
				SELECT 'Data Not Added', 0
				ROLLBACK
			END



IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[addBookingTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addBookingTypeData](@RestaurantId INT=NULL,
								@BookingType NVARCHAR(20)=NULL,
								@CreatedBy int)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM BookingTypeMaster WHERE BookingType = @BookingType AND RestaurantId=@RestaurantId)
		BEGIN
			INSERT INTO BookingTypeMaster (RestaurantId,BookingType,ActiveStatus,CreatedBy,CreatedDate)
			VALUES(@RestaurantId,@BookingType,'A',@CreatedBy,GETDATE())
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Booking type already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addBuffetData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addBuffetData](
								@RestaurantId INT,
								@BuffetName NVARCHAR(50),
								@FoodItems VARCHAR(Max),
								@FromDate DATE,
								@ToDate DATE,
								@BuffetTimings VARCHAR(50),
								@Tariff DECIMAL(9,2),
								@Createdby INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM BuffetMaster WHERE RestaurantId=@RestaurantId AND BuffetName = @BuffetName)
		BEGIN
			INSERT INTO BuffetMaster(RestaurantId,BuffetName,FoodItems,FromDate,ToDate,BuffetTimings,Tariff,ActiveStatus,Createdby) 
			VALUES (@RestaurantId,@BuffetName,@FoodItems,@FromDate,@ToDate,@BuffetTimings,@Tariff,'A', @Createdby)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Buffet name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addTaxMaster 'Restaurant','SSGST',NULL,'2023-03-28',NULL,NULL,NULL,1001
GO
/****** Object:  StoredProcedure [dbo].[addComplementaryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addComplementaryData](@RestaurantId INT,
											@FoodTimingId INT,
											@FoodId VARCHAR(100)=NULL,
											@CreatedBy INT
											)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM ComplementaryMaster WHERE FoodTimingId = @FoodTimingId AND RestaurantId=@RestaurantId)
		BEGIN
			INSERT INTO ComplementaryMaster (RestaurantId,FoodTimingId,FoodId,CreatedBy,ActiveStatus)
			VALUES(@RestaurantId,@FoodTimingId,@FoodId,@CreatedBy,'A')
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'FoodTiming Id already exists! Please Update the data.',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addConfigMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addConfigMasterData](
								@TypeId INT,
								@ConfigName NVARCHAR(150),
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM ConfigurationMaster WHERE ConfigName = @ConfigName AND TypeId=@TypeId)
		BEGIN
			INSERT INTO ConfigurationMaster (TypeId,ConfigName,ActiveStatus,CreatedBy) VALUES (@TypeId,@ConfigName,'A', @CreatedBy)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Config Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addTaxMaster 'Restaurant','SSGST',NULL,'2023-03-28',NULL,NULL,NULL,1001
GO
/****** Object:  StoredProcedure [dbo].[addConfigTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addConfigTypeData](
								@TypeName NVARCHAR(150),
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM ConfigurationType WHERE TypeName = @TypeName)
		BEGIN
			INSERT INTO ConfigurationType (TypeName,ActiveStatus, Createdby) VALUES (@TypeName,'A', @CreatedBy)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Type Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addTaxMaster 'Restaurant','SSGST',NULL,'2023-03-28',NULL,NULL,NULL,1001
GO
/****** Object:  StoredProcedure [dbo].[addDinningData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addDinningData](
								@RestaurantId INT,
								@DinningType NVARCHAR(20),
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM DinningMaster WHERE DinningType = @DinningType and RestaurantId=@RestaurantId)
		BEGIN
			INSERT INTO DinningMaster(RestaurantId,DinningType,CreatedBy,ActiveStatus) 
			VALUES (@RestaurantId,@DinningType,@CreatedBy,'A')
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Dinning type already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addDinningTableData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addDinningTableData](
								@DinningId INT,
								@TableName NVARCHAR(20),
								@ChairCount INT,
								@CreatedBy INT,
								@RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM DinningTableMaster WHERE DinningId = @DinningId and RestaurantId=@RestaurantId and TableName=@TableName)
		BEGIN
			INSERT INTO DinningTableMaster(DinningId,TableName,ChairCount,ActiveStatus,CreatedBy,RestaurantId) 
			VALUES (@DinningId,@TableName,@ChairCount,'A',@CreatedBy,@RestaurantId)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Table Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addFoodCategoryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addFoodCategoryData](
								@RestaurantId INT,
								@FoodCategoryName VARCHAR(100),
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM FoodCategoryMaster WHERE RestaurantId=@RestaurantId AND FoodCategoryName = @FoodCategoryName)
		BEGIN
			INSERT INTO FoodCategoryMaster(RestaurantId,FoodCategoryName,ActiveStatus,Createdby) 
			VALUES (@RestaurantId,@FoodCategoryName,'A', @CreatedBy)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Food category name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addFoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addFoodData](
								@RestaurantId INT,
								@FoodName VARCHAR(100),
								@Description NVARCHAR(250)=NULL,
								@FoodCategoryId INT,
								@ImageLink NVARCHAR(150)=NULL,
								@CreatedBy INT,
								@FoodTimingId VARCHAR(30))

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM FoodMaster WHERE RestaurantId=@RestaurantId AND FoodName = @FoodName)
		BEGIN
			INSERT INTO FoodMaster(RestaurantId,FoodName,Description,FoodCategoryId,ImageLink,ActiveStatus,Createdby,FoodTimingId) 
			VALUES (@RestaurantId,@FoodName,@Description,@FoodCategoryId,@ImageLink,'A', @CreatedBy,@FoodTimingId)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1,(SELECT FoodId,FoodName FROM FoodMaster WHERE RestaurantId=@RestaurantId AND FoodName = @FoodName AND  FoodCategoryId=@FoodCategoryId FOR JSON PATH, INCLUDE_NULL_VALUES)
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Food name already exists!',0,(SELECT FoodId,FoodName FROM FoodMaster WHERE RestaurantId=@RestaurantId AND FoodName = @FoodName AND  FoodCategoryId=@FoodCategoryId FOR JSON PATH, INCLUDE_NULL_VALUES)
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addFoodItemsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addFoodItemsData](@RestaurantId INT,
											@BarId INT,
											@FoodItems VARCHAR(100),
											@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * from MapFoodItemsToBar where BarId=@BarId and RestaurantId=@RestaurantId )
		BEGIN
			INSERT INTO MapFoodItemsToBar (RestaurantId,BarId,FoodItems,ActiveStatus,CreatedBy) 
			VALUES (@RestaurantId, @BarId,@FoodItems,'A',@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Trying to add duplicate record.',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addFoodQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addFoodQuantityData](
								@FoodId INT,
								@FoodQuantityId INT=NULL,
								@CreatedBy INT,
								@Tariff DECIMAL(9,2),
								@RestaurantId INT,
								@FoodCategoryId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM FoodQuantityMaster WHERE FoodQuantityMaster.RestaurantId=@RestaurantId AND FoodQuantityMaster.FoodId=@FoodId AND (FoodQuantityMaster.FoodQuantityId=@FoodQuantityId OR FoodQuantityMaster.FoodQuantityId IS NULL))
		BEGIN
			INSERT INTO FoodQuantityMaster(FoodId,FoodQuantityId,ActiveStatus,CreatedBy,Tariff,RestaurantId,FoodCategoryId) 
			VALUES (@FoodId,@FoodQuantityId,'A',@CreatedBy,@Tariff,@RestaurantId,@FoodCategoryId)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Trying to add duplicate record.',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addFoodTimingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addFoodTimingData](
								@RestaurantId INT,
								@FoodTimingName VARCHAR(50),
								@FoodTimingId INT,
								@StartTime DATETIME,
								@EndTime DATETIME,
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM FoodTimingMaster WHERE FoodTimingId = @FoodTimingId and RestaurantId=@RestaurantId)
		BEGIN
			INSERT INTO FoodTimingMaster(RestaurantId,FoodTimingName,FoodTimingId,StartTime,EndTime,ActiveStatus,Createdby) 
			VALUES (@RestaurantId,@FoodTimingName,@FoodTimingId,@StartTime,@EndTime,'A', @CreatedBy)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END			
		END
	ELSE
		BEGIN
			SELECT 'Food Timing name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addItemIssHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addItemIssHdrDtlData](
								@IssueDate DATE,
								@RestaurantId INT,
								@IssueRef NVARCHAR(100)=NULL,
								@ActiveStatus CHAR(1)=NULL,
								@CreatedBy INT,
								@ItemId INT,
								@IssuedQty DECIMAL(9,3)=NULL,
								@IssueRate DECIMAL(9,2)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO ItemIssHdr (IssueDate, RestaurantId, IssueRef, ActiveStatus, CreatedBy)
			VALUES (@IssueDate, @RestaurantId, @IssueRef, @ActiveStatus, @CreatedBy) 
			IF @@ROWCOUNT>0
				BEGIN
					INSERT INTO ItemIssDtl (IssueId,ItemId,IssuedQty,IssueRate)
					VALUES ((SELECT MAX (IssueId) as IssueId FROM ItemIssHdr),@ItemId,@IssuedQty,@IssueRate)
					IF @@ROWCOUNT>0
						BEGIN
							SELECT 'Data Added Successfully',1
							COMMIT
						END

					ELSE
						BEGIN
							SELECT 'Data Not Added',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
								
	

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addItemMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addItemMaster](@ItemDescription NVARCHAR(100),
								@ItemType INT,
								@RestaurantId INT,
								@UOM INT,
								@ItemRate DECIMAL(9,2)=NULL,
								@OpeningQty DECIMAL(12,3)=NULL,
								@ReceivedQty DECIMAL(12,3)=NULL,
								@IssuedQty DECIMAL(12,3)=NULL,
								@BalanceQty DECIMAL(12,3)=NULL,
								@ActiveStatus CHAR(1)=NULL, 
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
		BEGIN
			INSERT INTO ItemMaster (ItemDescription, ItemType, RestaurantId, UOM, ItemRate, OpeningQty, ReceivedQty, IssuedQty, BalanceQty,ActiveStatus, CreatedBy) 
			VALUES (@ItemDescription, @ItemType, @RestaurantId, @UOM, @ItemRate, @OpeningQty, @ReceivedQty, @IssuedQty, @BalanceQty, @ActiveStatus, @CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addItemPurHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addItemPurHdrDtlData](
								@PurchaseDate DATE,
								@RestaurantId INT,
								@VendorId INT,
								@VendorRef NVARCHAR(100)=NULL,
								@ActiveStatus CHAR(1)=NULL,
								@CreatedBy INT,
								@ItemId INT,
								@ReceivedQty DECIMAL(9,3)=NULL,
								@AcceptedQty DECIMAL(9,3)=NULL,
								@RejectedQty DECIMAL(9,3)=NULL,
								@RejectionReason NVARCHAR(150)=NULL,
								@PurchaseRate DECIMAL(9,2)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO ItemPurHdr (PurchaseDate, RestaurantId, VendorId, VendorRef, ActiveStatus, CreatedBy) 
			VALUES (@PurchaseDate, @RestaurantId,@VendorId, @VendorRef, @ActiveStatus, @CreatedBy) 
			IF @@ROWCOUNT>0
				BEGIN
					INSERT INTO ItemPurDtl (PurchaseId,ItemId, ReceivedQty,AcceptedQty, RejectedQty,RejectionReason,PurchaseRate)
					VALUES ((SELECT MAX (PurchaseId) as PurchaseId FROM ItemPurHdr),@ItemId,@ReceivedQty,@AcceptedQty,@RejectedQty,@RejectionReason,@PurchaseRate)
					IF @@ROWCOUNT>0
						BEGIN
							SELECT 'Data Added Successfully',1
							COMMIT
						END

					ELSE
						BEGIN
							SELECT 'Data Not Added',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
								
	

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addOfferMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addOfferMaster](@OfferType CHAR(1),
								@OfferCategory INT,
								@OfferName NVARCHAR(100),
								@AmountType CHAR(1),
								@Offer DECIMAL(9,2),
								@MinBIllAmount DECIMAL(9,2)=NULL,
								@EffectiveFrom DATE,
								@EffectiveTill DATE=NULL,
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM OfferMaster WHERE OfferName = @OfferName)
		BEGIN
			INSERT INTO OfferMaster (OfferType,OfferCategory,OfferName,AmountType,Offer,MinBIllAmount,EffectiveFrom,EffectiveTill,ActiveStatus,CreatedBy,CreatedDate)
			VALUES(@OfferType,@OfferCategory,@OfferName,@AmountType,@Offer,@MinBIllAmount,@EffectiveFrom,@EffectiveTill,'A',@CreatedBy,GETDATE())
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Offer name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addOrderHeaderDetails]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE TTDC_Restaurant
CREATE PROCEDURE [dbo].[addOrderHeaderDetails] 
						(@BookingMedia CHAR(1),
						 @BookingStatus CHAR(1) ,
						 @CreatedBy INT,
						 @CustomerId INT ,
						 @BillAmount DECIMAL(9,2),
						 @TaxAmount DECIMAL(9,2),
						 @NetAmount DECIMAL(9,2),
						 @OrderDate DATETIME,
						 @RestaurantId INT ,
						 @OrderDetails NVARCHAR(MAX)=NULL,
						 @OfferAmount DECIMAL(9,2)=0,
						 @OfferId INT =NULL,
						 @PaymentType INT=NULL,
						 @PaymentStatus CHAR(1),
						 @TableId VARCHAR(100)=NULL,
						 @DinningId INT=NULL,
						 @BookedChairs VARCHAR(250)=NULL,
						 @TableStatus CHAR(1)=NULL,
						 @SoftDrinkDetails NVARCHAR(MAX)=NULL,
						 @BookingType NVARCHAR(100),
						 @GuestName NVARCHAR(100)=NULL,
						 @GuestMobile NVARCHAR(10)=NULL,
						 @GuestMailId NVARCHAR(50)=NULL,
						 @CustomerGSTNo NVARCHAR(15)=NULL)
AS
BEGIN
	DECLARE @OrderHeaderSl INT;

	DECLARE @OrderDetailsTab TABLE ( FoodId INT ,
									OrderTime time(7),
									FoodVarietyId INT NULL,
									OrderQuantity INT ,
									BuffetId INT NULL,
									BookingType VARCHAR(20),
									Tariff DECIMAL(9,2),
									NetTariff DECIMAL(9,2), 
									ComplementaryId INT NULL,
									WaiterId INT NULL);

	DECLARE @SoftDrinkDetailsTab TABLE (SoftDrinkId INT,
									  SoftDrinkQuantityId varchar(100),
									  OrderQuantity INT,
									  Tariff DECIMAL(9,2),
									  OrderTime TIME(7),
									  BookingType VARCHAR(20),
									  WaiterId INT NULL,
									  NetTariff DECIMAL(9,2));

	DECLARE @subFoodId INT,
			@subOrderTime TIME,
			@subFoodVarietyId INT,
			@subOrderQuantity INT,
			@subBuffetId INT,
			@subBookingType VARCHAR(20),
			@subTariff DECIMAL(9,2),
			@subNetTariff DECIMAL(9,2),
			@subComplementaryId INT,
			@subWaiterId INT,
			@SoftDrinkId INT ,
			@SoftDrinkQuantityId varchar(100),
			@tempId INT,
			@remainingAmount INT,
			@issuedQty INT

	DECLARE @OrderId INT= CAST( (CAST(ISNULL((SELECT TOP 1 OrderId FROM OrderHeader WHERE RestaurantId = @RestaurantId AND CAST(OrderDate AS DATE) = CAST(GETDATE() as DATE) ORDER BY CreatedDate DESC),0) AS INT ) + 1) AS VARCHAR(20))

	INSERT INTO OrderHeader(RestaurantId ,DinningId ,TableId ,BookedChairs ,TableStatus ,OrderId  ,OrderDate ,CustomerId ,BookingType ,GuestName ,GuestMobile ,GuestMailId
							  ,CustomerGSTNo ,OfferId ,PaymentType ,BillAmount ,OfferAmount ,TaxAmount ,NetAmount ,BookingMedia ,BookingStatus ,PaymentStatus ,CreatedBy ,CreatedDate )
		VALUES(@RestaurantId ,@DinningId ,@TableId ,@BookedChairs ,@TableStatus ,@OrderId ,@OrderDate ,@CustomerId ,@BookingType ,@GuestName ,@GuestMobile ,@GuestMailId,@CustomerGSTNo ,
				@OfferId ,@PaymentType ,@BillAmount ,@OfferAmount ,@TaxAmount ,@NetAmount ,@BookingMedia ,@BookingStatus ,@PaymentStatus ,@CreatedBy ,GETDATE())
	IF @@ROWCOUNT > 0
		BEGIN
			SET @OrderHeaderSl = (SELECT TOP 1 OrderHeaderSl FROM OrderHeader ORDER BY OrderHeaderSl DESC)
			IF @OrderDetails IS NOT NULL
				BEGIN
					INSERT INTO @OrderDetailsTab ( FoodId ,OrderTime ,FoodVarietyId ,OrderQuantity ,BuffetId ,BookingType ,Tariff ,NetTariff ,ComplementaryId ,WaiterId ) 
						SELECT FoodId ,OrderTime ,FoodVarietyId ,OrderQuantity ,BuffetId ,BookingType ,Tariff ,NetTariff ,ComplementaryId ,WaiterId 
							FROM OPENJSON (@OrderDetails )
								WITH (FoodId INT '$.FoodId',
										OrderTime TIME '$.OrderTime',
										  FoodVarietyId INT '$.FoodVarietyId',
										  Tariff DECIMAL(9,2) '$.Tariff',
										  OrderQuantity INT '$.OrderQuantity',
										  NetTariff DECIMAL(9,2) '$.NetTariff',
										  WaiterId INT '$.WaiterId',
										  BookingType VARCHAR(20) '$.BookingType',
										  BuffetId INT '$.BuffetId',
										  ComplementaryId INT '$.ComplementaryId')
					
					DECLARE OrderDetailsCur CURSOR FAST_FORWARD FOR
						SELECT * FROM @OrderDetailsTab

					OPEN OrderDetailsCur
					FETCH NEXT FROM OrderDetailsCur INTO @subFoodId ,@subOrderTime ,@subFoodVarietyId ,@subOrderQuantity ,@subBuffetId ,@subBookingType ,
															@subTariff ,@subNetTariff ,@subComplementaryId ,@subWaiterId

					WHILE @@FETCH_STATUS = 0
						BEGIN
							INSERT INTO OrderDetails (FoodId ,OrderTime ,FoodVarietyId ,OrderQuantity ,BuffetId ,BookingType ,Tariff ,NetTariff ,ComplementaryId ,WaiterId ,
														OrderHeaderSl, RestaurantId, TableId, OrderDate, BookedChairs, CGST, SGST, OrderId, BookingStatus, CreatedBy, CustomerId)
								VALUES(@subFoodId ,@subOrderTime ,@subFoodVarietyId ,@subOrderQuantity ,@subBuffetId ,@subBookingType ,@subTariff ,@subNetTariff ,
											@subComplementaryId ,@subWaiterId ,@OrderHeaderSl, @RestaurantId, @TableId, GETDATE(), @BookedChairs, 
											ISNULL((SELECT TOP 1 TaxPercentage FROM TaxMasterData WHERE TaxDescription = 'CGST'),0), 
											ISNULL((SELECT TOP 1 TaxPercentage FROM TaxMasterData WHERE TaxDescription = 'SGST'),0), @OrderId, @BookingStatus, @CreatedBy, @CustomerId)
							IF @@ROWCOUNT = 0
								BEGIN
									SELECT 'Data Not Inserted', 0
									ROLLBACK
								END


							FETCH NEXT FROM OrderDetailsCur INTO @subFoodId ,@subOrderTime ,@subFoodVarietyId ,@subOrderQuantity ,@subBuffetId ,@subBookingType ,
															@subTariff ,@subNetTariff ,@subComplementaryId ,@subWaiterId
						END
					CLOSE OrderDetailsCur
					DEALLOCATE OrderDetailsCur

				END
		IF @SoftDrinkDetails IS NOT NULL
				BEGIN
					INSERT INTO @SoftDrinkDetailsTab ( SoftDrinkId ,SoftDrinkQuantityId ,OrderQuantity ,Tariff ,OrderTime ,BookingType ,WaiterId ,NetTariff ) 
						SELECT SoftDrinkId ,SoftDrinkQuantityId ,OrderQuantity ,Tariff ,OrderTime ,BookingType ,WaiterId ,NetTariff
							FROM OPENJSON (@SoftDrinkDetails )
								WITH (SoftDrinkId INT '$.SoftDrinkId',
										SoftDrinkQuantityId varchar(100) '$.SoftDrinkQuantityId',
										  Tariff DECIMAL(9,2) '$.Tariff',
										  OrderQuantity INT '$.OrderQuantity',
										  NetTariff DECIMAL(9,2) '$.NetTariff',
										  WaiterId INT '$.WaiterId',
										  OrderTime TIME(7) '$.OrderTime',
										  BookingType VARCHAR(20) '$.BookingType')

					
					DECLARE SoftDetailsCur CURSOR FAST_FORWARD FOR
						SELECT * FROM @SoftDrinkDetailsTab
				
					OPEN SoftDetailsCur
				
					FETCH NEXT FROM SoftDetailsCur INTO @SoftDrinkId ,@SoftDrinkQuantityId, @subOrderQuantity ,@subTariff, @subOrderTime ,@subBookingType,@subWaiterId ,
															 @subNetTariff 
			

					WHILE @@FETCH_STATUS = 0
						BEGIN
							INSERT INTO OrderDetails(SoftDrinkId ,OrderTime ,SoftDrinkQuantityId ,OrderQuantity ,BuffetId ,BookingType ,Tariff ,NetTariff ,ComplementaryId ,WaiterId ,
														OrderHeaderSl, RestaurantId, TableId, OrderDate, BookedChairs, CGST, SGST, OrderId, BookingStatus, CreatedBy, CustomerId)
								VALUES(@SoftDrinkId ,@subOrderTime ,@SoftDrinkQuantityId ,@subOrderQuantity ,@subBuffetId ,@subBookingType ,@subTariff ,@subNetTariff ,
											@subComplementaryId ,@subWaiterId ,@OrderHeaderSl, @RestaurantId, @TableId, GETDATE(), @BookedChairs, 
											ISNULL((SELECT TOP 1 TaxPercentage FROM TaxMasterData WHERE TaxDescription = 'CGST'),0), 
											ISNULL((SELECT TOP 1 TaxPercentage FROM TaxMasterData WHERE TaxDescription = 'SGST'),0), @OrderId, @BookingStatus, @CreatedBy, @CustomerId)

							IF @@ROWCOUNT > 0
								BEGIN
									WHILE @subOrderQuantity > 0
											BEGIN
												SELECT TOP 1 @tempId = sim.StockId, @remainingAmount=sim.BalanceQty FROM StockInMaster as sim
												WHERE sim.RestaurantId=@RestaurantId
													AND sim.SoftDrinkId=@SoftDrinkId
													AND sim.SoftDrinkQuantityId =@SoftDrinkQuantityId
													AND sim.BalanceQty > 0
												IF @subOrderQuantity > @remainingAmount
													BEGIN
														SET @issuedQty = @remainingAmount
													END
												ELSE
													BEGIN
														SET @issuedQty = @subOrderQuantity
													END
		
												UPDATE StockInMaster SET IssuedQty = IssuedQty+ @issuedQty , BalanceQty = (@remainingAmount - @issuedQty) WHERE StockId = @tempId
												IF @@ROWCOUNT = 0
													BEGIN
														SELECT 'data not updated', 1
														ROLLBACK
													END
												SET @subOrderQuantity = @subOrderQuantity -@issuedQty
		
											END
									SET @tempId = 0
									SET @issuedQty = 0
									SET @remainingAmount = 0

								END
							ELSE
								BEGIN
									SELECT 'Data Not Inserted', 0
									ROLLBACK
								END


							FETCH NEXT FROM SoftDetailsCur INTO @SoftDrinkId ,@SoftDrinkQuantityId, @subOrderQuantity ,@subTariff, @subOrderTime ,@subBookingType,@subWaiterId ,
															 @subNetTariff 
						END
					CLOSE SoftDetailsCur
					DEALLOCATE SoftDetailsCur
					

				END
				SELECT 'Data Inserted Successfully', 1, @OrderHeaderSl, (select * from OrderDetailsByOrderId where OrderHeaderSl=@OrderHeaderSl for json path)
		END
	ELSE
		BEGIN
			SELECT 'Data Not Inserted',0
		END
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
		
	END
END
GO
/****** Object:  StoredProcedure [dbo].[addPreferenceMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addPreferenceMaster](@RestaurantId INT=NULL,
								@ChairOption CHAR(1)=NULL,
								@RoomLink CHAR(1)=NULL,
								@BarLink CHAR(1)=NULL,
								@CreatedBy int)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM PreferenceMaster WHERE ChairOption IS NOT NULL AND RoomLink IS NOT NULL AND BarLink IS NOT NULL AND RestaurantId=@RestaurantId)
		BEGIN
			INSERT INTO PreferenceMaster (RestaurantId,ChairOption,RoomLink,BarLink,CreatedBy,CreatedDate)
			VALUES(@RestaurantId,@ChairOption,@RoomLink,@BarLink,@CreatedBy,GETDATE())
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			UPDATE PreferenceMaster SET ChairOption=@ChairOption,RoomLink=@RoomLink,BarLink=@BarLink WHERE RestaurantId=@RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END

		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addRestaurant]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addRestaurant](
								@BranchCode VARCHAR(10),
								@RestaurantName NVARCHAR(100),
								@Description NVARCHAR(300)=NULL,
								@HotelLocnId INT,
								@Address1 NVARCHAR(100),
								@Address2 NVARCHAR(100)=NULL,
								@Zipcode INT,
								@City NVARCHAR(50),
								@District NVARCHAR(50),
								@State NVARCHAR(50),
								@Latitude DECIMAL(12,8),
								@Longitude DECIMAL(12,8),
								@RestaurantManager INT,
								@OrderFrom TIME,
								@OrderTo TIME,
								@WorkingDays NVARCHAR(7),
								@MailId NVARCHAR(50),
								@CreatedBy INT,
								@PhoneNumber NVARCHAR(15)=NULL,
								@GSTIN NVARCHAR(20),
								@PhoneNumber2 NVARCHAR(15)=NULL,
								@LogoUrl NVARCHAR(500)=NULL)


AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO RestaurantMaster(BranchCode,RestaurantName,Description,HotelLocnId,Address1,Address2,Zipcode,
			City,District,State,Latitude,Longitude,RestaurantManager,OrderFrom,OrderTo,WorkingDays,ActiveStatus,MailId,
			CreatedBy,PhoneNumber,GSTIN,PhoneNumber2,LogoUrl) 
			VALUES (@BranchCode,@RestaurantName,@Description,@HotelLocnId,@Address1,@Address2,@Zipcode,
			@City,@District,@State,@Latitude,@Longitude,@RestaurantManager,@OrderFrom,@OrderTo,@WorkingDays,'A',@MailId,
			@CreatedBy,@PhoneNumber,@GSTIN,@PhoneNumber2,@LogoUrl)
			IF @@ROWCOUNT>0
				BEGIN
					SELECT 'Data Added Successfully',1
					COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END			
	

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addShiftMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addShiftMaster](@ShiftName NVARCHAR(100),
								@StartTime TIME,
								@EndTime TIME,
								@BreakStartTime TIME=NULL,
								@BreakEndTime TIME=NULL,
								@GracePeriod TINYINT,
								@CreatedBy INT,
								@BranchId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ShiftMaster WHERE ShiftName = @ShiftName AND BranchId=@BranchId)
		BEGIN
			INSERT INTO ShiftMaster (BranchId,ShiftName,StartTime,EndTime,BreakStartTime,BreakEndTime,GracePeriod,ActiveStatus,CreatedBy,CreatedDate)
			VALUES(@BranchId,@ShiftName,@StartTime,@EndTime,@BreakStartTime,@BreakEndTime,@GracePeriod,'A',@CreatedBy,GETDATE())
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Shift Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addSoftDrinkData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addSoftDrinkData](@RestaurantId INT,
								@SoftDrinkName VARCHAR(100),
								@Description NVARCHAR(250),
								@ImageLink NVARCHAR(150),
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM SoftDrinkMaster WHERE RestaurantId=@RestaurantId AND SoftDrinkName=@SoftDrinkName)
		BEGIN
			INSERT INTO SoftDrinkMaster (RestaurantId,Description,SoftDrinkName,ImageLink,CreatedBy) 
			VALUES (@RestaurantId, @Description,@SoftDrinkName,@ImageLink,@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Soft Drink Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addSoftDrinkQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addSoftDrinkQuantityData](@RestaurantId INT,
											@SoftDrinkId INT,
											@SoftDrinkQuantityId VARCHAR(100),
											@Tariff DECIMAL(9,2),
											@CreatedBy INT,
											@ActualRate DECIMAL(9,2)=NULL,
											@Margin DECIMAL(9,2)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT SoftDrinkQuantityMaster.RestaurantId, SoftDrinkQuantityMaster.SoftDrinkId, SoftDrinkQuantityMaster.SoftDrinkQuantityId FROM SoftDrinkQuantityMaster WHERE RestaurantId=@RestaurantId AND SoftDrinkId = @SoftDrinkId AND SoftDrinkQuantityId = @SoftDrinkQuantityId)
		BEGIN
			INSERT INTO SoftDrinkQuantityMaster (RestaurantId,SoftDrinkId,SoftDrinkQuantityId,Tariff,ActiveStatus,CreatedBy,ActualRate,Margin) 
			VALUES (@RestaurantId, @SoftDrinkId,@SoftDrinkQuantityId,@Tariff,'A',@CreatedBy,@ActualRate,@Margin)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Trying to add duplicate record.',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addStockinMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addStockinMasterData](@RestaurantId INT,
											@SoftDrinkId INT=NULL,
											@SoftDrinkQuantityId VARCHAR(100),
											@Date DATE=NULL,
											@Rate DECIMAL(9,2)=NULL,
											@ReceivedQty DECIMAL(12,3),
											@IssuedQty DECIMAL(12,3)=NULL,
											@BalanceQty DECIMAL(12,3)=NULL,
											@TotalAmt DECIMAL(9,2),
											@CreatedBy INT
											)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO StockInMaster (RestaurantId,SoftDrinkId,SoftDrinkQuantityId,Date,Rate,ReceivedQty,IssuedQty,BalanceQty,TotalAmt,CreatedBy) 
			VALUES (@RestaurantId, @SoftDrinkId,@SoftDrinkQuantityId,@Date,@Rate,@ReceivedQty,@IssuedQty,@BalanceQty,@TotalAmt,@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addTariffMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addTariffMasterData](
								@RestaurantId INT,
								@TariffTypeId INT,
								@FoodId INT,
								@FoodQuantityId INT,
								@Tariff DECIMAL(9,2),
								@CreatedBy INT)


AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO TariffMaster(RestaurantId,TariffTypeId,FoodId,FoodQuantityId,Tariff,ActiveStatus,CreatedBy) 
			VALUES (@RestaurantId,@TariffTypeId,@FoodId,@FoodQuantityId,@Tariff,'A',@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					SELECT 'Data Added Successfully',1
					COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END			
	

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addTariffTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addTariffTypeData](
								@RestaurantId INT,
								@TariffTypeName NVARCHAR(100),
								@SeasonStart DATE=NULL,
								@SeasonEnd DATE=NULL,
								@CreatedBy INT)


AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO TariffType(RestaurantId,TariffTypeName,SeasonStart,SeasonEnd,ActiveStatus,CreatedBy) 
			VALUES (@RestaurantId,@TariffTypeName,@SeasonStart,@SeasonEnd,'A',@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					SELECT 'Data Added Successfully',1
					COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END			
	

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addBuffetData 76,'specialBuffet','100,102,103','2023-03-28','2023-03-29','161,162,163','600',1001
GO
/****** Object:  StoredProcedure [dbo].[addTaxMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addTaxMaster](
								--@TaxId INT,
								@ServiceName NVARCHAR(50),
								@TaxDescription NVARCHAR(50),
								@TaxPercentage DECIMAL(3,2)=NULL,
								@EffectiveFrom DATE,
								--@EffectiveTill DATE=NULL,
								@RefNumber NVARCHAR(50)=NULL,
								@RefDate DATE=NULL,
								@RefDocumentLink NVARCHAR(150)=NULL,
								@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM TaxMaster WHERE EffectiveFrom=@EffectiveFrom AND TaxDescription=@TaxDescription)
		BEGIN
			IF NOT EXISTS(SELECT * FROM TaxMaster WHERE TaxDescription=@TaxDescription )
				BEGIN
                  INSERT INTO TaxMaster(TaxId, ServiceName, TaxDescription,TaxPercentage,EffectiveFrom,RefNumber,RefDate,RefDocumentLink,ActiveStatus,CreatedBy,UpdatedBy)
                  VALUES(3, @ServiceName, @TaxDescription,@TaxPercentage,@EffectiveFrom,@RefNumber,@RefDate,@RefDocumentLink,'A',@CreatedBy,@CreatedBy)
				  IF @@ROWCOUNT>0
					BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Added',0
						ROLLBACK
					END
				END
			ELSE
                  BEGIN 
					  UPDATE TaxMaster  SET EffectiveTill=cast(DATEADD(day,-1,@EffectiveFrom) as Date),ActiveStatus='D' WHERE
					  TaxDescription=@TaxDescription and EffectiveTill IS NULL
					  IF @@ROWCOUNT >0
						  INSERT INTO TaxMaster(TaxId, ServiceName, TaxDescription,TaxPercentage,EffectiveFrom,RefNumber,RefDate,RefDocumentLink,ActiveStatus,CreatedBy,UpdatedBy)
						  values(3, @ServiceName, @TaxDescription,@TaxPercentage,@EffectiveFrom,@RefNumber,@RefDate,@RefDocumentLink,'A',@CreatedBy,@CreatedBy)
						  IF @@ROWCOUNT>0
							BEGIN
								SELECT 'Data Added Successfully',1
								COMMIT
							END

						 ELSE
							BEGIN
								SELECT 'Data Not Added',0
								ROLLBACK
							END
                  END
			
		END
	ELSE
		BEGIN
			SELECT 'Tax Data Already Exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END

--EXEC addTaxMaster 'Restaurant','SSGST',NULL,'2023-03-28',NULL,NULL,NULL,1001
GO
/****** Object:  StoredProcedure [dbo].[addUPIData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addUPIData](@RestaurantId INT,
											@Name NVARCHAR(100),
											@Mobile BIGINT,
											@UPIId NVARCHAR(100),
											@CreatedBy INT
											)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM UPIMaster WHERE RestaurantId=@RestaurantId AND UPIId = @UPIId)
		BEGIN
			INSERT INTO UPIMaster(RestaurantId,Name,Mobile,UPIId,ActiveStatus,CreatedBy)
			VALUES(@RestaurantId,@Name,@Mobile,@UPIId,'A',@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE UPIMaster SET ActiveStatus = 'D' WHERE UPIMasterId != (SELECT Top 1 UPIMasterId FROM UPIMaster ORDER BY UPIMasterId DESC)
					IF @@ROWCOUNT>0
						BEGIN
							 SELECT 'Data Added Successfully',1
							 COMMIT
						END

					ELSE
						BEGIN
							SELECT 'Data Not Added',0
							ROLLBACK
						END
				END
				
		END
	ELSE
		BEGIN
			SELECT 'UPI Id already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addWaiter]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addWaiter](@RestaurantId INT,
									@FirstName NVARCHAR(50),
									@LastName NVARCHAR(50),
									@Mobile BIGINT,
									@Email NVARCHAR(100),
									@ShiftId INT,
									@Aadhar BIGINT,
									@WaiterType VARCHAR(20),
									@Zipcode INT,
									@City VARCHAR(50),
									@District VARCHAR(50),
									@State VARCHAR(50),
									@Address1 NVARCHAR(100),
									@Address2 NVARCHAR(100),
									@ImageLink NVARCHAR(150),
									@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			INSERT INTO WaiterMaster (RestaurantId,FirstName,LastName,Mobile,Email,ShiftId,ActiveStatus,Aadhar,WaiterType,
			Zipcode,City,District,State,Address1,Address2,ImageLink,CreatedBy) 
			VALUES (@RestaurantId, @FirstName,@LastName,@Mobile,@Email,@ShiftId,'A',@Aadhar,@WaiterType,@Zipcode,@City,
			@District,@State,@Address1,@Address2,@ImageLink,@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
					 SELECT 'Data Added Successfully',1
					 COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[addWaiterMapping]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[addWaiterMapping](@RestaurantId INT,
											@WaiterId NVARCHAR(100),
											@DinningId NVARCHAR(50),
											@CreatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM WaiterMappingMaster WHERE RestaurantId= @RestaurantId AND WaiterId = @WaiterId)
		BEGIN
			INSERT INTO WaiterMappingMaster(RestaurantId,WaiterId,DinningId,ActiveStatus,CreatedBy)
			VALUES(@RestaurantId,@WaiterId,@DinningId,'A',@CreatedBy)
			IF @@ROWCOUNT>0
				BEGIN
						SELECT 'Data Added Successfully',1
						COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not Added',0
					ROLLBACK
				END
		 END
				
		
	ELSE
		BEGIN
			SELECT 'Waiter Name already exists!',0
			COMMIT
		END

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[ConfigTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ConfigTypeData] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT (Select * FROM ConfigTypeDataView FOR JSON PATH, INCLUDE_NULL_VALUES) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[deleteAddOnsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteAddOnsData](@ActiveStatus CHAR(1),
										   @AddOnsId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE AddOns SET ActiveStatus = @ActiveStatus  WHERE AddOnsId = @AddOnsId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deletebookingTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deletebookingTypeData](@ActiveStatus CHAR(1),
										@BookingTypeId INT,
										@RestaurantId INT
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE BookingTypeMaster SET ActiveStatus = @ActiveStatus  WHERE BookingTypeId = @BookingTypeId AND RestaurantID = @RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteBuffetData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteBuffetData](@ActiveStatus CHAR(1),
												@BuffetId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE BuffetMaster SET ActiveStatus = @ActiveStatus  WHERE BuffetId = @BuffetId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteComplementaryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteComplementaryData](@ActiveStatus CHAR(1),
											 @ComplementaryId INT=NULL,
											 @FoodTimingId INT=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			IF @ComplementaryId IS NOT NULL
				BEGIN
					UPDATE ComplementaryMaster SET ActiveStatus = @ActiveStatus WHERE UniqueId = @ComplementaryId
					IF @@ROWCOUNT>0
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END
					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					UPDATE ComplementaryMaster SET ActiveStatus = @ActiveStatus WHERE FoodTimingId = @FoodTimingId
					IF @@ROWCOUNT>0
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END
					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteComplementaryDataFromTable]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteComplementaryDataFromTable](@ComplementaryId INT,
											     @RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			DELETE FROM ComplementaryMaster WHERE UniqueId = @ComplementaryId AND RestaurantId=@RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteConfigMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteConfigMasterData](@ActiveStatus CHAR(1),
												@TypeId INT,
												@ConfigId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ConfigurationMaster SET ActiveStatus = @ActiveStatus  WHERE TypeId = @TypeId AND ConfigId = @ConfigId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteConfigTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteConfigTypeData](@ActiveStatus CHAR(1),
												@TypeId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ConfigurationType SET ActiveStatus = @ActiveStatus  WHERE TypeId = @TypeId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteDinningData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteDinningData](@ActiveStatus CHAR(1),
										   @DinningId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE DinningMaster SET ActiveStatus = @ActiveStatus  WHERE DinningId = @DinningId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE DinningTableMaster SET ActiveStatus = @ActiveStatus WHERE DinningId = @DinningId
					IF @@ROWCOUNT>0
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END
					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END

			ELSE
					BEGIN
						SELECT 'Data Not Deleted',0
						ROLLBACK
					END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteDinningTableData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteDinningTableData](@ActiveStatus CHAR(1),
												@TableId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE DinningTableMaster SET ActiveStatus = @ActiveStatus WHERE TableId = @TableId
			IF @@ROWCOUNT>0				
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteFoodCategoryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteFoodCategoryData](@ActiveStatus CHAR(1),
												@FoodCategoryId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE FoodCategoryMaster SET ActiveStatus = @ActiveStatus WHERE FoodCategoryId = @FoodCategoryId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE FoodMaster SET ActiveStatus = @ActiveStatus WHERE FoodCategoryId = @FoodCategoryId
					IF @@ROWCOUNT>0
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END

					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					COMMIT
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteFoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteFoodData](@ActiveStatus CHAR(1),
										@FoodId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE FoodMaster SET ActiveStatus = @ActiveStatus WHERE FoodId = @FoodId
			IF @@ROWCOUNT>0				
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteFoodItems]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteFoodItems](@ActiveStatus CHAR(1),
											 @BarId INT,
											 @RestaurantId INT,
											 @UniqueId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE MapFoodItemsToBar SET ActiveStatus = @ActiveStatus  WHERE BarId = @BarId AND RestaurantId= @RestaurantId AND UniqueId=@UniqueId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteFoodQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteFoodQuantityData](@ActiveStatus CHAR(1),
												@FoodId INT,
												@UniqueId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			IF EXISTS(SELECT FoodQuantityMaster.FoodId, FoodQuantityMaster.FoodQuantityId, FoodQuantityMaster.ActiveStatus FROM FoodQuantityMaster WHERE FoodId = @FoodId AND ActiveStatus='A')
				BEGIN
					UPDATE FoodQuantityMaster SET ActiveStatus = @ActiveStatus  WHERE FoodId = @FoodId AND UniqueId=@UniqueId
					IF @@ROWCOUNT>0				
						BEGIN
							SELECT 'Deleted successfully.',1
							COMMIT							
						END

					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
				  UPDATE FoodMaster SET ActiveStatus = 'D' WHERE FoodId = @FoodId
				  IF @@ROWCOUNT>0				
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END
				  ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteFoodTimingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteFoodTimingData](@ActiveStatus CHAR(1),
												@FoodTimingId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE FoodTimingMaster SET ActiveStatus = @ActiveStatus  WHERE FoodTimingId = @FoodTimingId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[DeleteHoldWithoutHeader]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE TTDC_Restaurant;

CREATE PROCEDURE [dbo].[DeleteHoldWithoutHeader] (@OrderSl INT , 
				  @Tax DECIMAL(6,2)= NULL,
				  @NetTariff DECIMAL(9,2)= NULL,
				  @OfferAmount DECIMAL(9,2) = NULL,
				  @OrderHeaderSl INT = NULL,
				  @OrderQuantity INT =NULL,
				  @SoftDrinkId INT	=NULL,
				  @SoftDrinkQuantityId INT = NULL
				  )
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRAN
	
	--SELECT @OrderSl, @Tax, @NetTariff, @OfferAmount, @OrderHeaderSl, @OrderQuantity, @SoftDrinkId, @SoftDrinkQuantityId
	DELETE FROM OrderDetails WHERE OrderSl = @OrderSl
	IF @@ROWCOUNT > 0
		BEGIN
			UPDATE OrderHeader SET TaxAmount = TaxAmount - ISNULL(@Tax,0), BillAmount = BillAmount -@NetTariff, NetAmount = NetAmount- ISNULL(@NetTariff -ISNULL(@Tax,0),0), OfferAmount = ISNULL(OfferAmount,0) WHERE OrderHeaderSl = @OrderHeaderSl
			IF @@ROWCOUNT > 0
				BEGIN
					IF @SoftDrinkId != 0
						BEGIN
							UPDATE StockInMaster SET IssuedQty = IssuedQty-ISNULL(@OrderQuantity,0) , BalanceQty = BalanceQty+ ISNULL(@OrderQuantity ,0) WHERE SoftDrinkId = @SoftDrinkId AND SoftDrinkQuantityId = @SoftDrinkQuantityId
							IF @@ROWCOUNT = 0
								BEGIN
									SELECT 'Not Able to Delete',0
									ROLLBACK
								END
						END
					IF @@TRANCOUNT > 0
						BEGIN
							SELECT 'Deleted Successfully',1
							COMMIT
						END
				END
			ELSE 
				BEGIN
					SELECT 'Not Able to Delete',0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Not able to Delete', 0
			ROLLBACK
		END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteItemIssHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteItemIssHdrDtlData](@ActiveStatus CHAR(1),
												@IssueId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemIssHdr SET ActiveStatus = @ActiveStatus  WHERE IssueId = @IssueId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteItemMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteItemMasterData](@ActiveStatus CHAR(1),
												@ItemId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemMaster SET ActiveStatus = @ActiveStatus  WHERE ItemId = @ItemId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteItemPurHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteItemPurHdrDtlData](@ActiveStatus CHAR(1),
												@PurchaseId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemPurHdr SET ActiveStatus = @ActiveStatus  WHERE PurchaseId = @PurchaseId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteMultipleOrders]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE TTDC_Restaurant;
CREATE procedure [dbo].[deleteMultipleOrders](@OrderHeaderIds NVARCHAR(max))
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRAN
	IF EXISTS( SELECT * FROM StockInMaster 
					INNER JOIN OrderDetails 
						ON OrderDetails.SoftDrinkId = StockInMaster.SoftDrinkId 
							AND OrderDetails.SoftDrinkQuantityId = StockInMaster.SoftDrinkQuantityId 
							AND OrderDetails.OrderHeaderSl IN (SELECT value FROM STRING_SPLIT(@OrderHeaderIds,','))
							AND OrderDetails.SoftDrinkId IS NOT NULL
							AND OrderDetails.SoftDrinkQuantityId IS NOT NULL)
		BEGIN
			UPDATE StockInMaster 
				SET StockInMaster.IssuedQty = StockInMaster.IssuedQty -OrderDetails.OrderQuantity, 
					StockInMaster.BalanceQty = StockInMaster.BalanceQty + OrderDetails.OrderQuantity
			FROM StockInMaster 
			INNER JOIN OrderDetails 
				ON OrderDetails.SoftDrinkId = StockInMaster.SoftDrinkId 
					AND OrderDetails.SoftDrinkQuantityId = StockInMaster.SoftDrinkQuantityId 
					AND OrderDetails.OrderHeaderSl IN (SELECT value FROM STRING_SPLIT(@OrderHeaderIds,','))
					AND OrderDetails.SoftDrinkId IS NOT NULL
					AND OrderDetails.SoftDrinkQuantityId IS NOT NULL
			IF @@ROWCOUNT = 0
				BEGIN
				SELECT 'Data Not Deleted3', 0
					ROLLBACK
				END
		END
DELETE FROM OrderDetails WHERE OrderHeaderSl IN (SELECT value FROM STRING_SPLIT(@OrderHeaderIds,','))
IF @@ROWCOUNT > 0
	BEGIN
		DELETE FROM OrderHeader WHERE OrderHeaderSl IN (SELECT value FROM STRING_SPLIT(@OrderHeaderIds,','))
		IF @@ROWCOUNT > 0
			BEGIN
				SELECT 'Data Deleted', 1
				IF @@TRANCOUNT > 0
					BEGIN
						COMMIT
					END
			END
		ELSE
			BEGIN
				SELECT 'Data Not Deleted1', 0
				ROLLBACK
			END
				
	END
ELSE
	BEGIN
		SELECT 'Data Not Deleted2', 0
		ROLLBACK
	END
		

			
IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END

END
GO
/****** Object:  StoredProcedure [dbo].[deleteOfferMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteOfferMasterData](@ActiveStatus CHAR(1),
												@OfferId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE OfferMaster SET ActiveStatus = @ActiveStatus  WHERE OfferId = @OfferId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteOrder]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[deleteOrder] (@OrderHeaderSl INT)
as
BEGIN
SET NOCOUNT ON;
BEGIN TRAN
	IF EXISTS( SELECT * FROM StockInMaster 
					INNER JOIN OrderDetails 
						ON OrderDetails.SoftDrinkId = StockInMaster.SoftDrinkId 
							AND OrderDetails.SoftDrinkQuantityId = StockInMaster.SoftDrinkQuantityId 
							AND OrderDetails.OrderHeaderSl = @OrderHeaderSl
							AND OrderDetails.SoftDrinkId IS NOT NULL
							AND OrderDetails.SoftDrinkQuantityId IS NOT NULL)
		BEGIN
			UPDATE StockInMaster 
				SET StockInMaster.IssuedQty = StockInMaster.IssuedQty -OrderDetails.OrderQuantity, 
					StockInMaster.BalanceQty = StockInMaster.BalanceQty + OrderDetails.OrderQuantity
			FROM StockInMaster 
			INNER JOIN OrderDetails 
				ON OrderDetails.SoftDrinkId = StockInMaster.SoftDrinkId 
					AND OrderDetails.SoftDrinkQuantityId = StockInMaster.SoftDrinkQuantityId 
					AND OrderDetails.OrderHeaderSl = @OrderHeaderSl
					AND OrderDetails.SoftDrinkId IS NOT NULL
					AND OrderDetails.SoftDrinkQuantityId IS NOT NULL
			IF @@ROWCOUNT = 0
				BEGIN
				SELECT 'Data Not Deleted3', 0
					ROLLBACK
				END
		END
	
		DELETE OrderDetails WHERE OrderHeaderSl = @OrderHeaderSl
		IF @@ROWCOUNT > 0
			BEGIN
				DELETE OrderHeader WHERE OrderHeaderSl = @OrderHeaderSl
					IF @@ROWCOUNT > 0
						BEGIN
							SELECT 'Data Updated Successfully', 1
							IF @@TRANCOUNT > 0
								BEGIN
									COMMIT
								END
						END
					ELSE
						BEGIN
							SELECT 'Data Not Update', 0
							ROLLBACK
						END
			END
		ELSE
			BEGIN
				SELECT 'Data Not Update', 0
				ROLLBACK
			END
		

IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[deleteRestaurant]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteRestaurant](@ActiveStatus CHAR(1),
										   @RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE RestaurantMaster SET ActiveStatus = @ActiveStatus  WHERE RestaurantId = @RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteShiftMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteShiftMasterData](@ActiveStatus CHAR(1),
												@ShiftId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ShiftMaster SET ActiveStatus = @ActiveStatus  WHERE ShiftId = @ShiftId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Deleted successfully.',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteSoftDrinkData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteSoftDrinkData](@SoftDrinkId INT,
											 @RestaurantId INT,
											 @ActiveStatus CHAR(1),
											 @UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE SoftDrinkMaster SET ActiveStatus=@ActiveStatus,UpdatedBy=@UpdatedBy WHERE SoftDrinkId = @SoftDrinkId AND RestaurantId=@RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteSoftDrinkQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteSoftDrinkQuantityData](@SoftDrinkId INT,
											 @ActiveStatus CHAR(1),
											 @SoftDrinkQuantityId INT,
											 @UniqueId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE SoftDrinkQuantityMaster SET ActiveStatus = @ActiveStatus WHERE SoftDrinkId = @SoftDrinkId AND SoftDrinkQuantityId = @SoftDrinkQuantityId AND UniqueId=@UniqueId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteTariffMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteTariffMasterData](@RestaurantId INT,
												@FoodId INT,
												@FoodQuantityId INT,
												@ActiveStatus CHAR(1),
												@TariffTypeId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TariffMaster SET ActiveStatus = @ActiveStatus WHERE FoodId = @FoodId AND RestaurantId = @RestaurantId AND TariffTypeId = @TariffTypeId AND FoodQuantityId = @FoodQuantityId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteTariffTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteTariffTypeData](@RestaurantId INT,
												@ActiveStatus CHAR(1),
												@TariffTypeId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TariffType SET ActiveStatus = @ActiveStatus  WHERE RestaurantId = @RestaurantId AND TariffTypeId =@TariffTypeId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
		

			
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteTaxMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteTaxMasterData](@ActiveStatus CHAR(1),
												@UniqueId INT
												)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TaxMaster SET ActiveStatus = @ActiveStatus  WHERE UniqueId = @UniqueId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE TaxMaster SET ActiveStatus = @ActiveStatus WHERE ActiveStatus = 'A'
					IF @@ROWCOUNT>0
						BEGIN
								COMMIT
								SELECT 'Deleted successfully.',1
						END

					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					COMMIT
				END

	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteUPIData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteUPIData](@ActiveStatus CHAR(1),
										@UPIMasterId INT,
										@RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE UPIMaster SET ActiveStatus = @ActiveStatus WHERE UPIMasterId = @UPIMasterId AND RestaurantId = @RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE UPIMaster SET ActiveStatus = 'D' WHERE UPIMasterId != @UPIMasterId AND RestaurantId = @RestaurantId
					IF @@ROWCOUNT>0
						BEGIN
							COMMIT
							SELECT 'Deleted successfully.',1
						END
					ELSE
						BEGIN
							SELECT 'Data Not Deleted',0
							ROLLBACK
						END
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					COMMIT
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteWaiter]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteWaiter](@ActiveStatus CHAR(1),
									  @WaiterId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE WaiterMaster SET ActiveStatus = @ActiveStatus  WHERE WaiterId = @WaiterId
			IF @@ROWCOUNT>0
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
										
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[deleteWaiterMapping]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[deleteWaiterMapping](@ActiveStatus CHAR(1),
												@MappingId INT,
												@RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE WaiterMappingMaster SET ActiveStatus = @ActiveStatus WHERE MappingId = @MappingId AND RestaurantId = @RestaurantId
			IF @@ROWCOUNT>0			
				BEGIN
					COMMIT
					SELECT 'Deleted successfully.',1
				END
			ELSE
				BEGIN
					SELECT 'Data Not Deleted',0
					ROLLBACK
				END
				
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[getAcceptancePendingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAcceptancePendingData](@RestaurantId INT=NULL,
												   @HandOverTo INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL AND @HandOverTo IS NOT NULL 
					THEN (select * from AcceptancePendingData where RestaurantId=@RestaurantId AND HandOverTo=@HandOverTo AND Status='P'  FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			
				ELSE
					(select * from AcceptancePendingData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getActualRate]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getActualRate](@RestaurantId INT=NULL,
									   @SoftDrinkId INT=NULL,
									   @SoftDrinkQuantityId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId & @SoftDrinkId & @SoftDrinkQuantityId
				WHEN @RestaurantId IS NOT NULL AND @SoftDrinkId IS NOT NULL AND @SoftDrinkQuantityId IS NOT NULL
					THEN (select * from ActualRate where RestaurantId=@RestaurantId AND SoftDrinkId=@SoftDrinkId AND SoftDrinkQuantityId=@SoftDrinkQuantityId FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			
				ELSE
					(select * from ActualRate FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAddOnsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAddOnsData](@AddOnsId INT=NULL,
										@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @AddOnsId
				WHEN @AddOnsId IS NOT NULL AND @RestaurantId IS NULL
					THEN (select * from AddOnsDataView where AddOnsId=@AddOnsId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			-- @RestaurantId
				WHEN @AddOnsId IS NULL AND @RestaurantId IS NOT NULL
					THEN (select * from AddOnsDataView where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from AddOnsDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAddOnsMapData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAddOnsMapData](@FoodId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodId
				WHEN @FoodId IS NOT NULL 
					THEN (select * from AddOnsMapDataView where FoodId=@FoodId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from AddOnsMapDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllAddOnsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllAddOnsData] 
AS
BEGIN

SELECT (select * from AllAddOnsData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getAllBuffetData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllBuffetData] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from AllBuffetData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from AllBuffetData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllBuffetDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllBuffetDataByResId] (@RestaurantId INT=NULL,
												  @date Date=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId & date
				WHEN @RestaurantId IS NOT NULL AND @date IS NOT NULL
					THEN (select * from AllBuffetDataByResId where RestaurantId=@RestaurantId AND cast(@date as date) BETWEEN cast(FromDate as date) AND cast(ToDate as date) FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from AllBuffetDataByResId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllComplementaryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllComplementaryData](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL
					THEN (select * from AllComplementaryData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from AllComplementaryData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllConfigMstData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllConfigMstData] 
AS
BEGIN

select(select * from AllConfigMstData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllConfigTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllConfigTypeData] 
AS
BEGIN

select(select * from AllConfigTypeData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllDataFromComplementaryMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllDataFromComplementaryMaster](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL
					THEN (select * from DataFromComplementary where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from DataFromComplementary FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllDataOffer]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllDataOffer] 
AS
BEGIN

select(select * from AllDataOfferView FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getAllDinningTableData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllDinningTableData](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL
					THEN (select * from AllDinningTableData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from AllDinningTableData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllFoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
create PROCEDURE [dbo].[getAllFoodData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from AllFoodData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from AllFoodData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllFoodDataByFoodCategoryId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllFoodDataByFoodCategoryId] (@RestaurantId INT=NULL,
														 @FoodCategoryId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId AND FoodCategoryId
				WHEN @RestaurantId IS NOT NULL AND @FoodCategoryId IS NOT NULL
					THEN (SELECT * FROM(SELECT FoodMaster.RestaurantId, FoodMaster.FoodCategoryId, FoodCategoryMaster.FoodCategoryName, FoodMaster.FoodId, FoodMaster.FoodName, FoodMaster.FoodTimingId, FoodMaster.Description, FoodMaster.ImageLink, FoodMaster.ActiveStatus, FoodMaster.CreatedBy, FoodMaster.CreatedDate  
							FROM FoodMaster,FoodCategoryMaster 
							WHERE FoodMaster.FoodCategoryId = FoodCategoryMaster.FoodCategoryId 
							AND FoodMaster.RestaurantId = @RestaurantId AND FoodMaster.FoodCategoryId=@FoodCategoryId

							UNION ALL

							SELECT FoodMaster.RestaurantId, FoodMaster.FoodCategoryId, FoodCategoryMaster.FoodCategoryName, FoodMaster.FoodId, FoodMaster.FoodName, FoodMaster.FoodTimingId, FoodMaster.Description, FoodMaster.ImageLink, FoodMaster.ActiveStatus, FoodMaster.CreatedBy, FoodMaster.CreatedDate 
							FROM FoodMaster,FoodQuantityMaster, FoodCategoryMaster 
							WHERE FoodMaster.FoodCategoryId = FoodCategoryMaster.FoodCategoryId 
							AND FoodMaster.RestaurantId = @RestaurantId AND FoodQuantityMaster.RestaurantId = @RestaurantId AND FoodMaster.FoodCategoryId=@FoodCategoryId 
							AND FoodMaster.FoodId=FoodQuantityMaster.FoodId) as A FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from AllFoodDataByFoodCategoryId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllFoodItemstoBar]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllFoodItemstoBar](@RestaurantId INT=NULL,
											@BarId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL AND @BarId IS NOT NULL
					THEN (SELECT * FROM AllFoodItemstoBar WHERE RestaurantId=@RestaurantId AND BarId=@BarId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT * FROM AllFoodItemstoBar FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllFoodQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllFoodQuantityData] 
AS
BEGIN

select(select * from AllFoodQuantityData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getAllItemIssHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllItemIssHdrDtlData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from AllItemIssHdrDtlData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from AllItemIssHdrDtlData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllItemMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllItemMasterData](@RestaurantId INT) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL 
					THEN (SELECT * FROM AllItemMasterData WHERE RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT * FROM AllItemMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllItemPurHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllItemPurHdrDtlData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from AllItemPurHdrDtlData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from AllItemPurHdrDtlData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllItemsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
create PROCEDURE [dbo].[getAllItemsData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL 
					THEN (select FoodId from AllItemsData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select FoodId from AllItemsData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllMenuOption]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllMenuOption] 
AS
BEGIN

select(select * from AllMenuOptionView FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getAllOfferNameData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllOfferNameData] 
AS
BEGIN

select(select * from AllOfferNameData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllPaymentPendingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllPaymentPendingData](@OrderDate DATE=NULL,
										@RestaurantId INT=NULL,
										@OrderFrom CHAR(1)=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId AND @OrderDate AND @OrderFrom
				WHEN @OrderDate IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL
					THEN (SELECT * FROM AllPaymentPendingData 
							WHERE RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) = CAST(@OrderDate as Date)AND OrderFrom= @OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT * FROM AllPaymentPendingData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllRestaurantFeedBackData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllRestaurantFeedBackData]
AS
BEGIN

SELECT (SELECT * FROM AllRestaurantFeedBackData FOR JSON PATH , INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getAllRestaurantName]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllRestaurantName] 
AS
BEGIN

select(select * from AllRestaurantName FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllRestaurants]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllRestaurants] 
AS
BEGIN

select(select * from AllRestaurants FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllRestaurantType]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllRestaurantType] 
AS
BEGIN

select(select * from AllRestaurantType FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllShiftMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
CREATE PROCEDURE [dbo].[getAllShiftMasterData] (@BranchId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @BranchId
				WHEN @BranchId IS NOT NULL 
					THEN (select * from ShiftMasterView where BranchId=@BranchId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from ShiftMasterView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllSoftDrink]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllSoftDrink](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN  @RestaurantId IS NOT NULL
					THEN (select * from AllSoftDrink where RestaurantId=@RestaurantId  FOR JSON PATH, INCLUDE_NULL_VALUES)					

			
				ELSE
					(select * from AllSoftDrink FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllStatus]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllStatus](@OrderDate date=NULL,
										@RestaurantId INT=NULL,
										@OrderFrom CHAR(1)=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @OrderDate & @RestaurantId & @OrderFrom  
				WHEN @OrderDate IS NOT NULL  AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL
					THEN (SELECT COUNT(BookingStatus) AS TotalOrders,
							COUNT(CASE WHEN BookingStatus LIKE '%O%' THEN 1 END) AS Ordered,
							COUNT(CASE WHEN BookingStatus LIKE '%P%' THEN 1 END) AS Prepared,
							COUNT(CASE WHEN BookingStatus LIKE '%S%' THEN 1 END) AS Served,
							COUNT(CASE WHEN BookingStatus LIKE '%C%' THEN 1 END) AS Cancelled,
							COUNT(CASE WHEN BookingStatus LIKE '%C%' AND CancelRefund IS NOT NULL THEN 1 END) AS Refunded,
							COUNT(CASE WHEN PaymentStatus LIKE '%P%' AND BookingStatus LIKE '%S%' THEN 1 END) AS PaymentPending,
							COUNT(CASE WHEN PaymentStatus LIKE '%S%' AND BookingStatus LIKE '%S%' THEN 1 END) AS Closed
							FROM OrderHeader 
							where CAST(OrderHeader.OrderDate as date)=CAST(@OrderDate as date) AND OrderHeader.RestaurantId=@RestaurantId AND OrderHeader.OrderFrom=@OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)

								
				ELSE
					(SELECT COUNT(BookingStatus) AS TotalOrders,
							COUNT(CASE WHEN BookingStatus LIKE '%O%' THEN 1 END) AS Ordered,
							COUNT(CASE WHEN BookingStatus LIKE '%P%' THEN 1 END) AS Prepared,
							COUNT(CASE WHEN BookingStatus LIKE '%S%' THEN 1 END) AS Served,
							COUNT(CASE WHEN BookingStatus LIKE '%C%' THEN 1 END) AS Cancelled,
							COUNT(CASE WHEN BookingStatus LIKE '%C%' AND CancelRefund IS NOT NULL THEN 1 END) AS Refunded,
							COUNT(CASE WHEN PaymentStatus LIKE '%P%' AND BookingStatus LIKE '%S%' THEN 1 END) AS PaymentPending,
							COUNT(CASE WHEN PaymentStatus LIKE '%S%' AND BookingStatus LIKE '%S%' THEN 1 END) AS Closed
							FROM OrderHeader FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getAllTariffMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllTariffMasterData]
AS
BEGIN

SELECT (SELECT * FROM AllTariffMasterData FOR JSON PATH, INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getAllTariffNameData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllTariffNameData] 
AS
BEGIN

select(select * from AllTariffNameData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllTariffTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllTariffTypeData]
AS
BEGIN

SELECT (SELECT * FROM AllTariffTypeData FOR JSON PATH, INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getAllTaxData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllTaxData] 
AS
BEGIN

select(select * from AllTaxMasterView FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getAllUPIDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllUPIDataByResId](@RestaurantId INT=NULL,
											  @UPIMasterId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL  AND @UPIMasterId IS NULL
					THEN (select * from UPIMasterView where RestaurantId=@RestaurantId  FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- @UPIMasterId & &UPIMasterId
				WHEN @RestaurantId IS NOT NULL  AND @UPIMasterId IS NOT NULL
					THEN (select * from UPIMasterView where RestaurantId=@RestaurantId AND UPIMasterId=@UPIMasterId  FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			
				ELSE
					(select * from UPIMasterView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getAllVendorData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllVendorData] 
AS
BEGIN

select(select * from VendorMasterView FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getAllVendorNameData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllVendorNameData] 
AS
BEGIN

select(select * from AllVendorNameData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getAllWaiters]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getAllWaiters]
AS
BEGIN

SELECT (SELECT * FROM AllWaiters FOR JSON PATH, INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getBookingTypeMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getFoodDataByFoodCategoryId] 76,1,'10:04:42'
CREATE PROCEDURE [dbo].[getBookingTypeMasterData] (@RestaurantId INT=NULL,
												@BookingTypeId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL AND @BookingTypeId IS NULL
					THEN (select * from BookingTypeMasterData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			-- @BookingTypeId
				WHEN @RestaurantId IS NULL AND @BookingTypeId IS NOT NULL
					THEN (select * from BookingTypeMasterData where BookingTypeId=@BookingTypeId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)
			

				ELSE
					(select * from BookingTypeMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getBuffetData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getBuffetData](@BuffetId INT=NULL,
										@RestaurantId INT=NULL,
										@date DATE=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @BuffetId
				WHEN @BuffetId IS NOT NULL AND @RestaurantId IS NOT NULL AND @date IS NOT NULL
					THEN (select * from BuffetData where BuffetId= @BuffetId AND RestaurantId= @RestaurantId AND ActiveStatus='A' AND CAST(@date AS date) BETWEEN CAST(FromDate as date) AND CAST(ToDate as date) FOR JSON PATH, INCLUDE_NULL_VALUES)
					


			
				ELSE
					(select * from BuffetData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getCommonConfigData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getCommonConfigData](@Type NVARCHAR(150)) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @Type 
				WHEN @Type IS NOT NULL 
					THEN (SELECT ConfigId, ConfigName FROM ConfigurationMaster
							INNER JOIN ConfigurationType ON ConfigurationMaster.TypeId=ConfigurationType.TypeId
							WHERE ConfigurationType.TypeName=@Type FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT ConfigId, ConfigName FROM ConfigurationMaster
					 INNER JOIN ConfigurationType ON ConfigurationMaster.TypeId=ConfigurationType.TypeId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getComplementaryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getComplementaryData](@RestaurantId INT=NULL,
										@time time=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @BuffetId
				WHEN @RestaurantId IS NOT NULL AND @time IS NOT NULL
					THEN (select * from ComplementaryData where RestaurantId= @RestaurantId AND FoodTimingId IN (SELECT FoodTimingId FROM FoodTimingMaster WHERE CAST(@time as time) BETWEEN CAST(StartTime as time) AND CAST(EndTime as time) AND RestaurantId=@RestaurantId) FOR JSON PATH, INCLUDE_NULL_VALUES)
					


			
				ELSE
					(select * from ComplementaryData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getCountAndRevenueForDates]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getCountAndRevenueForDates](@RestaurantId INT,
													  @FromDate DATE,
													  @ToDate DATE)
AS
BEGIN
SELECT CAST((CASE 

			-- @RestaurantId & @FromDate & @ToDate 
				WHEN @RestaurantId IS NOT NULL AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL			 
					THEN (SELECT
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalOrderCount,
                            
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Buffet'
                                AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS BuffetOrderCount,
                              
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Dine In' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS DineOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Take Away' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TakeAwayOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE SoftDrinkId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS SoftDrinkOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE ComplementaryId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS ComplementaryOrderCount,
                                
                            (SELECT SUM(NetTariff) FROM OrderDetails WHERE OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalRevenue,
                                
                            (SELECT SUM(OrderQuantity*SoftDrinkQuantityMaster.Tariff)
                              FROM OrderDetails
                              INNER JOIN SoftDrinkQuantityMaster
                              ON SoftDrinkQuantityMaster.SoftDrinkId = OrderDetails.SoftDrinkId
                              WHERE OrderDetails.SoftDrinkId = SoftDrinkQuantityMaster.SoftDrinkId
                              AND OrderDetails.SoftDrinkQuantityId = SoftDrinkQuantityMaster.SoftDrinkQuantityId AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalSoftDrinkRevenue,
                                
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE BookingType='Buffet' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS BuffetOrderRevenue,
                            
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE BookingType='Dine In' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS DineOrderRevenue,
		
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE ComplementaryId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS ComplementaryOrderRevenue FOR JSON PATH, INCLUDE_NULL_VALUES)

								
				ELSE 
					(SELECT 
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalOrderCount,
                            
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Buffet'
                                AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS BuffetOrderCount,
                              
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Dine In' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS DineOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE BookingType='Take Away' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TakeAwayOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE SoftDrinkId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS SoftDrinkOrderCount,
                                
                            (SELECT COUNT(DISTINCT OrderId) FROM OrderDetails WHERE ComplementaryId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS ComplementaryOrderCount,
                                
                            (SELECT SUM(NetTariff) FROM OrderDetails WHERE OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalRevenue,
                                
                            (SELECT SUM(OrderQuantity*SoftDrinkQuantityMaster.Tariff)
                              FROM OrderDetails
                              INNER JOIN SoftDrinkQuantityMaster
                              ON SoftDrinkQuantityMaster.SoftDrinkId = OrderDetails.SoftDrinkId
                              WHERE OrderDetails.SoftDrinkId = SoftDrinkQuantityMaster.SoftDrinkId
                              AND OrderDetails.SoftDrinkQuantityId = SoftDrinkQuantityMaster.SoftDrinkQuantityId AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS TotalSoftDrinkRevenue,
                                
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE BookingType='Buffet' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS BuffetOrderRevenue,
                            
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE BookingType='Dine In' AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS DineOrderRevenue,
		
                            (SELECT SUM(Tariff) FROM OrderDetails WHERE ComplementaryId IS NOT NULL AND OrderDetails.BookingStatus != 'C'
                                AND CAST(OrderDate AS DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate AS DATE) <= CAST(@ToDate as Date)
                                AND OrderDetails.RestaurantId=@RestaurantId) AS ComplementaryOrderRevenue
							 FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getCurrentfoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getCurrentfoodData](@RestaurantId INT=NULL,
											@FoodCategoryId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId AND @FoodCategoryId
				WHEN  @RestaurantId IS NOT NULL AND @FoodCategoryId IS NOT NULL
					THEN (select * from CurrentfoodData 
					where RestaurantId=@RestaurantId AND FoodCategoryId=@FoodCategoryId FOR JSON PATH, INCLUDE_NULL_VALUES)					

			
				ELSE
					(select * from CurrentfoodData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getData] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,
				WHEN @RestaurantId IS NOT NULL
					THEN (select * from AllItemsDataView
					WHERE RestaurantId=@RestaurantId AND FoodId IN (SELECT FoodId FROM AllItems WHERE RestaurantId=@RestaurantId AND ActiveStatus='A')
					FOR JSON PATH, INCLUDE_NULL_VALUES)	
			
			
				ELSE
					(select * from AllItemsDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDataByResId] (@RestaurantId INT=NULL,
										@type CHAR(1)=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId & type='A'
				WHEN @RestaurantId IS NOT NULL AND @type='A'
					THEN(SELECT FoodMaster.RestaurantId, FoodMaster.FoodCategoryId, FoodCategoryMaster.FoodCategoryName, FoodMaster.FoodId, FoodMaster.Description, FoodMaster.FoodName,
							(SELECT * FROM (SELECT  ISNULL(FoodTimingId, '') as FoodTimingId, 'Y' as rights FROM FoodTimingMaster
							WHERE (FoodMaster.FoodTimingId!='NULL' OR FoodMaster.FoodTimingId!='null' ) AND  FoodTimingId IN (SELECT value FROM string_split(ISNULL(FoodMaster.FoodTimingId,''), ',')) AND RestaurantId = FoodMaster.RestaurantId 
							UNION 
							SELECT  ISNULL(FoodTimingId, '') as FoodTimingId, 'N' as rights FROM FoodTimingMaster
							WHERE (FoodMaster.FoodTimingId!='NULL' OR FoodMaster.FoodTimingId!='null' ) AND FoodTimingId NOT IN (SELECT value FROM  string_split(ISNULL(FoodMaster.FoodTimingId,''), ',')) AND RestaurantId = FoodMaster.RestaurantId) as tabData FOR JSON PATH ) AS FoodTimingIds, FoodMaster.ImageLink, FoodMaster.ActiveStatus, FoodMaster.CreatedBy, FoodMaster.CreatedDate, FoodMaster.UpdatedBy, FoodMaster.UpdatedDate 
							FROM FoodMaster 
							INNER JOIN FoodCategoryMaster ON FoodMaster.FoodCategoryId = FoodCategoryMaster.FoodCategoryId 
							WHERE FoodMaster.RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)
					--THEN (SELECT FoodMaster.RestaurantId, FoodMaster.FoodCategoryId, FoodCategoryMaster.FoodCategoryName, FoodMaster.FoodId, FoodMaster.Description, FoodMaster.FoodName,(SELECT  value  AS 'FoodTimingId'
					--		FROM FoodMaster as f 
					--			CROSS APPLY STRING_SPLIT(f.FoodTimingId, ',') 
					--		WHERE f.FoodId=FoodMaster.FoodId FOR JSON PATH) AS FoodTimingIds, FoodMaster.ImageLink, FoodMaster.ActiveStatus, FoodMaster.CreatedBy, FoodMaster.CreatedDate, FoodMaster.UpdatedBy, FoodMaster.UpdatedDate 
					--		FROM FoodMaster 
					--		INNER JOIN FoodCategoryMaster ON FoodMaster.FoodCategoryId = FoodCategoryMaster.FoodCategoryId 
					--		WHERE FoodMaster.RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)
							
			---@RestaurantId
				WHEN @RestaurantId IS NOT NULL AND @type IS NULL
				THEN(select * from DataByResId WHERE RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)


			
				ELSE
					(select * from DataByResId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getDataByResIdAndroid]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDataByResIdAndroid] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from FoodCategoryDataByResIdAndroid where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from FoodCategoryDataByResIdAndroid FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getDataOnBookingStatus]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDataOnBookingStatus](@OrderDate date=NULL,
												@BookingStatus CHAR(1)=NULL,
												@RestaurantId INT=NULL,
												@OrderFrom CHAR(1)=NULL,
												@PaymentStatus CHAR(1)=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @OrderDate & @BookingStatus & @RestaurantId & @OrderFrom  
				WHEN @OrderDate IS NOT NULL AND @BookingStatus IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL AND @PaymentStatus IS NULL
					THEN (select * from DataOnBookingStatus 
					where CAST(OrderDate as date)=CAST(@OrderDate as date) AND BookingStatus=@BookingStatus AND RestaurantId=@RestaurantId AND OrderFrom=@OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- @OrderDate & @BookingStatus & @RestaurantId & @OrderFrom
				WHEN @OrderDate IS NOT NULL AND @BookingStatus IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL AND @PaymentStatus IS NOT NULL
					THEN (select * from DataOnBookingStatus 
					where CAST(OrderDate as date)=CAST(@OrderDate as date) AND BookingStatus=@BookingStatus AND RestaurantId=@RestaurantId AND PaymentStatus=@PaymentStatus AND OrderFrom=@OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)
					
			
				ELSE
					(select * from DataOnBookingStatus FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getDateAndStatusSpecificDataV2]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDateAndStatusSpecificDataV2](@orderDate Date=NULL,
														@RestaurantId INT=NULL,
														@OrderFrom CHAR(1)=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @orderDate & @RestaurantId & @OrderFrom
				WHEN @orderDate IS NOT NULL  AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL
					THEN (SELECT (ISNULL((SELECT OrderHeader.OrderHeaderSl, OrderHeader.OrderId, OrderHeader.NetAmount, OrderHeader.TaxAmount, OrderHeader.PaymentType, OrderHeader.CustomerId,  OrderHeader.BillAmount, OrderHeader.OrderDate, OrderHeader.RestaurantId, OrderHeader.TableId, OrderHeader.BookingType, OrderHeader.BookingStatus, OrderHeader.OrderFrom, OrderHeader.PaymentStatus,
									ISNULL((SELECT * FROM (SELECT OrderDetails.RestaurantId, OrderDetails.OrderHeaderSl, OrderDetails.OrderId,
											'0' as OrderSl,
											'0' as FoodId,
											'0' as FoodVarietyId,
											(null) as FoodVarietyName,
											(select top(1) BuffetName from BuffetMaster where BuffetId=OrderDetails.BuffetId) as FoodName,
											OrderDetails.OrderQuantity, OrderDetails.TableId, OrderDetails.Tariff, 
											OrderDetails.NetTariff, OrderDetails.OrderTime, OrderDetails.ServedTime, OrderDetails.BookingStatus, OrderDetails.WaiterId, 
											OrderDetails.BuffetId,OrderDetails.BookingType 
											FROM OrderDetails,FoodMaster
											WHERE OrderDetails.FoodId=FoodMaster.FoodId AND 
											OrderDetails.OrderId= OrderHeader.OrderId AND 
											(OrderDetails.FoodVarietyId IS NULL  OR OrderDetails.FoodVarietyId='0')
											AND BookingStatus IN ('O', 'P', 'S', 'C') 
											AND OrderDetails.OrderHeaderSl= OrderHeader.OrderHeaderSl 
											and BookingType='Buffet' 
											group by BuffetId,OrderDetails.RestaurantId,OrderDetails.OrderHeaderSl, 
											OrderDetails.OrderId,OrderDetails.OrderQuantity, OrderDetails.TableId, OrderDetails.Tariff, 
											OrderDetails.NetTariff, OrderDetails.OrderTime, OrderDetails.ServedTime, OrderDetails.BookingStatus, OrderDetails.WaiterId, 
											OrderDetails.BuffetId,OrderDetails.BookingType
									UNION ALL

										SELECT OrderDetails.RestaurantId, OrderDetails.OrderHeaderSl,OrderDetails.OrderId, 
										OrderDetails.OrderSl, 
										OrderDetails.FoodId,
										OrderDetails.FoodVarietyId,
										ConfigurationMaster.ConfigName As FoodVarietyName,
										FoodMaster.FoodName, OrderDetails.OrderQuantity, 
										OrderDetails.TableId, OrderDetails.Tariff, OrderDetails.NetTariff, OrderDetails.OrderTime, OrderDetails.ServedTime, OrderDetails.BookingStatus, 
										OrderDetails.WaiterId, OrderDetails.BuffetId, OrderDetails.BookingType 
										FROM OrderDetails, ConfigurationMaster, FoodMaster 
										WHERE ConfigurationMaster.ConfigId=OrderDetails.FoodVarietyId AND OrderDetails.FoodId=FoodMaster.FoodId 
										AND OrderDetails.OrderId=OrderHeader.OrderId 
										AND BookingStatus IN ('O', 'P', 'S', 'C') 
										AND OrderDetails.OrderHeaderSl=OrderHeader.OrderHeaderSl 
									UNION ALL
 
										SELECT OrderDetails.RestaurantId, OrderDetails.OrderHeaderSl, OrderDetails.OrderId, 
										OrderDetails.OrderSl, 
										OrderDetails.FoodId,
										'0' as FoodVarietyId,
										(null) as FoodVarietyName,
										FoodMaster.FoodName, OrderDetails.OrderQuantity, OrderDetails.TableId, OrderDetails.Tariff, OrderDetails.NetTariff, OrderDetails.OrderTime, OrderDetails.ServedTime, OrderDetails.BookingStatus, 
										OrderDetails.WaiterId, OrderDetails.BuffetId,OrderDetails.BookingType
										FROM OrderDetails,FoodMaster 
										WHERE OrderDetails.FoodId=FoodMaster.FoodId 
										AND OrderDetails.OrderId=OrderHeader.OrderId 
										AND (OrderDetails.FoodVarietyId IS NULL OR OrderDetails.FoodVarietyId='0')AND BookingStatus IN ('O', 'P', 'S', 'C') 
										AND OrderDetails.OrderHeaderSl=OrderHeader.OrderHeaderSl 
										and BookingType!='Buffet' 
	
										)as A  order by A.OrderSl ASC FOR JSON PATH),'[]') AS FoodDetails,
									ISNULL((SELECT OrderDetails.RestaurantId, OrderDetails.OrderHeaderSl, OrderDetails.OrderId, OrderDetails.OrderSl, OrderDetails.SoftDrinkId, (SoftDrinkMaster.SoftDrinkName) as FoodName,OrderDetails.OrderQuantity, OrderDetails.SoftDrinkQuantityId, ConfigurationMaster.ConfigName AS SoftDrinkQuantityName, OrderDetails.TableId, OrderDetails.Tariff, OrderDetails.OrderTime, OrderDetails.ServedTime, OrderDetails.NetTariff, OrderDetails.BookingStatus, OrderDetails.WaiterId, OrderDetails.BookingType FROM OrderDetails,SoftDrinkMaster,ConfigurationMaster WHERE OrderDetails.SoftDrinkId=SoftDrinkMaster.SoftDrinkId AND OrderDetails.OrderId= OrderHeader.OrderId AND OrderDetails.SoftDrinkQuantityId = ConfigurationMaster.ConfigId AND BookingStatus IN ('O', 'P', 'S', 'C') AND OrderDetails.OrderHeaderSl= OrderHeader.OrderHeaderSl 
										FOR JSON PATH),'[]') AS SoftDrinkDetails
									FROM OrderHeader 
									WHERE OrderHeader.BookingStatus IN ('O', 'P', 'S', 'C' ) AND RestaurantId=@RestaurantId AND CONVERT(VARCHAR(10), OrderDate, 111)= CAST(@orderDate as date) AND OrderFrom = @OrderFrom FOR JSON PATH),'[]')) as 'OrderDetails',
									(ISNULL((SELECT COUNT(BookingStatus) AS TotalOrders,
											COUNT(CASE WHEN BookingStatus LIKE '%O%' THEN 1 END) AS Ordered,
											COUNT(CASE WHEN BookingStatus LIKE '%P%' THEN 1 END) AS Prepared,
											COUNT(CASE WHEN BookingStatus LIKE '%S%' THEN 1 END) AS Served,
											COUNT(CASE WHEN BookingStatus LIKE '%C%' THEN 1 END) AS Cancelled,
											COUNT(CASE WHEN PaymentStatus LIKE '%P%' AND BookingStatus LIKE '%S%' THEN 1 END) AS PaymentPending,
											COUNT(CASE WHEN PaymentStatus LIKE '%S%' AND BookingStatus LIKE '%S%' THEN 1 END) AS Closed 
											FROM OrderHeader 
											WHERE RestaurantId=@RestaurantId AND CONVERT(VARCHAR(10), OrderDate, 111)= CAST(@orderDate as date) AND OrderFrom = @OrderFrom FOR JSON PATH),'[]'))as 'OrderStatus'
							 FOR JSON PATH, INCLUDE_NULL_VALUES)
					
			
				ELSE
					(select * from DateAndStatusSpecificDataV2 FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getDateSpecificData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getDateSpecificData](@orderDate Date=NULL,
											 @RestaurantId INT=NULL,
											 @OrderFrom CHAR(1)=NULL,
											 @bookingStatus CHAR(1)=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @bookingStatus
				WHEN @orderDate IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL AND @bookingStatus IS NOT NULL
					THEN (select * from DateSpecificData 
					WHERE CAST(OrderDate as DATE)=@orderDate AND BookingStatus=@bookingStatus AND RestaurantId = @RestaurantId AND OrderFrom =@OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)

			---@orderDate
				WHEN @orderDate IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL AND @bookingStatus IS NULL
					THEN (select * from DateSpecificData1 
					WHERE CAST(OrderDate as DATE)=@orderDate AND RestaurantId = @RestaurantId AND OrderFrom =@OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			
				ELSE
					(select * from DateSpecificData1 FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getDateWiseSales]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDateWiseSales](@RestaurantId INT=NULL,
											@FromDate DATE=NULL,
											@ToDate DATE=NULL,
											@OrderFrom CHAR(1)=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL AND @OrderFrom IS NOT NULL
					THEN (SELECT ISNULL(SUM(O.BillAmount),0) AS TotalBillAmount,ISNULL(SUM(O.NetAmount),0) AS TotalNetAmount, ISNULL(SUM(O.TaxAmount),0) AS TotalTaxAmount, ISNULL((SUM(O.TaxAmount)/2),0) as CGST,ISNULL((SUM(O.TaxAmount)/2),0) as SGST ,ISNULL(COUNT(O.OrderId),0) AS Orders,
							ISNULL((SELECT ISNULL(SUM(BillAmount),0) AS BillAmount, ISNULL(SUM(NetAmount),0) AS NetAmount, ISNULL(COUNT(OrderId),0) AS TotalOrders, ISNULL(COUNT(PaymentType),0) AS CountOfPaymentType, ISNULL(PaymentType,'0') as PaymentType ,ISNULL(ConfigurationMaster.ConfigName,'') as PaymentMethod  
							FROM OrderHeader 
							LEFT JOIN ConfigurationMaster ON OrderHeader.PaymentType=ConfigurationMaster.ConfigId 
							WHERE OrderHeader.RestaurantId=@RestaurantId AND OrderHeader.PaymentStatus='S' AND CAST(OrderHeader.OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderHeader.OrderDate as DATE)<=CAST(@ToDate as Date) AND OrderFrom= OrderHeader.OrderFrom   
							GROUP BY OrderHeader.PaymentType,ConfigurationMaster.ConfigName FOR JSON PATH),'[]') as OrderDetails
							FROM OrderHeader as O 
							WHERE O.RestaurantId=@RestaurantId AND O.PaymentStatus='S' AND CAST(O.OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(O.OrderDate as DATE)<=CAST(@ToDate as Date) AND @OrderFrom= O.OrderFrom FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT ISNULL(SUM(O.BillAmount),0) AS TotalBillAmount,ISNULL(SUM(O.NetAmount),0) AS TotalNetAmount, ISNULL(SUM(O.TaxAmount),0) AS TotalTaxAmount, ISNULL((SUM(O.TaxAmount)/2),0) as CGST,ISNULL((SUM(O.TaxAmount)/2),0) as SGST ,ISNULL(COUNT(O.OrderId),0) AS Orders,
							ISNULL((SELECT ISNULL(SUM(BillAmount),0) AS BillAmount, ISNULL(SUM(NetAmount),0) AS NetAmount, ISNULL(COUNT(OrderId),0) AS TotalOrders, ISNULL(COUNT(PaymentType),0) AS CountOfPaymentType, ISNULL(PaymentType,'0') as PaymentType ,ISNULL(ConfigurationMaster.ConfigName,'') as PaymentMethod  
							FROM OrderHeader 
							LEFT JOIN ConfigurationMaster ON OrderHeader.PaymentType=ConfigurationMaster.ConfigId 
							WHERE  OrderHeader.PaymentStatus='S'   
							GROUP BY OrderHeader.PaymentType,ConfigurationMaster.ConfigName FOR JSON PATH),'[]') as OrderDetails
							FROM OrderHeader as O 
							WHERE O.PaymentStatus='S' FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getDinningData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDinningData](@DinningId INT=NULL,
										@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @DinningId
				WHEN @DinningId IS NOT NULL AND @RestaurantId IS NULL
					THEN (select * from DinningDataView where DinningId=@DinningId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			-- @RestaurantId
				WHEN @DinningId IS NULL AND @RestaurantId IS NOT NULL
					THEN (select * from DinningDataView where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from DinningTableDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getDinningDataByRestaurantd]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDinningDataByRestaurantd](@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			--  @RestaurantId 
				WHEN  @RestaurantId IS NOT NULL 
					THEN (SELECT * FROM  DinningDataByRestaurantd
						WHERE RestaurantId=@RestaurantId 
						FOR JSON PATH, INCLUDE_NULL_VALUES)
					
			
				ELSE
					(select * from DinningDataByRestaurantd FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getDinningTableData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getDinningTableData](@TableId INT=NULL,
											 @DinningId INT=NULL,
											 @RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @TableId 
				WHEN @TableId IS NOT NULL AND @DinningId IS NULL AND @RestaurantId IS NULL
					THEN (select * from DinningTableDataView where TableId=@TableId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			-- @DinningId AND @RestaurantId
				WHEN @TableId IS NULL AND @DinningId IS NOT NULL AND @RestaurantId IS NOT NULL
					THEN (select * from DinningTableDataView where DinningId=@DinningId AND RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)

			-- @DinningId 
				WHEN @TableId IS NULL AND @DinningId IS NOT NULL AND @RestaurantId IS NULL
					THEN (select TableId, TableName, ChairCount from DinningTableDataView where DinningId=@DinningId AND ActiveStatus='A'  FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(select * from DinningTableDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getFoodCategoryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
CREATE PROCEDURE [dbo].[getFoodCategoryData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL 
					THEN (select ISNULL((select fcd.* from FoodCategoryData as fcd where fcd.RestaurantId=@RestaurantId for json path),'[]') as FoodCategory,ISNULL((SELECT top 1 CONVERT(VARCHAR(5), 'true') FROM SoftDrinkMaster as sdm inner join 
						StockInMaster as stm on stm.SoftDrinkId=sdm.SoftDrinkId AND stm.BalanceQty!= '0'
						where sdm.RestaurantId=@RestaurantId AND sdm. ActiveStatus = 'A'),'false') as IsSoftDrinkAvailable FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from FoodCategoryData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END





GO
/****** Object:  StoredProcedure [dbo].[getFoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodData] (@FoodId INT=NULL,
									  @FoodCategoryId INT=NULL,
									  @RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodId 
				WHEN @FoodId IS NOT NULL AND @FoodCategoryId IS NULL AND @RestaurantId IS NULL
					THEN (select * from FoodDataBycategory where FoodId=@FoodId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)	

			-- @FoodCategoryId & RestaurantId
				WHEN @FoodId IS NULL AND @FoodCategoryId IS NOT NULL AND @RestaurantId IS NOT NULL
					THEN (select FoodId,FoodName from FoodDataBycategory where FoodCategoryId=@FoodCategoryId AND RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from FoodDataBycategory FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodDataByCategory]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodDataByCategory] (@FoodCategoryId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodCategoryId 
				WHEN @FoodCategoryId IS NOT NULL 
					THEN (select * from FoodDataBycategory where FoodCategoryId=@FoodCategoryId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from FoodDataBycategory FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodDataByFoodCategoryId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getFoodDataByFoodCategoryId] 76,1,'10:04:42'
CREATE PROCEDURE [dbo].[getFoodDataByFoodCategoryId] (@RestaurantId INT,@FoodCategoryId INT,@time time,@Type CHAR(2))
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL AND @FoodCategoryId IS NOT NULL AND @time IS NOT NULL AND @Type IS NULL
					THEN (select * from FoodDataByFoodCategoryId where RestaurantId=@RestaurantId and FoodCategoryId=@FoodCategoryId and @time between StartTime and EndTime
									order by FoodId ASC  FOR JSON PATH, INCLUDE_NULL_VALUES)
									
			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL AND @FoodCategoryId=0 AND @time IS NOT NULL AND @Type IS NOT NULL
					THEN (select * from FoodDataByFoodCategoryId where RestaurantId=@RestaurantId and @time between StartTime and EndTime AND AllItems='Y'
									order by FoodId ASC  FOR JSON PATH, INCLUDE_NULL_VALUES)
			

				ELSE
					(select * from FoodDataByFoodCategoryId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodDataByFoodNameProc]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getFoodDataByFoodNameProc] (@FoodName NVARCHAR(150),
										@RestaurantId INT)
AS
BEGIN
SET NOCOUNT ON;
	SELECT (CASE 
	WHEN @FoodName IS NOT NULL AND @RestaurantId IS NOT NULL
		THEN
			(SELECT * FROM getFoodDataByFoodName WHERE RestaurantId = @RestaurantId AND FoodName LIKE '%'+@FoodName+'%' FOR JSON PATH)
		
	ELSE 
			(SELECT '')
	END) as mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodName]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodName] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from getFoodNameView where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from getFoodNameView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodQuantityData] (@FoodId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodId 
				WHEN @FoodId IS NOT NULL 
					THEN (select * from FoodQuantityDataView where FoodId=@FoodId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from FoodQuantityDataView FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodQuantityDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodQuantityDataByResId] (@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL
					THEN (select * from FoodQuantityDataByResId where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from FoodQuantityDataByResId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getFoodTimingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getFoodTimingData] (@FoodTimingId INT=NULL,
											@RestaurantId INT=NULL
											)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId & FoodTimingId
				WHEN @RestaurantId IS NOT NULL AND @FoodTimingId IS NOT NULL
					THEN (select * from FoodTimingData where RestaurantId=@RestaurantId AND FoodTimingId=@FoodTimingId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)	

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL AND @FoodTimingId IS NULL
					THEN (select * from FoodTimingData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from FoodTimingData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getHoldMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
create PROCEDURE [dbo].[getHoldMasterData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from HoldMasterData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from HoldMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getHotelOrders]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getHotelOrders](@HotelOrderId VARCHAR(50)=NULL,
										@RestaurantId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @HotelOrderId & @RestaurantId  
				WHEN @HotelOrderId IS NOT NULL  AND @RestaurantId IS NOT NULL 
					THEN (SELECT * FROM HotelOrders 
								WHERE HotelOrderId = @HotelOrderId AND RestaurantId = @RestaurantId AND PaymentType = 112 FOR JSON PATH, INCLUDE_NULL_VALUES)

								
				ELSE
					(SELECT *
							FROM HotelOrders FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getIndividualOrderCount]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getIndividualOrderCount](@RestaurantId INT=NULL,
										@FromDate DATE,
										@ToDate DATE,
										@OrderType NVARCHAR(100))
AS
BEGIN
SELECT CAST((CASE 

			-- @RestaurantId & @FromDate & @ToDate 
				WHEN @RestaurantId IS NOT NULL AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL AND @OrderType IS NOT NULL			 
					THEN (SELECT CASE
							WHEN @OrderType = 'FoodOrders' 
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE FoodId IS NOT NULL AND BuffetId IS NULL AND ComplementaryId IS NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'BuffetOrders' 
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE BuffetId IS NOT NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'SoftDrinksOrders'
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE SoftDrinkId IS NOT NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'ComplementaryOrders'
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE ComplementaryId IS NOT NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(OrderDate as DATE) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'All'
							THEN (SELECT * FROM (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE FoodId IS NOT NULL AND BuffetId IS NULL AND ComplementaryId IS NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) and RestaurantId=@RestaurantId GROUP BY BookingType
									UNION             
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue
									FROM OrderDetails 
									WHERE BuffetId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) and RestaurantId=@RestaurantId GROUP BY BookingType
									UNION  
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE SoftDrinkId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) and RestaurantId=@RestaurantId GROUP BY BookingType
									UNION
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE ComplementaryId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) and RestaurantId=@RestaurantId GROUP BY BookingType) AS A FOR JSON PATH)
						END)

								
				ELSE 
					(SELECT CASE
							WHEN @OrderType = 'FoodOrders' 
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE FoodId IS NOT NULL AND BuffetId IS NULL AND ComplementaryId IS NULL  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'BuffetOrders' 
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE BuffetId IS NOT NULL  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'SoftDrinksOrders'
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE SoftDrinkId IS NOT NULL  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							WHEN @OrderType = 'ComplementaryOrders'
							THEN (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue FROM OrderDetails WHERE ComplementaryId IS NOT NULL  AND CAST(OrderDate as DATE) >= CAST(OrderDate as DATE) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType FOR JSON PATH)
							ELSE (SELECT * FROM (SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE FoodId IS NOT NULL AND BuffetId IS NULL AND ComplementaryId IS NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)  GROUP BY BookingType
									UNION             
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue
									FROM OrderDetails 
									WHERE BuffetId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)  GROUP BY BookingType
									UNION  
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE SoftDrinkId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType
									UNION
									SELECT BookingType, COUNT(BookingType) as BookingCount, SUM(NetTariff) as Revenue 
									FROM OrderDetails 
									WHERE ComplementaryId IS NOT NULL AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY BookingType) AS A FOR JSON PATH)
						END)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getIndividualOrderTypes]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getIndividualOrderTypes](@RestaurantId INT=NULL,
										@FromDate DATE,
										@ToDate DATE)
AS
BEGIN
SELECT CAST((CASE 

			-- @RestaurantId & @FromDate & @ToDate 
				WHEN @RestaurantId IS NOT NULL AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL 			 
					THEN (SELECT ISNULL((SELECT MAX(OrderDetails.FoodId) AS FoodId, COUNT(OrderDetails.OrderQuantity) AS OrderQuantity, MAX(FoodMaster.FoodName) 
										AS FoodName, MAX(FoodMaster.FoodCategoryId) AS FoodCategoryId,
										ISNULL((SELECT FoodCategoryName FROM FoodCategoryMaster WHERE FoodCategoryId=FoodMaster.FoodCategoryId),'') AS FoodCategoryName 
										FROM OrderDetails, FoodMaster WHERE 
										OrderDetails.FoodId=FoodMaster.FoodId AND OrderDetails.FoodId IS 
										NOT NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDetails.OrderDate as DATE) >= CAST(@FromDate as Date) AND 
										CAST(OrderDetails.OrderDate as DATE)<=CAST(@ToDate as Date) 
										GROUP BY OrderDetails.FoodId,FoodMaster.FoodCategoryId FOR JSON PATH),'[]') As FoodOrders,
	
								ISNULL((SELECT COUNT(OrderDetails.BuffetId) AS BuffetCount, MAX(OrderDetails.BuffetId) AS BuffetId, MAX(BuffetMaster.BuffetName) 
										  AS BuffetName FROM OrderDetails, BuffetMaster WHERE 
										  OrderDetails.BuffetId=BuffetMaster.BuffetId AND OrderDetails.FoodId IS 
										  NOT NULL AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDetails.OrderDate as DATE) >=  CAST(@FromDate as Date) AND 
										  CAST(OrderDetails.OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY OrderDetails.BuffetId FOR JSON PATH),'[]') AS BuffetOrders,

								ISNULL((SELECT COUNT(OrderDetails.SoftDrinkId) AS SoftDrinkCount, MAX(OrderDetails.SoftDrinkId) AS SoftDrinkId, 
										MAX(SoftDrinkMaster.SoftDrinkName) 
										AS SoftDrinkName FROM OrderDetails, SoftDrinkMaster WHERE 
										OrderDetails.SoftDrinkId=SoftDrinkMaster.SoftDrinkId AND OrderDetails.RestaurantId=@RestaurantId AND 
										CAST(OrderDetails.OrderDate as DATE) >= CAST(@FromDate as Date) AND 
										CAST(OrderDetails.OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY OrderDetails.SoftDrinkId  FOR JSON PATH),'[]') AS SoftDrinksOrders,
				
								ISNULL((SELECT COUNT(OrderDetails.SoftDrinkId) AS SoftDrinkCount, MAX(OrderDetails.SoftDrinkId) AS SoftDrinkId, 
										MAX(SoftDrinkMaster.SoftDrinkName) 
										AS SoftDrinkName FROM OrderDetails, SoftDrinkMaster WHERE 
										OrderDetails.SoftDrinkId=SoftDrinkMaster.SoftDrinkId AND OrderDetails.RestaurantId=@RestaurantId AND 
										CAST(OrderDetails.OrderDate as DATE) >=  CAST(@FromDate as Date) AND 
										CAST(OrderDetails.OrderDate as DATE)<= CAST(@ToDate as Date) GROUP BY OrderDetails.SoftDrinkId  FOR JSON PATH),'[]') AS ComplementaryDetails
										FOR JSON PATH, INCLUDE_NULL_VALUES)

								
				ELSE 
					(SELECT OrderHeader.OrderHeaderSl, OrderHeader.OrderId, OrderHeader.NetAmount, OrderHeader.TaxAmount, OrderHeader.PaymentType, OrderHeader.CustomerId,  OrderHeader.BillAmount, OrderHeader.OrderDate, OrderHeader.RestaurantId, OrderHeader.TableId, OrderHeader.BookingType, OrderHeader.BookingStatus, OrderHeader.PaymentStatus FROM OrderHeader WHERE CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) AND BookingStatus IN ('O', 'P', 'S', 'C') FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getOfferMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
CREATE PROCEDURE [dbo].[getOfferMasterData] (@OfferId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @OfferId
				WHEN @OfferId IS NOT NULL 
					THEN (select * from OfferData where OfferId=@OfferId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from OfferData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getOrderDataByWaiterId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getOrderDataByWaiterId](@orderDate DATE=NULL,
										@WaiterId INT=NULL,
										@RestaurantId INT=NULL,
										@OrderFrom CHAR(1)=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId AND @OrderDate AND @OrderFrom
				WHEN @orderDate IS NOT NULL AND @WaiterId IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL
					THEN (SELECT * FROM(SELECT OrderHeader.OrderHeaderSl,OrderHeader.OrderId, OrderHeader.OrderDate, OrderHeader.RestaurantId, OrderHeader.TableId, OrderHeader.BookingType, OrderHeader.PaymentStatus, OrderHeader.BookingStatus,
							ISNULL((SELECT * FROM ( SELECT OrderDetails.RestaurantId,
													 OrderDetails.OrderHeaderSl,
													 OrderDetails.OrderId, 
													 OrderDetails.OrderSl, 
													 OrderDetails.FoodId, 
													 FoodMaster.FoodName, 
													 OrderDetails.OrderQuantity,
													 OrderDetails.WaiterId,
													 OrderDetails.FoodVarietyId, 
													 ConfigurationMaster.ConfigName As FoodVarietyName, 
													 OrderDetails.TableId, 
													 OrderDetails.Tariff, 
													 OrderDetails.NetTariff, 
													 OrderDetails.OrderTime, 
													 ISNULL(OrderDetails.ServedTime, '') as ServedTime,
													 OrderDetails.BookingType, 
													 OrderDetails.BookingStatus,
													 ISNULL((SELECT CONCAT(WaiterMaster.FirstName,'',WaiterMaster.LastName) as WaiterName FROM WaiterMaster WHERE WaiterMaster.WaiterId=@WaiterId),'') as WaiterName 
													FROM OrderDetails, ConfigurationMaster, FoodMaster, WaiterMaster
													WHERE ConfigurationMaster.ConfigId=OrderDetails.FoodVarietyId AND OrderDetails.FoodId=FoodMaster.FoodId AND OrderDetails.OrderHeaderSl=OrderHeader.OrderHeaderSl AND OrderDetails.WaiterId= @WaiterId AND BookingStatus IN ('O', 'P', 'S', 'C') AND OrderDetails.WaiterId IS NOT NULL
													UNION ALL
													SELECT OrderDetails.RestaurantId, 
															OrderDetails.OrderHeaderSl, 
															OrderDetails.OrderId, 
															OrderDetails.OrderSl, 
															OrderDetails.FoodId, 
															FoodMaster.FoodName, 
															OrderDetails.OrderQuantity, 
															OrderDetails.WaiterId, 
															'0' as FoodVarietyId, 
															'NULL' as FoodVarietyName ,
															OrderDetails.TableId,
															OrderDetails.Tariff, 
															OrderDetails.NetTariff, 
															OrderDetails.OrderTime, 
															ISNULL(OrderDetails.ServedTime, '') as ServedTime, 
															OrderDetails.BookingType,
															OrderDetails.BookingStatus,
															ISNULL((SELECT CONCAT(WaiterMaster.FirstName,'',WaiterMaster.LastName) as WaiterName FROM WaiterMaster WHERE WaiterMaster.WaiterId=@WaiterId),'') as WaiterName
															FROM OrderDetails,FoodMaster , WaiterMaster
													WHERE OrderDetails.FoodId=FoodMaster.FoodId AND OrderDetails.OrderHeaderSl= OrderHeader.OrderHeaderSl AND OrderDetails.WaiterId= @WaiterId AND OrderDetails.FoodVarietyId IS NULL AND BookingStatus IN ('O', 'P', 'S', 'C') AND OrderDetails.WaiterId IS NOT NULL) as A FOR JSON PATH),'[]') as FoodDetails
							FROM OrderHeader 
							WHERE CAST(OrderHeader.OrderDate as DATE)= CAST(@orderDate as date) AND OrderHeader.BookingStatus IN ('O', 'P', 'S', 'C') AND OrderHeader.RestaurantId = @RestaurantId AND OrderFrom = @OrderFrom) as a WHERE FoodDetails!='[]' FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT * FROM(SELECT OrderHeader.OrderHeaderSl,OrderHeader.OrderId, OrderHeader.OrderDate, OrderHeader.RestaurantId, OrderHeader.TableId, OrderHeader.BookingType, OrderHeader.PaymentStatus, OrderHeader.BookingStatus,
							ISNULL((SELECT * FROM (SELECT OrderDetails.RestaurantId,
													 OrderDetails.OrderHeaderSl,
													 OrderDetails.OrderId, 
													 OrderDetails.OrderSl, 
													 OrderDetails.FoodId, 
													 FoodMaster.FoodName, 
													 OrderDetails.OrderQuantity,
													 OrderDetails.WaiterId,
													 OrderDetails.FoodVarietyId, 
													 ConfigurationMaster.ConfigName As FoodVarietyName, 
													 OrderDetails.TableId, 
													 OrderDetails.Tariff, 
													 OrderDetails.NetTariff, 
													 OrderDetails.OrderTime, 
													 OrderDetails.ServedTime, 
													 OrderDetails.BookingType, 
													 OrderDetails.BookingStatus
													FROM OrderDetails, ConfigurationMaster, FoodMaster, WaiterMaster
													WHERE ConfigurationMaster.ConfigId=OrderDetails.FoodVarietyId AND OrderDetails.FoodId=FoodMaster.FoodId AND OrderDetails.OrderHeaderSl=OrderHeader.OrderHeaderSl  AND BookingStatus IN ('O', 'P', 'S', 'C') AND OrderDetails.WaiterId IS NOT NULL
													UNION ALL
													SELECT OrderDetails.RestaurantId, 
															OrderDetails.OrderHeaderSl, 
															OrderDetails.OrderId, 
															OrderDetails.OrderSl, 
															OrderDetails.FoodId, 
															FoodMaster.FoodName, 
															OrderDetails.OrderQuantity, 
															OrderDetails.WaiterId, 
															'0' as FoodVarietyId, 
															'NULL' as FoodVarietyName ,
															OrderDetails.TableId,
															OrderDetails.Tariff, 
															OrderDetails.NetTariff, 
															OrderDetails.OrderTime, 
															OrderDetails.ServedTime, 
															OrderDetails.BookingType,
															OrderDetails.BookingStatus 
															FROM OrderDetails,FoodMaster, WaiterMaster  
													WHERE OrderDetails.FoodId=FoodMaster.FoodId AND OrderDetails.OrderHeaderSl= OrderHeader.OrderHeaderSl AND OrderDetails.WaiterId= @WaiterId AND OrderDetails.FoodVarietyId IS NULL AND BookingStatus IN ('O', 'P', 'S', 'C') AND OrderDetails.WaiterId IS NOT NULL) as A FOR JSON PATH),'[]') as FoodDetails
							FROM OrderHeader 
							WHERE OrderHeader.BookingStatus IN ('O', 'P', 'S', 'C')) AS a WHERE FoodDetails!='[]' FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getOrderDetails]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getOrderDetails]
AS
BEGIN

SELECT (SELECT * FROM OrderDetailsView FOR JSON PATH, INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getOrderDetailsbyOrderHeaderSl]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getOrderDetailsbyOrderHeaderSl](@OrderHeaderSl INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @AddOnsId
				WHEN @OrderHeaderSl IS NOT NULL 
					THEN (select * from OrderDetailsbyOrderHeaderSl where OrderHeaderSl=@OrderHeaderSl  FOR JSON PATH, INCLUDE_NULL_VALUES)
					
			
				ELSE
					(select * from OrderDetailsbyOrderHeaderSl FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getOrderDetailsByOrderId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[getOrderDetailsByOrderId] (@OrderHeaderSl INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @OrderHeaderSl
				WHEN @OrderHeaderSl IS NOT NULL 
					THEN (select * from OrderDetailsByOrderId where OrderHeaderSl=@OrderHeaderSl FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from OrderDetailsByOrderId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getOrderDetailsCount]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getOrderDetailsCount](@RestaurantId INT=NULL,
											  @FromDate Date=NULL,
											  @ToDate Date=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId AND @FoodCategoryId
				WHEN  @RestaurantId IS NOT NULL AND @FromDate IS NOT NULL AND @ToDate IS NOT NULL
					THEN (SELECT od.RestaurantId,RestaurantMaster.RestaurantName,od.FoodId,FoodMaster.FoodName,COUNT(od.OrderQuantity) AS TotalOrderQuantity,SUM(od.NetTariff) AS TotalNetTariff
							FROM OrderDetails as od
							INNER JOIN RestaurantMaster On RestaurantMaster.RestaurantId=od.RestaurantId
							INNER JOIN FoodMaster ON FoodMaster.FoodId=od.FoodId
							where od.RestaurantId=@RestaurantId AND CAST(od.OrderDate as date) BETWEEN CAST (@FromDate as Date) AND CAST (@ToDate as Date)
							GROUP BY od.RestaurantId,RestaurantMaster.RestaurantName,od.FoodId,FoodMaster.FoodName 
							ORDER BY TotalOrderQuantity DESC FOR JSON PATH, INCLUDE_NULL_VALUES)					

			
				ELSE
					(select * from OrderDetailsCount FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getOrderHeaderDetails]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getOrderHeaderDetails]
AS
BEGIN

SELECT (SELECT * FROM OrderHeaderDetails FOR JSON PATH,INCLUDE_NULL_VALUES) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getOrderTypes]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[getOrderTypes](@RestaurantId INT=NULL,
										@FromDate DATE,
										@ToDate DATE)
AS
BEGIN
SELECT CAST((CASE 

			-- @RestaurantId & @FromDate & @ToDate 
				WHEN EXISTS (SELECT OrderHeaderSl FROM OrderDetails WHERE FoodId IS NOT NULL AND (BuffetId IS NULL OR BuffetId=0) AND (ComplementaryId IS NULL OR ComplementaryId=0) AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date))			 
					THEN (SELECT(
							SELECT ISNULL((SELECT * FROM (SELECT COUNT(FoodId) as FoodOrders, ISNULL(SUM(Tariff),0) as Amount, (null) as BuffetOrders,(null) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE FoodId IS NOT NULL AND (BuffetId IS NULL OR BuffetId=0) AND (ComplementaryId IS NULL OR ComplementaryId=0) AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) 
							UNION 
							SELECT (null) as FoodOrders, ISNULL(SUM(Tariff),0) as Amount,COUNT(BuffetId) as BuffetOrders,(null) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE (BuffetId IS NOT NULL OR BuffetId!=0) AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)
							UNION 
							SELECT (null) as FoodOrders,ISNULL(SUM(Tariff),0) as Amount, (null) as BuffetOrders,COUNT(SoftDrinkId) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE (SoftDrinkId IS NOT NULL OR SoftDrinkId!=0) AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)
							UNION
							SELECT (null) as FoodOrders,ISNULL(SUM(Tariff),0) as Amount,(null) as BuffetOrders,(null) as SoftDrinksOrders,COUNT(ComplementaryId) as ComplementaryOrders
							FROM OrderDetails
							WHERE (ComplementaryId IS NOT NULL OR ComplementaryId!=0) AND OrderDetails.RestaurantId=@RestaurantId AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)) AS A
							FOR JSON PATH),'[]') AS OrderDetails,

							ISNULL((SELECT SUM(BillAmount) AS BillAmount, SUM(NetAmount) AS NetAmount, COUNT(OrderId) AS TotalOrders, COUNT(PaymentType) AS CountOfPaymentType, ISNULL(PaymentType,'') as PaymentType ,
							ISNULL((SELECT ConfigName FROM ConfigurationMaster WHERE ConfigId=PaymentType),'') AS PaymentMethod
								FROM OrderHeader WHERE RestaurantId=@RestaurantId AND PaymentStatus='S' AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) GROUP BY(PaymentType) FOR JSON PATH),'[]')AS PaymentType FOR JSON PATH, INCLUDE_NULL_VALUES))

								
				ELSE 
					(SELECT(
							SELECT ISNULL((SELECT * FROM (SELECT COUNT(FoodId) as FoodOrders, ISNULL(SUM(Tariff),0) as Amount, (null) as BuffetOrders,(null) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE FoodId IS NOT NULL AND (BuffetId IS NULL OR BuffetId=0) AND (ComplementaryId IS NULL OR ComplementaryId=0)  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date) 
							UNION 
							SELECT (null) as FoodOrders, ISNULL(SUM(Tariff),0) as Amount,COUNT(BuffetId) as BuffetOrders,(null) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE (BuffetId IS NOT NULL OR BuffetId!=0)  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)
							UNION 
							SELECT (null) as FoodOrders,ISNULL(SUM(Tariff),0) as Amount, (null) as BuffetOrders,COUNT(SoftDrinkId) as SoftDrinksOrders,(null) as ComplementaryOrders
							FROM OrderDetails
							WHERE (SoftDrinkId IS NOT NULL OR SoftDrinkId!=0)  AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)
							UNION
							SELECT (null) as FoodOrders,ISNULL(SUM(Tariff),0) as Amount,(null) as BuffetOrders,(null) as SoftDrinksOrders,COUNT(ComplementaryId) as ComplementaryOrders
							FROM OrderDetails
							WHERE (ComplementaryId IS NOT NULL OR ComplementaryId!=0) AND CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<=CAST(@ToDate as Date)) AS A
							FOR JSON PATH),'[]') AS OrderDetails,

							ISNULL((SELECT SUM(BillAmount) AS BillAmount, SUM(NetAmount) AS NetAmount, COUNT(OrderId) AS TotalOrders, COUNT(PaymentType) AS CountOfPaymentType, ISNULL(PaymentType,'') as PaymentType ,
							ISNULL((SELECT ConfigName FROM ConfigurationMaster WHERE ConfigId=PaymentType),'') AS PaymentMethod
								FROM OrderHeader WHERE CAST(OrderDate as DATE) >= CAST(@FromDate as Date) AND CAST(OrderDate as DATE)<= CAST(@ToDate as Date) GROUP BY(PaymentType) FOR JSON PATH),'[]')AS PaymentType FOR JSON PATH, INCLUDE_NULL_VALUES))

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getPreferenceMasterById]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getPreferenceMasterById] (@PreferenceId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @PreferenceId,
				WHEN @PreferenceId IS NOT NULL 
					THEN (select * from PreferenceMasterData
					WHERE PreferenceId=@PreferenceId 
					FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from PreferenceMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getPreferenceMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getFoodDataByFoodCategoryId] 76,1,'10:04:42'
CREATE PROCEDURE [dbo].[getPreferenceMasterData] (@RestaurantId INT)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from PreferenceMasterData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from PreferenceMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getQuantity]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getQuantity](@SoftDrinkId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @AddOnsId
				WHEN @SoftDrinkId IS NOT NULL 
					THEN (select * from QuantityData where SoftDrinkId=@SoftDrinkId FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			
				ELSE
					(select * from QuantityData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getQuantityDataByFoodId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getQuantityDataByFoodId] (@FoodId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodId 
				WHEN @FoodId IS NOT NULL 
					THEN (select * from QuantityDataByFoodId where FoodId=@FoodId AND ActiveStatus='A' FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from QuantityDataByFoodId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getReprint]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getReprint] (@orderDate date,
										@RestaurantId INT,
										@OrderFrom char(1))
AS
BEGIN
SET NOCOUNT ON;
	SELECT (CASE 
	WHEN @orderDate IS NOT NULL AND @RestaurantId IS NOT NULL AND @OrderFrom IS NOT NULL 
		THEN
			(SELECT * FROM ReprintView WHERE RestaurantId = @RestaurantId AND OrderFrom=@OrderFrom AND CAST(OrderDate as DATE)=@orderDate order by OrderHeaderSl desc  FOR JSON PATH)
		
	ELSE 
			(SELECT '')
	END) as mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getRestaurantAndAmountByDate]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getRestaurantAndAmountByDate](@RestaurantId INT=NULL,
													  @Date DATE=NULL) 
AS
BEGIN

SELECT CAST((CASE 

					

			-- @RestaurantId & @Date 
				WHEN @RestaurantId IS NOT NULL AND @Date IS NOT NULL
					THEN (SELECT SUM(NetAmount) as TotalAmount, SUM(CancelRefund) as TotalCancelRefund, COUNT(*) as TotalOrders 
							FROM OrderHeader
							WHERE CAST(OrderHeader.OrderDate as DATE) = CAST(@Date as date) AND OrderHeader.RestaurantId = @RestaurantId AND OrderHeader.PaymentStatus = 'S' FOR JSON PATH, INCLUDE_NULL_VALUES)

			
				ELSE
					(SELECT SUM(NetAmount) as TotalAmount, SUM(CancelRefund) as TotalCancelRefund, COUNT(*) as TotalOrders 
						FROM OrderHeader
						WHERE OrderHeader.PaymentStatus = 'S' FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getRestaurantData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getFoodDataByFoodCategoryId] 76,1,'10:04:42'
CREATE PROCEDURE [dbo].[getRestaurantData] (@RestaurantId INT,@StoreId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodCategoryId,@time
				WHEN @RestaurantId IS NOT NULL AND @StoreId IS NULL
					THEN (select * from RestaurantData where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			
				WHEN @RestaurantId IS NULL AND @StoreId IS NOT NULL
					THEN (select * from RestaurantData where StoreId=@StoreId FOR JSON PATH, INCLUDE_NULL_VALUES)	
				ELSE
					(select * from RestaurantData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getRoomLinkedOrders]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getRoomLinkedOrders](@Date date=NULL,
										@HotelOrderId VARCHAR(50)=NULL,
										@HotelRoomNo INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @Date & @HotelOrderId & @HotelRoomNo  
				WHEN @Date IS NOT NULL  AND @HotelOrderId IS NOT NULL AND @HotelRoomNo IS NOT NULL
					THEN (SELECT * FROM RoomLinkedOrders 
							where CAST(OrderDate as DATE)=CAST(@Date as date) AND HotelOrderId=@HotelOrderId AND HotelRoomNo=@HotelRoomNo AND PaymentType = 112 FOR JSON PATH, INCLUDE_NULL_VALUES)

								
				ELSE
					(SELECT *
							FROM RoomLinkedOrders FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[getSingleData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getHoldMasterData] 76
CREATE PROCEDURE [dbo].[getSingleData] (@TypeId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @TypeId
				WHEN @TypeId IS NOT NULL 
					THEN (select * from SingleData where TypeId=@TypeId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from SingleData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getSoftDrinkQuantityDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getSoftDrinkQuantityDataByResId](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN  @RestaurantId IS NOT NULL
					THEN (select * from SoftDrinkQuantityDataByResId 
					where RestaurantId=@RestaurantId ORDER BY SoftDrinkId ASC  FOR JSON PATH, INCLUDE_NULL_VALUES)					

			
				ELSE
					(select * from SoftDrinkQuantityDataByResId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getStockInMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getStockInMasterData](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId
				WHEN  @RestaurantId IS NOT NULL
					THEN (select * from StockInMasterData 
					where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)					

			
				ELSE
					(select * from StockInMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getStockInMasterDataByResId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getStockInMasterDataByResId](@RestaurantId INT=NULL) 
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId 
				WHEN @RestaurantId IS NOT NULL 
					THEN (select * from StockInMasterDataByResId where RestaurantId=@RestaurantId FOR JSON PATH, INCLUDE_NULL_VALUES)
					

			
				ELSE
					(select * from StockInMasterDataByResId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END

GO
/****** Object:  StoredProcedure [dbo].[getTariffByFoodId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getTariffByFoodId] (@FoodId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @FoodId 
				WHEN @FoodId IS NOT NULL
					THEN (select * from TariffByFoodId where FoodId=@FoodId FOR JSON PATH, INCLUDE_NULL_VALUES)	

			
				ELSE
					(select * from TariffByFoodId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[getTariffDataByFoodId]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getTariffDataByFoodId] (@RestaurantId INT=NULL,
												@FoodId INT=NULL)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId,@FoodId
				WHEN @RestaurantId IS NOT NULL AND @FoodId IS NOT NULL
					THEN (select * from TariffDataByFoodId where RestaurantId=@RestaurantId AND FoodId=@FoodId FOR JSON PATH, INCLUDE_NULL_VALUES)	
			

				ELSE
					(select * from TariffDataByFoodId FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData
END
GO
/****** Object:  StoredProcedure [dbo].[GetTaxMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [dbo].[getFoodDataByFoodCategoryId] 76,1,'10:04:42'
CREATE PROCEDURE [dbo].[GetTaxMasterData]
AS
BEGIN

select(select * from TaxMasterData FOR JSON PATH, INCLUDE_NULL_VALUES)AS mainData

END
GO
/****** Object:  StoredProcedure [dbo].[getWorkersShift]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[getWorkersShift](@RestaurantId INT=NULL,
										 @time Time)
AS
BEGIN

SELECT CAST((CASE 

			-- @RestaurantId and @time
				WHEN @RestaurantId IS NOT NULL AND @time IS NOT NULL
					THEN (select * from WorkersShift where 
					 RestaurantId=@RestaurantId AND CAST(@time as time) BETWEEN CAST(StartTime as time) AND CAST(EndTime as time) FOR JSON PATH, INCLUDE_NULL_VALUES)
			
			
				ELSE
					(select * from WorkersShift FOR JSON PATH, INCLUDE_NULL_VALUES)

					END)as nvarchar(max)) AS mainData

END

GO
/****** Object:  StoredProcedure [dbo].[putOrderHeader]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putOrderHeader](@OrderHeaderSl INT ,
								@CreatedBy INT,
								@CustomerId INT,
								--@BookingMedia CHAR(2),
								@BookingStatus CHAR(1),
								@BillAmount DECIMAL(9,2),
								@TaxAmount DECIMAL(9,2),
								@NetAmount DECIMAL(9,2),
								@OfferAmount DECIMAL(9,2)=NULL,
								@OfferId INT=NULL,
								@OrderId INT=NULL,
								@PaymentStatus CHAR(1),
								@RestaurantId INT,
								@OrderDetails NVARCHAR(max)
								--@SoftDrinkDetails NVARCHAR(max)
								)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @tempId INT
DECLARE @remainingAmount INT
DECLARE @issuedQty INT

DECLARE @subOrderId nvarchar(50),
		@subOrderSl INT,
		@subFoodId INT,
		@subFoodVarietyId INT,
		@subTableId varchar(100),
		@subTariff DECIMAL(9,2),
		@subComments NVARCHAR(300),
		@subCancelDate DATETIME,
		@subCancelCharges DECIMAL(9,2),
		@subOrderQuantity INT,
		@subCancelRefund DECIMAL(9,2),
		@subNetTariff DECIMAL(9,2),
		@subWaiterId INT,
		@subServedTime TIME(7),
		@subBookedChairs VARCHAR(250),
		@subBookingType VARCHAR(20),
		@subOrderHeaderSl BIGINT,
		@subSoftDrinkId INT,
		@subSoftDrinkQuantityId INT,
		@subBuffetId INT,
		@subComplementaryId INT,
		@subCGST DECIMAL(6,2),
		@subSGST DECIMAL(6,2),
		@newQuantity INT

DECLARE @subOrderDetail TABLE  (
       OrderSl INT NULL
      ,FoodId INT 
      ,FoodVarietyId INT
      ,TableId varchar(100) NULL
      ,Tariff DECIMAL(9,2)
      ,Comments NVARCHAR(300) NULL
      ,CancelDate DATETIME NULL
      ,CancelCharges DECIMAL(9,2) NULL
      ,OrderQuantity INT 
      ,CancelRefund DECIMAL(9,2) NULL
      ,NetTariff DECIMAL(9,2) 
      ,WaiterId INT NULL
      ,ServedTime TIME(7) NULL
      ,BookedChairs VARCHAR(250) NULL
      ,BookingType VARCHAR(20) 
      ,OrderHeaderSl BIGINT
      ,SoftDrinkId INT NULL
      ,SoftDrinkQuantityId INT NULL
      ,BuffetId INT NULL
      ,ComplementaryId INT NULL
      ,CGST DECIMAL(6,2) NULL
      ,SGST DECIMAL(6,2) NULL) 

BEGIN TRAN
	
	SET @subOrderId = ISNULL(@OrderId, (SELECT OrderId FROM OrderHeader WHERE OrderHeaderSl = @OrderHeaderSl))
	
	UPDATE OrderHeader SET BillAmount = @BillAmount, NetAmount = @NetAmount , TaxAmount = @TaxAmount , OfferAmount = ISNULL(@OfferAmount ,OfferAmount), PaymentStatus = ISNULL(@PaymentStatus, PaymentStatus) WHERE OrderHeaderSl = @OrderHeaderSl
	IF @@ROWCOUNT > 0
		BEGIN

			INSERT INTO @subOrderDetail SELECT  [OrderSl],[FoodId],[FoodVarietyId],[TableId],[Tariff],[Comments],
												[CancelDate],[CancelCharges],[OrderQuantity],[CancelRefund],[NetTariff],[WaiterId],[ServedTime],
												[BookedChairs],[BookingType],ISNULL([OrderHeaderSl], @OrderHeaderSl),[SoftDrinkId],[SoftDrinkQuantityId],[BuffetId],[ComplementaryId],
												ISNULL(CGST,0),ISNULL(SGST, 0) 
			FROM OPENJSON(@OrderDetails)
			WITH (
			  OrderSl INT '$.OrderSl'
			  ,FoodId INT '$.FoodId'
			  ,FoodVarietyId INT '$.FoodVarietyId'
			  ,TableId varchar(100) '$.TableId'
			  ,Tariff DECIMAL(9,2) '$.Tariff'
			  ,Comments NVARCHAR(300) '$.Comments'
			  ,CancelDate DATETIME '$.CancelDate'
			  ,CancelCharges DECIMAL(9,2) '$.CancelCharges'
			  ,OrderQuantity INT '$.OrderQuantity'
			  ,CancelRefund DECIMAL(9,2) '$.CancelRefund'
			  ,NetTariff DECIMAL(9,2) '$.NetTariff'
			  ,WaiterId INT '$.WaiterId'
			  ,ServedTime TIME(7) '$.ServedTime'
			  ,BookedChairs VARCHAR(250) '$.BookedChairs'
			  ,BookingType VARCHAR(20) '$.BookingType'
			  ,OrderHeaderSl BIGINT '$.OrderHeaderSl'
			  ,SoftDrinkId INT '$.SoftDrinkId'
			  ,SoftDrinkQuantityId INT '$.SoftDrinkQuantityId'
			  ,BuffetId INT '$.BuffetId'
			  ,ComplementaryId INT '$.ComplementaryId'
			  ,CGST DECIMAL(6,2) '$.CGST'
			  ,SGST DECIMAL(6,2) '$.SGST'
			)

			IF @@ROWCOUNT > 0
				BEGIN
	
					DECLARE orderDetailsCursor CURSOR FAST_FORWARD FOR
						SELECT * FROM @subOrderDetail
	
					OPEN orderDetailsCursor

					FETCH NEXT FROM orderDetailsCursor INTO @subOrderSl,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,@subComments,
														@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subNetTariff,@subWaiterId,@subServedTime,
														@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
														@subCGST,@subSGST
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @subOrderSl IS NOT NULL
								BEGIN
									IF @subSoftDrinkId IS NULL
										BEGIN
											
											UPDATE OrderDetails SET OrderQuantity = @subOrderQuantity , NetTariff = Tariff * @subOrderQuantity WHERE OrderSl= @subOrderSl
											IF @@ROWCOUNT = 0
												BEGIN
													SELECT 'Data Not Inserted', 0
													ROLLBACK
												END
										END
									ELSE
										BEGIN
									
											SET @newQuantity = (SELECT TOP 1 OrderQuantity - @subOrderQuantity FROM OrderDetails WHERE OrderSl = @subOrderSl)

											UPDATE OrderDetails SET OrderQuantity = @subOrderQuantity , NetTariff = Tariff * @subOrderQuantity WHERE OrderSl= @subOrderSl
											IF @@ROWCOUNT > 0
												BEGIN
													 WHILE @newQuantity > 0
															BEGIN
																SELECT TOP 1 @tempId = sim.StockId, @remainingAmount=sim.BalanceQty FROM StockInMaster as sim
																WHERE sim.RestaurantId=@RestaurantId
																	AND sim.SoftDrinkId=@subSoftDrinkId
																	AND sim.SoftDrinkQuantityId =@subSoftDrinkQuantityId
																	AND sim.BalanceQty > 0
																IF @newQuantity > @remainingAmount
																	BEGIN
																		SET @issuedQty = @remainingAmount
																	END
																ELSE
																	BEGIN
																		SET @issuedQty = @newQuantity
																	END
		
																UPDATE StockInMaster SET IssuedQty = IssuedQty+ @issuedQty , BalanceQty = (@remainingAmount - @issuedQty) WHERE StockId = @tempId
																IF @@ROWCOUNT = 0
																	BEGIN
																		SELECT 'data not updated', 1
																		ROLLBACK
																	END
																SET @newQuantity = @newQuantity -@issuedQty
		
															END
													--UPDATE StockInMaster SET IssuedQty = IssuedQty + @newQuantity , BalanceQty = BalanceQty - @newQuantity WHERE SoftDrinkId = @subSoftDrinkId AND SoftDrinkQuantityId = @subSoftDrinkQuantityId
													--IF @@ROWCOUNT = 0
													--	BEGIN
													--		SELECT 'Data Not Inserted', 0
													--		ROLLBACK
													--	END
												END
											ELSE 
												BEGIN
													SELECT 'Data Not Inserted', 0
													ROLLBACK
												END
										END
								END
							ELSE
								BEGIN
								
									INSERT INTO OrderDetails ([RestaurantId],[OrderId],[FoodId],[FoodVarietyId],[TableId],[Tariff],[BookingStatus],[Comments],
														[CancelDate],[CancelCharges],[OrderQuantity],[CancelRefund],[NetTariff],[WaiterId],[OrderTime],[ServedTime],
														[BookedChairs],[BookingType],[OrderHeaderSl],[SoftDrinkId],[SoftDrinkQuantityId],[BuffetId],[ComplementaryId],
														[CustomerId],[CreatedBy],[OrderDate],CGST,SGST) 
										VALUES (@RestaurantId,@subOrderId,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,(SELECT TOP 1 BookingStatus FROM OrderHeader as oh WHERE OrderHeaderSl = @OrderHeaderSl),@subComments,
													@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subTariff * @subOrderQuantity,@subWaiterId,CAST(GETDATE() as time),@subServedTime,
													@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
													@CustomerId,@CreatedBy,GETDATE(),(SELECT TOP 1 TaxPercentage FROM TaxMaster WHERE TaxDescription='CGST' and ActiveStatus='A'),
													(SELECT TOP 1 TaxPercentage FROM TaxMaster WHERE TaxDescription='SGST' and ActiveStatus='A'))
										IF @@ROWCOUNT= 0
											BEGIN
												SELECT 'Data Not Inserted', 0
												ROLLBACK
											END
								END
			
							FETCH NEXT FROM orderDetailsCursor INTO @subOrderSl,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,@subComments,
														@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subNetTariff,@subWaiterId,@subServedTime,
														@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
														@subCGST,@subSGST
						END
						CLOSE orderDetailsCursor
						DEALLOCATE orderDetailsCursor
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
						SELECT 'Data Inserted successfully', 1,(select * from OrderDetailsByOrderId where OrderHeaderSl=@OrderHeaderSl for json path)
						
				END
			ELSE
				BEGIN
					SELECT 'Data Not Inserted', 0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Updated', 0
			ROLLBACK
		END

IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END


END
GO
/****** Object:  StoredProcedure [dbo].[putOrderHeaderDeatils]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[putOrderHeaderDeatils](@OrderHeaderSl INT ,
								@CreatedBy INT,
								@CustomerId INT,
								--@BookingMedia CHAR(2),
								@TableId nvarchar(max),
								@BookedChairs nvarchar(max),
								@BookingStatus CHAR(1),
								@BillAmount DECIMAL(9,2),
								@TaxAmount DECIMAL(9,2),
								@NetAmount DECIMAL(9,2),
								@OfferAmount DECIMAL(9,2)=NULL,
								@OfferId INT=NULL,
								@OrderId INT=NULL,
								@PaymentStatus CHAR(1),
								@RestaurantId INT,
								@OrderDetails NVARCHAR(max)
								--@SoftDrinkDetails NVARCHAR(max)
								)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @tempId INT
DECLARE @remainingAmount INT
DECLARE @issuedQty INT

DECLARE @subOrderId nvarchar(50),
		@subOrderSl INT,
		@subFoodId INT,
		@subFoodVarietyId INT,
		@subTableId varchar(100),
		@subTariff DECIMAL(9,2),
		@subComments NVARCHAR(300),
		@subCancelDate DATETIME,
		@subCancelCharges DECIMAL(9,2),
		@subOrderQuantity INT,
		@subCancelRefund DECIMAL(9,2),
		@subNetTariff DECIMAL(9,2),
		@subWaiterId INT,
		@subServedTime TIME(7),
		@subBookedChairs VARCHAR(250),
		@subBookingType VARCHAR(20),
		@subOrderHeaderSl BIGINT,
		@subSoftDrinkId INT,
		@subSoftDrinkQuantityId INT,
		@subBuffetId INT,
		@subComplementaryId INT,
		@subCGST DECIMAL(6,2),
		@subSGST DECIMAL(6,2),
		@newQuantity INT

DECLARE @subOrderDetail TABLE  (
       OrderSl INT NULL
      ,FoodId INT 
      ,FoodVarietyId INT
      ,TableId varchar(100) NULL
      ,Tariff DECIMAL(9,2)
      ,Comments NVARCHAR(300) NULL
      ,CancelDate DATETIME NULL
      ,CancelCharges DECIMAL(9,2) NULL
      ,OrderQuantity INT 
      ,CancelRefund DECIMAL(9,2) NULL
      ,NetTariff DECIMAL(9,2) 
      ,WaiterId INT NULL
      ,ServedTime TIME(7) NULL
      ,BookedChairs VARCHAR(250) NULL
      ,BookingType VARCHAR(20) 
      ,OrderHeaderSl BIGINT
      ,SoftDrinkId INT NULL
      ,SoftDrinkQuantityId INT NULL
      ,BuffetId INT NULL
      ,ComplementaryId INT NULL
      ,CGST DECIMAL(6,2) NULL
      ,SGST DECIMAL(6,2) NULL) 

BEGIN TRAN
	
	SET @subOrderId = ISNULL(@OrderId, (SELECT OrderId FROM OrderHeader WHERE OrderHeaderSl = @OrderHeaderSl))
	
	UPDATE OrderHeader SET BillAmount = @BillAmount, NetAmount = @NetAmount , TaxAmount = @TaxAmount , OfferAmount = ISNULL(@OfferAmount ,OfferAmount), PaymentStatus = ISNULL(@PaymentStatus, PaymentStatus) WHERE OrderHeaderSl = @OrderHeaderSl
	IF @@ROWCOUNT > 0
		BEGIN

			INSERT INTO @subOrderDetail SELECT  [OrderSl],[FoodId],[FoodVarietyId],ISNULL([TableId],@TableId),[Tariff],[Comments],
												[CancelDate],[CancelCharges],[OrderQuantity],[CancelRefund],[NetTariff],[WaiterId],[ServedTime],
												ISNULL([BookedChairs],@BookedChairs),[BookingType],ISNULL([OrderHeaderSl], @OrderHeaderSl),[SoftDrinkId],[SoftDrinkQuantityId],[BuffetId],[ComplementaryId],
												ISNULL(CGST,0),ISNULL(SGST, 0) 
			FROM OPENJSON(@OrderDetails)
			WITH (
			  OrderSl INT '$.OrderSl'
			  ,FoodId INT '$.FoodId'
			  ,FoodVarietyId INT '$.FoodVarietyId'
			  ,TableId varchar(100) '$.TableId'
			  ,Tariff DECIMAL(9,2) '$.Tariff'
			  ,Comments NVARCHAR(300) '$.Comments'
			  ,CancelDate DATETIME '$.CancelDate'
			  ,CancelCharges DECIMAL(9,2) '$.CancelCharges'
			  ,OrderQuantity INT '$.OrderQuantity'
			  ,CancelRefund DECIMAL(9,2) '$.CancelRefund'
			  ,NetTariff DECIMAL(9,2) '$.NetTariff'
			  ,WaiterId INT '$.WaiterId'
			  ,ServedTime TIME(7) '$.ServedTime'
			  ,BookedChairs VARCHAR(250) '$.BookedChairs'
			  ,BookingType VARCHAR(20) '$.BookingType'
			  ,OrderHeaderSl BIGINT '$.OrderHeaderSl'
			  ,SoftDrinkId INT '$.SoftDrinkId'
			  ,SoftDrinkQuantityId INT '$.SoftDrinkQuantityId'
			  ,BuffetId INT '$.BuffetId'
			  ,ComplementaryId INT '$.ComplementaryId'
			  ,CGST DECIMAL(6,2) '$.CGST'
			  ,SGST DECIMAL(6,2) '$.SGST'
			)

			IF @@ROWCOUNT > 0
				BEGIN
	
					DECLARE orderDetailsCursor CURSOR FAST_FORWARD FOR
						SELECT * FROM @subOrderDetail
	
					OPEN orderDetailsCursor

					FETCH NEXT FROM orderDetailsCursor INTO @subOrderSl,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,@subComments,
														@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subNetTariff,@subWaiterId,@subServedTime,
														@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
														@subCGST,@subSGST
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF @subOrderSl IS NOT NULL
								BEGIN
									IF @subSoftDrinkId IS NULL
										BEGIN
											
											UPDATE OrderDetails SET OrderQuantity = @subOrderQuantity , NetTariff = Tariff * @subOrderQuantity WHERE OrderSl= @subOrderSl
											IF @@ROWCOUNT = 0
												BEGIN
													SELECT 'Data Not Inserted', 0
													ROLLBACK
												END
										END
									ELSE
									    
										BEGIN
											SET @newQuantity = (SELECT TOP 1 OrderQuantity - @subOrderQuantity FROM OrderDetails WHERE OrderSl = @subOrderSl)

											UPDATE OrderDetails SET OrderQuantity = @subOrderQuantity , NetTariff = Tariff * @subOrderQuantity WHERE OrderSl= @subOrderSl
											IF @@ROWCOUNT > 0
												BEGIN
													 WHILE @newQuantity > 0
															BEGIN
																SELECT TOP 1 @tempId = sim.StockId, @remainingAmount=sim.BalanceQty FROM StockInMaster as sim
																WHERE sim.RestaurantId=@RestaurantId
																	AND sim.SoftDrinkId=@subSoftDrinkId
																	AND sim.SoftDrinkQuantityId =@subSoftDrinkQuantityId
																	AND sim.BalanceQty > 0
																IF @newQuantity > @remainingAmount
																	BEGIN
																		SET @issuedQty = @remainingAmount
																	END
																ELSE
																	BEGIN
																		SET @issuedQty = @newQuantity
																	END
		
																UPDATE StockInMaster SET IssuedQty = IssuedQty+ @issuedQty , BalanceQty = (@remainingAmount - @issuedQty) WHERE StockId = @tempId
																IF @@ROWCOUNT = 0
																	BEGIN
																		SELECT 'data not updated', 1
																		ROLLBACK
																	END
																SET @newQuantity = @newQuantity -@issuedQty
		
															END
													--UPDATE StockInMaster SET IssuedQty = IssuedQty + @newQuantity , BalanceQty = BalanceQty - @newQuantity WHERE SoftDrinkId = @subSoftDrinkId AND SoftDrinkQuantityId = @subSoftDrinkQuantityId
													--IF @@ROWCOUNT = 0
													--	BEGIN
													--		SELECT 'Data Not Inserted', 0
													--		ROLLBACK
													--	END
												END
											ELSE 
												BEGIN
													SELECT 'Data Not Inserted', 0
													ROLLBACK
												END
										END
								END
							ELSE
								BEGIN
								
									INSERT INTO OrderDetails ([RestaurantId],[OrderId],[FoodId],[FoodVarietyId],[TableId],[Tariff],[BookingStatus],[Comments],
														[CancelDate],[CancelCharges],[OrderQuantity],[CancelRefund],[NetTariff],[WaiterId],[OrderTime],[ServedTime],
														[BookedChairs],[BookingType],[OrderHeaderSl],[SoftDrinkId],[SoftDrinkQuantityId],[BuffetId],[ComplementaryId],
														[CustomerId],[CreatedBy],[OrderDate],CGST,SGST) 
										VALUES (@RestaurantId,@subOrderId,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,(SELECT TOP 1 BookingStatus FROM OrderHeader as oh WHERE OrderHeaderSl = @OrderHeaderSl),@subComments,
													@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subTariff * @subOrderQuantity,@subWaiterId,CAST(GETDATE() as time),@subServedTime,
													@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
													@CustomerId,@CreatedBy,GETDATE(),(SELECT TOP 1 TaxPercentage FROM TaxMaster WHERE TaxDescription='CGST' and ActiveStatus='A'),
													(SELECT TOP 1 TaxPercentage FROM TaxMaster WHERE TaxDescription='SGST' and ActiveStatus='A'))
										
										IF @@ROWCOUNT= 0
											BEGIN
												SELECT 'Data Not Inserted', 0
												ROLLBACK
											END
										ELSE
										    IF @subSoftDrinkId IS NOT NULL
											SET @newQuantity = @subOrderQuantity
								
												BEGIN
														 WHILE @newQuantity > 0
																BEGIN
																	SELECT TOP 1 @tempId = sim.StockId, @remainingAmount=sim.BalanceQty FROM StockInMaster as sim
																	WHERE sim.RestaurantId=@RestaurantId
																		AND sim.SoftDrinkId=@subSoftDrinkId
																		AND sim.SoftDrinkQuantityId =@subSoftDrinkQuantityId
																		AND sim.BalanceQty > 0
																	IF @newQuantity > @remainingAmount
																		BEGIN
																			SET @issuedQty = @remainingAmount
																		END
																	ELSE
																		BEGIN
																			SET @issuedQty = @newQuantity
																		END
															
		
																	UPDATE StockInMaster SET IssuedQty = IssuedQty+ @issuedQty , BalanceQty = (@remainingAmount - @issuedQty) WHERE StockId = @tempId
																	IF @@ROWCOUNT = 0
																		BEGIN
																			SELECT 'data not updated', 1
																			ROLLBACK
																		END
																	SET @newQuantity = @newQuantity -@issuedQty
		
																END
														--UPDATE StockInMaster SET IssuedQty = IssuedQty + @newQuantity , BalanceQty = BalanceQty - @newQuantity WHERE SoftDrinkId = @subSoftDrinkId AND SoftDrinkQuantityId = @subSoftDrinkQuantityId
														--IF @@ROWCOUNT = 0
														--	BEGIN
														--		SELECT 'Data Not Inserted', 0
														--		ROLLBACK
														--	END
													END
										    
								END
			
							FETCH NEXT FROM orderDetailsCursor INTO @subOrderSl,@subFoodId,@subFoodVarietyId,@subTableId,@subTariff,@subComments,
														@subCancelDate,@subCancelCharges,@subOrderQuantity,@subCancelRefund,@subNetTariff,@subWaiterId,@subServedTime,
														@subBookedChairs,@subBookingType,@subOrderHeaderSl,@subSoftDrinkId,@subSoftDrinkQuantityId,@subBuffetId,@subComplementaryId,
														@subCGST,@subSGST
						END
						CLOSE orderDetailsCursor
						DEALLOCATE orderDetailsCursor
						IF @@TRANCOUNT > 0
							BEGIN
								COMMIT
							END
						SELECT 'Data Inserted successfully', 1
						
				END
			ELSE
				BEGIN
					SELECT 'Data Not Inserted', 0
					ROLLBACK
				END
		END
	ELSE
		BEGIN
			SELECT 'Data Not Updated', 0
			ROLLBACK
		END

IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END


END
GO
/****** Object:  StoredProcedure [dbo].[samplePro]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[samplePro](@OrderSl int) as
BEGIN
SET NOCOUNT ON;
BEGIN TRAN
	UPDATE OrderDetails SET CancelCharges=0
	IF @@ROWCOUNT > 0 
		BEGIN
			COMMIT
			SELECT 'done' as status
		END
	ELSE
		BEGIN
			SELECT 'fail' as status
		END

END
GO
/****** Object:  StoredProcedure [dbo].[updateAddOnsData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateAddOnsData](@AddOnsId INT,
										@AddOnsName VARCHAR(100),
										@UpdatedBy INT,
										@ImageLink NVARCHAR(150),
										@RestaurantId INT,
										@AddOnsType VARCHAR(10)=NULL,
										@Tariff DECIMAL(9,2)=NULL
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM AddOns WHERE AddOnsId = @AddOnsId AND AddOnsName = @AddOnsName)
			BEGIN
				UPDATE AddOns SET AddOnsType=@AddOnsType,AddOnsName=@AddOnsName,ImageLink=@ImageLink,UpdatedBy=@UpdatedBy,Tariff=@Tariff,UpdatedDate = GETDATE()  WHERE AddOnsId = @AddOnsId AND RestaurantId=@RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Addons Already Exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateAddOnsMap]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateAddOnsMap](@FoodId INT,
										@AddOnsId VARCHAR(100)=NULL,									
										@UpdatedBy INT
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
				UPDATE AddOnsMap SET AddOnsId=@AddOnsId,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE FoodId=@FoodId 
				IF @@ROWCOUNT>0
					BEGIN
						 COMMIT
						 SELECT 'Data Updated Successfully',1
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateAllItems]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[updateAllItems](@RestaurantId INT,
								@UpdatedBy INT,
								@FoodIds NVARCHAR(MAX))
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @subFoodId INT;
	DECLARE	@tempTab TABLE(FoodId INT);
	BEGIN TRAN

	 INSERT INTO @tempTab SELECT FoodId
							FROM OPENJSON(@FoodIds)
								WITH (FoodId INT '$.FoodId')
		IF @@ROWCOUNT > 0
			BEGIN
			IF EXISTS (SELECT * FROM AllItems WHERE RestaurantId = @RestaurantId AND FoodId NOT IN (SELECT FoodId FROM @tempTab))
				BEGIN
					DELETE FROM AllItems WHERE RestaurantId=@RestaurantId AND FoodId NOT IN (SELECT FoodId FROM @tempTab)
					IF @@ROWCOUNT = 0
						BEGIN
							SELECT 'Data Not Updated2', 0
							ROLLBACK
						END
				END
			DECLARE allItemsCursor CURSOR FAST_FORWARD FOR
			SELECT * FROM @tempTab
				OPEN allItemsCursor
				FETCH NEXT FROM allItemsCursor INTO @subFoodId
				WHILE @@FETCH_STATUS = 0
					BEGIN
						IF NOT EXISTS (SELECT * FROM AllItems WHERE RestaurantId= @RestaurantId AND FoodId=@subFoodId)
							BEGIN
								INSERT INTO AllItems (RestaurantId,FoodId,ActiveStatus,Createdby,CreatedDate) 
									VALUES (@RestaurantId,@subFoodId,'A',@UpdatedBy,GETDATE())
								IF @@ROWCOUNT = 0
								BEGIN
									SELECT 'Data Not Updated', 0
									ROLLBACK
								END
							END
										


						FETCH NEXT FROM allItemsCursor INTO @subFoodId
					END
					CLOSE allItemsCursor
					DEALLOCATE allItemsCursor
			IF @@TRANCOUNT > 0
				BEGIN
					COMMIT
				END
				SELECT 'Data Updated Successfully', 1
					
				
					
			END
		ELSE
			BEGIN
				SELECT 'Data Not Updated', 0
				ROLLBACK
			END



IF @@TRANCOUNT > 0
	BEGIN
		COMMIT
	END
END
GO
/****** Object:  StoredProcedure [dbo].[updateBookingTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateBookingTypeData](@RestaurantId INT,
									@BookingType NVARCHAR(20),
									@UpdatedBy INT,
									@BookingTypeId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS( SELECT * FROM BookingTypeMaster WHERE BookingType = @BookingType AND RestaurantId= @RestaurantId AND BookingTypeId !=@BookingTypeId)
			BEGIN
				UPDATE BookingTypeMaster SET BookingType=@BookingType,ActiveStatus='A',UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE() WHERE BookingTypeId = @BookingTypeId AND RestaurantId = @RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Booking Type already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateBuffetData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateBuffetData](@BuffetId INT,
											  @RestaurantId INT,
											  @BuffetName NVARCHAR(50),
											  @FoodItems VARCHAR(50),
											  @FromDate DATE,
											  @ToDate DATE,
											  @BuffetTimings VARCHAR(50),
											  @Tariff DECIMAL(9,2),
											  @Updatedby INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM BuffetMaster WHERE BuffetId! = @BuffetId AND BuffetName = @BuffetName AND RestaurantId=@RestaurantId)
			BEGIN
				UPDATE BuffetMaster SET BuffetName=@BuffetName,FoodItems=@FoodItems,FromDate=@FromDate,ToDate=@ToDate,BuffetTimings=@BuffetTimings,Tariff=@Tariff,ActiveStatus='A',Updatedby=@Updatedby, UpdatedDate=GETDATE() WHERE BuffetId=@BuffetId AND RestaurantId=@RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Buffet Name already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateComplementaryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateComplementaryData](@UniqueId INT,
										@RestaurantId INT,
										@FoodTimingId INT,
										@FoodId VARCHAR(100)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * From ComplementaryMaster WHERE FoodTimingId=@FoodTimingId AND RestaurantId=@RestaurantId AND UniqueId=@UniqueId)
			BEGIN
				UPDATE ComplementaryMaster SET RestaurantId=@RestaurantId,FoodTimingId=@FoodTimingId ,FoodId=@FoodId,ActiveStatus='A' WHERE  UniqueId=@UniqueId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'ComplementaryMaster already exists',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateConfigMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateConfigMasterData](@TypeId INT,
											  @ConfigId INT,
											  @ConfigName NVARCHAR(150),
											  @UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigurationMaster WHERE TypeId = @TypeId AND ConfigId != @ConfigId AND ConfigName=@ConfigName)
			BEGIN
				UPDATE ConfigurationMaster SET ConfigName=@ConfigName,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE TypeId = @TypeId AND ConfigId=@ConfigId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Configuration Master Already Exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateConfigTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateConfigTypeData](@TypeName NVARCHAR(150),
											  @UpdatedBy INT,
											  @TypeId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM ConfigurationType WHERE TypeId != @TypeId AND TypeName = @TypeName)
			BEGIN
				UPDATE ConfigurationType SET TypeName=@TypeName,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE TypeId=@TypeId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Type Name already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateDinningData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateDinningData](@DinningId INT,
										@RestaurantId INT,
										@DinningType NVARCHAR(20),
										@UpdatedBy INT
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * From DinningMaster WHERE  RestaurantId=@RestaurantId AND DinningType=@DinningType AND DinningId!=@DinningId)
			BEGIN
				UPDATE DinningMaster SET DinningType=@DinningType,UpdatedBy=@UpdatedBy,ActiveStatus='A', UpdatedDate = GETDATE()  WHERE DinningId = @DinningId AND RestaurantId=@RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Dinning type already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateDinningTableData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateDinningTableData](@TableId INT=NULL,
										@DinningId INT=NULL,
										@TableName NVARCHAR(20)=NULL,
										@ChairCount INT=NULL,
										@UpdatedBy INT=NULL
										--@RestaurantId INT=NULL
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (select * from DinningTableMaster where  TableId!=@TableId AND TableName=@TableName AND DinningId=@DinningId )
			BEGIN
				UPDATE DinningTableMaster SET DinningId=@DinningId,TableName=@TableName,ChairCount=@ChairCount,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate = GETDATE()  WHERE TableId = @TableId 
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'DinningTable name already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateFoodCategoryData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateFoodCategoryData](@FoodCategoryId INT,
											  @RestaurantId INT,
											  @FoodCategoryName NVARCHAR(50),
											  @UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM FoodCategoryMaster WHERE RestaurantId = @RestaurantId AND FoodCategoryName = @FoodCategoryName AND FoodCategoryId= @FoodCategoryId)
			BEGIN
				UPDATE FoodCategoryMaster SET FoodCategoryName=@FoodCategoryName,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE FoodCategoryId=@FoodCategoryId AND RestaurantId=@RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'FoodCategoryName Already Exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateFoodData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateFoodData](@FoodId INT,
										@RestaurantId INT,
										@FoodName NVARCHAR(100),
										@Description NVARCHAR(250)=NULL,
										@FoodCategoryId INT,
										@ImageLink NVARCHAR(150)=NULL,
										@UpdatedBy INT,
										@FoodTimingId VARCHAR(30)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM FoodMaster WHERE  FoodName= @FoodName and FoodCategoryId=@FoodCategoryId AND RestaurantId=@RestaurantId AND FoodId != @FoodId)
			BEGIN
				UPDATE FoodMaster SET ImageLink=@ImageLink,Description = @Description,FoodName = @FoodName,FoodCategoryId=@FoodCategoryId,FoodTimingId=@FoodTimingId,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE()  WHERE FoodId = @FoodId AND RestaurantId=@RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Food name already exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateFoodItems]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateFoodItems](@UniqueId INT,
										@RestaurantId INT,
										@BarId INT,
										@FoodItems VARCHAR(100),
										@UpdatedBy INT
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE MapFoodItemsToBar SET RestaurantId=@RestaurantId,FoodItems=@FoodItems,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE UniqueId = @UniqueId AND BarId = @BarId 
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateFoodQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateFoodQuantityData](@UniqueId INT,
										@FoodId INT,
										@FoodQuantityId INT=NULL,
										@UpdatedBy INT,
										@Tariff DECIMAL(9,2),
										@RestaurantId INT,
										@FoodCategoryId INT=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
				UPDATE FoodQuantityMaster SET FoodQuantityId=@FoodQuantityId,ActiveStatus='A',UpdatedBy=@UpdatedBy,Tariff=@Tariff,FoodCategoryId=@FoodCategoryId, UpdatedDate = GETDATE()  WHERE FoodId = @FoodId AND RestaurantId = @RestaurantId AND UniqueId=@UniqueId 
				IF @@ROWCOUNT>0
					BEGIN
						 COMMIT
						 SELECT 'Data Updated Successfully',1
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateFoodTimingData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateFoodTimingData](
											  --@UniqueId INT=NULL,
											  @RestaurantId INT=NULL,
											  @FoodTimingName NVARCHAR(50)=NULL,
											  @FoodTimingId INT=NULL,
											  @StartTime DATETIME=NULL,
											  @EndTime DATETIME=NULL,
											  @UpdatedBy INT=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
				UPDATE FoodTimingMaster SET RestaurantId=ISNULL(@RestaurantId,RestaurantId),FoodTimingName=ISNULL(@FoodTimingName,FoodTimingName),StartTime=@StartTime,EndTime=@EndTime,ActiveStatus='A',Updatedby=@UpdatedBy, UpdatedDate=GETDATE() WHERE FoodTimingId=@FoodTimingId
				IF @@ROWCOUNT>0
					BEGIN
						 COMMIT
						 SELECT 'Data Updated Successfully',1
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateItemIssHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateItemIssHdrDtlData](@IssueId INT,
									@IssueDate DATE,
									@RestaurantId INT,
									@IssueRef NVARCHAR(100)=NULL,
									@UpdatedBy INT,
									@ItemId INT,
									@IssuedQty DECIMAL(9,3)=NULL,
									@IssueRate DECIMAL(9,3)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemIssHdr SET IssueDate=@IssueDate,RestaurantId=@RestaurantId,IssueRef=@IssueRef,ActiveStatus='A',UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE()  WHERE IssueId = @IssueId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE ItemIssDtl SET ItemId=@ItemId,IssuedQty=@IssuedQty,IssueRate=@IssueRate WHERE IssueId = @IssueId
					IF @@ROWCOUNT>0
						BEGIN
								SELECT 'Data updated successfully.',1
								COMMIT
						END

					ELSE
						BEGIN
							SELECT 'Data Not updated',0
							ROLLBACK
						END
				 END

			ELSE
				BEGIN
					SELECT 'Data Not updated',0
					ROLLBACK
				END
				
	
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateItemMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateItemMasterData](@ItemId INT,
									@ItemDescription NVARCHAR(100),
									@ItemType INT,
									@RestaurantId INT,
									@UOM INT,
									@ItemRate DECIMAL(9,2)=NULL,
									@OpeningQty DECIMAL(12,3)=NULL,
									@ReceivedQty DECIMAL(12,3)=NULL,
									@IssuedQty DECIMAL(12,3)=NULL,
									@BalanceQty DECIMAL(12,3)=NULL,
									@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemMaster SET ItemDescription=@ItemDescription,ItemType=@ItemType,RestaurantId=@RestaurantId,UOM=@UOM,ItemRate=@ItemRate,OpeningQty=@OpeningQty,ReceivedQty=@ReceivedQty,IssuedQty=@IssuedQty,BalanceQty=@BalanceQty,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE ItemId=@ItemId
			IF @@ROWCOUNT>0
				BEGIN
						SELECT 'Data updated successfully.',1
						COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not updated',0
					ROLLBACK
				END
	
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateItemPurHdrDtlData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateItemPurHdrDtlData](@PurchaseId INT,
									@PurchaseDate DATE,
									@RestaurantId INT,
									@VendorId INT,
									@VendorRef NVARCHAR(100)=NULL,
									@UpdatedBy INT,
									@ItemId INT,
									@ReceivedQty DECIMAL(9,3)=NULL,
									@AcceptedQty DECIMAL(9,3)=NULL,
									@RejectedQty DECIMAL(9,3)=NULL,
									@RejectionReason NVARCHAR(150)=NULL,
									@PurchaseRate DECIMAL(9,2)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ItemPurHdr SET PurchaseDate=@PurchaseDate,RestaurantId=@RestaurantId,VendorId=@VendorId,VendorRef=@VendorRef,ActiveStatus='A',UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE()  WHERE PurchaseId = @PurchaseId
			IF @@ROWCOUNT>0
				BEGIN
					UPDATE ItemPurDtl SET ItemId=@ItemId,ReceivedQty=@ReceivedQty,AcceptedQty=@AcceptedQty,RejectedQty=@RejectedQty,RejectionReason=@RejectionReason,PurchaseRate=@PurchaseRate  WHERE PurchaseId = @PurchaseId
					IF @@ROWCOUNT>0
						BEGIN
								SELECT 'Data updated successfully.',1
								COMMIT
						END

					ELSE
						BEGIN
							SELECT 'Data Not updated',0
							ROLLBACK
						END
				 END

			ELSE
				BEGIN
					SELECT 'Data Not updated',0
					ROLLBACK
				END
				
	
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateOfferMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateOfferMasterData](@OfferType CHAR(1),
									@OfferCategory INT,
									@OfferName NVARCHAR(100),
									@AmountType CHAR(1),
									@Offer DECIMAL(9,2),
									@MinBIllAmount DECIMAL(9,2)=NULL,
									@EffectiveFrom DATE,
									@EffectiveTill DATE=NULL,
									@UpdatedBy INT,
									@OfferId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM OfferMaster WHERE OfferName=@OfferName AND EffectiveFrom=@EffectiveFrom AND EffectiveTill=@EffectiveTill AND OfferId!=@OfferId)
			BEGIN
				UPDATE OfferMaster SET OfferType=@OfferType,OfferCategory=@OfferCategory,OfferName=@OfferName,AmountType=@AmountType,Offer=@Offer,MinBIllAmount=@MinBIllAmount,EffectiveFrom=@EffectiveFrom,EffectiveTill=@EffectiveTill,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE OfferId=@OfferId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not found.',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Data Already Exists!',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updatePreferenceMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updatePreferenceMasterData](@RestaurantId INT,
									@ChairOption CHAR(1),
									@RoomLink CHAR(1),
									@BarLink CHAR(1),
									@UpdatedBy INT,
									@PreferenceId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS( SELECT * FROM PreferenceMaster WHERE RestaurantId=@RestaurantId AND PreferenceId!=@PreferenceId)
			BEGIN
				UPDATE PreferenceMaster SET ChairOption=@ChairOption,RoomLink=@RoomLink,BarLink=@BarLink,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE() WHERE PreferenceId = @PreferenceId AND RestaurantId = @RestaurantId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Data Already Exists',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updatePrintStatus]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updatePrintStatus](@OrderHeaderSl INT,
										@RestaurantId INT,
										@HotelOrderId VARCHAR(50)=NULL,
										@HotelRoomNo INT=NULL,
										@DinningId INT=NULL,
										@TableId NVARCHAR(100)=NULL,
										@BookedChairs NVARCHAR(250)=NULL,
										@TableStatus CHAR(1)=NULL,
										@OrderId NVARCHAR(50),
										@OrderDate DATETIME,
										@CustomerId INT,
										@BookingType NVARCHAR(100),
										@GuestName NVARCHAR(100)=NULL,
										@GuestMobile NVARCHAR(10)=NULL,
										@GuestMailId NVARCHAR(50)=NULL,
										@CustomerGSTNo NVARCHAR(15)=NULL,
										@OfferId INT=NULL,
										@PaymentType INT=NULL,
										@BillAmount DECIMAL(9,2)=NULL,
										@OfferAmount DECIMAL(9,2)=NULL,
										@TaxAmount DECIMAL(9,2)=NULL,
										@NetAmount DECIMAL(9,2)=NULL,
										@BookingMedia CHAR(2),
										@BookingStatus CHAR(1),
										@PaymentStatus CHAR(1),
										@Comments NVARCHAR(300)=NULL,
										@CancelDate DATETIME=NULL,
										@CancelCharges DECIMAL(9,2)=NULL,
										@CancelRefund DECIMAL(9,2)=NULL,
										@UpdatedBy INT=NULL,
										@OrderFrom NVARCHAR(100),
										@PrintedBy INT=NULL,
										@PrintReason NVARCHAR(300)=NULL)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE OrderHeader SET HotelOrderId=@HotelOrderId,HotelRoomNo=@HotelRoomNo,DinningId=@DinningId,TableId=@TableId,BookedChairs=@BookedChairs,TableStatus=@TableStatus,OrderDate=@OrderDate,CustomerId=@CustomerId,BookingType=@BookingType,GuestName=@GuestName,GuestMobile=@GuestMobile,GuestMailId=@GuestMailId,CustomerGSTNo=@CustomerGSTNo,OfferId=@OfferId,PaymentType=@PaymentType,BillAmount=@BillAmount,OfferAmount=@OfferAmount,TaxAmount=@TaxAmount,NetAmount=@NetAmount,BookingMedia=@BookingMedia,BookingStatus=@BookingStatus,PaymentStatus=@PaymentStatus,Comments=@Comments,CancelDate=@CancelDate,CancelCharges=@CancelCharges,CancelRefund=@CancelRefund,UpdatedBy=@UpdatedBy,OrderFrom=@OrderFrom,PrintedBy=@PrintedBy,PrintReason=@PrintReason,UpdatedDate=GETDATE(), PrintDate = GETDATE(), PrintStatus = 'P' WHERE RestaurantId = @RestaurantId AND OrderId = @OrderId AND OrderHeaderSl = @OrderHeaderSl
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not found.',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateRestaurant]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateRestaurant](@BranchCode VARCHAR(10),
								@RestaurantName NVARCHAR(100),
								@Description NVARCHAR(300)=NULL,
								@HotelLocnId INT,
								@Address1 NVARCHAR(100),
								@Address2 NVARCHAR(100)=NULL,
								@Zipcode INT,
								@City NVARCHAR(50),
								@District NVARCHAR(50),
								@State NVARCHAR(50),
								@Latitude DECIMAL(12,8),
								@Longitude DECIMAL(12,8),
								@RestaurantManager INT,
								@OrderFrom TIME,
								@OrderTo TIME,
								@WorkingDays NVARCHAR(7),
								@MailId NVARCHAR(50),
								@UpdatedBy INT,
								@PhoneNumber NVARCHAR(15)=NULL,
								@GSTIN NVARCHAR(20),
								@PhoneNumber2 NVARCHAR(15)=NULL,
								@LogoUrl NVARCHAR(500)=NULL,
								@RestaurantId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	UPDATE RestaurantMaster SET BranchCode=@BranchCode,RestaurantName=@RestaurantName,Description=@Description,HotelLocnId=ISNULL(@HotelLocnId,HotelLocnId),Address1=@Address1,Address2=@Address2,Zipcode=@Zipcode,City=@City,District=@District,State=@State,Latitude=@Latitude,Longitude=@Longitude,RestaurantManager=@RestaurantManager,OrderFrom=@OrderFrom,OrderTo=@OrderTo,WorkingDays=@WorkingDays,MailId=@MailId,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE(),PhoneNumber=@PhoneNumber,GSTIN=@GSTIN,PhoneNumber2=@PhoneNumber2,LogoUrl=@LogoUrl WHERE RestaurantId = @RestaurantId 
	IF @@ROWCOUNT>0
		BEGIN
				UPDATE [Paypre common].dbo.BranchMaster SET BranchCode=@BranchCode,BranchName=@RestaurantName,Description=@Description,HotelLocnId=ISNULL(@HotelLocnId,HotelLocnId),Address1=@Address1,Address2=@Address2,Zipcode=@Zipcode,City=@City,District=@District,State=@State,Latitude=@Latitude,Longitude=@Longitude,RestaurantManager=@RestaurantManager,OrderFrom=@OrderFrom,OrderTo=@OrderTo,WorkingDays=@WorkingDays,MailId=@MailId,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE(),PhoneNumber=@PhoneNumber,GSTIN=@GSTIN,PhoneNumber2=@PhoneNumber2,LogoUrl=@LogoUrl WHERE BranchId = @RestaurantId
				IF @@ROWCOUNT = 0
				BEGIN
					SELECT 'Data Not Updated',0
					IF @@TRANCOUNT>0 
						BEGIN
							ROLLBACK
						END
				END
			IF @@TRANCOUNT>0 
				BEGIN
					SELECT 'Data Updated Successfully',1
					COMMIT
				END
		END

	ELSE
		BEGIN
			SELECT 'Data Not Updated',0
			IF @@TRANCOUNT>0 
				BEGIN
					ROLLBACK
				END
		END
	
IF @@TRANCOUNT>0
	BEGIN
		COMMIT
	END

END
GO
/****** Object:  StoredProcedure [dbo].[updateShiftMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateShiftMasterData](@ShiftName NVARCHAR(100),
									@StartTime TIME,
									@EndTime TIME,
									@BreakStartTime TIME=NULL,
									@BreakEndTime TIME=NULL,
									@GracePeriod TINYINT,
									@UpdatedBy INT,
									@ShiftId INT,
									@BranchId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM ShiftMaster WHERE ShiftId=@ShiftId AND ShiftName!=@ShiftName AND BranchId=@BranchId)
			BEGIN
				UPDATE ShiftMaster SET BranchId=@BranchId,ShiftName=@ShiftName,StartTime=@StartTime,EndTime=@EndTime,BreakStartTime=@BreakStartTime,BreakEndTime=@BreakEndTime,GracePeriod=@GracePeriod,ActiveStatus='A',UpdatedBy=@UpdatedBy, UpdatedDate=GETDATE() WHERE ShiftId=@ShiftId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Data Not found.',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateShiftWiseStatusChange]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateShiftWiseStatusChange](@RestaurantId INT,
										@ShiftId INT,
										@CustomerId INT,
										@HandOverTo INT=NULL,
										@Date DATE,
										@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ShiftWiseStockMaster SET Status='A',UpdatedBy=@UpdatedBy WHERE RestaurantId = @RestaurantId AND CustomerId = @CustomerId AND ShiftId=@ShiftId AND CAST(CreatedDate as DATE) = CAST(@Date as Date)
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateShiftWiseStockInMaster]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateShiftWiseStockInMaster](@RestaurantId INT,
										@CustomerId INT,
										@HandOverTo INT=NULL,
										@CreatedBy INT,
										@Date DATE,
										@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE ShiftWiseStockMaster SET HandOverTo = @HandOverTo,UpdatedBy=@UpdatedBy WHERE RestaurantId = @RestaurantId AND CustomerId = @CustomerId AND CreatedBy = @CreatedBy AND CAST(CreatedDate as DATE) = CAST(@Date as Date)
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateSoftDrinkData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateSoftDrinkData](@SoftDrinkId INT=NULL,
										@RestaurantId INT=NULL,
										@SoftDrinkName VARCHAR(100)=NULL,
										@Description NVARCHAR(250)=NULL,
										@ImageLink NVARCHAR(150)=NULL,
										@UpdatedBy INT=NULL
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
	IF NOT EXISTS (SELECT * FROM SoftDrinkMaster WHERE SoftDrinkName=@SoftDrinkName AND RestaurantId=@RestaurantId AND SoftDrinkId!=@SoftDrinkId)
			BEGIN
				UPDATE SoftDrinkMaster SET RestaurantId=@RestaurantId,SoftDrinkName=@SoftDrinkName,Description=@Description,ImageLink=ISNULL(@ImageLink,ImageLink),UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE SoftDrinkId=@SoftDrinkId
				IF @@ROWCOUNT>0
					BEGIN
						 SELECT 'Data Updated Successfully',1
						 COMMIT
					END

				ELSE
					BEGIN
						SELECT 'Data Not Updated',0
						ROLLBACK
					END
			END
	ELSE
		BEGIN
			SELECT 'Soft Drink Name already exists',0
			COMMIT
		END
	

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateSoftDrinkQuantityData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateSoftDrinkQuantityData](@UniqueId INT,
										@RestaurantId INT,
										@SoftDrinkId INT,
										@SoftDrinkQuantityId VARCHAR(100),
										@Tariff DECIMAL(9,2),
										@UpdatedBy INT,
										@ActualRate DECIMAL(9,2)=NULL,
										@Margin DECIMAL(9,2)=NULL
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE SoftDrinkQuantityMaster SET SoftDrinkQuantityId=@SoftDrinkQuantityId,Tariff=@Tariff,UpdatedBy=@UpdatedBy,ActualRate=@ActualRate,Margin=@Margin,UpdatedDate=GETDATE() WHERE UniqueId = @UniqueId AND SoftDrinkId = @SoftDrinkId AND RestaurantId=@RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateStock]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [updateStock] '30',76,1026,119
--select * from StockInMaster where SoftDrinkId=1026 and SoftDrinkQuantityId=119

CREATE PROCEDURE [dbo].[updateStock] (@need int,@RestaurantId int,@SoftDrinkId int,@SoftDrinkQuantityId int)
AS
BEGIN
DECLARE @tempId INT
DECLARE @remainingAmount INT
DECLARE @issuedQty INT

WHILE @need > 0
	BEGIN
		SELECT TOP 1 @tempId = sim.StockId, @remainingAmount=sim.BalanceQty FROM StockInMaster as sim
		WHERE sim.RestaurantId=@RestaurantId
			AND sim.SoftDrinkId=@SoftDrinkId
			AND sim.SoftDrinkQuantityId =@SoftDrinkQuantityId
			AND sim.BalanceQty > 0
		IF @need > @remainingAmount
			BEGIN
				SET @issuedQty = @remainingAmount
			END
		ELSE
			BEGIN
				SET @issuedQty = @need
			END
		
		UPDATE StockInMaster SET IssuedQty = IssuedQty+ @issuedQty , BalanceQty = (@remainingAmount - @issuedQty) WHERE StockId = @tempId
		IF @@ROWCOUNT = 0
			BEGIN
				SELECT 'data not updated', 1
				ROLLBACK
			END
		SET @need = @need -@issuedQty
		
	END

END
GO
/****** Object:  StoredProcedure [dbo].[updateStockInMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateStockInMasterData](@StockId INT,
										@RestaurantId INT,
										@SoftDrinkId INT=NULL,
										@SoftDrinkQuantityId VARCHAR(100),
										@ReceivedQty DECIMAL(12,3),
										@IssuedQty DECIMAL(12,3)=NULL,
										@BalanceQty DECIMAL(12,3)=NULL,
										@Rate DECIMAL(9,2)=NULL,
										@TotalAmt DECIMAL(9,2),
										@UpdatedBy INT
										)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE StockInMaster SET RestaurantId=@RestaurantId,SoftDrinkId=@SoftDrinkId,SoftDrinkQuantityId=@SoftDrinkQuantityId,ReceivedQty=@ReceivedQty,IssuedQty=@IssuedQty,BalanceQty=@BalanceQty,Rate=@Rate,TotalAmt=@TotalAmt,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE StockId = @StockId 
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateTableStatus]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateTableStatus](@TableStatus CHAR(1),
										@RestaurantId INT,
										@OrderHeaderSl INT,
										@DinningId INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE OrderHeader SET TableStatus = @TableStatus WHERE RestaurantId = @RestaurantId AND OrderHeaderSl = @OrderHeaderSl AND DinningId = @DinningId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not found.',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateTariffMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateTariffMasterData](@RestaurantId INT,
								@TariffTypeId INT,
								@FoodId INT,
								@FoodQuantityId INT,
								@Tariff DECIMAL(9,2),					
								@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TariffMaster SET FoodQuantityId=@FoodQuantityId,Tariff=@Tariff,UpdatedBy=@UpdatedBy,UpdatedDate=GETDATE() WHERE RestaurantId = @RestaurantId AND TariffTypeId = @TariffTypeId AND FoodId = @FoodId 
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateTariffTypeData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateTariffTypeData](@TariffTypeId INT,
								@RestaurantId INT,
								@TariffTypeName NVARCHAR(100),
								@SeasonStart DATE=NULL,
								@SeasonEnd DATE=NULL,					
								@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TariffType SET TariffTypeName=@TariffTypeName,SeasonStart=@SeasonStart,SeasonEnd=@SeasonEnd,UpdatedBy=@UpdatedBy, UpdatedDate = GETDATE()  WHERE RestaurantId = @RestaurantId AND TariffTypeId =@TariffTypeId 
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateTaxMasterData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateTaxMasterData](@UniqueId INT,
									@TaxId INT,
									@ServiceName NVARCHAR(50),
									@TaxDescription NVARCHAR(50),
									@TaxPercentage DECIMAL(3,2)=NULL,
									@EffectiveFrom DATE,
									@EffectiveTill DATE=NULL,
									@RefNumber NVARCHAR(50)=NULL,
									@RefDate DATE=NULL,
									@RefDocumentLink NVARCHAR(150)=NULL,
									@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE TaxMaster SET TaxId=@TaxId,ServiceName=@ServiceName,TaxDescription=@TaxDescription,TaxPercentage=@TaxPercentage,EffectiveFrom=@EffectiveFrom,EffectiveTill=@EffectiveTill,RefNumber=@RefNumber,RefDate=@RefDate,RefDocumentLink=@RefDocumentLink,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE()  WHERE UniqueId = @UniqueId
			IF @@ROWCOUNT>0
				BEGIN
						SELECT 'Data updated successfully.',1
						COMMIT
				END

			ELSE
				BEGIN
					SELECT 'Data Not updated',0
					ROLLBACK
				END
	
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateUPIData]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateUPIData](@RestaurantId INT,
										@UPIMasterId INT,
										@Name NVARCHAR(100),
										@Mobile BIGINT,
										@UPIId NVARCHAR(100),
										@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON; 
	BEGIN TRAN
	
			UPDATE UPIMaster SET Name=@Name,Mobile=ISNULL(@Mobile,Mobile) ,UPIId=@UPIId,UpdatedBy=@UpdatedBy,UpdatedDate = GETDATE()  WHERE UPIMasterId = @UPIMasterId AND RestaurantId = @RestaurantId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateWaiterDetails]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateWaiterDetails](@RestaurantId INT,
								@WaiterId INT,
								@FirstName NVARCHAR(50),
								@LastName NVARCHAR(50),
								@Mobile BIGINT,
								@Email NVARCHAR(100),
								@ShiftId INT,
								@Aadhar BIGINT,
								@WaiterType VARCHAR(20),
								@Zipcode INT,
								@City VARCHAR(50),
								@District VARCHAR(50),
								@State VARCHAR(50),
								@Address1 NVARCHAR(100),
								@Address2 NVARCHAR(100),
								@ImageLink NVARCHAR(150),
								@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE WaiterMaster SET FirstName=@FirstName,LastName=@LastName,Mobile=@Mobile,Email=@Email,ShiftId=@ShiftId,Aadhar=@Aadhar,WaiterType=@WaiterType,Zipcode=@Zipcode,City=@City,District=@District,State=@State,Address1=@Address1,Address2=@Address2,ImageLink=@ImageLink,UpdatedBy=@UpdatedBy, UpdatedDate = GETDATE()  WHERE RestaurantId = @RestaurantId AND WaiterId =@WaiterId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[updateWaiterMapping]    Script Date: 27-Jul-23 11:33:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateWaiterMapping](@RestaurantId INT,
										@MappingId INT,
										@WaiterId NVARCHAR(100),
										@DinningId NVARCHAR(50),
										@UpdatedBy INT)

AS

BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			UPDATE WaiterMappingMaster SET RestaurantId=@RestaurantId,WaiterId=@WaiterId,DinningId=@DinningId,UpdatedBy=@UpdatedBy WHERE MappingId = @MappingId
			IF @@ROWCOUNT>0
				BEGIN
						COMMIT
						SELECT 'Data Updated Successfully',1
				END

			ELSE
				BEGIN
					SELECT 'Data Not Updated',0
					ROLLBACK
				END
	
IF @@TRANCOUNT>0
	COMMIT

END
GO
