USE [RocksFit]
GO
/****** Object:  StoredProcedure [dbo].[GetFooditem]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- =================================
--- Modify By Brijin
--- Date 10-01-23
--- =================================
--EXEC GetFooditem '100261','62','1','6:00 AM','2023-02-13','2023-04-13','2432','100001'

CREATE PROCEDURE [dbo].[GetFooditem] (@UserId INT=NULL,
									    @BookingId INT=NULL,
										@DietType INT=NULL,
										@WakeUpTime Time=NULL,
										@fromDate DATE=NULL,
										@ToDate DATE=NULL,
										@TotalCalories INT=NULL,
										@CreatedBy INT=NULL)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE @data nvarchar(max);

	DECLARE @ConfigName nvarchar(50);
	DECLARE @Id nvarchar(max);
	set @ConfigName=(select mc.configName from Mstr_DietType as md inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId where md.dietTypeId=@DietType)
	IF @configName='Vegeterian'
				BEGIN
					set @Id=(SELECT Stuff(
							(
							SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
							FROM Mstr_DietType as md 
							inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
							WHERE mc.configName IN ( 'Vegeterian','Vegan')
							FOR XML PATH('')
							), 1,1,'') AS ids)
				END
			ELSE IF @configName='Vegan'
				BEGIN
					set @Id=(SELECT Stuff(
							(
							SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
							FROM Mstr_DietType as md 
							inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
							WHERE mc.configName IN ('Vegan')
							FOR XML PATH('')
							), 1,1,'') AS ids)
				END
			ELSE IF @configName='Omnivore'
				BEGIN
					set @Id=(SELECT Stuff(
							(
							SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
							FROM Mstr_DietType as md 
							inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
							FOR XML PATH('')
							), 1,1,'') AS ids)
				END

			ELSE IF @configName='Eggtarian'
				BEGIN
					set @Id=(SELECT Stuff(
							(
							SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
							FROM Mstr_DietType as md 
							inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
							WHERE mc.configName IN ('Vegan','Eggtarian','Vegeterian')
							FOR XML PATH('')
							), 1,1,'') AS ids)
				END
			ELSE IF @configName='Sea Food'
				BEGIN
					set @Id=(SELECT Stuff(
							(
							SELECT ', '+cast(md.dietTypeId AS VARCHAR(10))
							FROM Mstr_DietType as md 
							inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
							WHERE mc.configName IN ('Vegan','Sea Food','Vegeterian')
							FOR XML PATH('')
							), 1,1,'') AS ids)
				END

			ELSE
				BEGIN
				set @Id=(select '0' as ids)
				END

	SET @data=(SELECT (SELECT DISTINCT um.userId,dt.dietTypeNameId,dt.dietTypeId,b.fromDate,b.toDate,b.branchId,b.branchName,bm.gymOwnerId,b.bookingId,
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) AS breakfastTime,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f

							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType

							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs)
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast') 
								AND ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='BreakFast'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='BreakFast'))>=@TotalCalories )

								AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS breakFast,
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast_Alter') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='BreakFast_Alter'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS breakFast_Alter,

							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) AS snacks1Time,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1') 
								AND ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks1'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
									AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks1'))>=@TotalCalories )
								AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS Snacks1,
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks_Alter1') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks_Alter1'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS Snacks_Alter1,

							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) AS lunchTime,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch') 
								AND ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Lunch'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
									AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Lunch'))>=@TotalCalories )
								AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS Lunch,
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch_Alter') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Lunch_Alter'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS Lunch_Alter,

							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) AS snacks2Time,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime ,
							CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2') AND 
				            ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks2'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
									AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks2'))>=@TotalCalories )
							AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS Snacks2,
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks_Alter2') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks_Alter2'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS Snacks_Alter2,

							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) as dinnerTime,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner') 
								AND ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Dinner'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
									AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Dinner'))>=@TotalCalories )
								AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS Dinner,
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner_Alter') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Dinner_Alter'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS Dinner_Alter,

							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs 
																												FROM MstrMealTimeConfig as mc 
																												INNER JOIN Mstr_FoodDietTime as fd 
																												ON fd.mealType=mc.mealTypeId 
																												AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME), 100))+' - ' +
							(SELECT CONVERT(varchar(15),CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs 
																												FROM MstrMealTimeConfig as mc 
																												INNER JOIN Mstr_FoodDietTime as fd 
																												ON fd.mealType=mc.mealTypeId  
																												AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME), 100)) AS snacks3Time,

							ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							FROM Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
							WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3') 
								AND ((SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
								AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks3'))<=@TotalCalories or (
									SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId 
									AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks3'))>=@TotalCalories )
								AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
							FOR JSON PATH),'[{"dietTimeId":0}]') AS Snacks3
							--ISNULL((SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
							--(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
							--FROM Mstr_FoodItem as f
							--INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							--INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
							--INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
							--INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.uniqueId
							--WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks_Alter3') AND (SELECT SUM(f.calories) FROM Mstr_FoodItem as f INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName ='Snacks_Alter3'))<=@TotalCalories
							--FOR JSON PATH),'[]') AS Snacks_Alter3
							FROM  Mstr_FoodItem as f
							INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
							INNER JOIN Mstr_User as um ON um.userId=@userId
							--INNER JOIN Mstr_UserDietTime as ud ON ud.dietTimeId=fd.uniqueId
							INNER JOIN Mstr_DietType as dt ON dt.dietTypeId=f.dietTypeId
							INNER JOIN Tran_Booking as b ON b.userId=@UserId
							INNER JOIN Mstr_Branch as bm ON bm.branchId=b.branchId
							WHERE um.userId=@userId 
								AND b.bookingId=@BookingId 
								AND dt.dietTypeId=@DietType 
								AND (@fromDate BETWEEN b.fromDate AND b.toDate) AND (@ToDate BETWEEN b.fromDate AND b.toDate)
				FOR JSON PATH)) 


 IF @data IS NOT NULL
	BEGIN
	   IF NOT EXISTS(SELECT up.userId FROM Tran_UserDietPlan as up INNER JOIN Mstr_UserDietTime as ut ON up.userId=ut.userId  WHERE up.userId=@userId AND (@fromDate BETWEEN up.fromDate AND up.toDate) AND (@toDate BETWEEN up.fromDate AND up.toDate) and up.bookingId =@BookingId)
		  BEGIN
				INSERT INTO Tran_UserDietPlan(gymOwnerId,branchId,branchName,bookingId,userId,fromDate,toDate,generatedBy,createdBy,createdDate) SELECT gymOwnerId,branchId,branchName,bookingId,@userId,@fromDate,@todate,'ML',@createdBy,GETDATE()
						FROM OPENJSON (@data)

						WITH(   gymOwnerId INT '$.gymOwnerId',
								branchId INT '$.branchId',
								branchName NVARCHAR(100) '$.branchName',
								bookingId INT '$.bookingId'
								)
						IF @@ROWCOUNT >0
							BEGIN
								INSERT INTO Mstr_UserDietTime(userId,bookingId,dietTypeId,[dietTimeId],fromTime,toTime,createdBy,createdDate) SELECT @userId,@BookingId,dietTypeId,BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime,@createdBy,GETDATE()
										FROM OPENJSON (@data)

										WITH(   dietTypeId INT '$.dietTypeId',
												breakFast NVARCHAR(MAX) AS JSON,
												--breakFast_Alter NVARCHAR(MAX) AS JSON,
												Snacks1 NVARCHAR(MAX) AS JSON,
												--Snacks_Alter1 NVARCHAR(MAX) AS JSON,
												Lunch NVARCHAR(MAX) AS JSON,
												--Lunch_Alter NVARCHAR(MAX) AS JSON,
												Snacks2 NVARCHAR(MAX) AS JSON,
												--Snacks_Alter2 NVARCHAR(MAX) AS JSON,
												Dinner NVARCHAR(MAX) AS JSON,
												--Dinner_Alter NVARCHAR(MAX) AS JSON,
												Snacks3 NVARCHAR(MAX) AS JSON
												--Snacks_Alter3 NVARCHAR(MAX) AS JSON
												) AS TableA
										CROSS APPLY (SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
										(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
										FROM OPENJSON(TableA.breakFast)
														 WITH(
															   dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--	 SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.breakFast_Alter)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable
													UNION ALL
														 SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
														 (SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
														 FROM OPENJSON(TableA.Snacks1)
														 WITH(
															  dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--	 SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.Snacks_Alter1)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable
													UNION ALL
													SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
													(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
														 FROM OPENJSON(TableA.Lunch)
														 WITH(
															   dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.Lunch_Alter)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable
													UNION ALL
														 SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
														 (SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
														 FROM OPENJSON(TableA.Snacks2)
														 WITH(
															   dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--	 SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.Snacks_Alter2)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable
													UNION ALL
														 SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
														 (SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
														 FROM OPENJSON(TableA.Dinner)
														 WITH(
															   dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--	 SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.Dinner_Alter)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable
													UNION ALL
														 SELECT ISNULL(BrTable.dietTimeId,0) as dietTimeId,
														 (SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')) , 
														 CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
														 (SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME)) AS toTime
														 FROM OPENJSON(TableA.Snacks3)
														 WITH(
															   dietTimeId INT
															   --fromTime Time,
															   --toTime Time
														 )BrTable
													--UNION ALL
													--	 SELECT BrTable.dietTimeId,BrTable.fromTime,BrTable.toTime
													--	 FROM OPENJSON(TableA.Snacks_Alter3)
													--	 WITH(
													--		   dietTimeId INT,
													--		   fromTime Time,
													--		   toTime Time
													--	 )BrTable

										 )AS BrTable
								IF @@ROWCOUNT > 0						
									BEGIN
										INSERT INTO Mstr_UserFoodMenu(userId,bookingId,dietTimeId,foodItemId,foodItemName,servingIn,calories,alternative,createdBy,createdDate) SELECT @userId,@BookingId,BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories,'N',@createdBy,GETDATE()
												FROM OPENJSON (@data)

												WITH(   
														breakFast NVARCHAR(MAX) AS JSON,
														--breakFast_Alter NVARCHAR(MAX) AS JSON,
														Snacks1 NVARCHAR(MAX) AS JSON,
														--Snacks_Alter1 NVARCHAR(MAX) AS JSON,
														Lunch NVARCHAR(MAX) AS JSON,
														--Lunch_Alter NVARCHAR(MAX) AS JSON,
														Snacks2 NVARCHAR(MAX) AS JSON,
														--Snacks_Alter2 NVARCHAR(MAX) AS JSON,
														Dinner NVARCHAR(MAX) AS JSON,
														--Dinner_Alter NVARCHAR(MAX) AS JSON,
														Snacks3 NVARCHAR(MAX) AS JSON
														--Snacks_Alter3 NVARCHAR(MAX) AS JSON
														) AS TableA
												CROSS APPLY (SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																FROM OPENJSON(TableA.breakFast)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--		SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.breakFast_Alter)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable
															UNION ALL
																	SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																	FROM OPENJSON(TableA.Snacks1)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--		SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.Snacks_Alter1)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable
															UNION ALL
															SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																	FROM OPENJSON(TableA.Lunch)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.Lunch_Alter)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable
															UNION ALL
																	SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																	FROM OPENJSON(TableA.Snacks2)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--		SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.Snacks_Alter2)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable
															UNION ALL
																	SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																	FROM OPENJSON(TableA.Dinner)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--		SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.Dinner_Alter)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable
															UNION ALL
																	SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
																	FROM OPENJSON(TableA.Snacks3)
																	WITH(
																		dietTimeId INT,
																			foodItemId INT,
																			foodItemName NVARCHAR(100),
																			servingInId INT,
																			calories INT
																	)BrTable WHERE BrTable.dietTimeId!=0
															--UNION ALL
															--		SELECT BrTable.dietTimeId,BrTable.foodItemId,BrTable.foodItemName,BrTable.servingInId,BrTable.calories
															--		FROM OPENJSON(TableA.Snacks_Alter3)
															--		WITH(
															--			dietTimeId INT,
															--				foodItemId INT,
															--				foodItemName NVARCHAR(100),
															--				servingInId INT,
															--				calories INT
															--		)BrTable

													)AS BrTable
												IF @@ROWCOUNT > 0
													BEGIN
														COMMIT
														SELECT @data as 'UserFoodMenu',1 AS 'StatusCode'
													END
												ELSE
													BEGIN
														ROLLBACK
														SELECT  'Data Not Added',0
													END																	
									END
								ELSE
									BEGIN
										ROLLBACK
										SELECT  'Data Not Added in UserDietTime',0
									END	
							END
						ELSE
						   BEGIN
								ROLLBACK
								SELECT  'Data Not Added in userDietplan',0
							END	
		  END
	  ELSE
		  BEGIN
			COMMIT
			SELECT @DATA as 'UserFoodMenu',1 AS 'StatusCode'
		  END	
	END

	ELSE
		BEGIN
			COMMIT 
			SELECT 'No Data Found' AS 'UserFoodMenu' ,0 AS 'StatusCode'
		  END	




IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[GetFooditemEdit]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --exec [dbo].[GetFooditemEdit] 100099,28
 
CREATE PROCEDURE [dbo].[GetFooditemEdit] ( @UserId INT=NULL,
										  @bookingId INT = NUll)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;
	--DECLARE @data nvarchar(max);
	--DECLARE @data1 nvarchar(max);

		SELECT    (SELECT DISTINCT up.userId,dt.dietTypeNameId,cg.configName AS dietTypeName,dt.dietTypeId,b.fromDate,b.toDate,b.branchId,b.branchName,b.bookingId,
				  ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName ,
				  CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
				  dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId,
								dt.uniqueId as 'UserfoodDietTimeId'
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND  c.configName = 'BreakFast'  FOR JSON PATH ) , '[]' ) AS breakFast,

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'BreakFast_Alter' FOR JSON PATH ), '[]') AS breakFast_Alter,

							
							ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName ,
						  CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
							dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId ,dt.uniqueId as 'UserfoodDietTimeId'
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	 	
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks1' FOR JSON PATH ), '[]') AS snacks1,

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks_Alter1' FOR JSON PATH ), '[]') AS snacks_Alter1,

							
							ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName ,
							 CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
							dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId ,dt.uniqueId as 'UserfoodDietTimeId'
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	 	
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Lunch' FOR JSON PATH ), '[]') AS lunch,

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Lunch_Alter' FOR JSON PATH ), '[]') AS lunch_Alter,

							
							ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName ,
							   CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
							dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId,dt.uniqueId as 'UserfoodDietTimeId' 
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks2' FOR JSON PATH ), '[]') AS snacks2,

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks_Alter2' FOR JSON PATH ), '[]') AS snacks_Alter2,

							
							ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , 
						  CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
							dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId ,dt.uniqueId as 'UserfoodDietTimeId'
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Dinner' FOR JSON PATH ), '[]') AS dinner,

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Dinner_Alter' FOR JSON PATH ), '[]') AS dinner_Alter,

							
							ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName ,
							 CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
							dt.dietTypeId,ft.foodItemId,
								uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId ,dt.uniqueId as 'UserfoodDietTimeId'
								From Mstr_UserFoodMenu AS uf 
								INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
								INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
								INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 		
								INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
								INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
								INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
								INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
								AND uf.dietTimeId=dt.dietTimeId
								where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks3' FOR JSON PATH ), '[]') AS snacks3

							--ISNULL((SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , dt.fromTIme,dt.toTime,dt.dietTypeId,ft.foodItemId,
							--	uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
							--	From Mstr_UserFoodMenu AS uf 
							--	INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
							--	INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
							--	INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.uniqueId 	
							--	INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
							--	INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
							--	INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
							--	INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and  uf.bookingId = dt.bookingid
							--	where uf.userId = @UserId  AND b.bookingId= @bookingId and uf.bookingId=@bookingId AND c.configName = 'Snacks_Alter3' FOR JSON PATH ), '[]') AS snacks_Alter3
							FROM Mstr_UserFoodMenu as uf
							INNER JOIN Tran_UserDietPlan as up ON up.userId=@userId
							INNER JOIN Mstr_UserDietTime as ut ON ut.dietTimeId=uf.dietTimeId
							INNER JOIN Mstr_DietType as dt ON dt.dietTypeId=ut.dietTypeId
							INNER JOIN Tran_Booking as b ON b.userId=@UserId
							INNER JOIN Mstr_Configuration as cg ON cg.configId = dt.dietTypeNameId
							WHERE up.userId=@userId AND ut.userId=@UserId AND b.bookingId= @bookingId 
							FOR JSON PATH ) AS 'UserFoodMenu'
 IF @@TRANCOUNT>0
	COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[GetPaymentUPIDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetPaymentUPIDetails] (@gymOwnerId INT=NULL,
											@branchId INT =NULL)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;
	IF(@gymOwnerId != 0 AND @branchId != 0)
	  BEGIN
				SELECT (SELECT paymentUPIDetailsId, gymOwnerId,branchId,name,UPIId,phoneNumber,merchantCode,merchantId,ISNULL ( mode , '') as mode,ISNULL (orgId , '') AS orgId
		                ,ISNULL (sign ,  '') AS sign,ISNULL(url , '') AS url
				FROM paymentUPIDetails Where gymOwnerId =@gymOwnerId AND branchId=@branchId AND activeStatus='A'
				FOR  JSON PATH ) AS 'PaymentUPIDetails' 

      END
	ELSE
		BEGIN
			COMMIT 
			SELECT 'No Data Found' AS 'PaymentUPIDetails' ,0 AS 'StatusCode'
		  END	
		  


		  
IF @@TRANCOUNT>0
	COMMIT

END
							

				
GO
/****** Object:  StoredProcedure [dbo].[GetPriceDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******
Modified By Brijin 07-02-2023
*******/
CREATE PROCEDURE [dbo].[GetPriceDetails] (@gymOwnerId INT=NULL,
											@branchId INT =NULL,											
											@categoryId INT = Null ,
											@trainingMode CHAR = Null,
											@priceId INT = Null)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;

	IF(@trainingMode = 'O' AND @priceId = 0)
	  BEGIN
				SELECT (SELECT CP.priceId,FC.categoryId,FC.categoryName,CP.planDuration AS planDurationId,CG.configName AS planDuration,CP.trainingTypeId,
				CP.trainingMode,C.configName as trainingType,CP.taxId,CP.cgstTax,CP.sgstTax,CP.netAmount,ISNULL(CP.actualAmount,0) AS  'actualAmount',
				ISNULL(CP.displayAmount,0) as 'displayAmount',CP.price 
				,CAST(CG.configName  AS VARCHAR)+' ~ '+CAST(C.configName AS VARCHAR) AS 'training'
				From Mstr_FitnessCategoryPrice As CP
				INNER JOIN Mstr_FitnessCategory AS FC On CP.categoryId = FC.categoryId 
				INNER JOIN Mstr_TrainingType AS T On CP.trainingTypeId = T.trainingTypeId
				INNER JOIN Mstr_Configuration AS CG On CP.planDuration = CG.configId
				INNER JOIN Mstr_Configuration AS C On T.trainingTypeNameId = C.configId
                WHERE  CP.gymOwnerId= @gymOwnerId AND CP.branchId = @branchId AND CP.categoryId = @categoryId 
				AND CP.trainingMode = 'O' AND CP.activeStatus = 'A' FOR  JSON PATH ) AS 'GetPriceDetails'

      END
	ELSE IF(@trainingMode = 'D' AND @priceId = 0)
	  BEGIN

				SELECT (SELECT CP.priceId,FC.categoryId,FC.categoryName,CP.planDuration AS planDurationId,CG.configName AS planDuration,CP.trainingTypeId,
				CP.trainingMode,C.configName as trainingType,CP.taxId,CP.cgstTax,CP.sgstTax,CP.netAmount,ISNULL(CP.actualAmount,0) AS  'actualAmount',
				ISNULL(CP.displayAmount,0) as 'displayAmount',CP.price 
				,CAST(CG.configName  AS VARCHAR)+' ~ '+CAST(C.configName AS VARCHAR) AS 'training'
				From Mstr_FitnessCategoryPrice As CP
				INNER JOIN Mstr_FitnessCategory AS FC On CP.categoryId = FC.categoryId 
				INNER JOIN Mstr_TrainingType AS T On CP.trainingTypeId = T.trainingTypeId
				INNER JOIN Mstr_Configuration AS CG On CP.planDuration = CG.configId
				INNER JOIN Mstr_Configuration AS C On T.trainingTypeNameId = C.configId
                WHERE  CP.gymOwnerId= @gymOwnerId AND CP.branchId = @branchId AND CP.categoryId = @categoryId 
				AND CP.trainingMode = 'D' AND CP.activeStatus = 'A' FOR JSON PATH ) AS 'GetPriceDetails'
	  END


	 ELSE IF(@trainingMode = 'D' AND @priceId != 0)
	    BEGIN

				SELECT (SELECT CP.priceId,FC.categoryId,FC.categoryName,CP.planDuration AS planDurationId,CG.configName AS planDuration,CP.trainingTypeId, 
				CP.trainingMode,C.configName as trainingType,CP.taxId,CP.cgstTax,CP.sgstTax,CP.netAmount,
			ISNULL(CP.actualAmount,0) AS  'actualAmount',ISNULL(CP.displayAmount,0) as 'displayAmount',CP.price 
				,CAST(CG.configName  AS VARCHAR)+' ~ '+CAST(C.configName AS VARCHAR) AS 'training' , CP.branchId,B.branchName,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=CP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName'
				From Mstr_FitnessCategoryPrice As CP
				INNER JOIN Mstr_FitnessCategory AS FC On CP.categoryId = FC.categoryId 
				INNER JOIN Mstr_TrainingType AS T On CP.trainingTypeId = T.trainingTypeId
				INNER JOIN Mstr_Configuration AS CG On CP.planDuration = CG.configId
				INNER JOIN Mstr_Configuration AS C On T.trainingTypeNameId = C.configId
				INNER JOIN Mstr_Branch AS B on  CP.branchId  = b.branchId
				AND CP.trainingMode = 'D' AND CP.activeStatus = 'A' AND CP.priceId = @priceId
				AND CP.categoryId=@categoryId FOR JSON PATH ) AS 'GetPriceDetails'
	   END


	    ELSE IF(@trainingMode = 'O' AND @priceId != 0)
	    BEGIN

				SELECT( SELECT CP.priceId,FC.categoryId,FC.categoryName,CP.planDuration AS planDurationId,CG.configName AS planDuration,CP.trainingTypeId, 
				CP.trainingMode,C.configName as trainingType,CP.taxId,CP.cgstTax,CP.sgstTax,CP.netAmount,
			ISNULL(CP.actualAmount,0) AS  'actualAmount',ISNULL(CP.displayAmount,0) as 'displayAmount',CP.price 
				,CAST(CG.configName  AS VARCHAR)+' ~ '+CAST(C.configName AS VARCHAR) AS 'training' , CP.branchId,B.branchName,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=CP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName'
				From Mstr_FitnessCategoryPrice As CP
				INNER JOIN Mstr_FitnessCategory AS FC On CP.categoryId = FC.categoryId 
				INNER JOIN Mstr_TrainingType AS T On CP.trainingTypeId = T.trainingTypeId
				INNER JOIN Mstr_Configuration AS CG On CP.planDuration = CG.configId
				INNER JOIN Mstr_Configuration AS C On T.trainingTypeNameId = C.configId
				INNER JOIN Mstr_Branch AS B on  CP.branchId  = b.branchId
				AND CP.trainingMode = 'O' AND CP.activeStatus = 'A' AND CP.priceId = @priceId 
				AND  CP.categoryId=@categoryId FOR JSON PATH ) AS 'GetPriceDetails'
	   END

	  ELSE
		BEGIN
			COMMIT 
			SELECT 'No Data Found' AS 'GetPriceDetails' ,0 AS 'StatusCode'
		  END	




IF @@TRANCOUNT>0
	COMMIT

END
							

				
GO
/****** Object:  StoredProcedure [dbo].[GetPublicCategoryDietPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC  GetPublicCategoryDietPlan '100007','4','1'
CREATE  PROCEDURE [dbo].[GetPublicCategoryDietPlan] ( 
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@categoryId INT=NULL)
AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;
	DECLARE  @WakeUpTime Time='6:00 AM'

                    SELECT (
				    SELECT * FROM(
					SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as 
					servingInId,f.calories,(fd.uniqueId) as dietTimeId,f.dietTypeId,mc.mealTypeId, 'BreakFast' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs 
					FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId 
					FROM Mstr_Configuration as c WHERE c.configName='BreakFast')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig 
					as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c 
					WHERE c.configName='BreakFast')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
				    INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR 
					DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs)
					AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='BreakFast') 
					AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A'
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
				    UNION ALL

					SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,f.calories,(fd.uniqueId)
					as dietTimeId,f.dietTypeId,mc.mealTypeId,'Snacks1' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc 
					INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c
					WHERE c.configName='Snacks1')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc 
					INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c
					WHERE c.configName='Snacks1')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
						INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime ,
					CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
					AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks1') 
						AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A'
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
				       UNION ALL

					SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as 
					servingInId,f.calories,(fd.uniqueId) as dietTimeId,f.dietTypeId,mc.mealTypeId,'Lunch' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs 
					FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as 
					mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c
					WHERE c.configName='Lunch')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
					INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs 
					OR DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
					AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Lunch')
						AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A'
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
				      UNION ALL
					SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  
					servingInId,f.calories,(fd.uniqueId) as dietTimeId,f.dietTypeId,mc.mealTypeId,'Snacks2' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs 
					FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId 
					FROM Mstr_Configuration as c WHERE c.configName='Snacks2')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc
					INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c 
					WHERE c.configName='Snacks2')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
				    INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime ,
					CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks2')
						AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A'
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
					  UNION ALL
							
				     SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,
					f.calories,(fd.uniqueId) as dietTimeId,f.dietTypeId,mc.mealTypeId,'Dinner' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs
					FROM MstrMealTimeConfig as mc INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner')) , CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc 
					INNER JOIN Mstr_FoodDietTime as fd ON fd.mealType=mc.mealTypeId  AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c 
					WHERE c.configName='Dinner')),DATEADD(MINUTE, 30, CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
				    INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR DATEDIFF(HOUR, @WakeUpTime ,
					CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
					AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Dinner') 
						AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A'
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
					
						  UNION ALL	
				    SELECT f.foodItemId,f.foodItemName,f.protein,f.carbs,f.fat,(cf.configName) as servingIn,(f.servingIn) as  servingInId,
					f.calories,(fd.uniqueId) as dietTimeId,f.dietTypeId,mc.mealTypeId,'Snacks3' as 'mealtypeName',b.categoryId,f.imageUrl,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs
					FROM MstrMealTimeConfig as mc  where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')) , 
					CONVERT(VARCHAR(10),@WakeUpTime,108))),108)) AS TIME)) AS fromTime,
					(SELECT CAST((SELECT CONVERT(VARCHAR(10),(DATEADD(HOUR,(SELECT DISTINCT mc.timeInHrs FROM MstrMealTimeConfig as mc  
					where mc.mealTypeId=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3')),DATEADD(MINUTE, 30,
					CONVERT(VARCHAR(10),@WakeUpTime,108)))),108)) AS TIME))AS toTime
					FROM Mstr_FoodItem as f
					INNER JOIN Mstr_FoodDietTime as fd ON fd.foodItemId=f.foodItemId
					INNER JOIN Mstr_Configuration as cf ON cf.configId=f.servingIn 
					INNER JOIN Mstr_ConfigurationType as ct ON cf.typeId=ct.typeId
					INNER JOIN MstrMealTimeConfig as mc ON mc.mealTypeId=fd.mealType
						INNER JOIN Mstr_CategoryDietPlan as b ON F.foodItemId=b.foodItemId 
					AND fd.uniqueId=B.dietTimeId AND b.activeStatus='A'
					WHERE (DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))<= mc.timeInHrs OR 
					DATEDIFF(HOUR, @WakeUpTime , CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,108))>= mc.timeInHrs) 
					AND fd.mealType=(SELECT c.configId FROM Mstr_Configuration as c WHERE c.configName='Snacks3') 
						AND b.gymOwnerId=@gymOwnerId AND b.branchId=@branchId AND b.categoryId=@categoryId AND  b.activeStatus='A' ) AS A
					--AND f.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' ))
				  FOR JSON PATH  ) AS 'CategoryDietPlan'
						
					
				

 IF @@TRANCOUNT>0
	COMMIT
END
GO
/****** Object:  StoredProcedure [dbo].[GetPublicUserDietList]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** 
Modified By Brijin 
Date : 13-1-23
*****/



CREATE PROCEDURE [dbo].[GetPublicUserDietList] (@UserId INT=NULL,
											@BookingId INT =NULL,
											@fromDate DATE =NULL)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;

				SELECT ( SELECT DISTINCT uf.userId ,b.bookingId,fd.mealType ,c.configName AS mealTypeName,ft.imageUrl,dt.fromTIme AS 'CheckTime',
				 CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',mc.timeInHrs,
				dt.dietTypeId,ft.foodItemId,
				d.typeIndicationImageUrl,uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId 
				From Mstr_UserFoodMenu AS uf 
				INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
				INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
				INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
				INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
				INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
				INNER JOIN Tran_UserDietPlan as udp on uf.userId = udp.userId
				INNER JOIN Tran_Booking AS b On uf.userId = b.userId and udp.bookingId = b.bookingId
				INNER JOIN Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and uf.bookingId= dt.bookingId
				INNER JOIN Mstr_DietType AS d On dt.dietTypeId = d.dietTypeId			
				where uf.userId = @UserId  AND b.bookingId= @BookingId AND (@fromDate BETWEEN b.fromDate AND b.toDate) and uf.bookingId =@BookingId  AND udp.approvedBy IS NOT NULL
				and CONCAT(fd.mealType, '-' ,ft.foodItemId) NOT IN(SELECT CONCAT(mealTypeId, '-' ,foodMenuId) FROM Tran_UserFoodTracking WHERE userId= @UserId and bookingId =@BookingId AND date=@fromDate
				)ORDER BY mc.timeInHrs asc FOR JSON PATH  ) AS 'UserPublicDietList'

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[GetPublicUserDietListWebBasedOnCategory]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetPublicUserDietListWebBasedOnCategory] (@UserId INT=NULL,
											@BookingId INT =NULL,
											@fromDate DATE =NULL,
											@categoryId INT= NULL)
											
AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;

				SELECT ( 
		        SELECT DISTINCT uf.userId ,b.bookingId,fd.mealType ,c.configName AS mealTypeName,ft.imageUrl,dt.fromTIme AS 'CheckTime',
				CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',mc.timeInHrs,
				dt.dietTypeId,ft.foodItemId,
				d.typeIndicationImageUrl,uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId ,
				CASE WHEN Track.consumingStatus = 'Y' THEN 'Y' ELSE 'N' END AS 'consumingStatus'
				From Mstr_UserFoodMenu AS uf 
				INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
				INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
				INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
				INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
				INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
				INNER JOIN Tran_UserDietPlan as udp on uf.userId = udp.userId
				INNER JOIN Tran_Booking AS b On uf.userId = b.userId and udp.bookingId = b.bookingId
				INNER JOIN Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and uf.bookingId= dt.bookingId
				INNER JOIN Mstr_DietType AS d On dt.dietTypeId = d.dietTypeId
				LEFT JOIN  Tran_UserFoodTracking AS Track ON   uf.BookingId=Track.bookingId And uf.userId=Track.userId And uf.foodItemId=track.foodMenuId
				And Track.mealTypeId=Fd.mealType
				And Track.date=@fromDate
				where uf.userId = @UserId  AND b.bookingId= @BookingId AND
				b.categoryId=@categoryId AND  (@fromDate BETWEEN b.fromDate AND b.toDate) and uf.bookingId =@BookingId  AND udp.approvedBy IS NOT NULL
				ORDER BY mc.timeInHrs asc 
				 FOR JSON PATH  ) AS 'UserPublicDietList'

IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[GetUserConsumingDietList]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- ==================================================
--- Modified By Abhinaya K
--- Date :09-01-23
--- Date :10-01-23
--- Modified For Changing Time Format fromTime,toTime
--- ==================================================

CREATE PROCEDURE [dbo].[GetUserConsumingDietList] (@UserId INT=NULL,
											@date date =NULL)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;

				
				SELECT (SELECT DISTINCT uf.uniqueId, uf.foodMenuId,f.foodItemName,c.configName as servingIn,f.protein ,
				f.fat,f.calories,f.carbs,CONVERT(VARCHAR(10), CAST(di.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(di.toTime AS TIME),0 ) AS 'toTime',uf.consumingStatus,ml.timeInHrs,
				cg.configName as mealTypeName,f.imageUrl,d.typeIndicationImageUrl 
				from Tran_UserFoodTracking  AS uf
				Inner join Mstr_FoodItem AS f On f.foodItemId = uf.foodMenuId 
				inner join Mstr_DietType AS d On f.dietTypeId = d.dietTypeId
				Inner Join Mstr_Configuration AS c On c.configId = f.servingIn
				INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodMenuId = fd.foodItemId and fd.mealType=uf.mealtypeid
				INNER JOIN Mstr_UserDietTime AS di On uf.userId = di.userId and di.dietTimeId = fd.uniqueId and uf.bookingId = di.bookingId
				Inner Join Mstr_Configuration AS cg On cg.configId = fd.mealType
				INNER JOIN MstrMealTimeConfig As ml on ml.mealTypeId = uf.mealtypeid
				where  uf.userId = @UserId  AND date= @date Order by ml.timeInHrs asc  FOR JSON PATH ) AS 'UserConsumingDietList'


IF @@TRANCOUNT>0
	COMMIT

END
GO
/****** Object:  StoredProcedure [dbo].[GetUserDietList]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetUserDietList] (@UserId INT=NULL,
											@BookingId INT =NULL,
											@mealTypeId INT =Null)

AS
BEGIN
	BEGIN TRAN
	SET NOCOUNT ON;

	IF(@mealTypeId != 0)
	  BEGIN
				SELECT (SELECT DISTINCT uf.uniqueId,uf.userId,b.bookingId,fd.mealType ,c.configName AS mealTypeName , 
				 CONVERT(VARCHAR(10), CAST(dt.fromTIme AS TIME),0 ) AS 'fromTime', CONVERT(VARCHAR(10), CAST(dt.toTime AS TIME),0 ) AS 'toTime',
				dt.dietTypeId,ft.foodItemId,
				uf.foodItemName,ft.protein,ft.carbs,ft.fat,(cf.configName) as servingIn,uf.calories,(fd.uniqueId) as foodDietTimeId,
				dt.uniqueId as 'UserfoodDietTimeId'
				From Mstr_UserFoodMenu AS uf 
				INNER JOIN Mstr_FoodItem AS ft On uf.foodItemId = ft.foodItemId 
				INNER JOIN Mstr_FoodDietTime AS Fd On uf.foodItemId = fd.foodItemId 
				INNER JOIN MstrMealTimeConfig AS mc On mc.mealTypeId = Fd.mealType 	
				INNER JOIN Mstr_Configuration as cf ON cf.configId=uf.servingIn
				INNER JOIN Mstr_Configuration as c ON c.configId=fd.mealType
				INNER JOIN Tran_Booking AS b On uf.userId = b.userId 
				INNER Join Mstr_UserDietTime AS dt On uf.userId = dt.userId and dt.dietTimeId = fd.uniqueId and uf.bookingId = dt.bookingId
				AND uf.dietTimeId=dt.dietTimeId
				where uf.userId = @UserId  AND b.bookingId= @BookingId and uf.bookingId = @BookingId AND c.configId = @mealTypeId FOR JSON PATH ) AS 'UserDietList'

      END
	ELSE 
	  BEGIN

				SELECT (SELECT userId,bookingId,dietTypeId,dietTypeName,CONVERT(VARCHAR(10), CAST(A.fromTIme AS TIME),0 ) AS 'fromTime',
			CONVERT(VARCHAR(10), CAST(A.toTime AS TIME),0 ) AS 'toTime',mealType,mealTypeName,(0) as foodDietTimeId 
			FROM (SELECT DISTINCT *,RANK() OVER(Order by B.fromTIme) AS row_number FROM (SELECT DISTINCT udt.userId,udt.BookingId,udt.dietTypeId,c.configName as dietTypeName,
			udt.fromTIme,udt.toTime
			FROM Mstr_UserDietTime  AS udt 
			INNER JOIN Mstr_DietType AS dt on dt.dietTypeId = udt.dietTypeId
			INNER JOIN Mstr_Configuration AS c On dt.dietTypeNameId = c.configId
			where udt.BookingId=@BookingId and udt.userId=@UserId)AS B) AS A
			LEFT JOIN
		    (SELECT C.configId AS mealType,C.configName AS mealTypeName,RANK() OVER(Order by  A.timeInHrs) AS row_numberr
			FROM MstrMealTimeConfig AS A INNER JOIN Mstr_Configuration AS C
			ON A.mealTypeId=C.configId) AS B
			ON A.row_number = B.row_numberr FOR JSON PATH ) AS 'UserDietList'
	  END

IF @@TRANCOUNT>0
	COMMIT

END
							

				
GO
/****** Object:  StoredProcedure [dbo].[SendSmsForLiveConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- ==================================================
--- Created By Abhinaya K
--- Created DAte 03-Mar-2023******/
--- Exec SendSmsForLiveConfig '100007','4',''
--- ==================================================
CREATE PROCEDURE [dbo].[SendSmsForLiveConfig]
(
@gymOwnerId INT,
@branchId INT,
@SMSBody NVARCHAR(1000)=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(1000)=NULL OUTPUT
)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @phoneNumber VARCHAR(10)
	DECLARE @userId VARCHAR(100)
			DECLARE db_cursor CURSOR LOCAL  FOR 
			SELECT phoneNumber,userId FROM Tran_Booking WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND traningMode='O'
			
			OPEN db_cursor  
			FETCH NEXT FROM db_cursor INTO @phoneNumber,@userId

			WHILE @@FETCH_STATUS = 0  
			BEGIN  
				IF(LEN(@phoneNumber) > 9)
				BEGIN
				     SET @SMSBody = 'Welcome to TTDC and thanks for registering with us. ' + CAST(@phoneNumber AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
					 					
						DECLARE @TRIMSMSMessage NVARCHAR(MAX)
						SET @TRIMSMSMessage=(SELECT top 1 value FROM STRING_SPLIT(@SMSBody, '&'))
						EXEC usp_MstrUserNotification 'Insert', '',@userId, @TRIMSMSMessage



					   EXEC  usp_MstrSendSMSServiceMessage @phoneNumber, @SMSBody
					  SET @StatusCode=1;
					  SET @Response='Sucess'
				END
				  
			FETCH NEXT FROM db_cursor INTO @phoneNumber ,@userId
			END 

			CLOSE db_cursor  
			DEALLOCATE db_cursor 

			COMMIT TRANSACTION
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
  END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[SendSmsForLiveConfig_bak]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- ==================================================
--- Created By Abhinaya K
--- Created DAte 03-Mar-2023******/
--- Exec SendSmsForLiveConfig '100007','4',''
--- ==================================================

CREATE  PROCEDURE [dbo].[SendSmsForLiveConfig_bak]
(
@gymOwnerId INT,
@branchId INT,
@SMSBody NVARCHAR(200)=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @phoneNumber VARCHAR(10)
			DECLARE db_cursor CURSOR FOR 
			SELECT phoneNumber FROM Tran_Booking WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND traningMode='O'

			OPEN db_cursor  
			FETCH NEXT FROM db_cursor INTO @phoneNumber

			WHILE @@FETCH_STATUS = 0  
			BEGIN  
				IF(LEN(@phoneNumber) > 9)
				BEGIN
				     SET @SMSBody = 'Welcome to TTDC and thanks for registering with us. ' + CAST(@phoneNumber AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
					  EXEC  usp_MstrSendSMSServiceMessage @phoneNumber,@SMSBody
					  SET @StatusCode=1;
					  SET @Response='Sucess'
				END
			FETCH NEXT FROM db_cursor INTO @phoneNumber 
			END 

			CLOSE db_cursor  
			DEALLOCATE db_cursor 
			COMMIT TRANSACTION
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
  END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[usp_DashboardReportDateBased]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- ======================================================
--- created by Jaya suriya
--- created date 22-02-2023
--- modified by Jaya suriya
--- modified date 28-02-2023
--- ======================================================

CREATE PROCEDURE [dbo].[usp_DashboardReportDateBased]
(
	@QueryType VARCHAR(100),
	@UserId INT,
	@FromDate DATE,
	@ToDate DATE
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DateDiff INT=(SELECT DATEDIFF(DAY,@FromDate,@ToDate))
	IF(@DateDiff<7 OR @DateDiff>30)
		BEGIN
			RETURN;
		END

	IF(@QueryType='Activities')
		BEGIN

			CREATE TABLE #WorkoutPlanResult(WorkoutPanId INT,ShorDayName VARCHAR(2),FullDayName VARCHAR(20),AllocatedDate DATE);
			CREATE TABLE #WorkoutTrackingResult(UniqueId INT,ShorDayName VARCHAR(2),FullDayName VARCHAR(20),CompletedDate DATE);

			DECLARE @WorkoutPlan CURSOR;
			DECLARE @Date DATE,@Day VARCHAR(2),@FullDayName VARCHAR(20);
			
			SET @WorkoutPlan=CURSOR FOR 
								WITH CTE_GetDateAndDay
									AS
									(
										SELECT fromDate,DayName FROM
										(
										SELECT @FromDate AS fromDate,DATENAME(WEEKDAY,@FromDate) AS 'DayName'
										)
										AS A
										UNION ALL
										SELECT DATEADD(DAY,1,C.fromDate) AS 'fromDate',DATENAME(WEEKDAY,DATEADD(DAY,1,C.fromDate)) AS 'DayName' FROM
										(
										SELECT @FromDate AS fromDate
										)
										AS B INNER JOIN CTE_GetDateAndDay AS C ON C.fromDate<@ToDate
									)
								SELECT fromDate AS 'Date',SUBSTRING([DayName],1,2) AS 'Day',[DayName] FROM CTE_GetDateAndDay

			OPEN @WorkoutPlan
			
			FETCH NEXT FROM @WorkoutPlan INTO @Date,@Day,@FullDayName;

			WHILE @@FETCH_STATUS=0
				BEGIN
					 INSERT INTO #WorkoutPlanResult(WorkoutPanId,ShorDayName,FullDayName,AllocatedDate)
					 (SELECT workoutPlanId,day,@FullDayName,@Date FROM Tran_UserWorkOutPlan WHERE [day]=@Day AND @Date BETWEEN fromDate AND toDate AND userId=@UserId)
					 

					  INSERT INTO #WorkoutTrackingResult(UniqueId,ShorDayName,FullDayName,CompletedDate)
					 (SELECT uniqueId,day,@FullDayName,@Date FROM Tran_UserWorkoutTracking WHERE [day]=@Day AND Date=@Date AND userId=@UserId)

					FETCH NEXT FROM @WorkoutPlan INTO @Date,@Day,@FullDayName;
				END

			CLOSE @WorkoutPlan;
			DEALLOCATE @WorkoutPlan;

			;WITH AllocatedActivities
			AS
			(
			SELECT 
				FullDayName AS 'day',ShorDayName,COUNT(WorkoutPanId) AS 'Allocated',0 AS 'Completed',AllocatedDate AS 'date'
			FROM 
				#WorkoutPlanResult 
			GROUP BY 
				AllocatedDate,ShorDayName,FullDayName
			),
			CompletedActivities
			AS
			(
			SELECT 
				FullDayName AS 'day',ShorDayName,0 AS 'Allocated',COUNT(UniqueId) AS 'Completed',CompletedDate AS 'date'
			FROM 
				#WorkoutTrackingResult 
			GROUP BY 
			CompletedDate,ShorDayName,FullDayName
			),
			Result
			AS
			(
			SELECT [day],[date],SUM(Allocated) AS 'Allocated',SUM(Completed) AS 'Completed' FROM
			(
				SELECT [day],[date],Allocated,Completed FROM AllocatedActivities
				UNION ALL
				SELECT [day],[date],Allocated,Completed FROM CompletedActivities
			)  AS A	GROUP BY [day],[date] 
			)
			SELECT [day],[date],Allocated,Completed FROM Result	 ORDER BY 	[Date] 
		END

	IF(@QueryType='FoodConsumptionDetails')
		BEGIN
			SELECT [date],[Day],SUM(protein) AS 'protein',SUM(carbs) AS 'carbs',SUM(calories) AS 'calories',SUM(fat) AS 'fat' FROM
			(
				SELECT 
					A.[date],DATENAME(WEEKDAY,A.[date]) AS 'Day',protein,carbs,calories,fat
				FROM
					Tran_UserFoodTracking AS A	INNER JOIN Mstr_FoodItem AS B ON A.foodMenuId=B.foodItemId AND A.UserId=@UserId
				WHERE
					A.[date]  BETWEEN @FromDate  AND @ToDate		
			)
			AS A 
			GROUP BY
				[date],[Day]
			ORDER BY
				[date]
		END

	IF(@QueryType='CaloriesDetails')
		BEGIN
			SELECT [date],[Day],SUM(caloriesIntake) AS 'caloriesIntake',SUM(caloriesBurnt) AS 'caloriesBurnt' FROM
			(
				SELECT
					[date],[Day],SUM(calories) AS 'caloriesIntake',0 AS 'caloriesBurnt'
				FROM
					(
						SELECT 
							userId,A.[date],DATENAME(WEEKDAY,A.[date]) AS 'Day',protein,carbs,calories,fat
						FROM
							Tran_UserFoodTracking AS A	INNER JOIN Mstr_FoodItem AS B ON A.foodMenuId=B.foodItemId AND A.UserId=@UserId
						WHERE
							A.[date]  BETWEEN @FromDate  AND @ToDate	
					)
				AS AA
				GROUP BY AA.[date],[Day]
   
			UNION ALL

					SELECT
						A.[date],
						A.[Day],
						0 AS 'caloriesIntake',SUM(Calories) AS 'caloriesBurnt' 
					FROM
					(
						SELECT
							[date],DATENAME(WEEKDAY,[date]) AS 'Day',calories 
						FROM
							Tran_UserWorkoutTracking
						WHERE
							date  BETWEEN @FromDate  AND @ToDate AND userId=@UserId	
					) AS A
					GROUP BY A.[date],A.[Day]
				)
				AS A GROUP BY A.[date],A.[Day] ORDER BY A.[date]
		END
END
--EXECUTE usp_DashboardReportDateBased @QueryType='AllocatedActivities',@UserId=100101,@FromDate='2023-02-01',@ToDate='2023-02-28'	 
--EXECUTE usp_DashboardReportDateBased @QueryType='FoodConsumptionDetails',@UserId=100101,@FromDate='2023-02-01',@ToDate='2023-02-28'	 
--EXECUTE usp_DashboardReportDateBased @QueryType='CaloriesDetails',@UserId=100101,@FromDate='2023-02-01',@ToDate='2023-02-28'	 
GO
/****** Object:  StoredProcedure [dbo].[usp_GetBookingDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetBookingDetails]
(
@QueryType VARCHAR(100),
@UserId INT=null,
@bookingId INT = NULL,
@gymOwnerId INT = NULL,
@branchId INT = NULL,
@mobileNo NVARCHAR(100) = NULL,
@fromDate DATE = NULL,
@toDate DATE = NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getDateBasedBookingDetails')
		BEGIN
				SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
				TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
				TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
				TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,
				CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,TB.offerAmount,TB.utilizedRewardPoints,
				TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
				TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
				CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt') AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
				fcp.planDuration,C.configName AS 'PlaneDurationMonth'
				from Tran_Booking as TB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
				INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
				INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
				AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
				INNER JOIN Mstr_Configuration AS CONFIG ON
				CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
				INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
				INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
				INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
				where TB.gymOwnerId=@gymOwnerId AND TB.branchId=@branchId 
				AND CAST(TB.BookingDate AS DATE) BETWEEN  @fromDate AND @toDate

		END  
		ELSE IF(@QueryType='getUserBookingDetails')
		BEGIN
				SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
				TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
				TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
				TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,
				CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,TB.offerAmount,TB.utilizedRewardPoints,
				TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
				TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
				CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt') AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
				fcp.planDuration,C.configName AS 'PlaneDurationMonth' from Tran_Booking as TB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
				INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
				INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
				AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
				INNER JOIN Mstr_Configuration AS CONFIG ON
				CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
				INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
				INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
				INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
				where TB.userId=@UserId and CAST(TB.fromDate  AS DATE) <= CAST(GETDATE() AS DATE)
                AND CAST(TB.toDate  AS DATE) >= CAST(GETDATE() AS DATE)
		END
		ELSE IF(@QueryType='getBookingDetails')
		BEGIN
				SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
				TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
				TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
				TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,
				CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,TB.offerAmount,TB.utilizedRewardPoints,
				TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
				TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
				CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt') AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
				fcp.planDuration,C.configName AS 'PlaneDurationMonth' from Tran_Booking as TB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
				INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
				INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
				AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
				INNER JOIN Mstr_Configuration AS CONFIG ON
				CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
				INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
				INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
				INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
				where TB.bookingId=@bookingId
		END 
		ELSE IF(@QueryType='getTrackBookingDetails')
		BEGIN	
		IF(@mobileNo IS NOT NULL)
		BEGIN
			SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
			TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
			TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
			TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,ISNULL(CONVERT(NVARCHAR(50),MU.dob, 105),'' ) As dob,ISNULL(MU.gender,'' ) As gender,
			CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,TB.offerAmount,TB.utilizedRewardPoints,
			TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
			TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
			CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt')AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
			fcp.planDuration,C.configName AS 'PlaneDurationMonth' from Tran_Booking as TB
			INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
			INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
			INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
			AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE TB.gymOwnerId=@gymOwnerId AND TB.branchId=@branchId AND
			--(TB.userId IN (SELECT DISTINCT userId FROM Tran_UserFoodTracking WHERE userId IN  (SELECT userId FROM Mstr_UserLogin WHERE (mobileNo=@mobileNo OR mailId=@mobileNo))) OR 
			--TB.userId IN (SELECT DISTINCT userId FROM Tran_UserWorkoutTracking WHERE userId IN  (SELECT userId FROM Mstr_UserLogin WHERE (mobileNo=@mobileNo OR mailId=@mobileNo))))
			 CAST(TB.fromDate  AS DATE) <= CAST(GETDATE() AS DATE) AND CAST(TB.toDate  AS DATE) >= CAST(GETDATE() AS DATE)
		END
		ELSE
		BEGIN
				SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
				TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
				TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
				TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,ISNULL(CONVERT(NVARCHAR(50),MU.dob, 105),'' ) As dob,ISNULL(MU.gender,'' ) As gender,
				CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,TB.offerAmount,TB.utilizedRewardPoints,
				TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
				TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
				CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt') AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
				fcp.planDuration,C.configName AS 'PlaneDurationMonth' from Tran_Booking as TB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
				INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
				INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
				AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
				INNER JOIN Mstr_Configuration AS CONFIG ON
				CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
				INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
				INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
				INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
				WHERE TB.gymOwnerId=@gymOwnerId AND TB.branchId=@branchId AND 
				--(TB.userId  IN (SELECT DISTINCT userId FROM Tran_UserFoodTracking ) OR 
				--TB.userId IN (SELECT DISTINCT userId FROM Tran_UserWorkoutTracking )) and 
				CAST(TB.fromDate  AS DATE) <= CAST(GETDATE() AS DATE) AND CAST(TB.toDate  AS DATE) >= CAST(GETDATE() AS DATE)
		END
		END 

			IF(@QueryType='getFollowupBooking')
		BEGIN	
		SELECT
            (SELECT TB.bookingId,TB.gymOwnerId,G.gymOwnerName,TB.branchId,TB.branchName,TB.categoryId,FC.categoryName,
			TB.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TB.traningMode,
			TB.slotId,CONVERT(NVARCHAR(50), TB.slotFromTime, 105) + ' ' + FORMAT(TB.slotFromTime,'hh:mm tt') AS 'slotFromTime',CONVERT(NVARCHAR(50), TB.slotToTime, 105) + ' ' + FORMAT(TB.slotToTime,'hh:mm tt') AS 'slotToTime',
			TB.priceId,TB.phoneNumber,TB.userId,ISNULL(MU.firstName,'')+''+ ISNULL(MU.lastName,'' ) AS 'UserName',TB.booking,TB.loginType,
			CONVERT(NVARCHAR,TB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TB.toDate,105) as 'toDate',TB.price,TB.taxId,TB.taxName,TB.taxAmount,TB.offerId,
			TB.offerAmount,TB.utilizedRewardPoints,
			TB.rewardPointsAmount,TB.totalAmount,TB.paidAmount,TB.paymentStatus,TB.paymentCycles,TB.paymentType,TB.cancellationStatus,
			TB.refundStatus,TB.cancellationCharges,TB.refundAmt,TB.cancellationReason,
			CONVERT(NVARCHAR(50), TB.bookingDate, 105) + ' ' + FORMAT(TB.bookingDate,'hh:mm tt') AS 'bookingDate',FCP.cgstTax,FCP.sgstTax,
			fcp.planDuration,C.configName AS 'PlaneDurationMonth',
			(select (case when DATEDIFF(DAY, TB.fromDate,@toDate)=0 then 1 ELSE DATEDIFF(DAY, TB.fromDate, @toDate) END  * count(*)) from Tran_UserWorkOutPlan
			WHERE userId=TB.userId AND bookingId=TB.bookingId) AS 'TotalActivity',
			(select count(*) from Tran_UserWorkoutTracking  WHERE userId=TB.userId AND bookingId=TB.bookingId) AS 'CompletedActivity',
			(select (case when DATEDIFF(DAY, TB.fromDate,@toDate)=0 then 1 ELSE DATEDIFF(DAY, TB.fromDate, @toDate) END  * count(*)) from 
			Mstr_UserFoodMenu WHERE userId=TB.userId AND bookingId=TB.bookingId) AS 'TotalCalories',
			(select count(*) from Tran_UserFoodTracking  WHERE userId=TB.userId AND bookingId=TB.bookingId) AS 'CompletedCalories',
			(SELECT * FROM dbo.GenerateFollowupDateday(TB.fromDate,@toDate,TB.userId,@gymOwnerId,@branchId,TB.bookingId,TB.fromDate,TB.toDate) 
			FOR JSON PATH ) AS 'FollowupDetails'
			from Tran_Booking as TB
			INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TB.gymOwnerId
			INNER JOIN Mstr_FitnessCategory AS FC ON  FC.categoryId=TB.categoryId AND FC.gymOwnerId=TB.gymOwnerId AND FC.branchId=TB.branchId
			INNER JOIN Mstr_TrainingType AS TT ON TT.gymOwnerId=TB.gymOwnerId AND TT.branchId=TB.branchId
			AND TT.activeStatus='A' AND TT.trainingTypeId=TB.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_User AS MU ON MU.userId=TB.userId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=TB.priceId AND FCP.gymOwnerId=TB.gymOwnerId AND FCP.branchId=TB.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			where TB.gymOwnerId=@gymOwnerId and tb.branchId=@branchId and CAST(TB.fromDate  AS DATE) <= CAST(GETDATE() AS DATE)
			AND CAST(TB.toDate  AS DATE) >= CAST(GETDATE() AS DATE)
			and  (@fromDate BETWEEN TB.fromDate AND TB.toDate OR @toDate BETWEEN TB.fromDate AND TB.toDate )
			AND ((TB.userId  IN (SELECT userId FROM Tran_UserWorkOutPlan WHERE bookingId=TB.bookingId ) OR
			TB.userId  IN (SELECT userId FROM Mstr_UserFoodMenu WHERE bookingId=TB.bookingId)) )
			AND ((select (case when DATEDIFF(DAY, TB.fromDate,@toDate)=0 then 1 ELSE DATEDIFF(DAY, TB.fromDate, @toDate) END  * count(*)) from Tran_UserWorkOutPlan 
			WHERE userId=TB.userId AND bookingId=TB.bookingId )>=
			(select count(*) from Tran_UserWorkoutTracking  WHERE userId=TB.userId AND bookingId=TB.bookingId))
			AND ((select (case when DATEDIFF(DAY, TB.fromDate,@toDate)=0 then 1 ELSE DATEDIFF(DAY, TB.fromDate, @toDate) END  * count(*)) 
			from Mstr_UserFoodMenu WHERE userId=TB.userId AND bookingId=TB.bookingId )>=
			(select count(*) from Tran_UserFoodTracking  WHERE userId=TB.userId AND bookingId=TB.bookingId))
			AND (TB.userId  IN (select distinct userId  from Tran_UserDietPlan where approvedBy is not null AND bookingId=TB.bookingId) OR
			TB.userId  IN (select distinct userId  from Tran_UserWorkOutPlan  where approvedBy is not null AND bookingId=TB.bookingId)) 
			FOR JSON PATH )AS 'BookingFollowupDetails'
	END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetBookingReports]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetBookingReports]
(
	@QueryType VARCHAR(150),
	@BranchId VARCHAR(10)='0',
	@GymOwnerId VARCHAR(10)='0',
	@CategoryId VARCHAR(10)='0',
	@fromDate DATETIME,
	@toDate DATETIME
)
AS
BEGIN
	IF(@QueryType='GetBookingReport')
		BEGIN
			DECLARE @Conditions VARCHAR(1000);
			DECLARE @Squery VARCHAR(MAX);

			IF(@BranchId <> 0 AND @GymOwnerId <> 0 AND @CategoryId <> 0 )
				BEGIN
					SET @Conditions='WHERE A.branchId='+@BranchId+' AND A.gymOwnerId=' + @GymOwnerId + ' AND A.categoryId=' + @CategoryId +' AND A.bookingDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,121) + ''' AND '''+CONVERT(VARCHAR,@toDate,121)+'''';
				END
			ELSE IF(@BranchId <> 0 AND @GymOwnerId <> 0)
				BEGIN
					SET @Conditions='WHERE A.branchId='+@BranchId+' AND A.gymOwnerId=' + @GymOwnerId + ' AND A.bookingDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,121) + ''' AND ''' + CONVERT(VARCHAR,@toDate,121)+'''';
				END
			ELSE IF(@BranchId <> 0)
				BEGIN
					SET @Conditions='WHERE A.branchId='+@BranchId + ' AND A.bookingDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,121) + ''' AND ''' + CONVERT(VARCHAR,@toDate,121)+'''';
				END
			ELSE
				BEGIN
					SET @Conditions='WHERE A.bookingDate BETWEEN ''' + CONVERT(VARCHAR,@fromDate,20) + ''' AND '''+ CONVERT(VARCHAR,@toDate,20)+'''';
				END

			SET @Squery='SELECT
							A.bookingId,
							CONVERT(VARCHAR,bookingDate,105)+'' ''+CONVERT(VARCHAR,bookingDate,108) AS ''bookingDate'',
							A.branchId,
							A.branchName,
							A.gymOwnerId,
							B.gymName,
							A.categoryId,
							C.categoryName,
							CASE WHEN A.traningMode=''D'' THEN ''Direct training'' ELSE	''Online training'' END AS ''trainingMode'',
							A.trainingTypeId,
							D.description,
							A.userId,
							E.firstName+'' ''+E.lastName AS ''userName'',
							A.phoneNumber,
							A.price,
							A.taxId,
							A.taxAmount,
							A.offerId,
							A.offerAmount,
							A.paymentType,
							F.configName AS ''paymentTypeName''
						FROM 
							Tran_Booking AS A 
						INNER JOIN Mstr_GymOwner AS B ON A.gymOwnerId=B.gymOwnerId
						INNER JOIN Mstr_FitnessCategory AS C ON A.branchId=C.branchId AND A.gymOwnerId=C.gymOwnerId AND A.categoryId=C.categoryId
						INNER JOIN Mstr_TrainingType AS D ON A.trainingTypeId=D.trainingTypeId 
						INNER JOIN Mstr_User AS E ON A.userId=E.userId 
						INNER JOIN Mstr_Configuration AS F ON A.paymentType=F.configId AND F.typeId=21' + @Conditions

				EXECUTE (@Squery)
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetBranchWorkingDays]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetBranchWorkingDays]
(
@QueryType VARCHAR(150),
@BranchId INT=NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF(@QueryType='GetBranchWorkingDays')
		BEGIN
			SELECT workingDayId,BW.branchId,B.branchName,BW.gymOwnerId,O.gymOwnerName,workingDay,fromTime,toTime,isHoliday 
			FROM Mstr_BranchWorkingDay AS BW INNER JOIN Mstr_Branch AS B ON BW.branchId  = B.branchId
			INNER JOIN Mstr_GymOwner AS O On BW.gymOwnerId = O.gymOwnerId 
			WHERE BW.branchId=@BranchId
		END

    IF(@QueryType='GetBranchWorkingDaysForSlot')
		BEGIN
		    SELECT workingDayId,workingDay 
			FROM Mstr_BranchWorkingDay AS BW INNER JOIN Mstr_Branch AS B ON BW.branchId  = B.branchId
			INNER JOIN Mstr_GymOwner AS O On BW.gymOwnerId = O.gymOwnerId 
			WHERE BW.branchId=@BranchId AND BW.isHoliday='N'
		END
END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetDashboardDatas]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetDashboardDatas]
(
@QueryType VARCHAR(100),
@date DATE=NULL,
@Fromdate DATE=NULL,
@Todate DATE=NULL,
@UserId INT=0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getDateFoodCalories')
	BEGIN
			select (SELECT SUM(calories) FROM Mstr_UserFoodMenu WHERE userId=FM.userId AND bookingId=FM.bookingId) AS 'TotalCalories',
			SUM(FM.calories) AS 'ConsumedCalories',FM.bookingId from Mstr_UserFoodMenu as FM
			INNER JOIN Tran_UserFoodTracking AS FT ON FM.userId=FT.userId AND FM.bookingId=FT.bookingId
			AND FM.foodItemId=FT.foodMenuId
			INNER JOIN Tran_Booking AS T ON T.userId=FT.userId AND T.bookingId=FT.bookingId AND FT.date BETWEEN T.fromDate AND T.toDate
			WHERE FM.userId=@UserId AND FT.date=@date AND CAST(T.fromDate  AS DATE) <= CAST(GETDATE() AS DATE)
            AND CAST(T.toDate  AS DATE) >= CAST(GETDATE() AS DATE)
			GROUP BY FM.bookingId,FM.userId	 
	END
	IF(@QueryType='getTwoDateFoodCalories')
	BEGIN
					declare @StartDateFood date =@Fromdate
					declare  @EndDateFood date =@Todate
					declare  @bookingIdFood INT
					declare @FromDateFood date
					declare  @ToDateFood date

					Declare @TempFood table (DateOfDay date, DaysName varchar(50),userId varchar(50),bookingId INT,TotalCalories INT,ConsumedCalories INT)
					While(@StartDateFood <= @EndDateFood)
					Begin

						SELECT @bookingIdFood=(SELECT TOP 1 bookingId FROM Mstr_UserFoodMenu  WHERE userId=@UserId ORDER BY createdDate DESC)
					SELECT @FromDateFood =(SELECT CAST(fromDate AS DATE) FROM Tran_Booking WHERE bookingID=@bookingIdFood)
                    SELECT @ToDateFood =(SELECT CAST(toDate AS DATE) FROM Tran_Booking WHERE bookingID=@bookingIdFood)
					Insert into @TempFood
					SELECT  @StartDateFood DateOfMonth, 
					case when DATENAME(DW, @StartDateFood) = 'Saturday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Sunday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Monday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Tuesday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Wednesday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Thursday' then DATENAME(DW, @StartDateFood) 
					when DATENAME(DW, @StartDateFood) = 'Friday' then DATENAME(DW, @StartDateFood) 
					end DaysName,@UserId,@bookingIdFood,(SELECT SUM(calories) FROM Mstr_UserFoodMenu WHERE userId=@UserId AND bookingId=@bookingIdFood) AS 'TotalCalories',
					(select ISNULL(SUM(FM.calories),0) 
					FROM Tran_UserFoodTracking AS FT
					INNER JOIN  Mstr_UserFoodMenu as FM on FM.userId=FT.userId AND FM.bookingId=FT.bookingId
					AND FM.foodItemId=FT.foodMenuId
					LEFT JOIN Tran_Booking AS TB ON TB.userId=FT.userId AND TB.bookingId=FT.bookingId AND @StartDateFood  BETWEEN TB.fromDate AND TB.toDate
					WHERE FT.userId=@UserId AND FT.bookingId=@bookingIdFood AND FT.date=@StartDateFood) AS 'ConsumedCalories' 

					SET @StartDateFood = DATEADD(d,1,@StartDateFood)
					End
					SELECT A.TotalCalories,A.ConsumedCalories,CONVERT(NVARCHAR,A.DateOfDay,105) AS 'DateOfDay',A.DaysName,A.bookingId FROM (
					SELECT * FROM @TempFood)AS A WHERE CAST(A.DateOfDay AS DATE) BETWEEN CAST(@FromDateFood AS DATE) AND CAST(@ToDateFood AS DATE)
					ORDER BY A.DateOfDay

	END
	IF(@QueryType='getTwoDateWorkoutCalories')
		BEGIN
				declare @StartDate date =@Fromdate
				declare  @EndDate date =@Todate
				declare  @bookingIdWorkout INT
				declare @FromDateWorkout date
				declare  @ToDateWorkout date
				Declare @Temp table (DateOfDay date, DaysName varchar(50),userId varchar(50),bookingId INT,CompletedActivity int,TotalActivity int)
				SELECT @bookingIdWorkout=(SELECT TOP 1 bookingId FROM Tran_UserWorkOutPlan  WHERE userId=@UserId ORDER BY createdDate DESC)
				SELECT @FromDateWorkout =(SELECT CAST(fromDate AS DATE) FROM Tran_Booking WHERE bookingID=@bookingIdWorkout)
				SELECT @ToDateWorkout =(SELECT CAST(toDate AS DATE) FROM Tran_Booking WHERE bookingID=@bookingIdWorkout)
				While(@StartDate <= @EndDate)
				Begin

					Insert into @Temp
					SELECT  @StartDate DateOfMonth, 
							case when DATENAME(DW, @StartDate) = 'Saturday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Sunday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Monday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Tuesday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Wednesday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Thursday' then DATENAME(DW, @StartDate) 
								 when DATENAME(DW, @StartDate) = 'Friday' then DATENAME(DW, @StartDate) 
							end DaysName,@UserId,@bookingIdWorkout,(SELECT COUNT(workoutTypeId) FROM Tran_UserWorkoutTracking  where userId=@UserId 
							and bookingId=@bookingIdWorkout AND  day=SUBSTRING(DATENAME(DW, @StartDate),1,2)  AND date=@StartDate)AS 'CompletedActivity',
							(select COUNT(WP.workoutTypeId)  FROM Tran_UserWorkOutPlan AS WP 
				           WHERE WP.userId=@UserId and bookingId=@bookingIdWorkout AND CAST(WP.fromDate  AS DATE) <= CAST(GETDATE() AS DATE)
						   AND CAST(WP.toDate  AS DATE) >= CAST(GETDATE() AS DATE) 
						   AND WP.day=SUBSTRING(DATENAME(DW, @StartDate),1,2)) AS 'TotalActivity' 

					SET @StartDate = DATEADD(d,1,@StartDate)
				End

                     SELECT A.TotalActivity,A.CompletedActivity,CONVERT(NVARCHAR,A.DateOfDay,105) AS 'DateOfDay',A.DaysName,A.bookingId FROM (
					SELECT * FROM @Temp)AS A WHERE CAST(A.DateOfDay AS DATE) BETWEEN CAST(@FromDateWorkout AS DATE) AND CAST(@ToDateWorkout AS DATE)
					ORDER BY A.DateOfDay
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetDashBoardForBranchAdmin]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Created By Jaya suriya
--Created Date 04-01-2022
--Modified Date 06-01-2022
CREATE PROCEDURE [dbo].[usp_GetDashBoardForBranchAdmin]
(
	@QueryType VARCHAR(150),
	@GymOwnerId INT,
	@BranchId INT,
	@FromDate DATE,
	@ToDate DATE
)
AS
BEGIN
	IF(@QueryType='GetBookingAndEnquiryCount')
		BEGIN
			DECLARE @BookingCount INT;
			DECLARE @EnquiryCount INT;
			
				SET @BookingCount=(
									SELECT 
										COUNT(BookingDate)
									FROM
									(
										SELECT
											CAST(bookingDate AS DATE) AS 'BookingDate'
										FROM 
											Tran_Booking
										WHERE
											gymOwnerId=@GymOwnerId AND
											branchId=@BranchId 
									) 
									AS A
									WHERE BookingDate BETWEEN @FromDate AND @ToDate
								  );

				SET @EnquiryCount=( 
									SELECT Count(CreatedDate) FROM
									(
										SELECT
											CAST(createdDate AS DATE) AS CreatedDate
										FROM
											Mstr_User
										WHERE
											gymOwnerId=@GymOwnerId AND
											branchId=@BranchId  AND
											activeStatus='A' AND
											(enquiryReason IS NOT NULL OR enquiryReason <>'')
									) 
									AS A
									WHERE createdDate BETWEEN @FromDate AND @ToDate
								  );

				SELECT @BookingCount AS 'BookingCount', @EnquiryCount AS 'EnquiryCount'
		END

	IF(@QueryType='GetBookingListBasedOnGymAndBranch')
		BEGIN
			SELECT 
				A.userId,ISNULL(A.userName,'-') AS 'userName',
				A.bookingId,
				Convert(VARCHAR,A.bookingDate,103) AS 'bookingDate',--103 -format dd/mm/yyyy
				Convert(VARCHAR,A.fromDate,103) AS 'fromDate',--103 -format dd/mm/yyyy
				Convert(VARCHAR,A.toDate,103) AS 'toDate',--103 -format dd/mm/yyyy
				A.totalAmount,A.phoneNumber,
				A.categoryId,A.categoryName,
				A.trainingTypeId,A.trainingType,A.trainingMode
			FROM
				(
					SELECT
						--Tran_Booking
						A.userId,
						A.bookingId,
						A.categoryId,
						A.trainingTypeId,
						A.phoneNumber,
						CAST(A.bookingDate AS DATE) AS 'bookingDate',
						CASE WHEN  A.traningMode='D' THEN 'Direct' ELSE 'Online' END AS 'trainingMode',
						CAST(A.fromDate AS DATE) AS 'fromDate',
						CAST(A.toDate AS DATE) AS 'toDate',
						A.totalAmount,
						A.gymOwnerId,
						A.branchId,

						--Mstr_Configuration
						C.configName AS 'trainingType',

						--Mstr_FitnessCategory
						D.categoryName,

						--Mstr_User
						E.firstName+''+E.lastName AS 'userName'
					FROM
						--Tran_Booking Is the Main Table
							Tran_Booking AS A 

						--For Getting trainingTypeNameId From Mstr_TrainingType
						INNER JOIN
							Mstr_TrainingType AS B ON A.branchId=B.branchId AND
							A.gymOwnerId=B.gymOwnerId AND
							A.trainingTypeId=B.trainingTypeId AND
							B.activeStatus='A'

						--For Getting trainingTypeName From Mstr_Configuration And '16' is Default Id of trainingType
						INNER JOIN 
							Mstr_Configuration AS C ON B.trainingTypeNameId=C.configId AND C.typeId='16'

						--For Getting CategoryName From Mstr_FitnessCategory
						INNER JOIN 
							Mstr_FitnessCategory AS D ON A.categoryId=D.categoryId AND D.activeStatus='A'

						--For Getting UserName From Mstr_User
						INNER JOIN 
							Mstr_User AS E ON A.userId=E.userId AND E.activeStatus='A'
					) AS A
			 WHERE
					A.gymOwnerId=@GymOwnerId AND 
					A.branchId=@BranchId AND 
					A.bookingDate BETWEEN @FromDate AND @ToDate
			ORDER BY 
				A.userName
		END
	--this query is used to get EnquiryList Based on gymOwnerId, branchId and enquiryReason(shouln't be nill)
	IF(@QueryType='GetEnquiryListBasedOnGymAndBranch')
		BEGIN
			SELECT 
				 A.userId,
				 A.userName,
				 A.gender,
				 A.mobileNo AS 'phoneNumber',
				 A.age,
				 A.followUpStatus,
				 A.followUpStatusName,
				 A.followUpMode,
				 A.followUpModeName,
				 A.enquiryDate,
				 A.enquiryReason
			FROM 
			(
				SELECT
					--Mstr_User
					A.userId,
					ISNULL(A.firstName+' '+A.lastName,'-') AS 'userName',
					CASE WHEN A.gender='M' THEN 'Male' ELSE 'Female' END AS 'gender',
					ISNULL(CAST(DATEDIFF(YEAR,CAST(A.dob AS DATE),CAST(GETDATE() AS DATE)) AS VARCHAR),'-') AS 'age',
					ISNULL(CAST(A.followUpStatus AS VARCHAR),'-') AS 'followUpStatus',
					ISNULL(CAST(A.followUpMode AS VARCHAR),'-') AS 'followUpMode',
					ISNULL(A.enquiryReason,'-') AS 'enquiryReason',
					CASE
						WHEN
							ISNULL(CAST(A.enquiryDate AS VARCHAR),'-')='-' THEN '-' 
						ELSE 
							CONVERT(VARCHAR,A.enquiryDate,103)--103 -format dd/mm/yyyy
						END AS 'enquiryDate',
					CAST(A.createdDate AS DATE) AS 'createdDate',
					A.gymOwnerId,
					A.branchId,

					--Mstr_UserLogin
					ISNULL(B.mobileNo,'-') AS 'mobileNo',

					--Mstr_Configuration
					ISNULL(C.configName,'-') AS 'followUpModeName',
					ISNULL(D.configName,'-') AS 'followUpStatusName'
				FROM
					Mstr_User AS A 
		
					--For Getting User's Mobile No
					INNER JOIN Mstr_UserLogin AS B ON A.userId=B.userId AND A.activeStatus='A'

					--For getting Follow up Mode Name And '23' Is Default Id of followUpMode
					LEFT JOIN Mstr_Configuration AS C ON A.followUpMode=C.configId AND C.typeId='23' AND C.activeStatus='A'
			
					--For getting Follow up Status Name And  '24' Is Default Id of followUpStatus
					LEFT JOIN Mstr_Configuration AS D ON A.followUpStatus=D.configId AND D.typeId='24' AND D.activeStatus='A'
				WHERE 
					A.gymOwnerId=@GymOwnerId AND
					A.branchId=@BranchId AND
					A.activeStatus='A' AND
				   (A.enquiryReason IS NOT NULL OR enquiryReason <>'')
			) AS A
			WHERE
				A.createdDate BETWEEN @FromDate AND @ToDate
			ORDER BY
				A.userName
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetFormsAccessRights]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetFormsAccessRights]
(
@QueryType VARCHAR(150),
@BranchId  INT, 
@GymOwnerId INT,
@UserId INT,
@RoleId INT
)
AS
BEGIN
	IF(@QueryType='GetFormAccessRights')
		BEGIN
			SELECT 
				A.optionId,B.optionName,viewRights,editRights,addRights,deleteRights,A.activeStatus
			FROM 
				Mstr_UserMenuAccess AS A 
			INNER JOIN
				Mstr_MenuOption AS B ON A.optionId=B.optionId 
			WHERE  B.activeStatus='A' AND A.branchId=@BranchId AND A.GymOwnerId=@GymOwnerId AND A.empId=@UserId AND A.roleId=@RoleId
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetGymOwnerAndBranch]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetGymOwnerAndBranch]
(
@QueryType VARCHAR(50),
@GymOwnerId INT=NULL
)
AS
BEGIN
 IF(@QueryType='GetGymOwnerId')
	BEGIN
		SELECT TOP 1 gymOwnerId FROM Mstr_GymOwner WHERE activeStatus='A'
	END

 IF(@QueryType='GetBranchId')
	BEGIN
		SELECT branchId,branchName FROM Mstr_Branch WHERE activeStatus='A' AND gymOwnerId=@GymOwnerId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrAppSetting]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrAppSetting]
(
@QueryType VARCHAR(150),
@gymOwnerId int =null,
@appVersion Varchar(10)=null,
@appType CHAR(1)=null,
@packageName NVARCHAR(50)=null
)
AS	
BEGIN
	SET NOCOUNT ON
	IF(@QueryType='GetAppVersions')
		BEGIN
			IF EXISTS(SELECT gymOwnerId,packageName,appVersion,appType,versionChanges FROM Mstr_AppSetting 
			WHERE  appVersion=@appVersion AND appType=@appType AND activeStatus='A')
			BEGIN
			   SELECT 'True' as Status
			END
			ELSE
			BEGIN
			   SELECT 'False' as Status
			END

		END
	ELSE IF(@QueryType='GetAllAppVersions')
		BEGIN
			SELECT ApSet.uniqueId,ApSet.gymOwnerId,GmOnr.gymOwnerName,packageName,appType,appVersion,versionChanges,ApSet.activeStatus
			FROM Mstr_AppSetting AS ApSet
			INNER JOIN Mstr_GymOwner AS GmOnr ON GmOnr.gymOwnerId = ApSet.gymOwnerId AND GmOnr.activeStatus='A'
			WHERE ApSet.activeStatus='A'
		END
	ELSE IF(@QueryType='GetAppVersionOnPckgName')
		BEGIN
			SELECT ApSet.uniqueId,ApSet.gymOwnerId,GmOnr.gymOwnerName,packageName,appType,appVersion,versionChanges,ApSet.activeStatus
			FROM Mstr_AppSetting AS ApSet
			INNER JOIN Mstr_GymOwner AS GmOnr ON GmOnr.gymOwnerId = ApSet.gymOwnerId AND GmOnr.activeStatus='A'
			WHERE ApSet.packageName=@packageName AND ApSet.activeStatus='A' 
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrBranch]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrBranch]
(
@queryType VARCHAR(100),
@gymOwnerId INT =0,
@branchId INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@queryType='GetBranchMstrSA')
		BEGIN
			SELECT branchId,gymOwnerId,branchName,shortName,latitude,longitude ,address1,address2,district,state,city,pincode,primaryMobileNumber,
			secondayMobilenumber,emailId,gstNumber,approvalStatus,activeStatus,'' AS 'image' FROM Mstr_Branch 
		END 
	ELSE IF(@queryType='GetBranchMstrOwner')
		BEGIN
			SELECT branchId,gymOwnerId,branchName,shortName,latitude,longitude ,address1,address2,district,state,city,pincode,primaryMobileNumber,
			secondayMobilenumber,emailId,gstNumber,approvalStatus,activeStatus,'' AS 'image' FROM Mstr_Branch  WHERE gymOwnerId=@gymOwnerId
		END
	ELSE IF(@queryType='GetBranchMstr')
		BEGIN
			SELECT branchId,gymOwnerId,branchName,shortName,latitude,longitude ,address1,address2,district,state,city,pincode,primaryMobileNumber,
			secondayMobilenumber,emailId,gstNumber,approvalStatus,activeStatus,'' AS 'image' FROM Mstr_Branch  WHERE gymOwnerId=@gymOwnerId and branchId=@branchId 
		END 

--Get DropDown

   ELSE IF(@queryType='ddlBranchMstrSA')
		BEGIN
			SELECT branchId,branchName,(SELECT TOP 1 imageUrl FROM Mstr_BranchGallery WHERE branchId=A.branchId ) AS 'image' FROM Mstr_Branch AS A
			Where activeStatus = 'A'
		END
	ELSE IF(@queryType='ddlBranchMstrOwner')
		BEGIN
			SELECT branchId,branchName,(SELECT TOP 1 imageUrl FROM Mstr_BranchGallery  where gymOwnerId=@gymOwnerId AND branchId=A.branchId  AND activeStatus = 'A')  AS 'image'
			FROM Mstr_Branch AS A  WHERE gymOwnerId=@gymOwnerId AND activeStatus = 'A'
		END
	ELSE IF(@queryType='ddlBranchMstr')
		BEGIN
			SELECT branchId,branchName,(SELECT TOP 1 imageUrl FROM Mstr_BranchGallery  where gymOwnerId=@gymOwnerId and branchId=@branchId  AND activeStatus = 'A') AS 'image' FROM Mstr_Branch  
			WHERE gymOwnerId=@gymOwnerId and branchId=@branchId  AND activeStatus = 'A'
		END 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrBranchGallery]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrBranchGallery]
(
@QueryType VARCHAR(100),
@branchId INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrBranchGallery')


		BEGIN
			SELECT imageId,branchId,imageUrl,activeStatus FROM Mstr_BranchGallery where branchId = @branchId
		END 

END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrBranchWorkingSlot]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrBranchWorkingSlot]
(
	@QueryType VARCHAR(150),
	@branchId INT,
	@workingDayId INT =0,
	@gymOwnerId INT
)
AS
BEGIN
	IF(@QueryType='GetBranchworkingDaysForSlots')
		BEGIN
			;WITH CTE_BranchWorkingSlots
			AS
			(
			 SELECT * FROM (
				SELECT 
					slotId,branchId,gymOwnerId,workingDayId,fromTime,toTime,slotTimeInMinutes,
					ROW_NUMBER() OVER(PARTITION BY workingDayId  ORDER BY workingDayId DESC) AS row_number
				FROM
					Mstr_BranchWorkingSlot 
				WHERE 
					branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A') AS A WHERE row_number=1 
			),
			CTE_BranchWorkingDay
			AS
			(
				SELECT 
					branchId,gymOwnerId,workingDayId,workingDay,fromTime,toTime 
				FROM 
					Mstr_BranchWorkingDay
				WHERE 
					branchId=@branchId AND gymOwnerId=@gymOwnerId
			)
			SELECT 
				A.slotId,A.branchId,A.gymOwnerId,A.workingDayId,B.workingDay 
			FROM
				CTE_BranchWorkingSlots AS A
			INNER JOIN
				Mstr_BranchWorkingDay AS B 	ON A.branchId=B.branchId AND A.workingDayId=B.workingDayId AND A.gymOwnerId=B.gymOwnerId
		END

		IF(@QueryType='GetBranchWorkingSlots')
			BEGIN
				;WITH CTE_BranchWorkingSlots
				AS
				(
					SELECT 
						slotId,branchId,gymOwnerId,workingDayId,fromTime,toTime,slotTimeInMinutes 
					FROM
						Mstr_BranchWorkingSlot 
					WHERE 
						branchId=@branchId AND gymOwnerId=@gymOwnerId AND workingDayId=@workingDayId 
						
				),
				CTE_BranchWorkingDay
				AS
				(
					SELECT 
						branchId,gymOwnerId,workingDayId,workingDay,fromTime,toTime 
					FROM 
						Mstr_BranchWorkingDay
					WHERE 
						branchId=@branchId AND gymOwnerId=@gymOwnerId AND workingDayId=@workingDayId
				)
				SELECT 
					A.slotId,A.branchId,A.gymOwnerId,A.workingDayId,B.workingDay,CONVERT(VARCHAR,A.fromTime,8) AS 'fromTime',CONVERT(VARCHAR,A.toTime,8) AS 'toTime'
					,A.slotTimeInMinutes
				FROM
					CTE_BranchWorkingSlots AS A
				INNER JOIN
					Mstr_BranchWorkingDay AS B 	ON A.branchId=B.branchId AND A.workingDayId=B.workingDayId AND A.gymOwnerId=B.gymOwnerId
			END

	IF(@QueryType='GetBranchWorkingDaysandSlotsForSlots')
			BEGIN
				;WITH CTE_BranchWorkingSlots
				AS
				(
					SELECT 
						slotId,branchId,gymOwnerId,workingDayId,fromTime,toTime,slotTimeInMinutes 
					FROM
						Mstr_BranchWorkingSlot 
					WHERE 
						branchId=@branchId AND gymOwnerId=@gymOwnerId AND workingDayId=@workingDayId
						 AND slotId NOT IN(SELECT slotId
						FROM Mstr_FitnessCategorySlot WHERE branchId=@branchId AND gymOwnerId=@gymOwnerId 
						AND workingDayId=@workingDayId)
				),
				CTE_BranchWorkingDay
				AS
				(
					SELECT 
						branchId,gymOwnerId,workingDayId,workingDay,fromTime,toTime 
					FROM 
						Mstr_BranchWorkingDay
					WHERE 
						branchId=@branchId AND gymOwnerId=@gymOwnerId AND workingDayId=@workingDayId
				)
				SELECT 
					A.slotId,A.branchId,A.gymOwnerId,A.workingDayId,B.workingDay,CONVERT(VARCHAR,A.fromTime,8) AS 'fromTime',CONVERT(VARCHAR,A.toTime,8) AS 'toTime'
					,A.slotTimeInMinutes
				FROM
					CTE_BranchWorkingSlots AS A
				INNER JOIN
					Mstr_BranchWorkingDay AS B 	ON A.branchId=B.branchId AND A.workingDayId=B.workingDayId AND A.gymOwnerId=B.gymOwnerId
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrCategory]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrCategory]
(
@QueryType VARCHAR(100),
@gymOwnerId Int=0 ,
@branchId INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getCategory')
	BEGIN
		 IF(@branchId != 0)
			BEGIN
				SELECT categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId WHERE F.gymOwnerId = @gymOwnerId AND F.branchId=@branchId
			END 
	 
	END
	ELSE IF(@QueryType='ddlCategory')
	    BEGIN
			SELECT categoryId,categoryName
			FROM Mstr_FitnessCategory WHERE gymOwnerId = @gymOwnerId AND branchId=@branchId AND activeStatus= 'A'		
		END
	ELSE IF(@QueryType='getCategoryForUser')
	BEGIN
		 IF(@gymOwnerId != 0 AND @branchId !=0)
			BEGIN
				
				SELECT * FROM (SELECT distinct F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,
				description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.gymOwnerId = @gymOwnerId AND F.branchId=@branchId AND F.activeStatus='A' 
				AND F.categoryId IN (SELECT categoryId FROM Mstr_FitnessCategoryPrice 
				WHERE gymOwnerId = @gymOwnerId AND branchId=@branchId AND activeStatus='A')) AS A
				LEFT JOIN 
				(SELECT * FROM(SELECT actualAmount,displayAmount,(actualAmount - displayAmount) AS 'SavedAmount',ROW_NUMBER() OVER(PARTITION BY categoryId
				ORDER BY displayAmount Asc) RowNumber,categoryId,branchId,gymOwnerId FROM Mstr_FitnessCategoryPrice) AS C 
				WHERE C.RowNumber=1	 ) AS B 
				ON A.categoryId=B.categoryId AND A.branchId=B.branchId AND A.gymOwnerId=B.gymOwnerId
			END 
		ELSE IF (@gymOwnerId != 0)
	      BEGIN
				SELECT  F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.gymOwnerId = @gymOwnerId  AND F.activeStatus='A' 
				AND categoryId IN(SELECT categoryId FROM Mstr_FitnessCategoryPrice WHERE  gymOwnerId = @gymOwnerId AND activeStatus='A')
		 END 

		 ELSE IF (@branchId != 0)
	      BEGIN
				SELECT  F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.branchId=@branchId AND F.activeStatus='A' 
				AND categoryId IN(SELECT categoryId FROM Mstr_FitnessCategoryPrice WHERE  branchId=@branchId AND activeStatus='A')
		 END 
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrCategory_20230225]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[usp_GetMstrCategory_20230225]
(
@QueryType VARCHAR(100),
@gymOwnerId Int=0,
@branchId INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getCategory')
	BEGIN
		 IF(@branchId != 0)
			BEGIN
				SELECT categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId WHERE F.gymOwnerId = @gymOwnerId AND F.branchId=@branchId
			END 
	 
	END
	ELSE IF(@QueryType='ddlCategory')
	    BEGIN
			SELECT categoryId,categoryName
			FROM Mstr_FitnessCategory WHERE gymOwnerId = @gymOwnerId AND branchId=@branchId AND activeStatus= 'A'		
		END
	ELSE IF(@QueryType='getCategoryForUser')
	BEGIN
		 IF(@gymOwnerId != 0 AND @branchId !=0)
			BEGIN
				SELECT  F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.gymOwnerId = @gymOwnerId AND F.branchId=@branchId AND F.activeStatus='A' 
				AND categoryId IN(SELECT categoryId FROM Mstr_FitnessCategoryPrice WHERE  gymOwnerId = @gymOwnerId AND branchId=@branchId AND activeStatus='A')
			
			END 
		ELSE IF (@gymOwnerId != 0)
	      BEGIN
				SELECT  F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.gymOwnerId = @gymOwnerId  AND F.activeStatus='A' 
				AND categoryId IN(SELECT categoryId FROM Mstr_FitnessCategoryPrice WHERE  gymOwnerId = @gymOwnerId AND activeStatus='A')
		 END 

		 ELSE IF (@branchId != 0)
	      BEGIN
				SELECT  F.categoryId,F.gymOwnerId,O.gymOwnerName,F.branchId, B.branchName,categoryName,description,imageUrl,F.activeStatus
				FROM Mstr_FitnessCategory AS F INNER JOIN Mstr_Branch AS B ON F.branchId  = B.branchId
				INNER JOIN Mstr_GymOwner AS O On F.gymOwnerId = O.gymOwnerId
				WHERE F.branchId=@branchId AND F.activeStatus='A' 
				AND categoryId IN(SELECT categoryId FROM Mstr_FitnessCategoryPrice WHERE  branchId=@branchId AND activeStatus='A')
		 END 
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrCategoryBenefit]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrCategoryBenefit]
(
@QueryType VARCHAR(100),
@CategoryId int=null,
@branchId int=null,
@typeName Varchar(50)=null
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getCategoryBenefit')
		BEGIN
		 IF(@CategoryId IS NOT NULL)
		 BEGIN
				SELECT uniqueId,CB.categoryId,FC.categoryName,CB.imageUrl,type,C.configName,CB.description,CB.activeStatus FROM Mstr_CategoryBenefit AS CB
				INNER JOIN Mstr_FitnessCategory AS FC ON CB.categoryId =FC.categoryId 
				INNER JOIN Mstr_Configuration AS C ON CB.type=C.configId
				where CB.categoryId=@CategoryId AND CB.activeStatus='A'
		 END
	     ELSE IF(@branchId IS NOT NULL)
		 BEGIN
				SELECT uniqueId,CB.categoryId,FC.categoryName,CB.imageUrl,type,C.configName,CB.description,CB.activeStatus FROM Mstr_CategoryBenefit AS CB
				INNER JOIN Mstr_FitnessCategory AS FC ON CB.categoryId =FC.categoryId 
				INNER JOIN Mstr_Configuration AS C ON CB.type=C.configId
				where  FC.branchId =@branchId
		END
		END  
	IF(@QueryType='getCategoryBenefitForUser')
		BEGIN
				SELECT uniqueId,CB.categoryId,FC.categoryName,CB.imageUrl,type,C.configName,CB.description,CB.activeStatus FROM Mstr_CategoryBenefit AS CB
				INNER JOIN Mstr_FitnessCategory AS FC ON CB.categoryId =FC.categoryId 
				INNER JOIN Mstr_Configuration AS C ON CB.type=C.configId
				where CB.categoryId=@CategoryId AND CB.activeStatus='A'
		END
	IF(@QueryType='getCategoryBenefitBasedOnBenefitType')
		BEGIN
				SELECT uniqueId,CB.categoryId,FC.categoryName,CB.imageUrl,type,C.configName,CB.description,CB.activeStatus FROM Mstr_CategoryBenefit AS CB
				INNER JOIN Mstr_FitnessCategory AS FC ON CB.categoryId =FC.categoryId 
				INNER JOIN Mstr_Configuration AS C ON CB.type=C.configId
				where  FC.branchId =@branchId AND CB.categoryId=@CategoryId AND CB.activeStatus='A' AND C.configName=@typeName
		END  
    IF(@QueryType='getCategoryBenefitDep')
		BEGIN
				SELECT uniqueId,CB.categoryId,FC.categoryName,CB.imageUrl,type,C.configName,CB.description,CB.activeStatus FROM Mstr_CategoryBenefit AS CB
				INNER JOIN Mstr_FitnessCategory AS FC ON CB.categoryId =FC.categoryId 
				INNER JOIN Mstr_Configuration AS C ON CB.type=C.configId
				where CB.categoryId=@CategoryId 
		END  
		
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrCategoryDietPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Modified By Abhinaya K
       ModiFied Date 03-Mar-2023******/

CREATE PROCEDURE [dbo].[usp_GetMstrCategoryDietPlan]
(
@QueryType VARCHAR(100),  
@categoryId INT = NUll,
@branchId INT = NUll,
@gymOwnerId INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrCategoryDietPlan')
	BEGIN 
	         SELECT (SELECT DISTINCT FD.mealTypeId,C.configName AS mealTypeName , 
			(SELECT ft.dietTimeId,Ft.uniqueId, Ft.mealTypeId,Ft.foodItemId,f.foodItemName,Ft.activeStatus,Ft.categoryId,Ms.categoryName AS categoryName
			FROM Mstr_CategoryDietPlan AS Ft 
			INNER JOIN Mstr_FitnessCategory As Ms ON Ms.categoryId=Ft.categoryId
			INNER JOIN Mstr_Configuration AS C ON C.configId = Ft.mealTypeId 
			INNER JOIN Mstr_FoodItem AS F ON Ft.foodItemId = F.foodItemId  WHERE C.configId = fd.mealTypeId 
			AND c.configName In (  'Breakfast' , 'Lunch' ,'Dinner' ,'Snacks1','Snacks2','Snacks3' )
			AND Ft.categoryId=@categoryId 
			AND FD.branchId=@branchId AND FD.gymOwnerId=@gymOwnerId 
			FOR JSON Path  ) AS FoodItemList
			FROM Mstr_CategoryDietPlan AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.mealTypeId WHERE FD.categoryId=@categoryId 
			AND FD.branchId=@branchId AND FD.gymOwnerId=@gymOwnerId 
			For JSON Path ) AS CategoryDietPlan 
    END
   IF(@QueryType='getMstrCategory')
	BEGIN 
	     SELECT DISTINCT A.categoryId,A.categoryName  FROM Mstr_FitnessCategory AS A
		 WHERE categoryId IN (SELECT categoryId FROM  Mstr_CategoryDietPlan WHERE  A.branchId=@branchId AND A.gymOwnerId=@gymOwnerId) 
		 AND A.branchId=@branchId AND A.gymOwnerId=@gymOwnerId
    END 
	 IF(@QueryType='getWeekDays')
	BEGIN 
	SELECT * FROM (
				SELECT (DATENAME(dw, GETDATE())) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() AS DATE),105) 'Date'
		UNION ALL  
		SELECT (DATENAME(dw, GETDATE() + 1))AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 1 AS DATE),105) 'Date'
		UNION ALL 
		SELECT (DATENAME(dw, GETDATE() + 2)) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 2 AS DATE),105) 'Date'
		UNION ALL 
		SELECT (DATENAME(dw, GETDATE() + 3)) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 3 AS DATE),105) 'Date'
		UNION ALL 
		SELECT (DATENAME(dw, GETDATE() + 4)) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 4 AS DATE),105) 'Date'
		UNION ALL 
		SELECT (DATENAME(dw, GETDATE() + 5)) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 5 AS DATE),105) 'Date'
		UNION ALL 
		SELECT (DATENAME(dw, GETDATE() + 6)) AS 'Day',CONVERT(NVARCHAR,CAST(GETDATE() + 6 AS DATE),105) 'Date') AS A

    END 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetMstrConfig]
(
@QueryType VARCHAR(100),
@typeId INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetConfigMaster')
		BEGIN
			SELECT A.typeId,B.typeName,A.configId,A.configName,A.activeStatus FROM Mstr_Configuration AS A INNER JOIN 
			Mstr_ConfigurationType AS B ON A.typeId=B.typeId ORDER BY B.typeName
		END 
		ELSE IF(@QueryType='ddlConfigMaster')
		BEGIN
		 IF(@typeId != 0)
			BEGIN
			IF(@typeId = 11)
			BEGIN
				SELECT configId,configName FROM Mstr_Configuration  WHere typeId=@typeId AND activeStatus='A' and configId NOT IN ('29','30','33')
			END
			ELSE 
			    BEGIN
				   SELECT configId,configName FROM Mstr_Configuration  WHere typeId=@typeId AND activeStatus='A'
				END
			END 
	   
		 ELSE 
			BEGIN
			    SELECT configId,configName FROM Mstr_Configuration WHere activeStatus='A'
			END
		END
END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrConfigType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrConfigType]
(
@QueryType VARCHAR(100),
@typeId INT=0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetConfigTypes')
		BEGIN
			SELECT typeId,typeName,activeStatus FROM Mstr_ConfigurationType
		END 
		ELSE IF(@QueryType='ddlConfigTypes')
		 IF(@typeId != 0)
		BEGIN
			SELECT typeId,typeName FROM Mstr_ConfigurationType WHere typeId=@typeId AND activeStatus='A'
		END 
		ELSE 
		BEGIN
		SELECT typeId,typeName FROM Mstr_ConfigurationType WHere activeStatus='A'
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrDietType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrDietType]
(
@QueryType VARCHAR(100)
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getDietType')
		BEGIN
			SELECT dietTypeId,dietTypeNameId,c.configName AS dietTypeName,description,
			imageUrl,typeIndicationImageUrl,D.activeStatus FROM Mstr_DietType AS D INNER JOIN Mstr_Configuration AS C On configId = dietTypeNameId
		END 

		ELSE IF(@QueryType='getddlDietType')
		BEGIN
			SELECT dietTypeId,c.configName AS dietTypeName
		    FROM Mstr_DietType AS D INNER JOIN Mstr_Configuration AS C On configId = dietTypeNameId 
			where D.activeStatus='A'
		END 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrEmployee]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrEmployee]
(
@queryType VARCHAR(100),
@gymOwnerId INT =0,
@branchId INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	 
	IF(@queryType='GetMstrEmployee')
		BEGIN
			SELECT BR.branchId,EMP.gymOwnerId,BR.branchName,empId,empType,et.configName as 'EmployeTypeName',firstName ,lastName,designation,d.configName as 'DesignationName',
			department,DE.configName as 'DepartmentName',gender,addressLine1,addressLine2,EMP.district,US.mailId,
			EMP.state,EMP.city,zipcode,maritalStatus,CONVERT(NVARCHAR,dob,105) AS 'dob',CONVERT(NVARCHAR,doj,105) AS 'doj',aadharId,photoLink,EMP.shiftId,S.ShiftName,US.roleId,R.configName as 'RoleName',US.mobileNo,
			US.password,mobileAppAccess,EMP.activeStatus
			FROM  Mstr_Employee AS EMP INNER JOIN Mstr_UserLogin AS US ON EMP.empId=US.userId
			INNER JOIN Mstr_Branch AS BR ON BR.branchId=EMP.branchId
			INNER JOIN Mstr_Configuration AS ET ON ET.configId=EMP.empType
			INNER JOIN Mstr_Configuration AS D ON D.configId=EMP.designation
			INNER JOIN Mstr_Configuration AS DE ON DE.configId=EMP.department
			INNER JOIN Mstr_Configuration AS R ON R.configId=us.roleId
			INNER JOIN Mstr_Shift AS S ON S.ShiftId=EMP.shiftId
			WHERE EMP.gymOwnerId=@gymOwnerId and EMP.branchId=@branchId 
		END 

		ELSE IF (@queryType='ddlMstrEmployee')
		BEGIN
		    SELECT empId,firstName +' '+ lastName AS 'empName' FROM Mstr_Employee WHERE gymOwnerId=@gymOwnerId and branchId=@branchId  AND activeStatus='A'
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFaq]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrFaq]
(
@QueryType VARCHAR(100)
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getFaq')
		BEGIN
			SELECT faqId,offerId,question,answer,questionType,activeStatus FROM Mstr_Faq
		END 
END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFitnessCategoryPrice]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrFitnessCategoryPrice]
(
@queryType VARCHAR(100),
@gymOwnerId INT =0,
@branchId INT =0,
@priceId INT =0,
@categoryId INT =0,
@planDuration INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	 
	IF(@queryType='GetMstrPrice')
		BEGIN
			SELECT  priceId,A.gymOwnerId,GY.gymName,A.branchId,BR.branchName,A.categoryId,CA.categoryName,
				A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TR.trainingTypeNameId as 'trainingType',
				A.trainingMode,planDuration,CONFI.configName AS 'planDurationName',price,cgstTax,sgstTax,
				(ISNULL(CAST(cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(sgstTax AS DECIMAL(18,2)),0)) AS 'tax',A.taxId,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=A.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
					netAmount,ISNULL(actualAmount,0) AS  'actualAmount',ISNULL(displayAmount,0) AS 'displayAmount',
					cyclePaymentsAllowed,maxNoOfCycles,A.activeStatus 
			FROM Mstr_FitnessCategoryPrice AS A
			INNER JOIN Mstr_GymOwner AS GY ON A.gymOwnerId=GY.gymOwnerId AND GY.activeStatus= 'A'
			INNER JOIN Mstr_Branch AS BR ON A.gymOwnerId=BR.gymOwnerId AND A.branchId=BR.branchId 
				AND BR.activeStatus= 'A'
		    INNER JOIN Mstr_FitnessCategory AS CA ON A.gymOwnerId=CA.gymOwnerId AND A.branchId=CA.branchId
				AND CA.activeStatus= 'A'
			AND A.categoryId=CA.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
				AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A' --trainingTypeName
			INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=A.planDuration AND CONFI.activeStatus='A' --planDurationName
			WHERE A.gymOwnerId=@gymOwnerId and A.branchId=@branchId 
		END 
		--not in use now
		IF(@queryType='GetPriceListForSlot')
		BEGIN
		SELECT  priceId,A.gymOwnerId,GY.gymName,A.branchId,BR.branchName,A.categoryId,CA.categoryName,
				A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TR.trainingTypeNameId as 'trainingType',
				A.trainingMode,planDuration,CONFI.configName AS 'planDurationName',price,cgstTax,sgstTax,
				(ISNULL(CAST(cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(sgstTax AS DECIMAL(18,2)),0)) AS 'tax',A.taxId,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId and taxId=A.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
					netAmount,ISNULL(actualAmount,0) AS  'actualAmount',ISNULL(displayAmount,0) AS 'displayAmount'
					,cyclePaymentsAllowed,maxNoOfCycles,A.activeStatus 
			FROM Mstr_FitnessCategoryPrice AS A
			INNER JOIN Mstr_GymOwner AS GY ON A.gymOwnerId=GY.gymOwnerId AND GY.activeStatus= 'A'
			INNER JOIN Mstr_Branch AS BR ON A.gymOwnerId=BR.gymOwnerId AND A.branchId=BR.branchId 
				AND BR.activeStatus= 'A'
		    INNER JOIN Mstr_FitnessCategory AS CA ON A.gymOwnerId=CA.gymOwnerId AND A.branchId=CA.branchId
				AND CA.activeStatus= 'A'
			AND A.categoryId=CA.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
				AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A' --trainingTypeName
			INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=A.planDuration AND CONFI.activeStatus='A' --planDurationName
			WHERE A.gymOwnerId=@gymOwnerId and A.branchId=@branchId   AND A.priceId=@priceId
		END 
		--end
		
		--IF(@queryType='GetPriceOnCategory')
		--BEGIN
		--	SELECT * FROM (
		--	SELECT FCP.priceId,FCP.categoryId,FC.categoryName,ISNULL(FCP.trainingTypeId,0) AS 'trainingTypeId',
		--	'Online' AS 'trainingTypeName',FCP.trainingMode,FCP.planDuration,CONFI.configName AS 'planDurationName',
		--	FCP.cyclePaymentsAllowed, FCP.maxNoOfCycles,FCP.price,FCP.cgstTax,FCP.sgstTax,FCP.taxId,
		--	(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',		
		--	(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
		--			WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
		--			FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
		--			Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' and taxId=FCP.taxId
		--			GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
		--	FCP.netAmount,FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,
		--	FCP.branchId,BR.branchName,0 AS 'row_number'
		--		FROM Mstr_FitnessCategoryPrice AS FCP 		 
		--		INNER JOIN Mstr_FitnessCategory AS FC ON 
		--			FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
		--			AND FC.activeStatus='A'		
		--		INNER JOIN Mstr_Configuration AS CONFI ON 
		--			CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
		--		INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
		--		INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
		--			BR.activeStatus=FCP.activeStatus
		--		WHERE FCP.gymOwnerId=@gymOwnerId AND FCP.branchId=@branchId AND FCP.activeStatus='A'
		--		AND FCP.categoryId = @categoryId AND FCP.trainingMode='O'

		--UNION ALL 

		--		SELECT * FROM(
		--	SELECT  FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
		--	FCP.trainingMode,FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
		--	FCP.maxNoOfCycles,FCP.price,
		--	FCP.cgstTax,FCP.sgstTax,FCP.taxId,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
		--	(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
		--			WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
		--			FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
		--			Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' and taxId=FCP.taxId
		--			GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
		--	FCP.netAmount,FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,
		--	FCP.branchId,BR.branchName,ROW_NUMBER() OVER(PARTITION BY planDuration
		--	ORDER BY planDuration DESC) AS row_number
		--		FROM Mstr_FitnessCategoryPrice AS FCP 		 
		--		INNER JOIN Mstr_FitnessCategory AS FC ON 
		--			FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
		--			AND FC.activeStatus='A'
		--		INNER JOIN Mstr_TrainingType AS TT ON 
		--			TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
		--			AND TT.activeStatus='A'
		--		INNER JOIN Mstr_Configuration AS CONFIG ON
		--			CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
		--		INNER JOIN Mstr_Configuration AS CONFI ON 
		--			CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
		--		INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
		--		INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
		--			BR.activeStatus=FCP.activeStatus
		--		WHERE FCP.gymOwnerId=@gymOwnerId AND FCP.branchId=@branchId AND FCP.activeStatus='A'
		--		AND FCP.categoryId = @categoryId  AND FCP.trainingMode='D') AS Dir WHERE  Dir.row_number =1) AS FP 
		--		ORDER BY planDurationName ,row_number	
		--END

		IF(@queryType='GetPriceOnCategory')
		BEGIN
		    SELECT * FROM(
			SELECT  FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
			FCP.trainingMode,FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
			FCP.maxNoOfCycles,FCP.price,
			FCP.cgstTax,FCP.sgstTax,FCP.taxId,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
			(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=FCP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
			FCP.netAmount,ISNULL(FCP.actualAmount,0) AS  'actualAmount',ISNULL(FCP.displayAmount,0) AS 'displayAmount',
			FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,
			FCP.branchId,BR.branchName,ROW_NUMBER() OVER(PARTITION BY planDuration
			ORDER BY planDuration DESC) AS row_number
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'
				INNER JOIN Mstr_TrainingType AS TT ON 
					TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
					AND TT.activeStatus='A'
				INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId=@gymOwnerId AND FCP.branchId=@branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId ) AS Dir WHERE  Dir.row_number =1
		END
		IF(@queryType='GetPriceOnDuration')
		 BEGIN
 			SELECT FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
			FCP.trainingMode, FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
			FCP.maxNoOfCycles,FCP.price,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
			FCP.cgstTax,FCP.sgstTax,FCP.taxId,
		(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=FCP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
			FCP.netAmount,ISNULL(FCP.actualAmount,0) AS  'actualAmount',ISNULL(FCP.displayAmount,0) AS 'displayAmount',
			FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,FCP.branchId,BR.branchName
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'
				INNER JOIN Mstr_TrainingType AS TT ON 
					TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
					AND TT.activeStatus='A'
				INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId = @gymOwnerId AND FCP.branchId = @branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId AND FCP.planDuration = @planDuration --AND FCP.trainingMode='D'
		 END

		 IF(@queryType='GetPriceOnPublicWeb')
		 BEGIN
		 SELECT FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
			FCP.trainingMode, FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
			FCP.maxNoOfCycles,FCP.price,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
			FCP.cgstTax,FCP.sgstTax,FCP.taxId,
		(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId=FCP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
			FCP.netAmount,ISNULL(FCP.actualAmount,0) AS  'actualAmount',ISNULL(FCP.displayAmount,0) AS 'displayAmount',( actualAmount - displayAmount) as SavedAmount,
			FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,FCP.branchId,BR.branchName
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'
				INNER JOIN Mstr_TrainingType AS TT ON 
					TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
					AND TT.activeStatus='A'
				INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId = @gymOwnerId AND FCP.branchId = @branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId 
		 END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFitnessCategoryPrice_20221213_BK]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrFitnessCategoryPrice_20221213_BK]
(
@queryType VARCHAR(100),
@gymOwnerId INT =0,
@branchId INT =0,
@priceId INT =0,
@categoryId INT =0,
@planDuration INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	 
	IF(@queryType='GetMstrPrice')
		BEGIN
			SELECT  priceId,A.gymOwnerId,GY.gymName,A.branchId,BR.branchName,A.categoryId,CA.categoryName,
				A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TR.trainingTypeNameId as 'trainingType',
				A.trainingMode,planDuration,CONFI.configName AS 'planDurationName',price,cgstTax,sgstTax,
				(ISNULL(CAST(cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(sgstTax AS DECIMAL(18,2)),0)) AS 'tax',A.taxId,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = a.gymOwnerId FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax a 
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A'
					GROUP BY gymOwnerId,taxId,taxPercentage) AS 'taxName',
					netAmount,cyclePaymentsAllowed,maxNoOfCycles,A.activeStatus 
			FROM Mstr_FitnessCategoryPrice AS A
			INNER JOIN Mstr_GymOwner AS GY ON A.gymOwnerId=GY.gymOwnerId AND GY.activeStatus= 'A'
			INNER JOIN Mstr_Branch AS BR ON A.gymOwnerId=BR.gymOwnerId AND A.branchId=BR.branchId 
				AND BR.activeStatus= 'A'
		    INNER JOIN Mstr_FitnessCategory AS CA ON A.gymOwnerId=CA.gymOwnerId AND A.branchId=CA.branchId
				AND CA.activeStatus= 'A'
			AND A.categoryId=CA.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
				AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A' --trainingTypeName
			INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=A.planDuration AND CONFI.activeStatus='A' --planDurationName
			WHERE A.gymOwnerId=@gymOwnerId and A.branchId=@branchId 
		END 
		--not in use now
		IF(@queryType='GetPriceListForSlot')
		BEGIN
		SELECT  priceId,A.gymOwnerId,GY.gymName,A.branchId,BR.branchName,A.categoryId,CA.categoryName,
				A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',TR.trainingTypeNameId as 'trainingType',
				A.trainingMode,planDuration,CONFI.configName AS 'planDurationName',price,cgstTax,sgstTax,
				(ISNULL(CAST(cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(sgstTax AS DECIMAL(18,2)),0)) AS 'tax',A.taxId,
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = a.gymOwnerId FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax a 
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A'
					GROUP BY gymOwnerId,taxId,taxPercentage) AS 'taxName',
					netAmount,cyclePaymentsAllowed,maxNoOfCycles,A.activeStatus 
			FROM Mstr_FitnessCategoryPrice AS A
			INNER JOIN Mstr_GymOwner AS GY ON A.gymOwnerId=GY.gymOwnerId AND GY.activeStatus= 'A'
			INNER JOIN Mstr_Branch AS BR ON A.gymOwnerId=BR.gymOwnerId AND A.branchId=BR.branchId 
				AND BR.activeStatus= 'A'
		    INNER JOIN Mstr_FitnessCategory AS CA ON A.gymOwnerId=CA.gymOwnerId AND A.branchId=CA.branchId
				AND CA.activeStatus= 'A'
			AND A.categoryId=CA.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
				AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A' --trainingTypeName
			INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=A.planDuration AND CONFI.activeStatus='A' --planDurationName
			WHERE A.gymOwnerId=@gymOwnerId and A.branchId=@branchId   AND A.priceId=@priceId
		END 
		--end
		
		IF(@queryType='GetPriceOnCategory')
		BEGIN
			SELECT * FROM (
			SELECT FCP.priceId,FCP.categoryId,FC.categoryName,ISNULL(FCP.trainingTypeId,0) AS 'trainingTypeId',
			'Online' AS 'trainingTypeName',FCP.trainingMode,FCP.planDuration,CONFI.configName AS 'planDurationName',
			FCP.cyclePaymentsAllowed, FCP.maxNoOfCycles,FCP.price,FCP.cgstTax,FCP.sgstTax,FCP.taxId,
			(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',		
			(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
						WHERE b.gymOwnerId = a.gymOwnerId FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax a 
						Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A'
						GROUP BY gymOwnerId,taxId,taxPercentage) AS 'taxName',
			FCP.netAmount,FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,
			FCP.branchId,BR.branchName,0 AS 'row_number'
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'		
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId=@gymOwnerId AND FCP.branchId=@branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId AND FCP.trainingMode='O'

		UNION ALL 

				SELECT * FROM(
			SELECT  FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
			FCP.trainingMode,FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
			FCP.maxNoOfCycles,FCP.price,
			FCP.cgstTax,FCP.sgstTax,FCP.taxId,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
			(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
						WHERE b.gymOwnerId = a.gymOwnerId FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax a 
						Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A'
						GROUP BY gymOwnerId,taxId,taxPercentage) AS 'taxName',
			FCP.netAmount,FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,
			FCP.branchId,BR.branchName,ROW_NUMBER() OVER(PARTITION BY planDuration
			ORDER BY planDuration DESC) AS row_number
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'
				INNER JOIN Mstr_TrainingType AS TT ON 
					TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
					AND TT.activeStatus='A'
				INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId=@gymOwnerId AND FCP.branchId=@branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId  AND FCP.trainingMode='D') AS Dir WHERE  Dir.row_number =1) AS FP 
				ORDER BY planDurationName ,row_number	
		END

		IF(@queryType='GetPriceOnDuration')
		 BEGIN
 			SELECT FCP.priceId,FCP.categoryId,FC.categoryName,FCP.trainingTypeId,CONFIG.configName AS 'trainingTypeName',
			FCP.trainingMode, FCP.planDuration,CONFI.configName AS 'planDurationName',FCP.cyclePaymentsAllowed,
			FCP.maxNoOfCycles,FCP.price,(ISNULL(CAST(FCP.cgstTax AS DECIMAL(18,2)),0)+ISNULL(CAST(FCP.sgstTax AS DECIMAL(18,2)),0)) AS 'tax',
			FCP.cgstTax,FCP.sgstTax,FCP.taxId,
			(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = a.gymOwnerId FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax a 
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A'
					GROUP BY gymOwnerId,taxId,taxPercentage) AS 'taxName',
			FCP.netAmount,FCP.activeStatus,FCP.gymOwnerId,GYO.gymName,FCP.branchId,BR.branchName
				FROM Mstr_FitnessCategoryPrice AS FCP 		 
				INNER JOIN Mstr_FitnessCategory AS FC ON 
					FC.categoryId=FCP.categoryId AND FC.gymOwnerId=FCP.gymOwnerId AND FC.branchId=FCP.branchId 
					AND FC.activeStatus='A'
				INNER JOIN Mstr_TrainingType AS TT ON 
					TT.trainingTypeId=FCP.trainingTypeId AND TT.gymOwnerId=FCP.gymOwnerId AND TT.branchId=FCP.branchId 
					AND TT.activeStatus='A'
				INNER JOIN Mstr_Configuration AS CONFIG ON
					CONFIG.typeId='16' AND CONFIG.configId=TT.trainingTypeNameId AND CONFIG.activeStatus='A' 
				INNER JOIN Mstr_Configuration AS CONFI ON 
					CONFI.typeId='13' AND CONFI.configId=FCP.planDuration AND CONFI.activeStatus='A' 
				INNER JOIN Mstr_GymOwner AS GYO ON GYO.gymOwnerId=FCP.gymOwnerId AND GYO.activeStatus='A'
				INNER JOIN Mstr_Branch AS BR ON BR.gymOwnerId=FCP.gymOwnerId AND BR.branchId=FCP.branchId AND 
					BR.activeStatus=FCP.activeStatus
				WHERE FCP.gymOwnerId = @gymOwnerId AND FCP.branchId = @branchId AND FCP.activeStatus='A'
				AND FCP.categoryId = @categoryId AND FCP.planDuration = @planDuration AND FCP.trainingMode='D'
		 END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFoodDietTime]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrFoodDietTime]
(
@QueryType VARCHAR(100),  
@foodItemId INT = NUll,
@mealType INT = NUll,
@activeStatus CHAR(1) = NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrFoodDietTime')
	BEGIN 
	IF(@foodItemId != 0 )
		BEGIN
			SELECT uniqueId,FD.foodItemId,F.foodItemName,mealType,C.configName AS mealTypeName, FD.activeStatus AS activeStatus 
			FROM Mstr_FoodDietTime AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.mealType 
			INNER JOIN Mstr_FoodItem AS F ON FD.foodItemId = F.foodItemId where F.foodItemId = @foodItemId  
		END 

		ELSE 
		BEGIN
		    SELECT (SELECT DISTINCT FD.mealType,C.configName AS mealTypeName , 
			(SELECT ft.uniqueId, Ft.mealType,Ft.foodItemId,f.foodItemName FROM Mstr_FoodDietTime AS Ft 
			INNER JOIN Mstr_Configuration AS C ON C.configId = Ft.mealType 
			INNER JOIN Mstr_FoodItem AS F ON Ft.foodItemId = F.foodItemId  WHERE C.configId = fd.mealType 
			AND c.configName In (  'Breakfast' , 'Lunch' ,'Dinner' ,'Snacks1','Snacks2','Snacks3' )
			FOR JSON Path  ) AS FoodDietList
			FROM Mstr_FoodDietTime AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.mealType For JSON Path ) AS FoodDietTime
			
		END
    END
	ELSE IF (@QueryType='ddlMstrFoodDietTime')
	BEGIN
			SELECT FD.uniqueId,CAST(C.configName  AS VARCHAR)+ ' ~ ' +CAST(F.foodItemName AS VARCHAR) AS 'mealTypeName'
			FROM Mstr_FoodDietTime AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.mealType 
			INNER JOIN Mstr_FoodItem AS F ON FD.foodItemId = F.foodItemId  WHERE  F.activeStatus = 'A'

	END

	ELSE IF (@QueryType='MstrFoodDietTime')
	BEGIN
	IF(@foodItemId != 0 )
		BEGIN
			SELECT uniqueId,FD.foodItemId,F.foodItemName,mealType,C.configName AS mealTypeName, FD.activeStatus AS activeStatus 
			FROM Mstr_FoodDietTime AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.mealType 
			INNER JOIN Mstr_FoodItem AS F ON FD.foodItemId = F.foodItemId WHERE F.foodItemId = @foodItemId  AND F.activeStatus = 'A'
		END 
	END
	ELSE IF (@QueryType='MealtypebasedFoodItem')
	BEGIN
			SELECT FI.foodItemId,FI.foodItemName,FDT.mealType,FDT.uniqueId,FDT.activeStatus FROM Mstr_FoodDietTime AS FDT
			INNER JOIN Mstr_FoodItem AS FI ON FDT.foodItemId=FI.foodItemId
			WHERE FDT.mealType=@mealType
	END

END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFoodItem]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetMstrFoodItem]
(
@QueryType VARCHAR(100),
@dietTypeId INT=NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getFoodItem')
		BEGIN
			SELECT foodItemId,dietTypeId,foodItemName,unit,servingIn,B.configName AS 'servingInName'
			,protein,carbs,fat,calories,imageUrl,A.activeStatus FROM Mstr_FoodItem AS A
			INNER JOIN Mstr_Configuration AS B ON A.servingIn=B.configId
		END
		
		ELSE IF(@QueryType='ddlgetFoodItem')
		BEGIN
			SELECT foodItemId,dietTypeId,foodItemName FROM Mstr_FoodItem where activeStatus='A'
		END 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrFooterDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrFooterDetails]
(
@QueryType VARCHAR(100),
@gymOwnerId Int=0,
@branchId INT =0,
@displayType INT =0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getFooterDetails')
	BEGIN
		 IF(@branchId != 0 AND @gymOwnerId= 0 and @displayType=0)
			BEGIN
				SELECT FooterDetailsId,icons,description,link,displayType,B.configName AS 'displayTypeName',gymOwnerId,branchId,A.activeStatus FROM Mstr_FooterDetails as A
				INNER JOIN Mstr_Configuration AS B ON A.DisplayType=B.configId
				WHERE A.branchId=@branchId			
			END 
			ELSE IF(@branchId != 0 AND @gymOwnerId!= 0 and @displayType=0)
			BEGIN
				SELECT FooterDetailsId,icons,description,link,displayType,B.configName AS 'displayTypeName',gymOwnerId,branchId,A.activeStatus FROM Mstr_FooterDetails as A
				INNER JOIN Mstr_Configuration AS B ON A.DisplayType=B.configId
				WHERE A.branchId=@branchId and A.gymOwnerId=@gymOwnerId 
			END
			ELSE IF(@branchId != 0 AND @gymOwnerId!= 0 and @displayType!=0)
			BEGIN
				SELECT FooterDetailsId,icons,description,link,displayType,B.configName AS 'displayTypeName',gymOwnerId,branchId,A.activeStatus FROM Mstr_FooterDetails as A
				INNER JOIN Mstr_Configuration AS B ON A.DisplayType=B.configId
				WHERE A.branchId=@branchId and A.gymOwnerId=@gymOwnerId and A.DisplayType=@displayType AND A.activeStatus='A'
			END
	 
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrLiveConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- ==================================
--- Modified By Imran
--- Modified Date 07-Jan-2023
--- ==================================
CREATE PROCEDURE [dbo].[usp_GetMstrLiveConfig]
(
@QueryType VARCHAR(100),
@gymownerId int=NULL,
@branchId int=NULL,
@Date DATE=NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getLiveConfig')
	BEGIN
		 SELECT uniqueId,gymownerId,branchId,liveurl,CONVERT(NVARCHAR,livedate,105) as 'livedate',purposename,activestatus 
		 FROM Mstr_LiveConfig	where activestatus='A'	 
	END
	IF(@QueryType='getLiveDateConfig')
	BEGIN
	IF EXISTS(SELECT liveurl,livedate FROM Mstr_LiveConfig where activestatus='A' AND livedate=@Date)
	BEGIN
		 SELECT uniqueId,gymownerId,branchId,liveurl,CONVERT(NVARCHAR,livedate,105) as 'livedate',purposename,activestatus
		 FROM Mstr_LiveConfig where activestatus='A' AND branchId=@branchId AND CAST(livedate AS DATE)=CAST(@Date AS DATE)
		 END
		 ELSE
		 BEGIN
		 SELECT TOP 1 uniqueId,gymownerId,branchId,liveurl,CONVERT(NVARCHAR,livedate,105) as 'livedate',purposename,activestatus 
		 FROM Mstr_LiveConfig where activestatus='A' AND branchId=@branchId AND CAST(livedate AS DATE)<=CAST(@Date AS DATE)
		 ORDER BY createddate DESC
		 END
	 
	END

		IF(@QueryType='getBranchownerConfig')
	BEGIN
	
		 SELECT uniqueId,gymownerId,branchId,liveurl,CONVERT(NVARCHAR,livedate,105) as 'livedate',purposename,activestatus
		 FROM Mstr_LiveConfig where  branchId=@branchId AND gymownerId=@gymownerId
	 
	END
	
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrMealTimeConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrMealTimeConfig]
(
@QueryType VARCHAR(100),
@dietTypeId INT=NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMealTimeConfig')
		BEGIN
			SELECT mt.uniqueId,mealTypeId,c.configName AS mealTypeName,timeInHrs FROM MstrMealTimeConfig AS mt
			INNER JOIN Mstr_Configuration AS c on mt.mealTypeId = c.configId
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrMenuOption]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrMenuOption]
(
	@QueryType VARCHAR(150)
)
AS 
BEGIN
	IF(@QueryType='GetMenuOption')
		BEGIN
				SELECT optionId,optionName,activeStatus FROM Mstr_MenuOption 
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrMessageTemplate]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--*******************************
--Modified By Abhinaya K
--Modified Date 07-Jan-2023
--*******************************
CREATE PROCEDURE [dbo].[usp_GetMstrMessageTemplate]
(
@QueryType VARCHAR(100),
@messageHeader  VARCHAR(50)=NULL,
@templateType  char(1)=NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMessageTemplate')
		BEGIN
			SELECT uniqueId,messageHeader,messageBody,subject,messageBody,templateType,peid,TPID FROM Mstr_MessageTemplates
		END 
		If(@QueryType ='getMessge')
		BEGIN
		     SELECT uniqueId,messageHeader,messageBody,subject,templateType,peid,TPID FROM Mstr_MessageTemplates
			 WHERE messageHeader=@messageHeader AND  templateType=@templateType
		END
	
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrOffer]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetMstrOffer]
(
@QueryType VARCHAR(100),
@offerId INT = 0,
@gymOwnerId INT,
@branchId INT = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType ='getOffer')
	BEGIN
		IF (@offerId != 0)
			BEGIN
				SELECT offerId,gymOwnerId ,offerTypePeriod,offerHeading,offerDescription,offerCode,offerImageUrl,CONVERT(NVARCHAR,fromDate,105) AS 'fromDate'
				,CONVERT(NVARCHAR,toDate,105) AS 'toDate',offerType,
				offerValue,minAmt,maxAmt,noOfTimesPerUser,termsAndConditions,activeStatus, CASE When (CAST(GETDATE()  AS Date) > toDate) THEN 'Expired'  
				ELSE 'Not Expired' END  AS 'expireStatus'
				FROM Mstr_Offer where offerId= @offerId	AND gymOwnerId = @gymOwnerId	
			END 
		ELSE 
			BEGIN
				SELECT offerId,gymOwnerId,offerTypePeriod,offerHeading,offerDescription,offerCode,offerImageUrl,CONVERT(NVARCHAR,fromDate,105) AS 'fromDate'
				,CONVERT(NVARCHAR,toDate,105) AS 'toDate',offerType,
				offerValue,minAmt,maxAmt,noOfTimesPerUser,termsAndConditions,activeStatus, CASE When (CAST(GETDATE()  AS Date) > toDate) THEN 'Expired'  
				ELSE 'Not Expired' END  AS 'expireStatus'
				FROM Mstr_Offer where gymOwnerId = @gymOwnerId
			END 
    END
	ELSE IF (@QueryType ='ddlgetOffer')
	BEGIN
	        --select offerId,offerHeading,offerCode from Mstr_Offer where activeStatus='A'
			  SELECT offerId,offerHeading,offerCode FROM Mstr_Offer WHERE activeStatus='A' AND gymOwnerId = @gymOwnerId AND 
			 (CAST(GETDATE()  AS Date) <= toDate) AND offerId NOT IN (
			 SELECT offerId FROM Mstr_BranchOffer WHERE gymOwnerId = @gymOwnerId AND branchId = @branchId)
	END

END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrOfferMapping]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Modified BY Abhinaya K 
--Modified Date 07-Jan-2023
CREATE PROCEDURE [dbo].[usp_GetMstrOfferMapping]
(
@queryType VARCHAR(100),
@gymOwnerId INT =0,
@branchId INT
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@queryType='GetMstrOfferMapping')
		BEGIN
			--SELECT  BR.offerMappingId,BR.gymOwnerId, BR.branchId,BR.offerId,OE.offerHeading AS 'OfferName',OE.activeStatus FROM Mstr_BranchOffer AS BR INNER JOIN Mstr_Offer AS OE ON BR.offerId =OE.offerId
			-- WHERE BR.gymOwnerId=@gymOwnerId AND  BR.branchId=@branchId

			SELECT BR.offerMappingId, BR.gymOwnerId, BR.branchId, Brnch.branchName, BR.offerId, OE.offerHeading, BR.activeStatus,
				offerTypePeriod, offerDescription, offerCode, offerImageUrl, 
				CONVERT(NVARCHAR,fromDate,105) AS 'fromDate', CONVERT(NVARCHAR,toDate,105) AS 'toDate', offerType, 
				offerValue, minAmt, maxAmt, noOfTimesPerUser, termsAndConditions,
				CASE When (CAST(GETDATE()  AS Date) >= toDate) THEN 'Expired' ELSE 'Not Expired' END  AS 'expireStatus'
			FROM Mstr_BranchOffer AS BR 
			INNER JOIN Mstr_Offer AS OE ON BR.offerId = OE.offerId AND BR.gymOwnerId = OE.gymOwnerId 
			INNER JOIN Mstr_Branch AS Brnch ON Brnch.branchId= BR.branchId AND Brnch.gymOwnerId = BR.gymOwnerId 
				WHERE BR.gymOwnerId=@gymOwnerId AND BR.branchId=@branchId	
				
			  
		END 
		IF(@queryType='GetMstrOfferMappingUser')
		BEGIN
			SELECT * FROM (
			SELECT BR.offerMappingId, BR.gymOwnerId, BR.branchId, Brnch.branchName, BR.offerId, OE.offerHeading, BR.activeStatus,
				offerTypePeriod, offerDescription, offerCode, offerImageUrl, 
				CONVERT(NVARCHAR,fromDate,105) AS 'fromDate', CONVERT(NVARCHAR,toDate,105) AS 'toDate', offerType, 
				offerValue, minAmt, maxAmt, noOfTimesPerUser, termsAndConditions,
				CASE When (CAST(GETDATE()  AS Date) >= toDate) THEN 'Expired' ELSE 'Not Expired' END  AS 'expireStatus'
			FROM Mstr_BranchOffer AS BR 
			INNER JOIN Mstr_Offer AS OE ON BR.offerId = OE.offerId AND BR.gymOwnerId = OE.gymOwnerId  
			INNER JOIN Mstr_Branch AS Brnch ON Brnch.branchId= BR.branchId AND Brnch.gymOwnerId = BR.gymOwnerId 
				WHERE BR.gymOwnerId=@gymOwnerId AND BR.branchId=@branchId	AND BR.activeStatus='A' AND OE.activeStatus='A') AS A
				WHERE  A.expireStatus ='Not Expired'				  
		END 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrOfferRule]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrOfferRule]
(
@QueryType VARCHAR(100),
@offerId INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getOfferRule')

	IF(@offerId != 0 )
		BEGIN
			SELECT offerRuleId,R.offerId,O.offerHeading,C.configName ruleTypeName,offerRule,ruleType,R.activeStatus FROM Mstr_OfferRule R
			INNER JOIN Mstr_Offer O ON R.offerId = O.offerId 
			INNER JOIN Mstr_Configuration C ON C.configId = R.ruleType
			where R.offerId = @offerId
		END 

		ELSE 
		BEGIN
		    SELECT offerRuleId,R.offerId,O.offerHeading,C.configName ruleTypeName,offerRule,ruleType,R.activeStatus FROM Mstr_OfferRule R
			INNER JOIN Mstr_Offer O ON R.offerId = O.offerId 
			INNER JOIN Mstr_Configuration C ON C.configId = R.ruleType
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrOwner]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrOwner]
(
@QueryType VARCHAR(100),
@gymOwnerId int=0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetMstrOwner')
		BEGIN
			SELECT GYO.gymOwnerId,GYO.gymName,GYO.shortName,GYO.gymOwnerName,UL.mobileNo AS 'mobileNumber',UL.mailId,UL.password ,GYO.logoUrl,GYO.websiteUrl,GYO.activeStatus FROM Mstr_GymOwner AS GYO INNER JOIN 
			Mstr_UserLogin AS UL ON  GYO.gymOwnerId=UL.userId 
		END 
		ELSE IF(@QueryType='ddlGetMstrOwner')
		BEGIN
			SELECT gymOwnerId,gymOwnerName,logoUrl FROM Mstr_GymOwner where activeStatus='A'
		END 
		ELSE IF(@QueryType='GetMstrIndividualOwner')
		BEGIN
			SELECT GYO.gymOwnerId,GYO.gymName,GYO.shortName,GYO.gymOwnerName,UL.mobileNo AS 'mobileNumber',UL.mailId,UL.password ,GYO.logoUrl,GYO.websiteUrl,GYO.activeStatus FROM Mstr_GymOwner AS GYO INNER JOIN 
			Mstr_UserLogin AS UL ON  GYO.gymOwnerId=UL.userId  where GYO.gymOwnerId=@gymOwnerId 
		END 
END



GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrShift]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrShift]
(
@QueryType VARCHAR(100),
@branchId INT = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getShift')
		BEGIN
			SELECT ShiftId,ShiftName,branchId,StartTime,EndTime,BreakStartTime,BreakEndTime,GracePeriod,ActiveStatus FROM Mstr_Shift
		END 
		ELSE IF(@QueryType='getShiftBasedOnBranch')
		BEGIN
			SELECT ShiftId,ShiftName,branchId,StartTime,EndTime,BreakStartTime,BreakEndTime,GracePeriod,ActiveStatus FROM Mstr_Shift WHERE branchId=@branchId
		END 
		ELSE IF(@QueryType='ddlgetShift')
		BEGIN
			SELECT ShiftId,ShiftName FROM Mstr_Shift
			where ActiveStatus='A' AND branchId=@branchId
		END 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrSubscriptionBenefits]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrSubscriptionBenefits]
(
@QueryType VARCHAR(100),
@subscriptionPlanId INT
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getSubscriptionBenefits')
		BEGIN
			SELECT uniqueId AS SubBenefitId,subscriptionPlanId,imageUrl,description,activeStatus 
			FROM Mstr_SubscriptionBenefits where subscriptionPlanId=@subscriptionPlanId
		END 
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrSubscriptionPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrSubscriptionPlan]
(
@QueryType VARCHAR(100),
@branchId INT = 0,
@gymOwnerId INT = 0,
@subscriptionPlanId INT =Null
)
AS 
BEGIN
	SET NOCOUNT ON;
	    IF(@QueryType='getSubscriptionPlan')
			BEGIN
					SELECT  SP.subscriptionPlanId, SP.gymOwnerId, SP.branchId, SP.packageName, SP.description, SP.imageUrl, SP.noOfDays, SP.amount, SP.tax, 
					 SP.cgstTax, SP.sgstTax, SP.netAmount, SP.taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= SP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
					credits,isTrialAvailable,noOfTrialDays,activeStatus  
					FROM Mstr_SubscriptionPlan as SP WHERE SP.branchId=@branchId AND  SP.gymOwnerId =@gymOwnerId
			END 
		ELSE IF (@QueryType='getuserSubscriptionDetails') 
			BEGIN
				SELECT S.subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,BW.fromTime,BW.toTime,
				S.description,SB.description AS benefitsDescription,
				ISNULL(SB.uniqueId,0) AS benefitsId,SB.imageUrl AS benefitsImageUrl,
				S.imageUrl,noOfDays,amount,tax, cgstTax,sgstTax,netAmount, actualAmount,displayAmount,
				(actualAmount - displayAmount) AS 'savedAmount',taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',credits,
				noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				LEFT JOIN Mstr_SubscriptionBenefits AS SB On S.subscriptionPlanId = SB.subscriptionPlanId
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				INNER JOIN Mstr_BranchWorkingDay AS BW On S.branchId = BW.branchId AND BW.workingDay = 'Monday'
				WHERE S.subscriptionPlanId=@subscriptionPlanId AND S.activeStatus = 'A'
			END
		ELSE IF (@QueryType='getHomeuserSubscription') 
		BEGIN
			IF(@branchId != 0 AND @gymOwnerId != 0)
			 BEGIN
					SELECT S.subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,description,
				S.imageUrl,noOfDays,amount,tax, 
				cgstTax,sgstTax,netAmount,actualAmount,displayAmount,(actualAmount - displayAmount) AS 'savedAmount',taxId,	
				(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
				(SELECT  STUFF((SELECT DISTINCT '  ' + CONCAT(description,',') FROM Mstr_SubscriptionBenefits as b 
					WHERE b.subscriptionPlanId = C.subscriptionPlanId 
					FOR XML PATH('')), 1, 2, '') as 'SubsBenefit' FROM Mstr_SubscriptionBenefits C
					Where activeStatus ='A' AND uniqueId = C.uniqueId and C.subscriptionPlanId= S.subscriptionPlanId 
					GROUP BY subscriptionPlanId) AS 'SubsBenefits', credits,	noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				WHERE S.activeStatus = 'A' AND S.branchId = @branchId AND S.gymOwnerId = @gymOwnerId
			END
		  ELSE IF (@gymOwnerId != 0)
		   BEGIN
				SELECT subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,
				imageUrl,noOfDays,amount,tax, 
				cgstTax,sgstTax,netAmount,taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',credits,
				noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				WHERE S.activeStatus = 'A' AND S.gymOwnerId = @gymOwnerId
			END
		END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrSubscriptionPlan_20230225]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[usp_GetMstrSubscriptionPlan_20230225]
(
@QueryType VARCHAR(100),
@branchId INT = 0,
@gymOwnerId INT = 0,
@subscriptionPlanId INT =Null
)
AS 
BEGIN
	SET NOCOUNT ON;
	    IF(@QueryType='getSubscriptionPlan')
			BEGIN
					SELECT  SP.subscriptionPlanId, SP.gymOwnerId, SP.branchId, SP.packageName, SP.description, SP.imageUrl, SP.noOfDays, SP.amount, SP.tax, 
					 SP.cgstTax, SP.sgstTax, SP.netAmount, SP.taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= SP.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',
					credits,isTrialAvailable,noOfTrialDays,activeStatus  
					FROM Mstr_SubscriptionPlan as SP WHERE SP.branchId=@branchId AND  SP.gymOwnerId =@gymOwnerId
			END 
		ELSE IF (@QueryType='getuserSubscriptionDetails') 
			BEGIN
				SELECT S.subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,BW.fromTime,BW.toTime,
				S.description,SB.description AS benefitsDescription,
				ISNULL(SB.uniqueId,0) AS benefitsId,SB.imageUrl AS benefitsImageUrl,
				S.imageUrl,noOfDays,amount,tax, 
				cgstTax,sgstTax,netAmount,taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',credits,
				noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				LEFT JOIN Mstr_SubscriptionBenefits AS SB On S.subscriptionPlanId = SB.subscriptionPlanId
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				INNER JOIN Mstr_BranchWorkingDay AS BW On S.branchId = BW.branchId AND BW.workingDay = 'Monday'
				WHERE S.subscriptionPlanId=@subscriptionPlanId AND S.activeStatus = 'A'
			END
		ELSE IF (@QueryType='getHomeuserSubscription') 
		BEGIN
			IF(@branchId != 0 AND @gymOwnerId != 0)
			 BEGIN
				SELECT subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,
				imageUrl,noOfDays,amount,tax, 
				cgstTax,sgstTax,netAmount,taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',credits,
				noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				WHERE S.activeStatus = 'A' AND S.branchId = @branchId AND S.gymOwnerId = @gymOwnerId
			END
		  ELSE IF (@gymOwnerId != 0)
		   BEGIN
				SELECT subscriptionPlanId,S.gymOwnerId,O.gymName,O.gymOwnerName,S.branchId,B.branchName,packageName,
				imageUrl,noOfDays,amount,tax, 
				cgstTax,sgstTax,netAmount,taxId,
					(SELECT  STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage) FROM Mstr_Tax as b 
					WHERE b.gymOwnerId = C.gymOwnerId and b.branchId=C.branchId and C.taxId=b.taxId
					FOR XML PATH('')), 1, 2, '') as 'taxDetails' FROM Mstr_Tax C
					Where branchId=@branchId AND gymOwnerId=@gymOwnerId  and taxId= S.taxId
					GROUP BY gymOwnerId,taxId,taxPercentage,branchId) AS 'taxName',credits,
				noOfTrialDays 
				FROM Mstr_SubscriptionPlan AS S
				INNER JOIN Mstr_Branch AS B On S.branchId = B.branchId
				INNER JOIN Mstr_GymOwner AS O On S.gymOwnerId = O.gymOwnerId
				WHERE S.activeStatus = 'A' AND S.gymOwnerId = @gymOwnerId
			END
		END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrTax]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrTax]
(
@queryType VARCHAR(100),
@gymOwnerId INT,
@branchId INT
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetAddTax')
		BEGIN
			SELECT gymOwnerId,branchId,taxId,UniqueId,B.configName AS 'serviceName',A.serviceName AS 'serviceId',taxDescription,taxPercentage,
			CONVERT(NVARCHAR,effectiveFrom,105) AS 'effectiveFrom',CONVERT(NVARCHAR,effectiveTill,103) AS 'effectiveTill',
			A.activeStatus FROM Mstr_Tax AS A
			INNER JOIN  Mstr_Configuration AS B ON  A.serviceName=B.configId
			Where branchId=@branchId AND
			gymOwnerId=@gymOwnerId AND A.activeStatus ='T' AND taxId=0
		END 
	IF(@QueryType='GetInsertTax')
		BEGIN
			SELECT gymOwnerId,branchId,taxId,UniqueId,B.configName AS 'serviceName',A.serviceName AS 'serviceId',taxDescription,taxPercentage,
			CONVERT(NVARCHAR,effectiveFrom,105) AS 'effectiveFrom',CONVERT(NVARCHAR,effectiveTill,103) AS 'effectiveTill',
			A.activeStatus FROM Mstr_Tax AS A
			INNER JOIN  Mstr_Configuration AS B ON  A.serviceName=B.configId Where branchId=@branchId AND
			gymOwnerId=@gymOwnerId AND A.activeStatus ='A' 
		END 
		IF(@QueryType='ddlgetTax')
		BEGIN
		 --   SELECT STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage)
			--FROM Mstr_Tax as b 
			--WHERE b.gymOwnerId = a.gymOwnerId 
			--FOR XML PATH('')), 1, 2, '') as 'taxDetails',a.taxId
			--FROM Mstr_Tax a 
			--Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' 
			--GROUP BY gymOwnerId,taxId,serviceName
			 SELECT STUFF((SELECT DISTINCT ', ' + CONCAT(taxDescription, '-' ,taxPercentage)
			FROM Mstr_Tax as b 
			WHERE b.gymOwnerId = a.gymOwnerId  and b.branchId=a.branchId and a.taxId=b.taxId
			FOR XML PATH('')), 1, 2, '') as 'taxDetails',a.taxId
			FROM Mstr_Tax a 
			Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus ='A' 
			GROUP BY gymOwnerId,taxId,serviceName,branchId

		END 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrTrainingType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- ==================================
--- Modified By Abhinaya K
--- Modified Date 07-Jan-2023
--- ==================================
CREATE PROCEDURE [dbo].[usp_GetMstrTrainingType]
(
@QueryType VARCHAR(100),
@trainingTypeId INT = 0,
@gymOwnerId INT = 0,
@branchId INT = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getTrainingType')
		BEGIN
		IF(@branchId != 0 )
			BEGIN
				SELECT trainingTypeId,gymOwnerId ,trainingTypeNameId,C.configName AS 'trainingTypeName',
				branchId,description,imageUrl,T.activeStatus FROM Mstr_TrainingType AS T INNER JOIN Mstr_Configuration AS C ON T.trainingTypeNameId = C.configId
				WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId
			END
			ELSE 
			BEGIN
				SELECT trainingTypeId,gymOwnerId ,trainingTypeNameId,C.configName AS 'trainingTypeName',
				branchId,description,imageUrl,T.activeStatus FROM Mstr_TrainingType AS T INNER JOIN Mstr_Configuration AS C ON T.trainingTypeNameId = C.configId
				
			END

		END 
	IF(@QueryType='ddlTrainingType')
	BEGIN
	     IF(@branchId != 0)
			BEGIN
				SELECT trainingTypeId,trainingTypeNameId,C.configName AS 'trainingTypeName' 
				FROM Mstr_TrainingType AS T INNER JOIN Mstr_Configuration AS C ON T.trainingTypeNameId = C.configId
				WHERE branchId=@branchId AND gymOwnerId =@gymOwnerId AND T.activeStatus='A'
			END 
		 ELSE 
			BEGIN
			    SELECT trainingTypeId,trainingTypeNameId,C.configName AS 'trainingTypeName'  
				FROM Mstr_TrainingType AS T INNER JOIN Mstr_Configuration AS C ON T.trainingTypeNameId = C.configId WHERE T.activeStatus='A'
			END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrUser]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrUser]
(
@queryType VARCHAR(100),
@mobileNo NVARCHAR(50) =NULL,
@userId Int =0,
@gymOwnerId INT = 0,
@branchId INT = 0,
@followUpStatusId int = NULL,
@passWord NVARCHAR(20) =NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	 DECLARE @UserRole NVARCHAR(50)
	IF(@queryType='signIn')
		BEGIN		
		IF  EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE (mailId=@mobileNo OR mobileNo=@mobileNo) AND activeStatus='A' )
			BEGIN
				SET @UserRole =(SELECT roleId FROM  Mstr_UserLogin 
				WHERE (mailId=@mobileNo OR mobileNo=@mobileNo) AND activeStatus='A')

				
				IF(@UserRole ='29' OR @UserRole ='31' OR @UserRole ='32')
				BEGIN
						SELECT userId,US.mobileNo,US.mailId,roleId,con.configName AS 'roleName',US.activeStatus,
						ISNULL(E.firstName, '') + ' ' + ISNULL(E.lastName, '') AS 'UserName',E.photoLink as 'Image',
						E.gymOwnerId,E.branchId,BR.branchName
						FROM  Mstr_UserLogin AS US 
						INNER JOIN Mstr_Configuration AS Con ON US.roleId=Con.configId				
						INNER JOIN Mstr_Employee AS E ON E.empId=US.userId
						LEFT JOIN Mstr_Branch AS BR ON BR.branchId=E.branchId
						WHERE (mailId=@mobileNo OR mobileNo=@mobileNo) AND US.activeStatus='A'
				END
				ELSE IF(@UserRole ='30' )
				BEGIN
						SELECT US.userId,US.mobileNo,US.mailId,roleId,con.configName AS 'roleName',US.activeStatus,
						G.gymOwnerName AS 'UserName',G.logoUrl as 'Image',G.gymOwnerId AS gymOwnerId,'' AS branchId,'' AS branchName
						FROM  Mstr_UserLogin AS US 
						INNER JOIN Mstr_Configuration AS Con ON US.roleId=Con.configId				
						INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=US.userId
						WHERE (mailId=@mobileNo OR mobileNo=@mobileNo) AND US.activeStatus='A'
				END
				ELSE IF(@UserRole ='33' )
				BEGIN
					SELECT US.userId,US.mobileNo,US.mailId,roleId,con.configName AS 'roleName',US.activeStatus,
					ISNULL(U.firstName, '') + ' ' +  ISNULL(U.lastName, '') AS 'UserName',U.photoLink as 'Image',
					'' AS gymOwnerId,'' AS branchId,'' AS branchName
					FROM  Mstr_UserLogin AS US 
					INNER JOIN Mstr_Configuration AS Con ON US.roleId=Con.configId				
					INNER JOIN Mstr_User AS U ON U.userId=US.userId
					WHERE (mailId=@mobileNo OR mobileNo=@mobileNo) AND US.activeStatus='A'
				END
		   END	
		END 

		IF(@queryType='GetMstrUser')
		BEGIN
		IF  EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE userId=@userId  AND activeStatus='A' )
			BEGIN
				SELECT EMP.userId,firstName,lastName,gender,addressLine1,addressLine2,district,ISNULL(firstName,'')+''+ ISNULL(lastName,'' ) AS 'userName',
				state,city,zipcode,maritalStatus,CONVERT(NVARCHAR,dob,105) AS 'dob',US.roleId,
				US.mobileNo,EMP.activeStatus,configName as 'roleName',photoLink,US.mailId
				FROM  Mstr_User AS EMP INNER JOIN Mstr_UserLogin AS US ON EMP.userId=US.userId
				INNER JOIN Mstr_Configuration AS Con ON  Con.configId=US.roleId AND Con.activeStatus=US.activeStatus
				WHERE EMP.userId=@userId   AND US.activeStatus='A'
		   END 
		
		END 
		  IF(@queryType='GetMstrUserBasedOnMobileNo')
		BEGIN
		IF  EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE mobileNo=@mobileNo  AND activeStatus='A' )
			BEGIN
				SELECT EMP.userId,firstName,lastName,gender,addressLine1,addressLine2,district,
				state,city,zipcode,maritalStatus,CONVERT(NVARCHAR,dob,105) AS 'dob',US.roleId,ISNULL(firstName,'')+''+ ISNULL(lastName,'' ) AS 'userName',
				US.mobileNo,EMP.activeStatus,configName as 'roleName',photoLink,US.mailId
				FROM  Mstr_User AS EMP INNER JOIN Mstr_UserLogin AS US ON EMP.userId=US.userId
				INNER JOIN Mstr_Configuration AS Con ON  Con.configId=US.roleId AND Con.activeStatus=US.activeStatus
				WHERE US.mobileNo=@mobileNo  AND US.activeStatus='A'
		   END 
		
	   END

		IF(@queryType='GetAdminUser')
		BEGIN
			IF(@followUpStatusId IS NOT NULL)
		BEGIN
		        SELECT EMP.userId,firstName,lastName,gender,addressLine1,addressLine2,district,
				state,city,zipcode,maritalStatus,CONVERT(NVARCHAR,dob,105) AS 'dob',US.roleId,
				US.mobileNo,EMP.activeStatus,Con.configName as 'roleName',photoLink,US.mailId,score,gymOwnerId,branchId,
				rewardPoints,rewardUtilized,promoNotification,enquiryReason,CONVERT(NVARCHAR,enquiryDate,105) as 'enquiryDate',followUpMode,sta.configName as 'followUpModeName',
                followUpStatus,Mo.configName as 'followUpStatusName'
				FROM  Mstr_User AS EMP INNER JOIN Mstr_UserLogin AS US ON EMP.userId=US.userId
				INNER JOIN Mstr_Configuration AS Con ON  Con.configId=US.roleId AND Con.activeStatus=US.activeStatus
				INNER JOIN Mstr_Configuration AS Sta ON  Sta.configId=emp.followUpMode AND Sta.activeStatus='A'
                INNER JOIN Mstr_Configuration AS Mo ON  Mo.configId=emp.followUpStatus AND Mo.activeStatus='A'
				WHERE EMP.gymOwnerId=@gymOwnerId AND EMP.branchId=@branchId  AND US.activeStatus='A' AND EMP.followUpStatus=@followUpStatusId
		END
		ELSE
		BEGIN
		SELECT EMP.userId,firstName,lastName,gender,addressLine1,addressLine2,district,
				state,city,zipcode,maritalStatus,CONVERT(NVARCHAR,dob,105) AS 'dob',US.roleId,
				US.mobileNo,EMP.activeStatus,Con.configName as 'roleName',photoLink,US.mailId,score,gymOwnerId,branchId,
				rewardPoints,rewardUtilized,promoNotification,enquiryReason,CONVERT(NVARCHAR,enquiryDate,105) as 'enquiryDate',followUpMode,sta.configName as 'followUpModeName',
                followUpStatus,Mo.configName as 'followUpStatusName'
				FROM  Mstr_User AS EMP INNER JOIN Mstr_UserLogin AS US ON EMP.userId=US.userId
				INNER JOIN Mstr_Configuration AS Con ON  Con.configId=US.roleId AND Con.activeStatus=US.activeStatus
				INNER JOIN Mstr_Configuration AS Sta ON  Sta.configId=emp.followUpMode AND Sta.activeStatus='A'
                INNER JOIN Mstr_Configuration AS Mo ON  Mo.configId=emp.followUpStatus AND Mo.activeStatus='A'
				WHERE EMP.gymOwnerId=@gymOwnerId AND EMP.branchId=@branchId  AND US.activeStatus='A'				
		END
				
			
		END 
		
END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrUserInBodyTest]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetMstrUserInBodyTest]
(
@QueryType VARCHAR(100),  
@userId INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrUserInBodyTest')

	IF(@userId != 0 )
		BEGIN
			SELECT UBT.userId,ISNULL(U.firstName, '') +  ISNULL(U.lastName, '') AS 'UserName',CONVERT(NVARCHAR(50), U.dob, 105) AS 'dob',
			U.gender,weight,height,fatPercentage,WorkOutStatus,WorkOutValue,age,BMR,BMI,TDEE, CONVERT(NVARCHAR(50), date, 105) AS 'date',UBT.createdDate
			FROM Mstr_UserInBodyTest AS UBT
			INNER JOIN Mstr_User AS U ON U.userId=UBT.userId
			where UBT.userId = @userId  ORDER BY UBT.createdDate DESC
		END 

		ELSE 
		BEGIN
			SELECT DISTINCT  UBT.userId,ISNULL(U.firstName, '') +  ISNULL(U.lastName, '') AS 'UserName',CONVERT(NVARCHAR(50), U.dob, 105) AS 'dob',
			U.gender,weight,height,fatPercentage,WorkOutStatus,WorkOutValue,age,BMR,BMI,TDEE,CONVERT(NVARCHAR(50), date, 105) AS 'date' ,UBT.createdDate
			FROM Mstr_UserInBodyTest AS UBT
			INNER JOIN Mstr_User AS U ON U.userId=UBT.userId  ORDER BY  UBT.createdDate DESC

		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrUserMenuAccess]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrUserMenuAccess]
(
	@queryType VARCHAR(150),
	@gymOwnerId INT=0,
	@branchId INT=0,
	@roleId INT=0,
	@empId INT=0
)
AS
BEGIN
	IF(@queryType='GetRoles')
		BEGIN
			SELECT 
				B.configId AS 'RoleId',B.configName AS 'roleName'
			FROM 
				Mstr_ConfigurationType AS A INNER JOIN Mstr_Configuration AS B ON A.typeId=B.typeId
			WHERE 
				A.typeId=11 AND B.typeId=11 AND A.activeStatus='A' AND B.activeStatus='A' AND B.configId IN (31,32)
		END

	IF(@queryType='GetEmployee')
		BEGIN
			SELECT 
				empId,firstName+' '+lastName AS 'fullName'
			FROM 
				Mstr_Employee AS A INNER JOIN Mstr_UserLogin AS B ON A.empId=B.userId
			WHERE 
				A.branchId=@branchId AND B.roleId=@roleId AND A.activeStatus='A' AND B.activeStatus='A'
		END

	IF(@queryType='GetAllOptionsName')
		BEGIN
			SELECT optionId,optionName FROM Mstr_MenuOption WHERE activeStatus='A' AND optionId
			NOT IN (SELECT optionId FROM Mstr_UserMenuAccess WHERE gymOwnerId= @gymOwnerId AND empId=@empId AND branchId=@branchId AND roleId=@roleId)
		END

	IF(@queryType='GetAllOptionsNameForUpdate')
		BEGIN
			SELECT
				MenuOptionAcessId,gymOwnerId,empId,roleId,A.optionId,B.optionName,viewRights,addRights,editRights,deleteRights,A.activeStatus
			FROM 
				Mstr_UserMenuAccess AS A INNER JOIN Mstr_MenuOption AS B ON A.optionId=B.optionId AND B.activeStatus='A'
			WHERE
				empId=@empId AND gymOwnerId=@gymOwnerId AND roleId=@roleId AND branchId=@branchId
		END

	IF(@queryType='GetEmpNameForGV')
		BEGIN
			;WITH CTE_UserAccessMenu
			AS
			(
				SELECT 
					empId,roleId
				FROM
					Mstr_UserMenuAccess 
				GROUP BY empId,roleId
			),
			CTE_Configs
			AS
			(
				SELECT 
					B.configId,B.configName
				FROM 
					Mstr_ConfigurationType AS A INNER JOIN Mstr_Configuration AS B ON A.typeId=B.typeId
				WHERE 
					A.typeId=11 AND B.typeId=11 AND A.activeStatus='A' AND B.activeStatus='A' AND B.configId IN (31,32)
			),
			CTE_Employee
			AS
			(

				SELECT 
					empId,firstName+' '+lastName AS 'fullName',branchId,gymOwnerId 
				FROM
					Mstr_Employee 
				WHERE
					activeStatus='A' AND branchId=@branchId AND gymOwnerId=@gymOwnerId 
			)
			SELECT A.empId,C.fullName,B.configId AS 'roldId',B.configName AS 'roleName',branchId,gymOwnerId FROM CTE_UserAccessMenu AS A 
			INNER JOIN CTE_Configs AS B ON A.roleId=B.configId
			INNER JOIN CTE_Employee AS C ON C.empId=A.empId
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrUserNotification]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrUserNotification]
(
@QueryType VARCHAR(100),
@userId Int=0,
@Notification  NVARCHAR(MAX)=NULL,
@readstatus char(1) =NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getUserNotification')
	BEGIN
	IF(@readstatus IS NOT NULL)
	BEGIN
	    select notificationId,userid,notification,readstatus from Mstr_UserNotification
		where userid=@userId and readstatus=@readstatus
	END
	ELSE
	BEGIN
	    select notificationId,userid,notification,readstatus from Mstr_UserNotification
		where userid=@userId 
	END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrUserTestimonials]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrUserTestimonials]
(
@QueryType VARCHAR(100),  
@bookingId INT = NUll,
@gymOwnerId INT=NULL,
@branchId INT=NULL
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrUserTestimonials')
		BEGIN
			IF(@bookingId != 0 )

					BEGIN
						SELECT feedbackId,gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus
						FROM Mstr_UserTestimonials where bookingId = @bookingId
					END 
					ELSE
					BEGIN
						SELECT feedbackId,gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus
						FROM Mstr_UserTestimonials 
					END
		END
	 IF (@QueryType='getMstrUserBranchTestimonials')
		BEGIN
		 IF(@gymOwnerId != 0 AND @branchId !=0)
			 BEGIN
				SELECT feedbackId,gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus
				FROM Mstr_UserTestimonials 
				WHERE gymOwnerId = @gymOwnerId AND dispayStatus='Y'
				AND branchId=@branchId
			END
			ELSE IF (@gymOwnerId != 0)
			  BEGIN
					SELECT feedbackId,gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus
				    FROM Mstr_UserTestimonials WHERE gymOwnerId = @gymOwnerId AND dispayStatus='Y'
				
			 END 

		   ELSE IF (@branchId != 0)
			  BEGIN
					SELECT feedbackId,gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus
				    FROM Mstr_UserTestimonials WHERE  dispayStatus='Y'AND branchId=@branchId
			 END 
		END
END


GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrWorkoutMealPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrWorkoutMealPlan]
(
@QueryType VARCHAR(100),  
@typeOfRoutine INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrWorkoutMealPlan')

	IF(@typeOfRoutine != 0 )
		BEGIN
			SELECT uniqueId,C.configName AS typeOfRoutine,description,specificInstruction, W.activeStatus AS activeStatus 
			FROM Mstr_WorkoutMealPlan AS W INNER JOIN Mstr_Configuration AS C
            ON C.configId = W.typeOfRoutine where W.typeOfRoutine = @typeOfRoutine
		END 

		ELSE 
		BEGIN
	       SELECT uniqueId,C.configName AS typeOfRoutine,description,specificInstruction, W.activeStatus AS activeStatus 
		   FROM Mstr_WorkoutMealPlan AS W INNER JOIN Mstr_Configuration AS C
            ON C.configId = W.typeOfRoutine 
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrWorkOutPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetMstrWorkOutPlan]
(
@QueryType VARCHAR(100),  
@categoryId INT = NUll,
@branchId INT = NUll,
@gymOwnerId INT = NUll
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getMstrCategoryWorkOutPlan')
	BEGIN   
	SELECT (SELECT DISTINCT FD.workoutCatTypeId,C.configName AS workoutCatTypeName , 
			(SELECT ft.workoutTypeId,D.workoutType,Ft.uniqueId, Ft.workoutCatTypeId,
			C.configName AS 'workoutCatTypeName',Ft.activeStatus,Ft.categoryId,Ms.categoryName AS categoryName
			FROM Mstr_CategoryWorkOutPlan AS Ft 
			INNER JOIN Mstr_FitnessCategory As Ms ON Ms.categoryId=Ft.categoryId
			INNER JOIN Mstr_Configuration AS C ON C.configId = Ft.workoutCatTypeId 
			INNER JOIN Mstr_WorkoutType AS D ON D.workoutTypeId = Ft.workoutTypeId  AND D.workoutCatTypeId=FD.workoutCatTypeId
			 AND  FD.branchId=Ft.branchId AND FD.gymOwnerId=FT.gymOwnerId
			 	WHERE Ft.categoryId=@categoryId AND  FD.gymOwnerId=@gymOwnerId AND FD.branchId=@branchId
			FOR JSON Path  ) AS WorkOutList
			FROM Mstr_CategoryWorkOutPlan AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.workoutCatTypeId
			WHERE FD.categoryId=@categoryId AND  FD.gymOwnerId=@gymOwnerId AND FD.branchId=@branchId
			For JSON Path ) AS CategoryWorkOutPlan 
    END
   IF(@QueryType='getMstrCategoryWorkOut')
	BEGIN 
	     SELECT DISTINCT A.categoryId,A.categoryName  FROM Mstr_FitnessCategory AS A
		 WHERE categoryId IN (SELECT categoryId FROM  Mstr_CategoryWorkOutPlan WHERE  A.branchId=@branchId AND A.gymOwnerId=@gymOwnerId) 
		 AND A.branchId=@branchId AND A.gymOwnerId=@gymOwnerId
    END
	 IF(@QueryType='getMstrWorkOut')
	BEGIN 
	  SELECT (SELECT DISTINCT FD.workoutCatTypeId,C.configName AS workoutCatTypeName , 
			(SELECT ft.workoutTypeId,Ft.workoutType,Ft.activeStatus
			FROM Mstr_WorkoutType AS Ft 
			WHERE Ft.workoutCatTypeId=FD.workoutCatTypeId  AND  FD.branchId=Ft.branchId AND FD.gymOwnerId=FT.gymOwnerId
			FOR JSON Path  ) AS WorkOutList
			FROM Mstr_WorkoutType AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.workoutCatTypeId 
		    WHERE FD.gymOwnerId=@gymOwnerId AND FD.branchId=@branchId
			For JSON Path ) AS CategoryWorkOutPlan 

    END
	 IF(@QueryType='GetPublicCategoryWorkOutPlan')
	BEGIN 
	  	SELECT (SELECT DISTINCT FD.workoutCatTypeId,C.configName AS workoutCatTypeName ,
		CASE WHEN COUNT(workoutCatTypeId) >=1 THEN COUNT(workoutCatTypeId) ELSE 0 END  AS 'VideoCount',
			(SELECT ft.workoutTypeId,D.workoutType,Ft.uniqueId, Ft.workoutCatTypeId,
			C.configName AS 'workoutCatTypeName',Ft.activeStatus,Ft.categoryId,Ms.categoryName AS categoryName,
			D.video,D.gymOwnerId,D.branchId,D.description,D.imageUrl,
			 CASE WHEN  COUNT(userId) >=1 THEN COUNT(userId) ELSE 0 END  AS 'UserUsed'
			FROM Mstr_CategoryWorkOutPlan AS Ft 
			INNER JOIN Mstr_FitnessCategory As Ms ON Ms.categoryId=Ft.categoryId
			INNER JOIN Mstr_Configuration AS C ON C.configId = Ft.workoutCatTypeId 
			INNER JOIN Mstr_WorkoutType AS D ON D.workoutTypeId = Ft.workoutTypeId  AND D.workoutCatTypeId=FD.workoutCatTypeId
			AND D.activeStatus='A'
			 AND  FD.branchId=Ft.branchId AND FD.gymOwnerId=FT.gymOwnerId
			LEFT JOIN  Tran_UserWorkOutPlan AS A ON A.workoutCatTypeId=Ft.workoutCatTypeId AND A.workoutTypeId=Ft.workoutTypeId
			WHERE Ft.categoryId=@categoryId AND  FD.gymOwnerId=@gymOwnerId AND FD.branchId=@branchId
			GROUP BY ft.workoutTypeId,D.workoutType,Ft.uniqueId, Ft.workoutCatTypeId,C.configName 
			,Ft.activeStatus,Ft.categoryId,Ms.categoryName ,D.video,D.gymOwnerId,D.branchId,D.description,D.imageUrl
			FOR JSON Path  ) AS WorkOutList
			FROM Mstr_CategoryWorkOutPlan AS FD 
			INNER JOIN Mstr_Configuration AS C ON C.configId = FD.workoutCatTypeId
			WHERE FD.categoryId=@categoryId AND  FD.gymOwnerId=@gymOwnerId AND FD.branchId=@branchId AND FD.activeStatus='A'
			GROUP BY FD.workoutCatTypeId,C.configName ,branchId,gymOwnerId,workoutTypeId,categoryId
			For JSON Path ) AS CategoryWorkOutPlan 


    END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetMstrWorkOutType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Modified By Abhinaya K
        Modified date 15-Feb-2023 ******/
CREATE PROCEDURE [dbo].[usp_GetMstrWorkOutType]
(
@queryType VARCHAR(100),
@gymOwnerId INT=0,
@branchId INT=0,
@workoutCatTypeId INT=0
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetWorkOutType')
		BEGIN
			SELECT gymOwnerId,branchId,workoutTypeId,workoutCatTypeId,configName AS workoutTypeName,workoutType,description,imageUrl,video,W.activeStatus 
			FROM Mstr_WorkoutType AS W INNER JOIN Mstr_Configuration AS C ON workoutCatTypeId = C.configId
			Where branchId=@branchId AND gymOwnerId=@gymOwnerId
		END 
		IF(@QueryType='GetWorkOutSubCategory')
		BEGIN
			SELECT gymOwnerId,branchId,workoutTypeId,workoutCatTypeId,configName AS workoutTypeName,workoutType,W.activeStatus 
			FROM Mstr_WorkoutType AS W INNER JOIN Mstr_Configuration AS C ON workoutCatTypeId = C.configId
			Where branchId=@branchId AND gymOwnerId=@gymOwnerId AND workoutCatTypeId=@workoutCatTypeId And W.activeStatus='A' AND C.activeStatus='A'
		END 	
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetSubspBookingDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetSubspBookingDetails]
(
@QueryType VARCHAR(100),
@UserId int=null,
@gymOwnerId int =null,
@branchId int=null,
@BookingId int=null
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='getAllSubspBookingDetails')
		BEGIN
				SELECT TSB.subBookingId,TSB.gymOwnerId,G.gymOwnerName,TSB.branchId,TSB.branchName,TSB.subscriptionPlanId,
				SP.packageName,SP.noOfDays,SP.noOfTrialDays,SP.netAmount,SP.amount,SP.tax,SP.cgstTax,SP.sgstTax,SP.isTrialAvailable,
				TSB.userId,MU.firstName + ''+ MU.lastName AS 'UserName',TSB.booking,TSB.loginType,
				CONVERT(NVARCHAR,TSB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TSB.toDate,105) as 'toDate',TSB.price,TSB.taxId,TSB.taxName,TSB.taxAmount,TSB.offerId,TSB.offerAmount,
				TSB.totalAmount,TSB.paidAmount,TSB.paymentStatus,TSB.paymentType,TSB.cancellationStatus,
				TSB.refundStatus,TSB.cancellationCharges,TSB.refundAmt,TSB.cancellationReason,
				CONVERT(NVARCHAR(50), TSB.bookingDate, 105) + ' ' + SUBSTRING(CONVERT(varchar(20), TSB.bookingDate, 22), 10, 11) AS 'bookingDate' from Tran_SubspBooking as TSB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TSB.gymOwnerId
				INNER JOIN Mstr_SubscriptionPlan AS SP ON SP.subscriptionPlanId=TSB.subscriptionPlanId AND SP.branchId=TSB.branchId
				INNER JOIN Mstr_User AS MU ON MU.userId=TSB.userId
		END  
		ELSE IF(@QueryType='getUserSubspBookingDetails')
		BEGIN
				SELECT TSB.subBookingId,TSB.gymOwnerId,G.gymOwnerName,TSB.branchId,TSB.branchName,TSB.subscriptionPlanId,
				SP.packageName,SP.noOfDays,SP.noOfTrialDays,SP.netAmount,SP.amount,SP.tax,SP.cgstTax,SP.sgstTax,SP.isTrialAvailable,
				TSB.userId,MU.firstName + ''+ MU.lastName AS 'UserName',TSB.booking,TSB.loginType,
				CONVERT(NVARCHAR,TSB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TSB.toDate,105) as 'toDate',TSB.price,TSB.taxId,TSB.taxName,TSB.taxAmount,TSB.offerId,TSB.offerAmount,
				TSB.totalAmount,TSB.paidAmount,TSB.paymentStatus,TSB.paymentType,TSB.cancellationStatus,
				TSB.refundStatus,TSB.cancellationCharges,TSB.refundAmt,TSB.cancellationReason,
				CONVERT(NVARCHAR(50), TSB.bookingDate, 105) + ' ' + SUBSTRING(CONVERT(varchar(20), TSB.bookingDate, 22), 10, 11) AS 'bookingDate' from Tran_SubspBooking as TSB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TSB.gymOwnerId
				INNER JOIN Mstr_SubscriptionPlan AS SP ON SP.subscriptionPlanId=TSB.subscriptionPlanId AND SP.branchId=TSB.branchId
				INNER JOIN Mstr_User AS MU ON MU.userId=TSB.userId
				where TSB.userId=@UserId
		END 
		ELSE IF(@QueryType='getBranchownerSubspBookingDetails')
		BEGIN
				SELECT TSB.subBookingId,TSB.gymOwnerId,G.gymOwnerName,TSB.branchId,TSB.branchName,TSB.subscriptionPlanId,
				SP.packageName,SP.noOfDays,SP.noOfTrialDays,SP.netAmount,SP.amount,SP.tax,SP.cgstTax,SP.sgstTax,SP.isTrialAvailable,
				TSB.userId,MU.firstName + ''+ MU.lastName AS 'UserName',TSB.booking,TSB.loginType,
				CONVERT(NVARCHAR,TSB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TSB.toDate,105) as 'toDate',TSB.price,TSB.taxId,TSB.taxName,TSB.taxAmount,TSB.offerId,TSB.offerAmount,
				TSB.totalAmount,TSB.paidAmount,TSB.paymentStatus,TSB.paymentType,TSB.cancellationStatus,
				TSB.refundStatus,TSB.cancellationCharges,TSB.refundAmt,TSB.cancellationReason,
				CONVERT(NVARCHAR(50), TSB.bookingDate, 105) + ' ' + SUBSTRING(CONVERT(varchar(20), TSB.bookingDate, 22), 10, 11) AS 'bookingDate' from Tran_SubspBooking as TSB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TSB.gymOwnerId
				INNER JOIN Mstr_SubscriptionPlan AS SP ON SP.subscriptionPlanId=TSB.subscriptionPlanId AND SP.branchId=TSB.branchId
				INNER JOIN Mstr_User AS MU ON MU.userId=TSB.userId
				where TSB.gymOwnerId=@gymOwnerId and tsb.branchId=@branchId
		END 
		ELSE IF(@QueryType='getBookingIdSubspBookingDetails')
		BEGIN
				SELECT TSB.subBookingId,TSB.gymOwnerId,G.gymOwnerName,TSB.branchId,TSB.branchName,TSB.subscriptionPlanId,
				SP.packageName,SP.noOfDays,SP.noOfTrialDays,SP.netAmount,SP.amount,SP.tax,SP.cgstTax,SP.sgstTax,SP.isTrialAvailable,
				TSB.userId,MU.firstName + ''+ MU.lastName AS 'UserName',TSB.booking,TSB.loginType,
				CONVERT(NVARCHAR,TSB.fromDate,105) as 'fromDate',CONVERT(NVARCHAR,TSB.toDate,105) as 'toDate',TSB.price,TSB.taxId,TSB.taxName,TSB.taxAmount,TSB.offerId,TSB.offerAmount,
				TSB.totalAmount,TSB.paidAmount,TSB.paymentStatus,TSB.paymentType,TSB.cancellationStatus,
				TSB.refundStatus,TSB.cancellationCharges,TSB.refundAmt,TSB.cancellationReason,
				CONVERT(NVARCHAR(50), TSB.bookingDate, 105) + ' ' + SUBSTRING(CONVERT(varchar(20), TSB.bookingDate, 22), 10, 11) AS 'bookingDate' from Tran_SubspBooking as TSB
				INNER JOIN Mstr_GymOwner AS G ON  G.gymOwnerId=TSB.gymOwnerId
				INNER JOIN Mstr_SubscriptionPlan AS SP ON SP.subscriptionPlanId=TSB.subscriptionPlanId AND SP.branchId=TSB.branchId
				INNER JOIN Mstr_User AS MU ON MU.userId=TSB.userId
				where TSB.subBookingId=@BookingId
		END 
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetTranUserFoodTracking_Old]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetTranUserFoodTracking_Old]
(
@QueryType VARCHAR(100),
@userId INT = NUll,
@date date = Null
)
AS 
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetTranUserFoodTracking')
		BEGIN
			SELECT userId,date
			FROM Tran_UserFoodTracking 
			where userId = @userId AND date = @date
		END
	IF(@QueryType='GetUserBreakFast')
	    BEGIN
		            SELECT userId,foodMenuId,F.foodItemName,C.configName,F.calories,F.protein,F.fat,F.servingIn,date 
					FROM Tran_UserFoodTracking AS FT
					INNER JOIN Mstr_FoodItem AS F On FT.foodMenuId = F.foodItemId
					INNER JOIN Mstr_FoodDietTime AS FD On FT.foodMenuId = FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C  On C.configId = FD.mealType AND C.configName = 'Breakfast'
			        WHERE  userId = @userId AND date = @date 
		END
		IF(@QueryType='GetUserBreakFast')
	    BEGIN
		            SELECT userId,foodMenuId,F.foodItemName,C.configName,F.calories,F.protein,F.fat,F.servingIn,date 
					FROM Tran_UserFoodTracking AS FT
					INNER JOIN Mstr_FoodItem AS F On FT.foodMenuId = F.foodItemId
					INNER JOIN Mstr_FoodDietTime AS FD On FT.foodMenuId = FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C  On C.configId = FD.mealType AND  C.configName = 'Breakfast_alter'
			        WHERE  userId = @userId AND date = @date 
		END
		IF(@QueryType='GetUserBreakFast')
	    BEGIN
		            SELECT userId,foodMenuId,F.foodItemName,C.configName,F.calories,F.protein,F.fat,F.servingIn,date 
					FROM Tran_UserFoodTracking AS FT
					INNER JOIN Mstr_FoodItem AS F On FT.foodMenuId = F.foodItemId
					INNER JOIN Mstr_FoodDietTime AS FD On FT.foodMenuId = FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C  On C.configId = FD.mealType AND C.configName = 'Breakfast_alter'
			        WHERE  userId = @userId AND date = @date 
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetTranUserWorkOutPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Modified By Abhinaya K
        Modifie Date 28-Feb-2023******/
CREATE PROCEDURE [dbo].[usp_GetTranUserWorkOutPlan](
											@QueryType VARCHAR(200),
											@userId Int=0,
											@workoutCatTypeId Int=0,
											@workoutTypeId Int=0,
											@Day char(3)=NULL,
											@bookingId INT=NULL,
											@categoryId INT =NULL,
											@Date Date=NULL
										   )
AS
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetTranUserWorkOutPlan')
	BEGIN
		SELECT UWOP.workoutPlanId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,
			UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
			UWOP.workoutTypeId,WOT.workoutType AS 'workoutTypeName',
			UWOP.bookingId,
			CASE WHEN UWOP.day='SU' Then 'Sunday' WHEN UWOP.day='Mo' Then 'Monday'  WHEN UWOP.day='Tu' Then 'Tuesday'  WHEN UWOP.day='We' Then 'Wednesday'
		      WHEN UWOP.day='Th' Then 'Thursday'  WHEN UWOP.day='Fr' Then 'Friday'  WHEN UWOP.day='Sa' Then 'Saturday' END  AS 'day',
			CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
			UWOP.csetType,ST.configName AS 'setTypeName',UWOP.cnoOfReps,UWOP.cweight,UWOP.userId,
			WOT.description,WOT.imageUrl,WOT.video
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
		INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOP.workoutTypeId
			AND WOT.activeStatus='A' AND WOT.branchId= UWOP.branchId
		LEFT JOIN Mstr_Configuration AS ST ON ST.configId= UWOP.csetType
			AND ST.typeId='22' AND ST.activeStatus='A'
		WHERE UWOP.userId = @userId
	END

	IF(@QueryType='GetTranUserWorkOutPlanCategoryTypeDetails')
	BEGIN
		SELECT UWOP.workoutPlanId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,UWOP.branchId,'' AS 'branchName',
			UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
			UWOP.workoutTypeId,WOT.workoutType AS 'workoutTypeName',
			UWOP.bookingId,UWOP.day,CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
			UWOP.csetType,ST.configName AS 'setTypeName',UWOP.cnoOfReps,UWOP.cweight,UWOP.userId,
			WOT.description,WOT.imageUrl,WOT.video
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId AND G.activeStatus='A'
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId AND B.activeStatus='A'
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
		INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOP.workoutTypeId
			AND WOT.activeStatus='A' AND WOT.branchId= UWOP.branchId
		LEFT JOIN Mstr_Configuration AS ST ON ST.configId= UWOP.csetType
			AND ST.typeId='22' AND ST.activeStatus='A' 
		WHERE UWOP.userId = @userId AND UWOP.workoutCatTypeId = @workoutCatTypeId
	END

	IF(@QueryType='GetCategoryTypeBasedonDateDay')
	BEGIN
		SELECT UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,
		UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
		UWOP.bookingId,UWOP.day,CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
		UWOP.userId
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
		AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'

		WHERE UWOP.userId = @userId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day AND UWOP.approvedBy IS NOT NULL
		GROUP BY UWOP.workoutCatTypeId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,CONFIG.configName,UWOP.bookingId,UWOP.day,
		UWOP.fromDate,UWOP.toDate,UWOP.userId
	END

		IF(@QueryType='GetCategoryTypeBasedonDateDayPublicPlan')
	BEGIN
		SELECT UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,
		UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
		UWOP.bookingId,UWOP.day,CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
		UWOP.userId,COUNT(TU.workoutTypeId) AS 'VideoCount'
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
		INNER JOIN Tran_Booking  AS Boo ON Boo.gymOwnerId=UWOP.gymOwnerId And Boo.branchId=UWOP.branchId
		AND UWOP.bookingId =Boo.bookingId AND UWOP.userId=Boo.userId
		AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
		LEFT JOIN Mstr_WorkoutType AS TU
		ON UWOP.workoutCatTypeId=TU.workoutCatTypeId AND UWOP.gymOwnerId=TU.gymOwnerId AND UWOP.branchId = TU.branchId
		AND TU.workoutTypeId=UWOP.workoutTypeId
	    WHERE UWOP.userId = @userId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day AND UWOP.approvedBy IS NOT NULL
		AND Boo.categoryId=@categoryId
		GROUP BY UWOP.workoutCatTypeId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,CONFIG.configName,UWOP.bookingId,UWOP.day,
		UWOP.fromDate,UWOP.toDate,UWOP.userId
	END

	IF(@QueryType='GetWorkoutTypeBasedonDateDay')
	BEGIN
			SELECT UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,UWOP.branchId,
			UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
			UWOP.workoutTypeId,WOT.workoutType AS 'workoutTypeName',
			UWOP.bookingId,UWOP.day,CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
			UWOP.userId,WOT.description,WOT.imageUrl,WOT.video,
			CASE WHEN  COUNT(UWOP.userId) >=1 THEN 1 ELSE 0 END  AS 'UserUsed',
			CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date and day=@day AND workoutCatTypeId=UWOP.workoutCatTypeId AND workoutTypeId=UWOP.workoutTypeId
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId) =
			(SELECT COUNT(*) FROM Tran_UserWorkOutPlan WHERE @Date BETWEEN fromDate AND toDate AND workoutCatTypeId=UWOP.workoutCatTypeId AND workoutTypeId=UWOP.workoutTypeId
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId AND day=@Day) THEN 'Yes' ELSE 'No' END as 'OverAllCompletedStatus'
			FROM Tran_UserWorkOutPlan AS UWOP 
			INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId AND G.activeStatus='A'
			INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId AND B.activeStatus='A'
			INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOP.workoutTypeId
			AND WOT.activeStatus='A' AND WOT.branchId= UWOP.branchId
			WHERE UWOP.userId = @userId AND UWOP.workoutCatTypeId = @workoutCatTypeId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day
			GROUP BY UWOP.workoutCatTypeId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,CONFIG.configName,UWOP.bookingId,UWOP.day,
			UWOP.fromDate,UWOP.toDate,UWOP.userId,UWOP.workoutTypeId,WOT.workoutType,WOT.description,WOT.imageUrl,WOT.video
	END

	IF(@QueryType='GetSetTypeBasedonDateDay')
	BEGIN
		SELECT UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,UWOP.branchId,
		UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
		UWOP.workoutTypeId,WOT.workoutType AS 'workoutTypeName',
		UWOP.bookingId,CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
		UWOP.csetType,ST.configName AS 'setTypeName',UWOP.cnoOfReps,UWOP.cweight,UWOP.userId,
		WOT.description,WOT.imageUrl,WOT.video,
		CASE WHEN UWOP.day='SU' Then 'Sunday' WHEN UWOP.day='Mo' Then 'Monday'  WHEN UWOP.day='Tu' Then 'Tuesday'  WHEN UWOP.day='We' Then 'Wednesday'
		WHEN UWOP.day='Th' Then 'Thursday'  WHEN UWOP.day='Fr' Then 'Friday'  WHEN UWOP.day='Sa' Then 'Saturday' END  AS 'Day',
		CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date AND workoutCatTypeId=UWOP.workoutCatTypeId AND
		workoutTypeId=UWOP.workoutTypeId AND setType=UWOP.csetType AND noOfReps=UWOP.cnoOfReps AND weight=UWOP.cweight 
		AND userId=UWOP.userId AND bookingId=UWOP.bookingId) = 1 THEN 'Yes' ELSE 'No' END as 'VideoCompletedStatus',
		CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date and day=@day AND workoutCatTypeId=UWOP.workoutCatTypeId  AND workoutTypeId=UWOP.workoutTypeId
		AND userId=UWOP.userId AND bookingId=UWOP.bookingId) =
		(SELECT COUNT(*) FROM Tran_UserWorkOutPlan WHERE @Date BETWEEN fromDate AND toDate AND workoutCatTypeId=UWOP.workoutCatTypeId AND workoutTypeId=UWOP.workoutTypeId
		AND userId=UWOP.userId AND bookingId=UWOP.bookingId AND day=@Day) THEN 'Yes' ELSE 'No' END as 'OverAllCompletedStatus'
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId AND G.activeStatus='A'
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId AND B.activeStatus='A'
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
		AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
		INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOP.workoutTypeId
		AND WOT.activeStatus='A' AND WOT.branchId= UWOP.branchId
		LEFT JOIN Mstr_Configuration AS ST ON ST.configId= UWOP.csetType
		AND ST.typeId='22' AND ST.activeStatus='A'
		WHERE UWOP.userId = @userId AND UWOP.workoutCatTypeId = @workoutCatTypeId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day
		AND UWOP.workoutTypeId=@workoutTypeId
	END

	IF(@QueryType='GetTranUserWorkOutPlanBasedOnDay')
	BEGIN
    
		SELECT UWOP.workoutPlanId,UWOP.gymOwnerId,G.gymOwnerName,UWOP.branchId,B.branchName,
			UWOP.workoutCatTypeId,CONFIG.configName AS 'workoutCatTypeName',
			UWOP.workoutTypeId,WOT.workoutType AS 'workoutTypeName',
			UWOP.bookingId,
			CASE WHEN UWOP.day='SU' Then 'Sunday' WHEN UWOP.day='Mo' Then 'Monday'  WHEN UWOP.day='Tu' Then 'Tuesday'  WHEN UWOP.day='We' Then 'Wednesday'
		      WHEN UWOP.day='Th' Then 'Thursday'  WHEN UWOP.day='Fr' Then 'Friday'  WHEN UWOP.day='Sa' Then 'Saturday' END  AS 'day',
			CONVERT(NVARCHAR,UWOP.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,UWOP.toDate,103) AS 'toDate',
			UWOP.csetType,ST.configName AS 'setTypeName',UWOP.cnoOfReps,UWOP.cweight,UWOP.userId,
			WOT.description,WOT.imageUrl,WOT.video
		FROM Tran_UserWorkOutPlan AS UWOP 
		INNER JOIN Mstr_GymOwner AS G ON G.gymOwnerId=UWOP.gymOwnerId
		INNER JOIN Mstr_Branch AS B ON B.branchId = UWOP.branchId
		INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOP.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
		INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOP.workoutTypeId
			AND WOT.activeStatus='A' AND WOT.branchId= UWOP.branchId
		LEFT JOIN Mstr_Configuration AS ST ON ST.configId= UWOP.csetType
			AND ST.typeId='22' AND ST.activeStatus='A'
		WHERE UWOP.userId = @userId AND bookingId=@bookingId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetTranUserWorkOutTracking]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetTranUserWorkOutTracking](
											@QueryType VARCHAR(100),
											@userId INT,
											@Day char(3)=NULL,
											@Date Date=NULL,
											@workoutCatTypeId INT=NULL,
											@workoutTypeId INT=NULL
										   )
AS
BEGIN
	SET NOCOUNT ON;
	IF(@QueryType='GetTranUserWorkOutTracking')
		BEGIN
			SELECT UWOT.uniqueId, UWOT.bookingId, UWOT.userId, CONVERT(NVARCHAR,UWOT.date,103) AS 'date',
			UWOT.workoutCatTypeId, CONFIG.configName AS 'workoutCatTypeName',
			UWOT.workoutTypeId, WOT.workoutType AS 'workoutTypeName', UWOT.setType, ST.configName AS 'setTypeName',
			UWOT.noOfReps, UWOT.weight,WOT.description,WOT.imageUrl,WOT.video
			FROM Tran_UserWorkoutTracking AS UWOT
			INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOT.workoutCatTypeId
				AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOT.workoutTypeId
				AND WOT.activeStatus='A'
			INNER JOIN Mstr_Configuration AS ST ON ST.configId= UWOT.setType
			AND ST.typeId='22' AND ST.activeStatus='A'
			WHERE UWOT.userId = @userId
		END
		IF(@QueryType='GetTranUserWorkOutTrackingBasedonDateDay')
		BEGIN
			SELECT UWOT.uniqueId, UWOT.bookingId, UWOT.userId, CONVERT(NVARCHAR,UWOT.date,103) AS 'date',
			UWOT.workoutCatTypeId, CONFIG.configName AS 'workoutCatTypeName',
			UWOT.workoutTypeId, WOT.workoutType AS 'workoutTypeName', UWOT.setType, ST.configName AS 'setTypeName',
			UWOT.noOfReps, UWOT.weight,WOT.description,WOT.imageUrl,WOT.video,
			CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date AND workoutCatTypeId=UWOP.workoutCatTypeId AND
			workoutTypeId=UWOP.workoutTypeId AND setType=UWOP.csetType AND noOfReps=UWOP.cnoOfReps AND weight=UWOP.cweight 
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId) = 1 THEN 'Yes' ELSE 'No' END as 'VideoCompletedStatus',
			CASE WHEN UWOP.day='SU' Then 'Sunday' WHEN UWOP.day='Mo' Then 'Monday'  WHEN UWOP.day='Tu' Then 'Tuesday'  WHEN UWOP.day='We' Then 'Wednesday'
            WHEN UWOP.day='Th' Then 'Thursday'  WHEN UWOP.day='Fr' Then 'Friday'  WHEN UWOP.day='Sa' Then 'Saturday' END  AS 'Day',
			CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date AND workoutCatTypeId=UWOP.workoutCatTypeId 
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId) =
			(SELECT COUNT(*) FROM Tran_UserWorkOutPlan WHERE @Date BETWEEN fromDate AND toDate AND workoutCatTypeId=UWOP.workoutCatTypeId
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId AND day=@Day) THEN 'Yes' ELSE 'No' END as 'OverAllCompletedStatus'
			FROM Tran_UserWorkoutTracking AS UWOT
			INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOT.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOT.workoutTypeId
			AND WOT.activeStatus='A'
			INNER JOIN Mstr_Configuration AS ST ON ST.configId= UWOT.setType
			AND ST.typeId='22' AND ST.activeStatus='A'
			INNER JOIN  Tran_UserWorkOutPlan AS UWOP ON UWOP.userId=UWOT.userId AND  UWOP.bookingId=UWOT.bookingId AND
			UWOP.workoutCatTypeId=UWOT.workoutCatTypeId AND UWOP.workoutTypeId=UWOT.workoutTypeId AND UWOP.csetType=UWOT.setType AND
			UWOP.cnoOfReps=UWOT.noOfReps  AND UWOP.cweight=UWOT.weight 
			WHERE UWOT.userId = @userId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day AND  UWOT.date=@Date
		END
		IF(@QueryType='GetTranUserWorkOutTrackingBasedonDateDayCategoryIdWorkoutTypeId')
		BEGIN
			SELECT UWOT.uniqueId, UWOT.bookingId, UWOT.userId, CONVERT(NVARCHAR,UWOT.date,103) AS 'date',
			UWOT.workoutCatTypeId, CONFIG.configName AS 'workoutCatTypeName',
			UWOT.workoutTypeId, WOT.workoutType AS 'workoutTypeName', UWOT.setType, ST.configName AS 'setTypeName',
			UWOT.noOfReps, UWOT.weight,WOT.description,WOT.imageUrl,WOT.video,
			CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date AND workoutCatTypeId=UWOP.workoutCatTypeId AND
			workoutTypeId=UWOP.workoutTypeId AND setType=UWOP.csetType AND noOfReps=UWOP.cnoOfReps AND weight=UWOP.cweight 
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId) = 1 THEN 'Yes' ELSE 'No' END as 'VideoCompletedStatus',
			CASE WHEN UWOP.day='SU' Then 'Sunday' WHEN UWOP.day='Mo' Then 'Monday'  WHEN UWOP.day='Tu' Then 'Tuesday'  WHEN UWOP.day='We' Then 'Wednesday'
            WHEN UWOP.day='Th' Then 'Thursday'  WHEN UWOP.day='Fr' Then 'Friday'  WHEN UWOP.day='Sa' Then 'Saturday' END  AS 'Day',
			CASE WHEN (SELECT COUNT(*) FROM Tran_UserWorkoutTracking WHERE date=@Date AND workoutCatTypeId=UWOP.workoutCatTypeId 
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId) =
			(SELECT COUNT(*) FROM Tran_UserWorkOutPlan WHERE @Date BETWEEN fromDate AND toDate AND workoutCatTypeId=UWOP.workoutCatTypeId
			AND userId=UWOP.userId AND bookingId=UWOP.bookingId AND day=@Day) THEN 'Yes' ELSE 'No' END as 'OverAllCompletedStatus'
			FROM Tran_UserWorkoutTracking AS UWOT
			INNER JOIN Mstr_Configuration AS CONFIG ON CONFIG.configId= UWOT.workoutCatTypeId
			AND CONFIG.typeId='19' AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_WorkoutType AS WOT ON WOT.workoutTypeId= UWOT.workoutTypeId
			AND WOT.activeStatus='A'
			INNER JOIN Mstr_Configuration AS ST ON ST.configId= UWOT.setType
			AND ST.typeId='22' AND ST.activeStatus='A'
			INNER JOIN  Tran_UserWorkOutPlan AS UWOP ON UWOP.userId=UWOT.userId AND  UWOP.bookingId=UWOT.bookingId AND
			UWOP.workoutCatTypeId=UWOT.workoutCatTypeId AND UWOP.workoutTypeId=UWOT.workoutTypeId AND UWOP.csetType=UWOT.setType AND
			UWOP.cnoOfReps=UWOT.noOfReps  AND UWOP.cweight=UWOT.weight 
			WHERE UWOT.userId = @userId AND @Date BETWEEN UWOP.fromDate AND UWOP.toDate AND UWOP.day=@Day AND  UWOT.date=@Date
			AND UWOT.workoutCatTypeId=@workoutCatTypeId AND UWOT.workoutTypeId=@workoutTypeId
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_GetUserBookingDetailsDept]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [usp_GetUserBookingDetailsDept] 'GetUserBookingDetailsBasedOnType','','','62 ','2','0','13','100042','2023-01-10','N'
/****** Modified By Abhinaya K
        Modified Date 15-Feb-2023 ******/
CREATE PROCEDURE [dbo].[usp_GetUserBookingDetailsDept]
(
@queryType VARCHAR(100),
@gymOwnerId INT=0,
@branchId INT=0,
@mealType INT=0,
@dietTypeId INT=0,
@uniqueId INT =0,
@bookingId INT =0,
@userId INT =0,
@Date Date =NULL,
@Type Char(2)=NULL
)
AS 
BEGIN
     
	IF(@QueryType='GetUserBookingDetails')
		BEGIN
			
					SELECT DISTINCT C.bookingId,C.userId,C.userName,C.phoneNumber,C.categoryId,C.categoryName,
			C.trainingTypeId,C.trainingTypeName,C.planDuration,C.planDurationName,C.mailId,CASE WHEN C.ApprovedStatusDiet='A' AND C.ApprovedStatusWork='A' THEN 'A'
			ELSE 'N' END AS 'approvedStatus',C.fromDate,C.toDate,C.fromDateDiet,C.toDateDiet,
			C.TDEE,C.PlanGeneareted,C.PlanGenearetedDiet,C.paymentStatus FROM (
			SELECT * FROM(
		    SELECT  A.bookingId  AS 'bookingIdDiet',A.userId  AS 'userIdDiet',
			ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userNameDiet',A.phoneNumber  AS 'phoneNumberDiet',
			A.categoryId  AS 'categoryIdDiet',B.categoryName  AS 'categoryNameDiet',
			A.trainingTypeId  AS 'trainingTypeIdDiet',CONFIG.configName AS 'trainingTypeNameDiet',FCP.planDuration AS 'planDurationDiet',C.configName AS 'planDurationNameDiet',
			A.fromDate AS 'fromDateDiet',A.toDate AS 'toDateDiet',UL.mailId AS 'MailIdDiet',
			CASE WHEN ISNULL(TD.approvedBy,'0')=0 THEN 'N' ELSE 'A'  END AS 'ApprovedStatusDiet',CASE WHEN ISNULL((SELECT TOP 1 userId FROM Tran_UserDietPlan
			WHERE USERID=A.userId ORDER BY createdDate DESC),'0')=0 THEN 'N' ELSE 'Y'  END AS'PlanGenearetedDiet',
			(SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'DIETTDEE',A.paymentStatus AS 'DietPaymentStatus'
			FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=US.userId
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			LEFT JOIN  Tran_UserDietPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId) AS A

			LEFT JOIN 
				(
				SELECT Distinct A.bookingId,A.userId,ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userName',A.phoneNumber,A.categoryId,B.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',FCP.planDuration,C.configName AS 'planDurationName',
		  CONVERT(NVARCHAR,A.fromDate,105) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,105) AS 'toDate',UL.mailId,CASE WHEN ISNULL(TD.approvedBy,'0')=0 THEN 'N' ELSE 'A'  END AS  'ApprovedStatusWork','N' AS 'PlanGeneareted',
		  (SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'TDEE',A.paymentStatus  FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=Us.userId 
			LEFT JOIN  Tran_UserWorkOutPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE A.bookingId NOT IN(SELECT bookingId FROM  Tran_UserWorkOutPlan) AND  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId 
			UNION ALL
			SELECT Distinct A.bookingId,A.userId,ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userName',A.phoneNumber,A.categoryId,B.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',FCP.planDuration,C.configName AS 'planDurationName',
			CONVERT(NVARCHAR,A.fromDate,105) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,105) AS 'toDate',UL.mailId, 'A' AS 'ApprovedStatusWork','Y' AS 'PlanGeneareted',
			(SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'TDEE',A.paymentStatus  FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=Us.userId 
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			LEFT JOIN  Tran_UserWorkOutPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE A.bookingId  IN(SELECT bookingId FROM  Tran_UserWorkOutPlan) AND  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId )AS B
			ON A.bookingIdDiet =B.bookingId AND A.userIdDiet=B.userId
			) AS C WHERE  CAST(C.fromDateDiet  AS DATE) <= CAST(GETDATE() AS DATE)
			AND CAST(C.toDateDiet  AS DATE) >= CAST(GETDATE() AS DATE)
			
		END
		--Newly Added On 06-Feb-2023
		--Newly Added By Abhinaya K
		IF(@QueryType='GetUserBookingDetailsBasedOnType')
		BEGIN
			SELECT * FROM(
					SELECT DISTINCT C.bookingId,C.userId,C.userName,C.phoneNumber,C.categoryId,C.categoryName,
			C.trainingTypeId,C.trainingTypeName,C.planDuration,C.planDurationName,C.mailId,CASE WHEN C.ApprovedStatusDiet='A' AND C.ApprovedStatusWork='A' THEN 'A'
			ELSE 'N' END AS 'approvedStatus',C.fromDate,C.toDate,C.fromDateDiet,C.toDateDiet,
			C.TDEE,C.PlanGeneareted,C.PlanGenearetedDiet,C.paymentStatus FROM (
			SELECT * FROM(
		    SELECT  A.bookingId  AS 'bookingIdDiet',A.userId  AS 'userIdDiet',
			ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userNameDiet',A.phoneNumber  AS 'phoneNumberDiet',
			A.categoryId  AS 'categoryIdDiet',B.categoryName  AS 'categoryNameDiet',
			A.trainingTypeId  AS 'trainingTypeIdDiet',CONFIG.configName AS 'trainingTypeNameDiet',FCP.planDuration AS 'planDurationDiet',C.configName AS 'planDurationNameDiet',
			A.fromDate AS 'fromDateDiet',A.toDate AS 'toDateDiet',UL.mailId AS 'MailIdDiet',
			CASE WHEN ISNULL(TD.approvedBy,'0')=0 THEN 'N' ELSE 'A'  END AS 'ApprovedStatusDiet',CASE WHEN ISNULL((SELECT TOP 1 userId FROM Tran_UserDietPlan
			WHERE USERID=A.userId ORDER BY createdDate DESC),'0')=0 THEN 'N' ELSE 'Y'  END AS'PlanGenearetedDiet',
			(SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'DIETTDEE',A.paymentStatus AS 'DietPaymentStatus'
			FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=US.userId
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			LEFT JOIN  Tran_UserDietPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId) AS A

			LEFT JOIN 
				(
				SELECT Distinct A.bookingId,A.userId,ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userName',A.phoneNumber,A.categoryId,B.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'trainingTypeName',FCP.planDuration,C.configName AS 'planDurationName',
		  CONVERT(NVARCHAR,A.fromDate,105) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,105) AS 'toDate',UL.mailId,CASE WHEN ISNULL(TD.approvedBy,'0')=0 THEN 'N' ELSE 'A'  END AS  'ApprovedStatusWork','N' AS 'PlanGeneareted',
		  (SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'TDEE', A.paymentStatus FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=Us.userId 
			LEFT JOIN  Tran_UserWorkOutPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE A.bookingId NOT IN(SELECT bookingId FROM  Tran_UserWorkOutPlan) AND  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId 
			UNION ALL
			SELECT Distinct A.bookingId,A.userId,ISNULL(US.firstName,'')+''+ ISNULL(US.lastName,'' ) AS 'userName',A.phoneNumber,A.categoryId,B.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',FCP.planDuration,C.configName AS 'planDurationName',
			CONVERT(NVARCHAR,A.fromDate,105) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,105) AS 'toDate',UL.mailId, 'A' AS 'ApprovedStatusWork','Y' AS 'PlanGeneareted',
			(SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=A.userId ORDER BY createdDate DESC) AS 'TDEE',A.paymentStatus  FROM Tran_Booking AS A
			INNER JOIN Mstr_FitnessCategory AS B ON  A.gymOwnerId=B.gymOwnerId AND A.branchId=B.branchId
			AND A.categoryId=B.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId
			AND A.trainingTypeId=TR.trainingTypeId
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN  Mstr_User AS US ON A.userId=Us.userId 
			--INNER JOIN  Mstr_UserInBodyTest AS UST ON A.userId=UST.userId
			LEFT JOIN  Tran_UserWorkOutPlan AS TD ON A.userId=TD.userId  AND A.bookingId=TD.bookingId
			INNER JOIN  Mstr_UserLogin AS UL ON A.userId=UL.userId 
			INNER JOIN Mstr_FitnessCategoryPrice  AS FCP ON FCP.priceId=A.priceId AND FCP.gymOwnerId=A.gymOwnerId AND FCP.branchId=A.branchId
			INNER JOIN Mstr_Configuration AS C ON C.typeId='13' AND C.configId=FCP.planDuration AND C.activeStatus='A'
			WHERE A.bookingId  IN(SELECT bookingId FROM  Tran_UserWorkOutPlan) AND  A.gymOwnerId=@gymOwnerId AND A.branchId=@branchId )AS B
			ON A.bookingIdDiet =B.bookingId AND A.userIdDiet=B.userId
			) AS C WHERE  (CAST(C.fromDateDiet  AS DATE) <= CAST(@Date AS DATE))
			AND CAST(C.toDateDiet  AS DATE) >= CAST(@Date AS DATE) ) AS A WHERE A.approvedStatus=@Type
			
		END
		IF(@QueryType='GetFoodItemBasedOnMealType')
		BEGIN
		IF(@uniqueId != 0)
		BEGIN
					DECLARE @ConfigName nvarchar(50);
			  DECLARE @Id nvarchar(max);
				set @ConfigName=(select mc.configName from Mstr_DietType as md inner join 
				Mstr_Configuration as mc on mc.configId=md.dietTypeNameId where md.dietTypeId=@dietTypeId)
				 IF @configName='Vegeterian'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ( 'Vegeterian','Vegan')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
						ELSE IF @configName='Vegan'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
					ELSE IF @configName='Omnivore'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END

					ELSE IF @configName='Eggtarian'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan','Eggtarian','Vegeterian')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
					ELSE IF @configName='Sea Food'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ', '+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan','Sea Food','Vegeterian')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END

					ELSE
						BEGIN
						set @Id=(select '0' as ids)
						END
					SELECT FI.foodItemId,FI.foodItemName,FI.servingIn,FI.calories,FD.uniqueId AS 'dietTimeId',FI.dietTypeId FROM Mstr_FoodItem AS FI 
					INNER JOIN Mstr_FoodDietTime AS FD ON FI.foodItemId =FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C ON FD.mealType=C.configId
					WHERE C.configId=@mealType AND FI.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' )) 
					AND FI.foodItemId NOT IN (			

					SELECT A.foodItemId FROM Mstr_UserFoodMenu AS A
					INNER JOIN Mstr_FoodDietTime AS B ON B.foodItemId=A.foodItemId AND A.dietTimeId=B.uniqueId
					WHERE A.userId=@userId AND BookingId=@bookingId AND B.mealType=@mealType
					 )
					
					 UNION ALL 
					SELECT FI.foodItemId,FI.foodItemName,FI.servingIn,FI.calories,FD.uniqueId AS 'dietTimeId',FI.dietTypeId FROM Mstr_FoodItem AS FI 
					INNER JOIN Mstr_FoodDietTime AS FD ON FI.foodItemId =FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C ON FD.mealType=C.configId
					WHERE C.configId=@mealType AND FI.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' )) 
					AND FI.foodItemId IN (SELECT A.foodItemId FROM Mstr_UserFoodMenu AS A
					INNER JOIN Mstr_FoodDietTime AS B ON B.foodItemId=A.foodItemId AND A.dietTimeId=B.uniqueId
					WHERE A.userId=@userId AND BookingId=@bookingId AND B.mealType=@mealType AND A.uniqueId=@uniqueId)
					
			END
			ELSE
			BEGIN	
				set @ConfigName=(select mc.configName from Mstr_DietType as md inner join 
				Mstr_Configuration as mc on mc.configId=md.dietTypeNameId where md.dietTypeId=2)
				 IF @configName='Vegeterian'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ( 'Vegeterian','Vegan')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
						ELSE IF @configName='Vegan'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
					ELSE IF @configName='Omnivore'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END

					ELSE IF @configName='Eggtarian'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ','+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan','Eggtarian','Vegeterian')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END
					ELSE IF @configName='Sea Food'
						BEGIN
							set @Id=(SELECT Stuff(
									(
									SELECT ', '+cast(md.dietTypeId AS VARCHAR(10))
									FROM Mstr_DietType as md 
									inner join Mstr_Configuration as mc on mc.configId=md.dietTypeNameId
									WHERE mc.configName IN ('Vegan','Sea Food','Vegeterian')
									FOR XML PATH('')
									), 1,1,'') AS ids)
						END

					ELSE
						BEGIN
						set @Id=(select '0' as ids)
						END
					SELECT FI.foodItemId,FI.foodItemName,FI.servingIn,FI.calories,FD.uniqueId AS 'dietTimeId',FI.dietTypeId FROM Mstr_FoodItem AS FI 
					INNER JOIN Mstr_FoodDietTime AS FD ON FI.foodItemId =FD.foodItemId 
					INNER JOIN Mstr_Configuration AS C ON FD.mealType=C.configId
					WHERE C.configId=@mealType AND FI.dietTypeId in (Select Value from STRING_SPLIT ( @Id , ',' )) 
					AND FI.foodItemId NOT IN (			

					SELECT A.foodItemId FROM Mstr_UserFoodMenu AS A
					INNER JOIN Mstr_FoodDietTime AS B ON B.foodItemId=A.foodItemId AND A.dietTimeId=B.uniqueId
					WHERE A.userId=@userId AND BookingId=@bookingId AND B.mealType=@mealType
					 )
					
			END

       END
	   
		
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetUserSessionId]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_GetUserSessionId]
(
	@QueryType VARCHAR(150),
	@SessionId VARCHAR(200),
	@UserId INT
)
AS
BEGIN
	IF(@QueryType='GetSessioId')
		BEGIN
			SELECT SessionId FROM Mstr_UserLogin WHERE userId=@UserId AND SessionId=@SessionId AND activeStatus='A'
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrAppSetting]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrAppSetting]
(
@QueryType VARCHAR(150),
@gymOwnerId int ,
@packageName NVARCHAR(50),
@appVersion VARCHAR(25),
@appType CHAR(1),
@createdBy INT,
@versionChanges NVARCHAR(MAX),
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRANSACTION
	BEGIN TRY
		IF(@QueryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT uniqueId FROM Mstr_AppSetting WHERE gymOwnerId=@gymOwnerId AND packageName =@packageName AND  appVersion = @appVersion AND AppType = @AppType)
					BEGIN

						UPDATE Mstr_AppSetting SET updatedBy=@createdBy,updatedDate=GETDATE(),activeStatus='D' 
						WHERE appType=@appType AND activeStatus='A'
						
						INSERT INTO Mstr_AppSetting (gymOwnerId,packageName,AppType, appVersion, CreatedBy, versionChanges)
						VALUES(@gymOwnerId,@packageName,@AppType, @appVersion, @CreatedBy, @versionChanges)

						IF @@ROWCOUNT > 0		  
							BEGIN	
								SET @StatusCode = 1					
								SET @Response ='App Settings Added Successfully !!!.'
							END	
						ELSE
							BEGIN	
								SET @StatusCode = 0			
								SET @Response ='Something went wrong!!!.'
							END							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						Declare @ApplType NVARCHAR(50)
						IF @appType = 'A' SET @ApplType = 'Android' ELSE SET @ApplType = 'Web'						
						SET @Response='AppVersion ' + @appVersion + ' With AppType ' +@ApplType+ ' Already Exists !!!.'

					END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='Invalid QueryType '+@QueryType
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
	END CATCH

	IF(@StatusCode=1)
		BEGIN
			COMMIT TRANSACTION
		END
	ELSE 
		BEGIN
			ROLLBACK TRANSACTION
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrBranch]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrBranch]
(
@queryType NVARCHAR(100),
@gymOwnerId INT=0,
@branchId INT=0,
@branchName VARCHAR(50)= NULL,
@shortName VARCHAR(50)=NULL,
@latitude decimal(18, 10)=NULL,
@longitude decimal(18, 10)=NULL,
@address1 NVARCHAR(50)=NULL,
@address2 NVARCHAR(50)=NULL,
@district NVARCHAR(50)=NULL,
@state NVARCHAR(50)=NULL,
@city NVARCHAR(50)=NULL,
@pincode INT=0,
@primaryMobileNumber NVARCHAR(15)=NULL,
@secondayMobilenumber NVARCHAR(15)=NULL,
@emailId NVARCHAR(50)=NULL,
@gstNumber NVARCHAR(20)=NULL,
@approvalStatus CHAR(1)=NULL,
@cancellationReason NVARCHAR(200)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='insert')
			BEGIN
				IF NOT EXISTS(SELECT branchName FROM Mstr_Branch WHERE gymOwnerId=@gymOwnerId AND branchName=@branchName AND latitude=@latitude AND longitude=@longitude)
					BEGIN
						INSERT INTO Mstr_Branch(gymOwnerId,branchName,shortName,latitude,longitude ,address1,address2,district,state,city,pincode,
						primaryMobileNumber,secondayMobilenumber,emailId,gstNumber,approvalStatus,activeStatus,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchName,@shortName,@latitude,@longitude ,@address1,@address2,@district,@state,@city,@pincode,
						@primaryMobileNumber,@secondayMobilenumber,@emailId,@gstNumber,@approvalStatus,'A',@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Details Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Branch Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT branchName FROM Mstr_Branch WHERE gymOwnerId=@gymOwnerId AND branchName=@branchName AND latitude=@latitude
			AND longitude=@longitude AND activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_Branch WHERE branchName=@branchName AND latitude=@latitude AND longitude=@longitude
				                      AND branchId!=@branchId AND  gymOwnerId=@gymOwnerId )
						BEGIN 
							UPDATE Mstr_Branch SET branchName=@branchName,shortName=@shortName,latitude=@latitude , longitude=@longitude,
							address1=@address1,address2=@address2,district=@district,state=@state,city=@city,pincode=@pincode,
							primaryMobileNumber=@primaryMobileNumber,secondayMobilenumber=@secondayMobilenumber,emailId=@emailId,gstNumber=@gstNumber,
							updatedBy=@updatedBy,updatedDate=GETDATE() WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Details  Updated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Branch Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT branchName FROM Mstr_Branch WHERE branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_Branch SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							  branchId=@branchId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Details Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT branchName FROM Mstr_Branch WHERE   branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_Branch SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							  branchId=@branchId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Details InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
		 ELSE IF(@queryType ='approve')
				BEGIN
					IF EXISTS(SELECT branchName FROM Mstr_Branch WHERE  branchId=@branchId AND gymOwnerId=@gymOwnerId AND approvalStatus='W' and activeStatus='A')
						BEGIN
							UPDATE Mstr_Branch SET approvalStatus=@approvalStatus,cancellationReason=@cancellationReason,updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							  branchId=@branchId AND activeStatus='A' AND approvalStatus='W' AND gymOwnerId=@gymOwnerId

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									IF(@approvalStatus ='C')
									BEGIN
									   SET @Response='Branch Details Approval Cancelled Successfully !!!'
									END
									ELSE
									BEGIN 
									   SET @Response='Branch Details Approved Successfully !!!'
									END
									
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


SELECT * FROM Mstr_Branch
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrBranchGallery]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrBranchGallery]
(
@queryType VARCHAR(100),
@imageId INT=NULL,
@branchId INT=NULL,
@imageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT imageId,imageUrl FROM Mstr_BranchGallery WHERE  imageUrl=@imageUrl AND branchId=@branchId)
					BEGIN
						INSERT INTO Mstr_BranchGallery (branchId,imageUrl,createdBy,createdDate) 
						VALUES(@branchId,@imageUrl,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Branch Gallery Image Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Branch Gallery Image Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT imageId,branchId FROM Mstr_BranchGallery WHERE imageId=@imageId AND branchId= @branchId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT imageId,branchId,imageUrl FROM Mstr_BranchGallery WHERE  imageUrl= @imageUrl AND branchId=@branchId
						AND imageId !=@imageId)
							BEGIN
								UPDATE Mstr_BranchGallery SET branchId=@branchId, imageUrl=@imageUrl,					
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE branchId=@branchId AND imageId= @imageId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Branch Gallery Image Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Branch Gallery Image Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Branch Gallery Image Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT imageId FROM Mstr_BranchGallery WHERE imageId=@imageId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_BranchGallery SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							imageId=@imageId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Gallery Image Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Gallery Image Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT imageId FROM Mstr_BranchGallery WHERE imageId=@imageId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_BranchGallery SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							imageId=@imageId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch Gallery Image InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Gallery Image Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrBranchWorkingDays]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--- ====================================
--- Modified BY Abhinaya k
--- Modified Date 09-Jan-2023
--- ====================================

CREATE PROCEDURE [dbo].[usp_MstrBranchWorkingDays]
(
	@QueryType VARCHAR(150),
	@InsertBranchWrokingDays  InsertMstr_BranchWorkingDay READONLY,
	@fromTime TIME(7)=NULL,
	@toTime TIME(7)=NULL,
	@isHoliday CHAR(1)=NULL,
	@updatedBy INT=0,
	@workingDayId INT=0,
	@branchId INT=0,
	@gymOwnerId INT=0,
	@StatusCode INT=0 OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @workingDay  VARCHAR(50)
	BEGIN TRANSACTION
	BEGIN TRY
		IF(@QueryType='Insert')
			BEGIN
				--IF((SELECT COUNT(branchId) FROM @InsertBranchWrokingDays)=7)
				--	BEGIN
						IF NOT EXISTS(SELECT workingDayId FROM Mstr_BranchWorkingDay WHERE branchId = (SELECT TOP 1 branchId FROM @InsertBranchWrokingDays) AND  workingDay IN(SELECT workingDay FROM @InsertBranchWrokingDays)  )
							BEGIN
								INSERT INTO Mstr_BranchWorkingDay (branchId,gymOwnerId,workingDay,fromTime,toTime,isHoliday,createdBy)
								(SELECT branchId,gymOwnerId,LOWER(workingDay),fromTime,toTime,isHoliday,createdBy FROM @InsertBranchWrokingDays)

									IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='Branch WorkingDays Inserted Successfully !!!.'
											COMMIT TRANSACTION
										END
									ELSE
										BEGIN
											SET @StatusCode=0;
											SET @Response='Something went wrong !!!.'
											ROLLBACK TRANSACTION
										END
								END
						ELSE
							BEGIN
									SET @StatusCode=0;
									SET @Response='Branch WorkingDays are Already Exists !!!.'
									ROLLBACK TRANSACTION
							END
					--END
				--ELSE
				--	BEGIN
				--		SET @StatusCode=0;
				--		SET @Response='Must Pass Details For 7 Days, Passed Details For'+CAST((SELECT COUNT(branchId) FROM @InsertBranchWrokingDays) AS VARCHAR(3))+' Days.'
				--		ROLLBACK TRANSACTION
				--	END
			END
		ELSE IF(@QueryType='Update')
			BEGIN
			SET @workingDay=(SELECT workingDay FROM Mstr_BranchWorkingDay WHERE workingDayId=@workingDayId AND branchId=@branchId AND gymOwnerId =@gymOwnerId )
				IF NOT EXISTS(SELECT workingDay FROM Mstr_BranchWorkingDay WHERE workingDay=@workingDay AND workingDayId!=@workingDayId AND branchId=@branchId AND gymOwnerId =@gymOwnerId)
					BEGIN
						UPDATE Mstr_BranchWorkingDay SET fromTime=@fromTime,toTime=@toTime,isHoliday=@isHoliday,updatedBy=@updatedBy,updatedDate=GETDATE()
						WHERE workingDayId=@workingDayId AND branchId=@branchId AND gymOwnerId =@gymOwnerId
							
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Branch WorkingDays Updated Successfully !!!.'
									COMMIT TRANSACTION
								END
							ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Something Went Wrong !!!.'
									ROLLBACK TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Branch WorkingDays Does Not Exists !!!.'
						ROLLBACK TRANSACTION
					END
			END
		ELSE
			BEGIN
					SET @StatusCode=0;
					SET @Response='InValid QueryType'
					ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrBranchWorkingSlot]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrBranchWorkingSlot]
(
@QueryType VARCHAR(150),
@InsertMstrBranchWorkingSlot AS InsertMstr_BranchWorkingSlot READONLY,
@branchId INT=0,
@workingDayId INT=0,
@gymOwnerId INT=0,
@fromTime Time(7)=NULL,
@toTime Time(7)=NULL,
@createdBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY
		IF(@QueryType='insert')
			BEGIN
			IF NOT EXISTS(SELECT * FROM Mstr_BranchWorkingSlot WHERE workingDayId IN (SELECT workingDayId FROM @InsertMstrBranchWorkingSlot ) 
			AND branchId IN (SELECT branchId  FROM @InsertMstrBranchWorkingSlot )
			AND gymOwnerId IN (SELECT gymOwnerId  FROM @InsertMstrBranchWorkingSlot ) AND
			fromTime IN (SELECT  cast(fromTime as varchar(max))  FROM @InsertMstrBranchWorkingSlot ) AND
			toTime IN (SELECT  cast(toTime as varchar(max))  FROM @InsertMstrBranchWorkingSlot ) AND activeStatus='A')
				 BEGIN	
					INSERT INTO Mstr_BranchWorkingSlot (workingDayId,gymOwnerId,branchId,fromTime,toTime,slotTimeInMinutes,activeStatus,createdBy,createdDate)
					(SELECT workingDayId,gymOwnerId,branchId,fromTime,toTime,DATEDIFF(MINUTE,fromTime,toTime) AS 'slotTimeInMinutes','A',createdBy,GETDATE() FROM @InsertMstrBranchWorkingSlot)

					IF(@@ROWCOUNT>0)
						BEGIN
							SET @StatusCode=1;
							SET @Response='Branch Working Slots Inserted Successfully !!!.';
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Something went wrong!!!.'
						END
						END
				ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Working Slots Already Exits'
						END
			END

		 ELSE IF(@QueryType='singleInsert')
			BEGIN
			IF NOT EXISTS(SELECT branchId FROM Mstr_BranchWorkingSlot WHERE branchId=@branchId AND workingDayId=@workingDayId AND gymOwnerId=@gymOwnerId
			 AND fromTime=@fromTime AND toTime=@toTime)
			  BEGIN
						INSERT INTO Mstr_BranchWorkingSlot (workingDayId,gymOwnerId,branchId,fromTime,toTime,slotTimeInMinutes,activeStatus,createdBy,createdDate)VALUES
						( @workingDayId,@gymOwnerId,@branchId,@fromTime,@toTime,DATEDIFF(MINUTE,@fromTime,@toTime),'A',@createdBy,GETDATE())

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='Branch Working Slots Inserted Successfully !!!.';
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Something went wrong!!!.'
							END
				END
				ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Branch Working Slots Already Exits'
						END
			END

		ELSE IF(@QueryType='inActive')
			BEGIN
				IF EXISTS(SELECT branchId FROM Mstr_BranchWorkingSlot WHERE branchId=@branchId AND workingDayId=@workingDayId AND gymOwnerId=@gymOwnerId AND activeStatus='A')
					BEGIN
						UPDATE Mstr_BranchWorkingSlot SET activeStatus='D' FROM Mstr_BranchWorkingSlot
						WHERE branchId=@branchId AND workingDayId=@workingDayId AND gymOwnerId=@gymOwnerId AND activeStatus='A'

				IF(@@ROWCOUNT>0)
					BEGIN
						SET @StatusCode=1;
						SET @Response='Branch Working Slots Deleted Successfully !!!.';
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Something went wrong!!!.'
					END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Branch Working Slots Does Not Exists !!!.'
					END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='Invalid QueryType !!!.'
			END
	END TRY 
	BEGIN CATCH
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
	END CATCH

	IF @StatusCode=1
		BEGIN
			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrCategory]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrCategory]
(
@queryType VARCHAR(100),
@categoryId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@categoryName NVARCHAR(50)=NULL,
@description NVARCHAR(150)=NULL,
@imageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT categoryName,gymOwnerId,branchId FROM Mstr_FitnessCategory WHERE  categoryName=@categoryName AND gymOwnerId=@gymOwnerId AND branchId = @branchId)
					BEGIN
						INSERT INTO Mstr_FitnessCategory (gymOwnerId,branchId,categoryName,description,imageUrl,createdBy,createdDate) VALUES(@gymOwnerId,@branchId,@categoryName,@description,@imageUrl,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='CategoryName '+@categoryName+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='CategoryName '+@categoryName+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT CategoryName,gymOwnerId,branchId FROM Mstr_FitnessCategory WHERE categoryId=@categoryId AND gymOwnerId= @gymOwnerId AND branchId = @branchId AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT categoryId,gymOwnerId,branchId ,CategoryName FROM Mstr_FitnessCategory WHERE  gymOwnerId= @gymOwnerId AND branchId = @branchId AND CategoryName = @CategoryName AND categoryId !=@categoryId)
							BEGIN
								UPDATE Mstr_FitnessCategory SET categoryName=@categoryName,description=@description,imageUrl = @imageUrl,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE categoryId=@categoryId AND gymOwnerId= @gymOwnerId AND branchId = @branchId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='CategoryName '+@categoryName+' Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='CategoryName '+@categoryName+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='CategoryName '+@categoryName+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT categoryId FROM Mstr_FitnessCategory WHERE categoryId=@categoryId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_FitnessCategory SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							categoryId=@categoryId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='CategoryName Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='CategoryName Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT categoryId FROM Mstr_FitnessCategory WHERE categoryId=@categoryId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_FitnessCategory SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							categoryId=@categoryId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='CategoryName InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='CategoryName Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrCategoryBenefit]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrCategoryBenefit]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@categoryId INT=NULL,
@imageUrl NVARCHAR(MAX)=NULL,
@type INT=NULL,
@description NVARCHAR(150)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT categoryId,type,description FROM Mstr_CategoryBenefit WHERE  categoryId=@categoryId AND type=@type AND description=@description)
					BEGIN
						INSERT INTO Mstr_CategoryBenefit (categoryId,imageUrl,type,description,createdBy,createdDate)
						VALUES(@categoryId,@imageUrl,@type,@description,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='CategoryBenefit  Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='CategoryBenefit Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT categoryId,type,description FROM Mstr_CategoryBenefit WHERE  uniqueId=@uniqueId AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT categoryId,imageUrl,type FROM Mstr_CategoryBenefit WHERE categoryId=@categoryId AND type=@type AND description = @description  AND uniqueId !=@uniqueId  )
							BEGIN
								UPDATE Mstr_CategoryBenefit SET categoryId=@categoryId,imageUrl=@imageUrl,type = @type,
								description=@description,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE uniqueId=@uniqueId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='CategoryBenefit Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='CategoryBenefit Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='CategoryBenefit Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_CategoryBenefit WHERE uniqueId=@uniqueId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_CategoryBenefit SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='CategoryBenefit Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='CategoryBenefit Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_CategoryBenefit WHERE uniqueId=@uniqueId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_CategoryBenefit SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='CategoryBenefit InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='CategoryBenefit  Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrCategoryDietPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[usp_MstrCategoryDietPlan]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@categoryId INT=NULL,
@dietTimeId INT=NULL,
@foodItemId INT=NULL,
@mealTypeId INT=NULL,
@activeStatus Char(1)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
		         BEGIN
					IF NOT EXISTS(SELECT foodItemId FROM Mstr_CategoryDietPlan WHERE mealTypeId=@mealTypeId AND foodItemId =@foodItemId AND 
					dietTimeId=@dietTimeId AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId )
			           BEGIN
							INSERT INTO Mstr_CategoryDietPlan (gymOwnerId,branchId,categoryId,dietTimeId,mealTypeId,foodItemId,activeStatus ,createdBy ,createdDate) 
							VALUES(@gymOwnerId,@branchId,@categoryId,@dietTimeId,@mealTypeId,@foodItemId,@activeStatus,@createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
									BEGIN 
										SET @StatusCode=1;
										SET @Response='Food Is Inserted Successfully !!!' 
										COMMIT TRANSACTION
									END
							END

			     	ELSE
					  BEGIN
						SET @StatusCode=0;
						SET @Response='Food  Is Already Exists !!!'
						ROLLBACK TRANSACTION
					  END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT uniqueId,mealTypeId FROM Mstr_CategoryDietPlan WHERE mealTypeId=@mealTypeId AND foodItemId =@foodItemId AND
				dietTimeId=@dietTimeId  AND uniqueId= @uniqueId AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId)
					BEGIN
						IF NOT EXISTS(SELECT uniqueId,mealTypeId FROM Mstr_CategoryDietPlan WHERE mealTypeId=@mealTypeId AND foodItemId =@foodItemId 
						AND dietTimeId=@dietTimeId AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId  AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_CategoryDietPlan SET  mealTypeId=@mealTypeId, categoryId=@categoryId, activeStatus=@activeStatus,			
								foodItemId =@foodItemId,dietTimeId=@dietTimeId ,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE   uniqueId= @uniqueId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Food  Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Food  Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END

				ELSE
					
					  BEGIN
						SET @StatusCode=0;
						SET @Response='Food  Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					 END
			END


	 ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrCategoryPriceSlots]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrCategoryPriceSlots]
(
	@QueryType VARCHAR(150),
	@SlotId INT=NULL,
	@gymOwnerId INT=NULL,
	@branchId INT=NULL,
	@workingDayId INT=NULL,
	@categoryId INT=NULL,
	@trainingTypeId INT=NULL,
	@trainingMode CHAR(1)=NULL,
	@empId INT=NULL,
	@createdBy INT=NULL,
	@fromDate DATETIME=NULL,
	@toDate DATETIME=NULL,
	@StatusCode INT=0 OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

	IF(@QueryType='Insert')
		BEGIN
			IF NOT EXISTS(SELECT * FROM Mstr_FitnessCategorySlot WHERE slotId=@SlotId AND gymOwnerId=@gymOwnerId
						  AND branchId=@branchId AND workingDayId=@workingDayId AND categoryId=@categoryId
						  AND trainingTypeId=@trainingTypeId AND trainingMode=@trainingMode AND fromDate=@fromDate 
						  AND toDate=@toDate AND empId=@empId)
						  BEGIN
							INSERT INTO Mstr_FitnessCategorySlot (slotId,gymOwnerId,branchId,workingDayId,categoryId,trainingTypeId,trainingMode,fromDate,toDate,empId,createdBy)
							VALUES(@slotId,@gymOwnerId,@branchId,@workingDayId,@categoryId,@trainingTypeId,@trainingMode,@fromDate,@toDate,@empId,@createdBy)

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Slots Inserted Successfully !!!.'
									END
								ELSE
									BEGIN
										SET @StatusCode=0;
										SET @Response='something went wrong !!!.'
									END
						  END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Slot Already Exists !!!.'
						END
							
		END
	ELSE
		BEGIN
			SET @StatusCode=0;
			SET @Response='Invalid QueryType !!!.'
		END
		END TRY
		BEGIN CATCH
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE());
		END CATCH

		IF(@StatusCode =1)
			BEGIN
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				ROLLBACK TRANSACTION
			END
END





GO
/****** Object:  StoredProcedure [dbo].[usp_MstrCategoryWorkOutPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[usp_MstrCategoryWorkOutPlan]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@categoryId INT=NULL,
@workoutTypeId INT=NULL,
@workoutCatTypeId INT=NULL,
@activeStatus Char(1)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
		         BEGIN
					IF NOT EXISTS(SELECT workoutTypeId FROM Mstr_CategoryWorkOutPlan WHERE workoutTypeId=@workoutTypeId AND workoutCatTypeId =@workoutCatTypeId 
					 AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId )
			           BEGIN
							INSERT INTO Mstr_CategoryWorkOutPlan (gymOwnerId,branchId,categoryId,workoutTypeId,workoutCatTypeId,activeStatus ,createdBy ,createdDate) 
							VALUES(@gymOwnerId,@branchId,@categoryId,@workoutTypeId,@workoutCatTypeId,@activeStatus,@createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
									BEGIN 
										SET @StatusCode=1;
										SET @Response='WorkOut Is Inserted Successfully !!!' 
										COMMIT TRANSACTION
									END
							END

			     	ELSE
					  BEGIN
						SET @StatusCode=0;
						SET @Response='WorkOut  Is Already Exists !!!'
						ROLLBACK TRANSACTION
					  END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT uniqueId FROM Mstr_CategoryWorkOutPlan WHERE workoutTypeId=@workoutTypeId AND workoutCatTypeId =@workoutCatTypeId
				 AND uniqueId= @uniqueId AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId)
					BEGIN
						IF NOT EXISTS(SELECT uniqueId FROM Mstr_CategoryWorkOutPlan WHERE workoutTypeId=@workoutTypeId AND workoutCatTypeId =@workoutCatTypeId
					 AND categoryId=@categoryId AND gymOwnerId=@gymOwnerId AND branchId=@branchId  AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_CategoryWorkOutPlan SET  workoutTypeId=@workoutTypeId , workoutCatTypeId =@workoutCatTypeId,
								categoryId=@categoryId, activeStatus=@activeStatus,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE   uniqueId= @uniqueId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='WorkOut  Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='WorkOut  Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END

				ELSE
					
					  BEGIN
						SET @StatusCode=0;
						SET @Response='WorkOut  Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					 END
			END


	 ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrConfig]
(
@QueryType VARCHAR(100),
@typeId INT=NULL,
@configId INT=NULL,
@configName NVARCHAR(150)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@QueryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT typeId FROM Mstr_Configuration WHERE typeId=@typeId AND configName=@configName)
					BEGIN
						INSERT INTO Mstr_Configuration(typeId,configName,createdBy) VALUES(@typeId,@configName,@createdBy)
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='ConfigName '+@configName+' Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigName '+@configName+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    IF(@QueryType='Update')
			BEGIN
				IF EXISTS(SELECT typeId FROM Mstr_Configuration WHERE typeId=@typeId AND configId=@configId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT typeId FROM Mstr_Configuration WHERE typeId=@typeId AND configName=@configName AND configId !=@configId)
							BEGIN
								UPDATE Mstr_Configuration SET configName=@configName,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE typeId=@typeId AND activeStatus='A' AND configId=@configId

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='ConfigName Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='ConfigName '+@configName+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigName '+@configName+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

			IF(@QueryType ='Active')
				BEGIN
					IF EXISTS(SELECT typeId FROM Mstr_Configuration WHERE typeId=@typeId AND configId=@configId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_Configuration SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							typeId=@typeId AND configId=@configId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='ConfigName Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='ConfigName Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

			IF(@QueryType ='InActive')
				BEGIN
					IF EXISTS(SELECT typeId FROM Mstr_Configuration WHERE typeId=@typeId AND configId=@configId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_Configuration SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							typeId=@typeId AND configId=@configId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='ConfigName InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='ConfigName Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


SELECT * FROM Mstr_Configuration
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrConfigType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrConfigType]
(
@QueryType VARCHAR(100),
@typeId INT=NULL,
@typeName NVARCHAR(150)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION 
	BEGIN TRY
--------------------------------------Insert----------------------------------------------------------
		IF(@QueryType ='Insert')
			BEGIN
				IF NOT EXISTS(SELECT typeId FROM Mstr_ConfigurationType WHERE typeName=@typeName)
					BEGIN
						INSERT INTO Mstr_ConfigurationType 
						(typeName,createdBy) VALUES	(@typeName,@createdBy)

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='ConfigurationType Inserted Successfully !!!'
								COMMIT TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigurationType Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
--------------------------------------Update----------------------------------------------------------
	ELSE IF(@QueryType='Update')
			BEGIN
				IF EXISTS(SELECT typeId FROM Mstr_ConfigurationType WHERE typeId=@typeId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT typeId FROM Mstr_ConfigurationType WHERE typeId!=@typeId AND activeStatus='A' AND typeName=@typeName)
							BEGIN
								UPDATE Mstr_ConfigurationType SET typeName=@typeName,updatedBy=@updatedBy,updatedDate=GETDATE() WHERE typeId=@typeId AND activeStatus='A'

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='ConfigurationType Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='ConfigurationType '+ @typeName +' is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE	
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigurationType Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
--------------------------------------Active----------------------------------------------------------
	ELSE IF(@QueryType='Active')
			BEGIN
				IF EXISTS(SELECT typeId FROM Mstr_ConfigurationType WHERE typeId=@typeId AND activeStatus='D')
					BEGIN
						UPDATE Mstr_ConfigurationType SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE typeId=@typeId AND activeStatus='D'

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='ConfigurationType Activated Successfully !!!'
								COMMIT TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigurationType Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
--------------------------------------InActive----------------------------------------------------------
		ELSE IF(@QueryType='Inactive')
			BEGIN
				IF EXISTS(SELECT typeId FROM Mstr_ConfigurationType WHERE typeId=@typeId AND activeStatus='A')
					BEGIN
						UPDATE Mstr_ConfigurationType SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE typeId=@typeId AND activeStatus='A'

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='ConfigurationType Inactivated Successfully !!!'
								COMMIT TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ConfigurationType Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
				ROLLBACK TRANSACTION
			END
	--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


GO
/****** Object:  StoredProcedure [dbo].[usp_MstrDietType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrDietType]
(
@queryType VARCHAR(100),
@dietTypeNameId INT=NULL,
@dietTypeId INT=NULL,
@description NVARCHAR(150)=NULL,
@imageUrl VARCHAR(Max)=NULL,
@typeIndicationImageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT dietTypeId,dietTypeNameId FROM Mstr_DietType WHERE dietTypeNameId=@dietTypeNameId)
					BEGIN
						INSERT INTO Mstr_DietType (dietTypeNameId,description,imageUrl,typeIndicationImageUrl,createdBy,createdDate) 
						VALUES(@dietTypeNameId,@description,@imageUrl,@typeIndicationImageUrl,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='DietType Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='DietType Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT dietTypeId,dietTypeNameId FROM Mstr_DietType WHERE dietTypeNameId=@dietTypeNameId AND dietTypeId= @dietTypeId AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT dietTypeId,dietTypeNameId FROM Mstr_DietType 
						WHERE  dietTypeId!= @dietTypeId AND dietTypeNameId = @dietTypeNameId)
							BEGIN
								UPDATE Mstr_DietType SET dietTypeNameId=@dietTypeNameId,description=@description,
								imageUrl = @imageUrl,typeIndicationImageUrl=@typeIndicationImageUrl,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE dietTypeNameId=@dietTypeNameId AND dietTypeId= @dietTypeId 
							    AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='DietType Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='DietType Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='DietType Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT dietTypeId FROM Mstr_DietType WHERE dietTypeId=@dietTypeId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_DietType SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							dietTypeId=@dietTypeId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='DietType Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='DietType Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT dietTypeId FROM Mstr_DietType WHERE dietTypeId=@dietTypeId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_DietType SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							dietTypeId=@dietTypeId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='DietType InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='DietType Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrEmployee]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_MstrEmployee]
(
@queryType NVARCHAR(100),
@gymOwnerId INT=0,
@branchId INT=0,
@empId  INT=0,
@empType  INT=0,
@firstName NVARCHAR(50)=NULL,
@lastName NVARCHAR(50)=NULL,
@designation INT =0,
@department INT=0,
@addressLine1 NVARCHAR(50)=NULL,
@addressLine2 NVARCHAR(50)=NULL,
@district NVARCHAR(50)=NULL,
@state NVARCHAR(50)=NULL,
@city NVARCHAR(50)=NULL,
@zipcode INT=0,
@dob Date=NULL,
@doj Date=NULL,
@aadharId NVARCHAR(16)=NULL,
@mobileNo NVARCHAR(10)=NULL,
@mailId NVARCHAR(50)=NULL,
@passWord NVARCHAR(20)=NULL,
@photoLink VARCHAR(MAX)=NULL,
@shiftId INT=0,
@roleId INT=0,
@maritalStatus CHAR(1)= NULL,
@gender CHAR(1)= NULL,
@mobileAppAccess CHAR(1)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
		DECLARE @userId INT
	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='insert')
			BEGIN
				IF NOT EXISTS(SELECT * FROM Mstr_UserLogin AS UserLogin WHERE  UserLogin.mobileNo=@mobileNo)
					BEGIN
					 INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,activeStatus,createdBy,createdDate) 
						   VALUES(@mobileNo,@mailId,@passWord,@roleId,'A',@createdBy,GETDATE())
						   	IF(@@ROWCOUNT>0)
								BEGIN
								 SET @userId= (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mobileNo=@mobileNo)
									INSERT INTO Mstr_Employee(empId,branchId,gymOwnerId,empType,firstName ,lastName,designation,department,
									gender,addressLine1,addressLine2,district,
											state,city,zipcode,maritalStatus,dob,doj,aadharId,photoLink,
											shiftId,mobileAppAccess,activeStatus,createdBy,createdDate) 
									VALUES(@userId,@branchId,@gymOwnerId,@empType,@firstName ,@lastName,@designation,@department,@gender,@addressLine1
									      ,@addressLine2,@district,@state,@city,@zipcode,@maritalStatus,@dob,@doj,@aadharId,@photoLink,
											@shiftId,@mobileAppAccess,'A',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
											BEGIN
												SET @StatusCode=1;
												SET @Response='Employee Details Is Inserted Successfully !!!'
												COMMIT TRANSACTION
										END
							  END
					END
				ELSE

					BEGIN
						SET @StatusCode=0;
						SET @Response='MobileNo "'+ @mobileNo +'" Is Already Exist !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT * FROM Mstr_UserLogin AS UserLogin WHERE  UserLogin.mobileNo=@mobileNo)
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_Employee AS Emp INNER JOIN Mstr_UserLogin AS UserLogin  ON Emp.empId=UserLogin.userId  
				     WHERE   Emp.firstName=@firstName AND UserLogin.mobileNo=@mobileNo AND Emp.branchId=@branchId AND Emp.gymOwnerId=@gymOwnerId  AND Emp.empId !=@empId)
						BEGIN 
							UPDATE Mstr_Employee SET empType=@empType,firstName=@firstName, lastName=@lastName,designation=@designation,department=@department,
							gender=@gender,addressLine1=@addressLine1,addressLine2=@addressLine2,district=@district,state=@state,city=@city,zipcode=@zipcode,
							maritalStatus=@maritalStatus,dob=@dob,doj=@doj,aadharId=@aadharId,photoLink=@photoLink,shiftId=@shiftId,mobileAppAccess=@mobileAppAccess,
							updatedBy=@updatedBy,updatedDate=GETDATE() WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND empId=@empId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET mobileNo=@mobileNo,mailId=@mailId,passWord=@passWord,roleId=@roleId,
									updatedBy=@updatedBy,updatedDate=GETDATE() WHERE userId=@empId AND activeStatus='A'
										IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='Employee Details  Updated Successfully !!!'
											COMMIT TRANSACTION
										END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='MobileNo "'+ @mobileNo +'" Is Already Exist !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Employee Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_Employee WHERE empId=@empId AND branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_Employee SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  empId=@empId AND
							  branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@empId
									 AND activeStatus='D'
									IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Employee Details Activated Successfully !!!'
										COMMIT TRANSACTION
									END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Employee Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_Employee WHERE  empId=@empId AND branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_Employee SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE empId=@empId AND 
							  branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@empId
									 AND activeStatus='A'
									IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Employee Details InActivated Successfully !!!'
										COMMIT TRANSACTION
									END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Employee Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
		
		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END



GO
/****** Object:  StoredProcedure [dbo].[usp_MstrFaq]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrFaq]
(
@queryType VARCHAR(100),
@faqId INT=NULL,
@offerId INT=NULL,
@question NVARCHAR(max)=NULL,
@answer NVARCHAR(max)=NULL,
@questionType char(1)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT question,answer FROM Mstr_Faq WHERE  question=@question AND answer=@answer AND questionType = @questionType)
					BEGIN
						INSERT INTO Mstr_Faq (offerId,question,answer,questionType,createdBy,createdDate)
						VALUES(@offerId,@question,@answer,@questionType,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Faq Q&A Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Faq Q&A Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT question,answer FROM Mstr_Faq WHERE  faqId=@faqId AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT question,answer FROM Mstr_Faq WHERE question=@question AND answer=@answer AND faqId !=@faqId )
							BEGIN
								UPDATE Mstr_Faq SET offerId=@offerId,question=@question,answer=@answer,questionType = @questionType,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE faqId=@faqId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Faq Q&A Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Faq Q&A Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Faq Q&A Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT faqId FROM Mstr_Faq WHERE faqId=@faqId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_Faq SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							faqId=@faqId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Faq Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Faq Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT faqId FROM Mstr_Faq WHERE faqId=@faqId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_Faq SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							faqId=@faqId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Faq InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Faq Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrFitnessCategoryPrice]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrFitnessCategoryPrice]
(
@queryType NVARCHAR(100),
@priceId INT=0,
@gymOwnerId INT=0,
@branchId INT=0,
@categoryId INT =0,
@trainingTypeId INT =0,
@trainingMode CHAR(1)=NULL,
@planDuration INT =0,
@price decimal(18,2)=NULL,
@tax decimal(18,2)=NULL,
@taxId INT =0,
@netAmount decimal(18,2)=NULL,
@actualAmount decimal(18,2)=NULL,
@displayAmount decimal(18,2)=NULL,
@cyclePaymentsAllowed CHAR(1)=NULL,
@maxNoOfCycles INT=0,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @cgstTax decimal(18,2)=0
    DECLARE @sgstTax decimal(18,2)=0
    SET	@cgstTax =@tax/2
	SET @sgstTax =@tax/2

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='insert')
			BEGIN
				IF NOT EXISTS(SELECT priceId FROM Mstr_FitnessCategoryPrice WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND categoryId=@categoryId
				AND trainingTypeId =@trainingTypeId AND  trainingMode=@trainingMode AND planDuration=@planDuration)
					BEGIN
						INSERT INTO Mstr_FitnessCategoryPrice(gymOwnerId,branchId,categoryId,trainingTypeId,trainingMode,
						planDuration ,price,cgstTax,sgstTax,taxId,netAmount,actualAmount,displayAmount,
						cyclePaymentsAllowed,maxNoOfCycles,activeStatus,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchId,@categoryId,@trainingTypeId,@trainingMode,@planDuration ,@price,@cgstTax,@sgstTax,@taxId,@netAmount,@actualAmount,
						@displayAmount,@cyclePaymentsAllowed,@maxNoOfCycles,'A',@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Price Details Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Price Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT priceId FROM Mstr_FitnessCategoryPrice WHERE  gymOwnerId=@gymOwnerId AND branchId=@branchId AND categoryId=@categoryId
				 AND activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_FitnessCategoryPrice WHERE  gymOwnerId=@gymOwnerId AND branchId=@branchId AND categoryId=@categoryId
				AND trainingTypeId =@trainingTypeId AND  trainingMode=@trainingMode AND planDuration=@planDuration AND   priceId != @priceId )
						BEGIN 
							UPDATE Mstr_FitnessCategoryPrice SET categoryId=@categoryId,trainingTypeId=@trainingTypeId,trainingMode=@trainingMode,
							planDuration=@planDuration,price=@price,cgstTax=@cgstTax,sgstTax=@sgstTax,taxId=@taxId,netAmount=@netAmount,
							actualAmount=@actualAmount,displayAmount=@displayAmount,
							cyclePaymentsAllowed=@cyclePaymentsAllowed,maxNoOfCycles=@maxNoOfCycles ,
							updatedBy=@updatedBy,updatedDate=GETDATE() WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND priceId=@priceId
							AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Price Details  Updated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Price Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Price Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT priceId FROM Mstr_FitnessCategoryPrice WHERE
					 gymOwnerId=@gymOwnerId AND priceId=@priceId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_FitnessCategoryPrice SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							   priceId=@priceId  AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Price Details Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Price Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT priceId FROM Mstr_FitnessCategoryPrice WHERE  priceId=@priceId  AND gymOwnerId=@gymOwnerId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_FitnessCategoryPrice SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							   priceId=@priceId  AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Price Details InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Price Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
	
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
				ROLLBACK TRANSACTION
			END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrFoodDietTime]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrFoodDietTime]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@foodItemId INT=NULL,
@mealType INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
		         BEGIN
					IF NOT EXISTS(SELECT uniqueId,mealType,foodItemId FROM Mstr_FoodDietTime WHERE mealType=@mealType AND foodItemId =@foodItemId)
			           BEGIN
							INSERT INTO Mstr_FoodDietTime (mealType,foodItemId,createdBy,createdDate) 
							VALUES(@mealType,@foodItemId,@createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
									BEGIN 
										SET @StatusCode=1;
										SET @Response='Food Diet Time Is Inserted Successfully !!!' 
										COMMIT TRANSACTION
									END
							END

			     	ELSE
					  BEGIN
						SET @StatusCode=0;
						SET @Response='Food Diet Time Is Already Exists !!!'
						ROLLBACK TRANSACTION
					  END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT uniqueId,mealType FROM Mstr_FoodDietTime WHERE mealType=@mealType  AND uniqueId= @uniqueId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT uniqueId,mealType FROM Mstr_FoodDietTime WHERE mealType=@mealType AND foodItemId =@foodItemId AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_FoodDietTime SET foodItemId=@foodItemId,					
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE mealType=@mealType AND uniqueId= @uniqueId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Food Diet Time Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Food Diet Time Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END

				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Food Diet Time Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_FoodDietTime WHERE uniqueId=@uniqueId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_FoodDietTime SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Food Diet Time Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Food Diet Time Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_FoodDietTime WHERE uniqueId=@uniqueId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_FoodDietTime SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Food Diet Time InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Food Diet Time Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrFoodItem]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrFoodItem]
(
@queryType VARCHAR(100),
@foodItemId INT=NULL,
@dietTypeId INT=NULL,
@foodItemName NVARCHAR(50)=NULL,
@unit INT=NULL,
@servingIn INT=NULL,
@protein DECIMAL = NUll,
@carbs DECIMAL = NUll,
@fat DECIMAL = NUll,
@calories INT=NULL,
@imageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT foodItemId,dietTypeId,foodItemName FROM Mstr_FoodItem WHERE foodItemName=@foodItemName AND dietTypeId=@dietTypeId)
					BEGIN
						INSERT INTO Mstr_FoodItem (dietTypeId,foodItemName,unit,servingIn,protein,carbs,fat,calories,imageUrl,createdBy,createdDate) 
						VALUES(@dietTypeId,@foodItemName,@unit,@servingIn,@protein,@carbs,@fat,@calories,@imageUrl,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='FoodItem '+@foodItemName+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='FoodItem '+@foodItemName+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT foodItemId,dietTypeId FROM Mstr_FoodItem WHERE foodItemId=@foodItemId AND dietTypeId= @dietTypeId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT foodItemId,dietTypeId ,foodItemName FROM Mstr_FoodItem WHERE  dietTypeId= @dietTypeId 
						AND foodItemName = @foodItemName AND foodItemId !=@foodItemId)
							BEGIN
								UPDATE Mstr_FoodItem SET foodItemName=@foodItemName,unit=@unit,servingIn=@servingIn,
								protein =@protein,carbs =@carbs,fat=@fat,calories=@calories,imageUrl=@imageUrl,
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE foodItemId=@foodItemId AND dietTypeId= @dietTypeId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='FoodItem Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='FoodItem '+@foodItemName+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='FoodItem '+@foodItemName+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT foodItemId FROM Mstr_FoodItem WHERE foodItemId=@foodItemId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_FoodItem SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							foodItemId=@foodItemId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='FoodItem Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='FoodItem Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT foodItemId FROM Mstr_FoodItem WHERE foodItemId=@foodItemId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_FoodItem SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							foodItemId=@foodItemId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='FoodItem InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='FoodItem Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrFooterDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrFooterDetails]
(
@queryType VARCHAR(100),
@FooterDetailsId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@icons NVARCHAR(MAX)=NULL,
@description NVARCHAR(MAX)=NULL,
@link NVARCHAR(MAX)=NULL,
@displayType NVARCHAR(50)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				INSERT INTO Mstr_FooterDetails (icons,description,link,displayType,gymOwnerId,branchId,createdBy,createdDate) 
				VALUES(@icons,@description,@link,@displayType,@gymOwnerId,@branchId,@createdBy,GETDATE())
					IF(@@ROWCOUNT>0)
						BEGIN 
							SET @StatusCode=1;
							SET @Response='FooterDetails '+@displayType+' Is Inserted Successfully !!!' 
							COMMIT TRANSACTION
						END
				END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT icons,description,link,displayType  FROM Mstr_FooterDetails
				WHERE  displayType=@displayType AND gymOwnerId=@gymOwnerId AND branchId = @branchId AND  activeStatus='A')
			
						BEGIN
								UPDATE Mstr_FooterDetails SET icons=@icons,description=@description,link = @link,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE activeStatus='A' and FooterDetailsId =@FooterDetailsId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='FooterDetails '+@displayType+' Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='FooterDetails '+@displayType+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT FooterDetailsId FROM Mstr_FooterDetails WHERE FooterDetailsId=@FooterDetailsId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_FooterDetails SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							FooterDetailsId=@FooterDetailsId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Footer Details displayType Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Footer Details displayType Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT FooterDetailsId FROM Mstr_FooterDetails WHERE FooterDetailsId=@FooterDetailsId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_FooterDetails SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							FooterDetailsId=@FooterDetailsId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Footer Details displayType InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Footer Details displayType Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrGetCategoryPriceSlots]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrGetCategoryPriceSlots]
(
@QueryType VARCHAR(150),
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@categoryId INT=NULL,
@trainingTypeId INT=NULL,
@trainingMode CHAR=NULL,
@workingDayId INT=NULL
)
AS
BEGIN
	IF(@QueryType='GetCategorySingleSlot')
		BEGIN
		    SELECT DISTINCT A.gymOwnerId,A.branchId,A.categoryId,FC.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',A.trainingMode,E.empId,E.firstName +' '+ E.lastName AS 'empName',
			CONVERT(NVARCHAR,A.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,103) AS 'toDate'
			 FROM Mstr_FitnessCategorySlot AS A
			INNER JOIN Mstr_BranchWorkingSlot AS B ON A.branchId=B.branchId AND A.activeStatus='A' AND A.gymOwnerId=B.gymOwnerId AND
			A.workingDayId=B.workingDayId AND A.slotId=B.slotId
			INNER JOIN Mstr_BranchWorkingDay AS C ON A.branchId=C.branchId AND A.activeStatus='A' AND A.gymOwnerId=C.gymOwnerId AND A.workingDayId=C.workingDayId
			AND C.isHoliday='N'
			INNER JOIN Mstr_FitnessCategory AS FC ON A.gymOwnerId=FC.gymOwnerId AND A.branchId=FC.branchId AND A.activeStatus=FC.activeStatus AND A.categoryId=FC.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_Employee AS E ON A.gymOwnerId=E.gymOwnerId AND A.branchId=E.branchId  And E.empId=A.empId
			WHERE A.branchId=@branchId AND A.categoryId=@categoryId  AND A.trainingTypeId=@trainingTypeId
			AND A.trainingMode=@trainingMode AND A.gymOwnerId=@gymOwnerId	
		END
		IF(@QueryType='GetCategoryListSlot')
		BEGIN
			SELECT  A.gymOwnerId,A.branchId,A.workingDayId,C.workingDay,A.categoryId,FC.categoryName,
			CONVERT(NVARCHAR,A.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,103) AS 'toDate',
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',A.trainingMode,E.empId,E.firstName +' '+ E.lastName AS 'empName',A.slotId,
			CONVERT(VARCHAR,B.fromTime,8)+'-'+CONVERT(VARCHAR,B.toTime,8) AS 'slots'
			 FROM Mstr_FitnessCategorySlot AS A
			INNER JOIN Mstr_BranchWorkingSlot AS B ON A.branchId=B.branchId AND A.activeStatus='A' AND A.gymOwnerId=B.gymOwnerId AND
			A.workingDayId=B.workingDayId AND A.slotId=B.slotId
			INNER JOIN Mstr_BranchWorkingDay AS C ON A.branchId=C.branchId AND A.activeStatus='A' AND A.gymOwnerId=C.gymOwnerId AND A.workingDayId=C.workingDayId
			AND C.isHoliday='N'
			INNER JOIN Mstr_FitnessCategory AS FC ON A.gymOwnerId=FC.gymOwnerId AND A.branchId=FC.branchId AND A.activeStatus=FC.activeStatus AND A.categoryId=FC.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_Employee AS E ON A.gymOwnerId=E.gymOwnerId AND A.branchId=E.branchId  And E.empId=A.empId
			WHERE A.branchId=@branchId AND A.categoryId=@categoryId  AND A.trainingTypeId=@trainingTypeId
			AND A.trainingMode=@trainingMode AND A.gymOwnerId=@gymOwnerId AND A.workingDayId=@workingDayId
		END
		IF(@QueryType='GetCategoryListDays')
		BEGIN
			SELECT  A.gymOwnerId,A.branchId,A.workingDayId,C.workingDay,A.categoryId,FC.categoryName,
			CONVERT(NVARCHAR,A.fromDate,103) AS 'fromDate',CONVERT(NVARCHAR,A.toDate,103) AS 'toDate',
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',A.trainingMode,A.empId,E.firstName +' '+ E.lastName AS 'empName'
			 FROM Mstr_FitnessCategorySlot AS A
			INNER JOIN Mstr_BranchWorkingSlot AS B ON A.branchId=B.branchId AND A.activeStatus='A' AND A.gymOwnerId=B.gymOwnerId AND
			A.workingDayId=B.workingDayId AND A.slotId=B.slotId
			INNER JOIN Mstr_BranchWorkingDay AS C ON A.branchId=C.branchId AND A.activeStatus='A' AND A.gymOwnerId=C.gymOwnerId AND A.workingDayId=C.workingDayId
			AND C.isHoliday='N'
			INNER JOIN Mstr_FitnessCategory AS FC ON A.gymOwnerId=FC.gymOwnerId AND A.branchId=FC.branchId AND A.activeStatus=FC.activeStatus AND A.categoryId=FC.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			INNER JOIN Mstr_Employee AS E ON A.gymOwnerId=E.gymOwnerId AND A.branchId=E.branchId  And E.empId=A.empId
			WHERE A.branchId=@branchId AND A.categoryId=@categoryId AND A.trainingTypeId=@trainingTypeId
			AND A.trainingMode=@trainingMode AND A.gymOwnerId=@gymOwnerId	
			GROUP  BY A.gymOwnerId,A.branchId,A.workingDayId,C.workingDay,A.categoryId,FC.categoryName,A.fromDate,A.toDate,
			A.trainingTypeId,CONFIG.configName ,A.trainingMode,A.empId,E.firstName,E.lastName	
		END
		IF(@QueryType='GetCategoryAvailableSlot')
		BEGIN
			SELECT A.gymOwnerId,A.branchId,A.categorySlotId,A.workingDayId,C.workingDay,A.categoryId,FC.categoryName,
			A.trainingTypeId,CONFIG.configName AS 'traningTypeName',A.trainingMode,B.slotTimeInMinutes,A.categorySlotId,
			CONVERT(VARCHAR,B.fromTime,8) AS 'fromTime', CONVERT(VARCHAR,B.toTime,8) AS 'toTime' FROM Mstr_FitnessCategorySlot AS A
			INNER JOIN Mstr_BranchWorkingSlot AS B ON A.branchId=B.branchId AND A.activeStatus='A' AND A.gymOwnerId=B.gymOwnerId AND
			A.workingDayId=B.workingDayId AND A.slotId=B.slotId
			INNER JOIN Mstr_BranchWorkingDay AS C ON A.branchId=C.branchId AND A.activeStatus='A' AND A.gymOwnerId=C.gymOwnerId AND A.workingDayId=C.workingDayId
			AND C.isHoliday='N'
			INNER JOIN Mstr_FitnessCategory AS FC ON A.gymOwnerId=FC.gymOwnerId AND A.branchId=FC.branchId AND A.activeStatus=FC.activeStatus AND A.categoryId=FC.categoryId
			INNER JOIN Mstr_TrainingType AS TR ON A.gymOwnerId=TR.gymOwnerId AND A.branchId=TR.branchId AND TR.activeStatus = 'A' AND A.trainingTypeId=TR.trainingTypeId		
			INNER JOIN Mstr_Configuration AS CONFIG ON
			CONFIG.typeId='16' AND CONFIG.configId=TR.trainingTypeNameId AND CONFIG.activeStatus='A'
			WHERE A.branchId=@branchId AND A.categoryId=@categoryId  AND A.trainingTypeId=@trainingTypeId
			AND A.trainingMode='D' AND A.gymOwnerId=@gymOwnerId	
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrLiveConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Modified By Abhinaya K
       ModiFied Date 03-Mar-2023******/
CREATE PROCEDURE [dbo].[usp_MstrLiveConfig]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@branchId INT=NULL,
@gymownerId INT=NULL,
@livedate DATETIME=NULL,
@liveurl VARCHAR(Max)=NULL,
@purposename  VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT liveurl FROM Mstr_LiveConfig WHERE  liveurl=@liveurl)
					BEGIN
						INSERT INTO Mstr_LiveConfig (gymownerId,branchId,liveurl,livedate,purposename,createdBy,createdDate)
						VALUES(@gymownerId,@branchId,@liveurl,@livedate,@purposename,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='LiveURL '+@liveurl+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='LiveURL '+@liveurl+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT  liveurl FROM Mstr_LiveConfig WHERE  liveurl=@liveurl AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT  liveurl FROM Mstr_LiveConfig WHERE  liveurl=@liveurl AND @uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_LiveConfig SET gymownerId=@gymownerId,branchId=@branchId,liveurl=@liveurl,livedate=@livedate,
								purposename=@purposename,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE  @uniqueId =@uniqueId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='LiveURL '+@liveurl+' Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='LiveURL '+@liveurl+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='LiveURL '+@liveurl+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT liveurl FROM Mstr_LiveConfig WHERE  @uniqueId =@uniqueId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_LiveConfig SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							 @uniqueId =@uniqueId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='LiveURL Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='LiveURL Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT liveurl FROM Mstr_LiveConfig WHERE  @uniqueId =@uniqueId  AND activeStatus='A')
						BEGIN
							UPDATE Mstr_LiveConfig SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							 @uniqueId =@uniqueId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='LiveURL InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='LiveURL Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrMealTimeConfig]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrMealTimeConfig]
(
@QueryType VARCHAR(100),
@uniqueId INT=NULL,
@mealTypeId INT=NULL,
@timeInHrs INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@QueryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT mealTypeId FROM MstrMealTimeConfig WHERE mealTypeId=@mealTypeId)
					BEGIN
						INSERT INTO MstrMealTimeConfig(mealTypeId,timeInHrs,createdBy) VALUES(@mealTypeId,@timeInHrs,@createdBy)
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Meal Time Config  Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Meal Time Config Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    IF(@QueryType='Update')
			BEGIN
				IF EXISTS(SELECT uniqueId,mealTypeId FROM MstrMealTimeConfig WHERE uniqueId=@uniqueId AND mealTypeId=@mealTypeId )
					BEGIN
						IF NOT EXISTS(SELECT mealTypeId FROM MstrMealTimeConfig WHERE mealTypeId=@mealTypeId AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE MstrMealTimeConfig SET mealTypeId=@mealTypeId,timeInHrs=@timeInHrs,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE uniqueId=@uniqueId AND mealTypeId=@mealTypeId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Meal Time Config Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Meal Time Config Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Meal Time Config  Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrMenuOption]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_MstrMenuOption]
(
	@QueryType VARCHAR(150),
	@OptionName NVARCHAR(100)=NULL,
	@OptionId INT=0,
	@CreatedBy INT=NULL,
	@UpdatedBy INT=NULL,
	@StatusCode INT=0 OUT,
	@Response VARCHAR(150)=NULL OUT
)
AS 
BEGIN
	SET NOCOUNT ON;

	SET @OptionName =LTRIM(RTRIM(@OptionName));

	BEGIN TRAN

	BEGIN TRY
		IF(@QueryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT optionId FROM [dbo].[Mstr_MenuOption] WHERE optionName=@OptionName)
					BEGIN
						INSERT INTO Mstr_MenuOption (optionName,createdBy) VALUES(@OptionName,@CreatedBy);

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='MenuOption Inserted Successfully !!!.'							
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Something Went Wrong !!!.'
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Option Name '''+@OptionName+''' Is Already Exist !!!.'
					END
			END

			IF(@QueryType='Update')
				BEGIN
					IF EXISTS(SELECT optionId FROM [dbo].[Mstr_MenuOption] WHERE optionId=@OptionId)
						BEGIN
							IF NOT EXISTS(SELECT optionId FROM [dbo].[Mstr_MenuOption] WHERE optionId<>@OptionId AND optionName=@OptionName)
								BEGIN
									UPDATE [Mstr_MenuOption] SET optionName=@OptionName,updatedBy=@UpdatedBy,updatedDate=GETDATE() WHERE optionId=@OptionId
										
										IF(@@ROWCOUNT>0)
											BEGIN
												SET @StatusCode=1;
												SET @Response='OptionName '''+@OptionName+''' Is Update Successfully !!!.';
											END
										ELSE
											BEGIN
												SET @StatusCode=0;
												SET @Response='Something Went Wrong !!!.'
											END
								END
							ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='OptionName '''+ @OptionName +''' Is Already Exists !!!.'									
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Option ID '''+CAST(@OptionId AS VARCHAR)+''' Does Not Exist !!!.'
						END
				END

			IF(@QueryType='Active')		
				BEGIN
					IF EXISTS(SELECT optionId FROM [dbo].[Mstr_MenuOption] WHERE optionId=@OptionId)
						BEGIN
							UPDATE [Mstr_MenuOption] SET activeStatus='A',updatedBy=@UpdatedBy,updatedDate=GETDATE() WHERE optionId=@OptionId
										
								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='OptionName Is Activated Successfully !!!.';
									END
								ELSE
									BEGIN
										SET @StatusCode=0;
										SET @Response='Something Went Wrong !!!.'
									END							
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Option ID '''+CAST(@OptionId AS VARCHAR)+''' Does Not Exist !!!.'
						END
				END

			IF(@QueryType='InActive')		
				BEGIN
					IF EXISTS(SELECT optionId FROM [dbo].[Mstr_MenuOption] WHERE optionId=@OptionId)
						BEGIN
							UPDATE [Mstr_MenuOption] SET activeStatus='D',updatedBy=@UpdatedBy,updatedDate=GETDATE() WHERE optionId=@OptionId
										
								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='OptionName Is InActivated Successfully !!!.';
									END
								ELSE
									BEGIN
										SET @StatusCode=0;
										SET @Response='Something Went Wrong !!!.'
									END							
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Option ID '''+CAST(@OptionId AS VARCHAR)+''' Does Not Exist !!!.'
						END
				END
	END TRY

	BEGIN CATCH
		SET @StatusCode=0;
		SET @Response=(SELECT ERROR_MESSAGE());

		SELECT 
			ERROR_LINE() AS 'ERROR_LINE',
			ERROR_MESSAGE() AS 'ERROR_MESSAGE',
			ERROR_PROCEDURE() AS 'ERROR_PROCEDURE',
			ERROR_NUMBER() AS 'ERROR_NUMBER',
			ERROR_SEVERITY() AS 'ERROR_SEVERITY'
	END CATCH
END

	IF(@StatusCode=1)
		BEGIN
			COMMIT TRAN
		END
	ELSE
		BEGIN
		ROLLBACK TRAN
	END


GO
/****** Object:  StoredProcedure [dbo].[usp_MstrMessageTemplate]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrMessageTemplate]
(
@queryType VARCHAR(100),
@uniqueId int=NULL,
@messageHeader varchar(50)=NULL,
@subject varchar(150)=NULL,
@messageBody varchar(max)=NULL,
@templateType char(1)=NULL,
@peid varchar(30)=NULL,
@tpid varchar(30)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT messageHeader,messageBody,subject,templateType FROM Mstr_MessageTemplates WHERE messageHeader=@messageHeader AND messageBody=@messageBody AND subject = @subject)
					BEGIN
						INSERT INTO Mstr_MessageTemplates (messageHeader,subject,messageBody,templateType,peid,tpid,createdBy,createdDate)
						VALUES(@messageHeader,@subject,@messageBody,@templateType,@peid,@tpid,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='MessageTemplates '+@messageHeader+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='MessageTemplates '+@messageHeader+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT messageHeader,messageBody,subject,templateType FROM Mstr_MessageTemplates WHERE  uniqueId= @uniqueId)
					BEGIN
						IF NOT EXISTS(SELECT messageHeader,messageBody,subject FROM Mstr_MessageTemplates WHERE messageHeader=@messageHeader 
						--AND messageBody=@messageBody AND subject = @subject 
						AND uniqueId!= @uniqueId )
							BEGIN
								UPDATE Mstr_MessageTemplates SET messageHeader=@messageHeader,messageBody=@messageBody,subject = @subject,templateType=@templateType,
								       peid=@peid,tpid = @tpid,updatedBy=@updatedBy,updatedDate=GETDATE() WHERE uniqueId= @uniqueId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='MessageTemplates '+@messageHeader+' Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='MessageTemplates '+@messageHeader+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='MessageTemplates '+@messageHeader+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END


					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrOffer]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Modified by = Imran
--Modified date = 2023-01-06
CREATE PROCEDURE [dbo].[usp_MstrOffer]
(
@queryType VARCHAR(100),
@offerId INT=NULL,
@gymOwnerId INT = Null,
@offerTypePeriod Char=NULL,
@offerHeading Varchar(50)=NULL,
@offerDescription Varchar(50)=NULL,
@offerCode Varchar(20)=NULL,
@offerImageUrl Varchar(Max)=NULL,
@fromDate Date=NULL,
@toDate Date=NULL,
@offerType Char(1)=NULL,
@offerValue Decimal=NULL,
@minAmt Decimal=NULL,
@maxAmt Decimal=NULL,
@noOfTimesPerUser INT=NULL,
@termsAndConditions VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
        SET NOCOUNT ON

        BEGIN TRANSACTION
        BEGIN TRY
                IF(@queryType='insert')
                        BEGIN
									IF NOT EXISTS(SELECT offerId,offerHeading FROM Mstr_Offer WHERE gymOwnerId=@gymOwnerId AND offerHeading=@offerHeading
									AND offerType = @offerType AND offerValue = @offerValue AND minAmt=@minAmt AND maxAmt=@maxAmt AND offerTypePeriod = @offerTypePeriod AND activeStatus = 'A')
											BEGIN
													INSERT INTO Mstr_Offer (offerTypePeriod,gymOwnerId,offerHeading,offerDescription,
													offerCode,offerImageUrl,fromDate,toDate,offerType,offerValue,minAmt,maxAmt,noOfTimesPerUser,termsAndConditions,
													createdBy,createdDate) 
													VALUES(@offerTypePeriod,@gymOwnerId,@offerHeading,@offerDescription,@offerCode,@offerImageUrl,@fromDate,
													 @toDate,@offerType,@offerValue,@minAmt,@maxAmt,@noOfTimesPerUser,@termsAndConditions,@createdBy,GETDATE())
															IF(@@ROWCOUNT>0)
																	BEGIN 
																			SET @StatusCode=1;
																			SET @Response=''+@offerHeading+ ' Offer Is Inserted Successfully !!!' 
																			COMMIT TRANSACTION
																	END
                                                        
											END
									ELSE
											BEGIN
													SET @StatusCode=0;
													SET @Response=''+@offerHeading+ ' Offer Is Already Exists !!!'
													ROLLBACK TRANSACTION
											END
                         END
                        
                        
           ELSE IF(@queryType='update')
                        BEGIN
						IF NOT EXISTS(select * from Tran_Booking where offerId=@offerId and CAST(fromDate  AS DATE) <= CAST(GETDATE() AS DATE)
									 AND CAST(toDate  AS DATE) >= CAST(GETDATE() AS DATE))
                            BEGIN
							IF EXISTS(SELECT offerId,offerHeading FROM Mstr_Offer WHERE gymOwnerId=@gymOwnerId AND offerHeading=@offerHeading 
							AND offerType = @offerType AND offerValue = @offerValue AND minAmt=@minAmt AND maxAmt=@maxAmt AND offerTypePeriod = @offerTypePeriod AND activeStatus = 'A')
                                        BEGIN
                                                IF NOT EXISTS(SELECT offerHeading FROM Mstr_Offer WHERE gymOwnerId=@gymOwnerId AND  offerHeading= @offerHeading 
                                                AND offerId !=@offerId)
                                                        BEGIN
                                                                UPDATE Mstr_Offer SET gymOwnerId=@gymOwnerId, offerTypePeriod=@offerTypePeriod,offerHeading=@offerHeading,offerDescription=@offerDescription,
																offerCode=@offerCode,offerImageUrl=@offerImageUrl,fromDate=@fromDate,toDate=@toDate,offerType=@offerType,offerValue=@offerValue,
																minAmt=@minAmt,maxAmt=@maxAmt,noOfTimesPerUser=@noOfTimesPerUser,termsAndConditions=@termsAndConditions,
                                                                updatedBy=@updatedBy,updatedDate=GETDATE()
                                                                WHERE offerId=@offerId  AND activeStatus='A' AND gymOwnerId=@gymOwnerId

                                                                IF(@@ROWCOUNT>0)
                                                                        BEGIN
                                                                                SET @StatusCode=1;
                                                                                SET @Response=''+@offerHeading+ ' Offer Is Updated Successfully !!!'
                                                                                COMMIT TRANSACTION
                                                                        END
                                                        END
                                                   ELSE
                                                        BEGIN
                                                                SET @StatusCode=0;
                                                                SET @Response=''+@offerHeading+ ' Offer Is Already Exists !!!'
                                                                ROLLBACK TRANSACTION
                                                        END
                                        END
                                ELSE
                                        BEGIN
                                                SET @StatusCode=0;
                                                SET @Response=''+@offerHeading+ ' Offer Is Does Not Exists !!!'
                                                ROLLBACK TRANSACTION
                                        END
							END
							ELSE
							BEGIN
							    SET @StatusCode=0;
								SET @Response='This Offer is Already Used so Deactivate this and Add New offer!!!'
								ROLLBACK TRANSACTION
							END
                                
                        END

                ELSE        IF(@queryType ='active')
                                BEGIN
								  IF EXISTS(SELECT offerId FROM Mstr_Offer WHERE offerId=@offerId AND activeStatus='D')
                                                BEGIN
                                                        UPDATE Mstr_Offer SET activeStatus='A', updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
                                                        offerId=@offerId AND activeStatus='D'

                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response='Offer Activated Successfully !!!'
                                                                        COMMIT TRANSACTION
                                                                END
                                                END
                                        ELSE
                                                BEGIN
                                                        SET @StatusCode=0;
                                                        SET @Response='Offer Does Not Exists !!!'
                                                        ROLLBACK TRANSACTION
                                                END								  
                                END

                ELSE        IF(@queryType ='inActive')
                                BEGIN
								 IF EXISTS(SELECT offerId FROM Mstr_branchOffer WHERE offerId=@offerId and activeStatus='D')
								 BEGIN
                                        IF EXISTS(SELECT offerId FROM Mstr_Offer WHERE offerId=@offerId AND activeStatus='A')
                                                BEGIN
                                                        UPDATE Mstr_Offer SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
                                                        offerId=@offerId AND activeStatus='A'

                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response=' Offer InActivated Successfully !!!'
                                                                        COMMIT TRANSACTION
                                                                END
                                                END
                                        ELSE
                                                BEGIN
                                                        SET @StatusCode=0;
                                                        SET @Response=' Offer Does Not Exists !!!'
                                                        ROLLBACK TRANSACTION
                                                END
												 END
                                 ELSE IF NOT EXISTS(SELECT offerId FROM Mstr_branchOffer WHERE offerId=@offerId)
								 BEGIN
                                        IF EXISTS(SELECT offerId FROM Mstr_Offer WHERE offerId=@offerId AND activeStatus='A')
                                                BEGIN
                                                        UPDATE Mstr_Offer SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
                                                        offerId=@offerId AND activeStatus='A'

                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response=' Offer InActivated Successfully !!!'
                                                                        COMMIT TRANSACTION
                                                                END
                                                END
                                        ELSE
                                                BEGIN
                                                        SET @StatusCode=0;
                                                        SET @Response=' Offer Does Not Exists !!!'
                                                        ROLLBACK TRANSACTION
                                                END
												 END
								 ELSE
								 BEGIN
								                SET @StatusCode=0;
                                                SET @Response='InActivate This offer In Offer Mapping !!!'
                                                ROLLBACK TRANSACTION
								 END
                                END

                                        ELSE
                        BEGIN
                                SET @StatusCode=0;
                                SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
                                ROLLBACK TRANSACTION
                        END
        END TRY
        BEGIN CATCH 
                        SET @StatusCode=0;
                        SET @Response=(SELECT ERROR_MESSAGE())
                        ROLLBACK TRANSACTION
        END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrOfferMapping]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Modified By Abhinaya K
--Modified Date  06-Jan-2023
CREATE PROCEDURE [dbo].[usp_MstrOfferMapping]
(
@queryType NVARCHAR(100),
@gymOwnerId INT=0,
@branchId INT= 0,
@offerId INT= 0,
@offerMappingId INT= 0,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY

		IF(@queryType='insert')
			BEGIN
				IF NOT EXISTS(SELECT * FROM Mstr_BranchOffer WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId  AND offerId=@offerId)
					BEGIN
					      
						INSERT INTO Mstr_BranchOffer(gymOwnerId,branchId,offerId,activeStatus,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchId,@offerId,'A',@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Mapping Details Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Offer Mapping Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT * FROM Mstr_BranchOffer WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND offerId=@offerId AND activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_BranchOffer WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND offerId=@offerId AND offerMappingId !=@offerMappingId  )
						BEGIN
							
							UPDATE Mstr_BranchOffer SET gymOwnerId=gymOwnerId, branchId=branchId,offerId=offerId,updatedBy=@updatedBy,updatedDate=GETDATE()
							WHERE offerMappingId=@offerMappingId AND activeStatus='A'
								IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Mapping Details Updated Successfully !!!'
									COMMIT TRANSACTION
								END
								
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Offer Mapping Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Offer Mapping Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_BranchOffer WHERE offerMappingId=@offerMappingId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_BranchOffer SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							  offerMappingId=@offerMappingId  AND activeStatus='D'

								IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Mapping Details Activated Successfully !!!'
									COMMIT TRANSACTION
								END
								
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Offer Mapping Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_BranchOffer WHERE  offerMappingId=@offerMappingId  AND activeStatus='A')
						BEGIN
							UPDATE Mstr_BranchOffer SET activeStatus='D',updatedBy=@updatedBy, updatedDate=GETDATE() WHERE 
							   offerMappingId=@offerMappingId AND activeStatus='A'
								IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Mapping Details InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Offer Mapping Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


SELECT * FROM Mstr_BranchOffer
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrOfferRule]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrOfferRule]
(
@queryType VARCHAR(100),
@offerRuleId INT=NULL,
@offerId INT=NULL,
@offerRule VARCHAR(Max)=NULL,
@ruleType INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT offerRuleId,offerId FROM Mstr_OfferRule WHERE  offerId=@offerId)
					BEGIN
						INSERT INTO Mstr_OfferRule (offerId,offerRule,ruleType,createdBy,createdDate) 
						VALUES(@offerId,@offerRule,@ruleType,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Offer Rule Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Offer Rule Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT offerRuleId,offerId FROM Mstr_OfferRule WHERE offerId=@offerId AND offerRuleId= @offerRuleId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT offerRuleId,offerId FROM Mstr_OfferRule WHERE  offerId= @offerId 
						AND offerRuleId !=@offerRuleId)
							BEGIN
								UPDATE Mstr_OfferRule SET offerId=@offerId,offerRule=@offerRule,ruleType=@ruleType,							
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE offerId=@offerId AND offerRuleId= @offerRuleId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Offer Rule Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Offer Rule Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Offer Rule Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT offerRuleId FROM Mstr_OfferRule WHERE offerRuleId=@offerRuleId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_OfferRule SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							offerRuleId=@offerRuleId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Rule Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Offer Rule Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT offerRuleId FROM Mstr_OfferRule WHERE offerRuleId=@offerRuleId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_OfferRule SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							offerRuleId=@offerRuleId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Offer Rule InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Offer Rule Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrOwner]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrOwner]
(
@queryType NVARCHAR(100),
@gymOwnerId INT=0,
@gymName NVARCHAR(50)= NULL,
@shortName NVARCHAR(50)=NULL,
@gymOwnerName NVARCHAR(50)=NULL,
@mobileNumber NVARCHAR(10)=NULL,
@mailId NVARCHAR(50)=NULL,
@passWord NVARCHAR(20)=NULL,
@logoUrl NVARCHAR(200)=NULL,
@websiteUrl NVARCHAR(150)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @userId INT
	DECLARE @OwnerRoleId INT=0
	BEGIN TRANSACTION
	BEGIN TRY
	SET @OwnerRoleId=(SELECT configId FROm Mstr_Configuration WHERE configName='GymOwner')
		IF(@queryType='insert')
			BEGIN
				IF EXISTS(SELECT userId FROM Mstr_UserLogin WHERE mobileNo=@mobileNumber)
					BEGIN
						SET @StatusCode=0;
					    SET @Response='MobileNo "'+ @mobileNumber +'" Is Already Exist !!!'
						ROLLBACK TRANSACTION
						RETURN;
					END


				IF NOT EXISTS(SELECT * FROM Mstr_GymOwner AS Owner INNER JOIN Mstr_UserLogin AS UserLogin  ON Owner.gymOwnerId=UserLogin.userId  
				WHERE  UserLogin.mobileNo=@mobileNumber)
					BEGIN
					       INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,activeStatus,createdBy,createdDate) 
						   VALUES(@mobileNumber,@mailId,@passWord,@OwnerRoleId,'A',@createdBy,GETDATE())
						  IF(@@ROWCOUNT>0)
								BEGIN
								    SET @userId= (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mobileNo=@mobileNumber)
									INSERT INTO Mstr_GymOwner(gymOwnerId,gymName,gymOwnerName,shortName ,logoUrl,websiteUrl,activeStatus,createdBy,createdDate) 
									VALUES(@userId,@gymName,@gymOwnerName,@shortName,@logoUrl,@websiteUrl,'A',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
											BEGIN
												SET @StatusCode=1;
												SET @Response='Owner Details Is Inserted Successfully !!!'
												COMMIT TRANSACTION
											END
							  END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
					    SET @Response='MobileNo "'+ @mobileNumber +'" Is Already Exist !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT userId FROM Mstr_UserLogin WHERE mobileNo=@mobileNumber AND userId <> @userId)
				BEGIN
					SET @StatusCode=0;
					SET @Response='MobileNo "'+ @mobileNumber +'" Is Already Exist !!!'
					ROLLBACK TRANSACTION
					RETURN;
				END

			IF EXISTS(SELECT * FROM Mstr_GymOwner AS Owner INNER JOIN Mstr_UserLogin AS UserLogin  ON Owner.gymOwnerId=UserLogin.userId 
				WHERE  UserLogin.mobileNo=@mobileNumber)
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_GymOwner AS Owner INNER JOIN Mstr_UserLogin AS UserLogin  ON Owner.gymOwnerId=UserLogin.userId 
				        WHERE Owner.gymName=@gymName AND UserLogin.mobileNo=@mobileNumber  AND Owner.shortName=@shortName AND Owner.gymOwnerId!=@gymOwnerId )
						BEGIN
							UPDATE Mstr_UserLogin SET mobileNo=@mobileNumber,mailId=@mailId,passWord=@passWord,updatedBy=@updatedBy,updatedDate=GETDATE()
							WHERE userId=@gymOwnerId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
								    UPDATE Mstr_GymOwner SET gymOwnerName=@gymOwnerName, gymName=@gymName,shortName=@shortName,logoUrl=@logoUrl,
									websiteUrl=@websiteUrl,updatedBy=@updatedBy,updatedDate=GETDATE()
									WHERE gymOwnerId=@gymOwnerId AND activeStatus='A'
										IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='Owner Details  Updated Successfully !!!'
											COMMIT TRANSACTION
										END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Owner Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='MobileNo "'+ @mobileNumber +'" Is Already Exist !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_GymOwner WHERE gymOwnerId=@gymOwnerId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_GymOwner SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							 gymOwnerId=@gymOwnerId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@gymOwnerId
									 AND activeStatus='D'
									IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Owner Details Activated Successfully !!!'
										COMMIT TRANSACTION
									END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Owner Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_GymOwner WHERE  gymOwnerId=@gymOwnerId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_GymOwner SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							 gymOwnerId=@gymOwnerId AND activeStatus='A'

						IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@gymOwnerId
									 AND activeStatus='A'
									IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Owner Details InActivated Successfully !!!'
										COMMIT TRANSACTION
									END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Owner Details Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSendAndVerifyOtp]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- ==================================================
--- Modified By : Imran
--- Modified Date : 2023-03-04
--- EXEC  usp_MstrSendAndVerifyOtp 'verifyOtp','3145','8778212106'
--- ==================================================

CREATE PROCEDURE [dbo].[usp_MstrSendAndVerifyOtp]
(
	@queryType NVARCHAR(100),
	@otp  INT=0,
	@Userid INT=NULL,
	@mobileNo NVARCHAR(10)=NULL,
	@link NVARCHAR(500)=NULL,
	@StatusCode INT=0 OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @OrgiOTP INT
	BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @SMSMessage NVARCHAR(MAX)
	  IF(@queryType='sendSignInOtp')
			BEGIN
					SELECT @otp = ROUND(((9999 - 1111 -1) * RAND() + 1111), 0)
					IF(LEN(@mobileNo) > 9)
					BEGIN
						 INSERT INTO  Mstr_OtpLogDetails (otpType,mobileNo,otp,createdDate) VALUES('SignIn',@mobileNo,@otp,GETDATE())
						 IF(@@ROWCOUNT>0)
								BEGIN
									SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST(@otp AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
									
									SET @StatusCode=1;
									SET @Response=CAST(@otp AS VARCHAR(20))+' ~ SignIn OTP Is Sent Successfully !!!'
									
									
								END
								ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='OTP Already Exists !!!'
									
								END
                   END
				   ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Enter 10 Digit MobileNo !!!'
									
								END
		    
			END
	  ELSE IF(@queryType='sendForgotOtp')
			BEGIN
					SELECT @otp = ROUND(((9999 - 1111 -1) * RAND() + 1111), 0)
					IF(LEN(@mobileNo) > 9)
					BEGIN
						 INSERT INTO  Mstr_OtpLogDetails (otpType,mobileNo,otp,createdDate) VALUES('ForgotPassword',@mobileNo,@otp,GETDATE())
						 IF(@@ROWCOUNT>0)
								BEGIN
									SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST(@otp AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
									
									SET @StatusCode=1;
									SET @Response=CAST(@otp AS VARCHAR(20))+' ~  Forgot OTP Is Sent Successfully !!!'
									
									
								END
								ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='OTP Already Exists !!!'
									
								END
                   END
				   ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Enter 10 Digit MobileNo !!!'
									
								END
		    
			END

	  ELSE  IF(@queryType='verifyOtp')
	 		BEGIN
			      IF(LEN(@mobileNo) > 9)
					BEGIN
						  SET @OrgiOTP=(SELECT TOP 1 otp FROM  Mstr_OtpLogDetails  WHERE mobileNo=@mobileNo ORDER BY createdDate Desc )
						  IF  (CAST(@OrgiOTP AS INT) = CAST(@otp AS INT))
						  BEGIN
								UPDATE Mstr_OtpLogDetails SET VerifiedStatus='Y'  WHERE mobileNo=@mobileNo
								 IF(@@ROWCOUNT>0)
									BEGIN									
										SET @StatusCode=1;
										SET @Response='OTP Verified Successfully !!!'
										
								  END
								ELSE
								  BEGIN
									  SET @StatusCode=0;
									  SET @Response='Enter Valid OTP !!!'
									  
								  END
						 END
						 ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Enter Valid OTP !!!'
									
								END
				 END
				ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Enter 10 Digit MobileNo !!!'
								
							END
			END
	  ELSE  IF(@queryType='SendSMSAndMailForPlan')
	 		BEGIN
				     SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST('3443' AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
					 -- EXECUTE usp_MstrSendSMSServiceMessage @mobileNo, @SMSMessage
					  SET @StatusCode=1;
					  SET @Response='Mail / Sms Sent Successfully !!!!'
				 END

	  ELSE  IF(@queryType='SendSMSAndMailForFollowUp')
	 		BEGIN
				        SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST('3443' AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
					 -- EXECUTE usp_MstrSendSMSServiceMessage @mobileNo, @SMSMessage
					    SET @StatusCode=1;
					  SET @Response='Mail / Sms Sent Successfully !!!!'
				 END
 
      ELSE  IF(@queryType='SendSMSforbookingclasses')
	 		BEGIN
				        SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST('3441' AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
					
					    SET @StatusCode=1;
					  SET @Response='Mail / Sms Sent Successfully !!!!'
				 END
	  ELSE  IF(@queryType='SendSMSforbookingsubscription')
	 		BEGIN
				        SET @SMSMessage = 'Welcome to TTDC and thanks for registering with us. ' + CAST('3442' AS VARCHAR(10)) + ' is OTP to complete your registration. OTP is secret, do not share it with anyone.&peid=1201159447435425122&tpid=1707161702075327606'
				
					    SET @StatusCode=1;
					  SET @Response='Mail / Sms Sent Successfully !!!!'
				 END
		

		
		IF(@StatusCode = 1)
		BEGIN
				SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			  -- IF(@queryType !='verifyOtp')
				 --BEGIN
					-- EXECUTE usp_MstrSendSMSServiceMessage @mobileNo, @SMSMessage
				 -- END

				   IF(@queryType ='SendSMSforbookingclasses' or @queryType ='SendSMSforbookingsubscription')
				 BEGIN
					
					DECLARE @TRIMSMSMessage NVARCHAR(MAX)
					SET @TRIMSMSMessage=(SELECT top 1 value FROM STRING_SPLIT(@SMSMessage, '&'))
					EXECUTE usp_MstrUserNotification 'Insert', '',@Userid, @TRIMSMSMessage


				  END
			  COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			  SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			  ROLLBACK TRANSACTION
		END
			
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			
	END CATCH
	
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSendSMSServiceMessage]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_MstrSendSMSServiceMessage]
(
	@MobileNo NVARCHAR(50),
	@Message NVARCHAR(MAX)
)
AS
BEGIN

		--GO 
		--RECONFIGURE; 
		--GO 
		--sp_configure 'Ole Automation Procedures', 1 
		--GO 
		--RECONFIGURE; 
		--GO 
		--sp_configure 'show advanced options', 1 
		--GO 
		--RECONFIGURE;
		

	   Declare @iReq int,@hr int 
	   Declare @sUrl as varchar(500) 
	   DECLARE @errorSource VARCHAR(8000)
	   DECLARE @errorDescription VARCHAR(8000) 
	   DECLARE @sResponse varchar(1000)

	   -- Create Object for XMLHTTP 
	   EXEC @hr = sp_OACreate 'Microsoft.XMLHTTP', @iReq OUT 

	   if @hr <> 0 
		  Raiserror('sp_OACreate Microsoft.XMLHTTP FAILED!', 16, 1) 

	   --sender=PREMTX

	   set @sUrl='http://smsstreet.in/websms/sendsms.aspx?userid=prematix&password=matixpre&sender=TTDCIN&mobileno=#MobNo#&msg=#Msg#'

	   set @sUrl=REPLACE(@sUrl,'#MobNo#', @MobileNo) 
	   set @sUrl=REPLACE(@sUrl,'#Msg#', @Message) 

	   -- sms code start 
	   EXEC @hr = sp_OAMethod @iReq, 'Open', NULL, 'GET', @sUrl, true 	  

	   if @hr <> 0 
		  Raiserror('sp_OAMethod Open FAILED!', 16, 1) 

	   EXEC @hr = sp_OAMethod @iReq, 'send' 	 

	   if @hr <> 0 
	   Begin 
		   EXEC sp_OAGetErrorInfo @iReq, @errorSource OUTPUT, @errorDescription OUTPUT

		   SELECT [Error Source] = @errorSource, [Description] = @errorDescription

		   Raiserror('sp_OAMethod Send FAILED!', 16, 1) 
	   end 
	else 
	Begin
		EXEC @hr = sp_OAGetProperty @iReq, 'responseText', @sResponse OUT 
	end
	
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrShift]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Modified by = Abhinaya
--Modified date = 2023-01-06
CREATE PROCEDURE [dbo].[usp_MstrShift]

(
@queryType VARCHAR(100),
@shiftId INT=NULL,
@branchId INT=NULL,
@shiftName NVARCHAR(100)=NULL,
@startTime time(7)=NULL,
@endTime time(7)=NULL,
@breakEndTime time(7)=NULL,
@breakStartTime time(7)=NULL,
@gracePeriod INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT StartTime,EndTime FROM Mstr_Shift WHERE  branchId=@branchId AND ShiftName=@ShiftName )
					BEGIN
						INSERT INTO Mstr_Shift (branchId,ShiftName,StartTime,EndTime,BreakStartTime,BreakEndTime,GracePeriod,createdBy,createdDate)
						VALUES(@branchId,@ShiftName,@StartTime,@EndTime,@BreakStartTime,@BreakEndTime,@GracePeriod,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='ShiftName '+@ShiftName+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ShiftName '+@ShiftName+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT ShiftName,StartTime,EndTime FROM Mstr_Shift WHERE  ShiftId=@ShiftId  AND branchId=@branchId AND  activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT ShiftName,StartTime,EndTime FROM Mstr_Shift WHERE  ShiftId !=@ShiftId  )
							BEGIN
								UPDATE Mstr_Shift SET StartTime=@StartTime,EndTime = @EndTime,
								BreakStartTime=@BreakStartTime,BreakEndTime=@BreakEndTime,GracePeriod = @GracePeriod,updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE ShiftId=@ShiftId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='ShiftName '+@ShiftName+' Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='ShiftName '+@ShiftName+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='ShiftName '+@ShiftName+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT ShiftId FROM Mstr_Shift WHERE ShiftId=@ShiftId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_Shift SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							ShiftId=@ShiftId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='ShiftDetails Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='ShiftDetails Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT ShiftId FROM Mstr_Shift WHERE ShiftId=@ShiftId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_Shift SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							ShiftId=@ShiftId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='ShiftDetails InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='ShiftDetails  Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSignUp]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_MstrSignUp]
(
@queryType NVARCHAR(100),
@userId  INT=0,
@mobileNo NVARCHAR(10)=NULL,
@mailId NVARCHAR(50)=NULL,
@passWord NVARCHAR(100)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
		DECLARE @userIds INT
		DECLARE @roleIds INT
		
	BEGIN TRANSACTION
	BEGIN TRY
	SET @roleIds=(SELECT configId FROm Mstr_Configuration WHERE configName='User')
		IF(@queryType='signUp')
			BEGIN
			IF(@mobileNo IS NOT NULL)
			BEGIN
				IF(LEN(@mobileNo) !=10)
					BEGIN
						SET @StatusCode=0;
						SET @Response='Invalid Mobile Number !!!' 
						ROLLBACK TRANSACTION
						RETURN;
					END

			IF NOT EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE mobileNo=@mobileNo)
					BEGIN
					 INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,activeStatus) 
						   VALUES(@mobileNo,@mailId,@passWord,@roleIds,'A')
						   	IF(@@ROWCOUNT>0)
								BEGIN
								 SET @userId= (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mobileNo=@mobileNo)
									INSERT INTO Mstr_User(userId,activeStatus,createdBy,createdDate) 
									VALUES(@userId,'A',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
											BEGIN
											   UPDATE Mstr_UserLogin SET createdBy=@userId,createdDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
											      IF(@@ROWCOUNT>0)
											      BEGIN
												   UPDATE Mstr_User SET createdBy=@userId,createdDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
												   IF(@@ROWCOUNT>0)
													  BEGIN
														SET @StatusCode=1;
														SET @Response='User Details Is Inserted Successfully !!!'
														COMMIT TRANSACTION
													  END
												  END
										END
							  END
					END
				ELSE IF EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE mobileNo=@mobileNo and activeStatus='D')
				BEGIN
						SET @StatusCode=0;
						SET @Response='User is  Blocked !!!'
						ROLLBACK TRANSACTION
					END
					ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='User Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
			ELSE IF(@mailId IS NOT NULL)
			BEGIN
			 IF NOT EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE  mailId=@mailId)
					BEGIN
					 INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,activeStatus) 
						   VALUES(@mobileNo,@mailId,@passWord,@roleIds,'A')
						   	IF(@@ROWCOUNT>0)
								BEGIN
								 SET @userId= (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mailId=@mailId)
									INSERT INTO Mstr_User(userId,activeStatus,createdBy,createdDate) 
									VALUES(@userId,'A',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
											BEGIN
											   UPDATE Mstr_UserLogin SET createdBy=@userId,createdDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
											      IF(@@ROWCOUNT>0)
											      BEGIN
												   UPDATE Mstr_User SET createdBy=@userId,createdDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
												   IF(@@ROWCOUNT>0)
													  BEGIN
														SET @StatusCode=1;
														SET @Response='User Details Is Inserted Successfully !!!'
														COMMIT TRANSACTION
													  END
												  END
										END
							  END
					END
			ELSE IF EXISTS(SELECT * FROM  Mstr_UserLogin  WHERE mailId=@mailId and activeStatus='D')
				BEGIN
						SET @StatusCode=0;
						SET @Response='User is  Blocked !!!'
						ROLLBACK TRANSACTION
					END
					ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='User Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
				
			END
		ELSE
		BEGIN
			SET @StatusCode=0;
			SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
			--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
		END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSignupUsingExcel]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_MstrSignupUsingExcel]
(
@roleId INT,
@createdBy INT,
@gymOwnerId INT,
@branchId INT,

--Mstr_UserLogin
@mobileNo NVARCHAR(20)=NULL,
@mailId NVARCHAR(50)=NULL,
@password NVARCHAR(50)=NULL,

--Mstr_User
@firstName NVARCHAR(50)=NULL,
@lastName NVARCHAR(50)=NULL,
@dob DATE=NULL,
@gender CHAR(1)=NULL,
@maritalStatus CHAR(1)=NULL,
@addressLine1 NVARCHAR(100)=NULL,
@addressLine2 NVARCHAR(100)=NULL,
@zipcode INT=0,
@city NVARCHAR(50)=NULL,
@district NVARCHAR(50)=NULL,
@state NVARCHAR(50)=NULL,

--Mstr_UserInBodyTest
@weight DECIMAL(6,2),
@height DECIMAL(6,2),
@fatPercentage INT,
@WorkOutStatus NVARCHAR(50),
@WorkOutValue DECIMAL(6,2)=0,
@age INT,
@BMR DECIMAL(6,2),
@BMI DECIMAL(6,2),
@TDEE INT,
@date DATE,

@StatusCode INT=0 OUT,
@Response VARCHAR(500)=NULL OUT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY

		DECLARE @UserId INT;
		IF NOT EXISTS(SELECT A.userId FROM Mstr_UserLogin AS A INNER JOIN Mstr_User AS B ON A.userId=B.userId WHERE A.mobileNo=@mobileNo AND B.branchId=@branchId AND B.gymOwnerId=@gymOwnerId)
			BEGIN
				INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,createdBy,activeStatus,createdDate)
									VALUES(@mobileNo,@mailId,@password,@roleId,@createdBy,'A',GETDATE())

				IF(@@ROWCOUNT>0)
					BEGIN
						SET @UserId=(SELECT TOP 1 userId FROM Mstr_UserLogin AS A ORDER BY createdDate DESC);

						INSERT INTO Mstr_User(userId,branchId,gymOwnerId,firstName,lastName,dob,gender,maritalStatus,addressLine1,addressLine2,zipcode,city,district,state,activeStatus,createdBy)
									   VALUES(@UserId,@branchId,@gymOwnerId,@firstName,@lastName,@dob,@gender,@maritalStatus,@addressLine1,@addressLine2,@zipcode,@city,@district,@state,'A',@createdBy)

						IF(@@ROWCOUNT>0)
							BEGIN
								INSERT INTO Mstr_UserInBodyTest(userId,weight,height,fatPercentage,WorkOutStatus,WorkOutValue,age,BMR,BMI,TDEE,date,createdBy)
														 VALUES(@UserId,@weight,@height,@fatPercentage,@WorkOutStatus,@WorkOutValue,@age,@BMR,@BMI,@TDEE,@Date,@createdBy)

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Users SignedUp Successfully !!!.';
									END
								ELSE
									BEGIN
										SET @StatusCode=0;
										SET @Response='Something went wrong !!!.';
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Something went wrong !!!.';
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Something went wrong !!!.';
					END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response=@mobileNo+', User Already Exists !!!.';
			END

	END TRY
	BEGIN CATCH
		SET @StatusCode=0;
		SET @Response=(SELECT ERROR_MESSAGE());

		 SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_STATE() AS ErrorState,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

	IF(@StatusCode =1)
		BEGIN
			COMMIT TRAN
		END
	ELSE
		BEGIN
			ROLLBACK TRAN
		END
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSubscriptionBenefits]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrSubscriptionBenefits]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@subscriptionPlanId INT=NULL,
@description NVARCHAR(Max)=NULL,
@imageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT uniqueId,subscriptionPlanId FROM Mstr_SubscriptionBenefits WHERE  subscriptionPlanId=@subscriptionPlanId AND  description=@description)
					BEGIN
						INSERT INTO Mstr_SubscriptionBenefits (subscriptionPlanId,imageUrl,description,createdBy,createdDate) 
						VALUES(@subscriptionPlanId,@imageUrl,@description,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Subscription Benefits Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Subscription Benefits Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT subscriptionPlanId,uniqueId FROM Mstr_SubscriptionBenefits WHERE subscriptionPlanId=@subscriptionPlanId  AND uniqueId= @uniqueId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT uniqueId,subscriptionPlanId FROM Mstr_SubscriptionBenefits WHERE  subscriptionPlanId= @subscriptionPlanId  AND  description=@description
						AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_SubscriptionBenefits SET imageUrl=@imageUrl,description=@description,							
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE uniqueId=@uniqueId AND subscriptionPlanId= @subscriptionPlanId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Subscription Benefits Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Subscription Benefits Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Subscription Benefits Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_SubscriptionBenefits WHERE uniqueId=@uniqueId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_SubscriptionBenefits SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Subscription Benefits Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Subscription Benefits Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_SubscriptionBenefits WHERE uniqueId=@uniqueId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_SubscriptionBenefits SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Subscription Benefits InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Subscription Benefits Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrSubscriptionPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Modified by = Abhinaya
--Modified date = 2023-01-06
CREATE PROCEDURE [dbo].[usp_MstrSubscriptionPlan]
(
@queryType VARCHAR(100),
@subscriptionPlanId INT=0,
@gymOwnerId INT = 0,
@branchId INT= 0,
@packageName NVARCHAR(50)=NULL,
@description NVARCHAR(Max)=NULL,
@imageUrl VARCHAR(Max)=NULL,
@noOfDays INT=0,
@tax decimal(9, 2)=NULL,
@taxId INT =0,
@netAmount decimal(9, 2)=NULL,
@amount decimal(9, 2) = NUll,
@credits INT=0,
@isTrialAvailable CHAR(1)=NULL,
@noOfTrialDays INT=0,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @cgstTax decimal(9, 2)=0
    DECLARE @sgstTax decimal(9, 2)=0
    SET	@cgstTax =@tax/2
	SET @sgstTax =@tax/2

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT subscriptionPlanId,gymOwnerId,branchId,packageName FROM Mstr_SubscriptionPlan WHERE 
				  branchId=@branchId AND gymOwnerId=@gymOwnerId AND noOfDays =@noOfDays)
					BEGIN
						INSERT INTO Mstr_SubscriptionPlan (gymOwnerId,branchId,packageName,description,imageUrl,noOfDays,tax,taxId,amount,cgstTax,
						sgstTax,netAmount,credits,isTrialAvailable,noOfTrialDays,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchId,@packageName,@description,@imageUrl,@noOfDays,@tax,@taxId,@amount,@cgstTax,
						@sgstTax,@netAmount,@credits,@isTrialAvailable,@noOfTrialDays,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Subscription Plan '+@packageName+' Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Subscription Plan '+@packageName+' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT subscriptionPlanId,gymOwnerId,branchId FROM Mstr_SubscriptionPlan WHERE subscriptionPlanId=@subscriptionPlanId 
				AND noOfDays =@noOfDays AND gymOwnerId=@gymOwnerId 
				AND branchId= @branchId  AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT subscriptionPlanId,gymOwnerId,branchId ,packageName FROM Mstr_SubscriptionPlan WHERE gymOwnerId=@gymOwnerId AND packageName =@packageName AND
						branchId= @branchId AND subscriptionPlanId !=@subscriptionPlanId AND noOfDays =@noOfDays)
							BEGIN
								UPDATE Mstr_SubscriptionPlan SET packageName=@packageName,description=@description,imageUrl=@imageUrl,
								noOfDays =@noOfDays,tax=@tax,taxId=@taxId,amount =@amount,cgstTax=@cgstTax,sgstTax=@sgstTax,netAmount=@netAmount,credits=@credits,isTrialAvailable=@isTrialAvailable,noOfTrialDays=@noOfTrialDays,
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE subscriptionPlanId=@subscriptionPlanId AND branchId= @branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Subscription Plan Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Subscription Plan '+@packageName+' Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Subscription Plan '+@packageName+' Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT subscriptionPlanId FROM Mstr_SubscriptionPlan WHERE subscriptionPlanId=@subscriptionPlanId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_SubscriptionPlan SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							subscriptionPlanId=@subscriptionPlanId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Subscription Plan Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Subscription Plan Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT subscriptionPlanId FROM Mstr_SubscriptionPlan WHERE subscriptionPlanId=@subscriptionPlanId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_SubscriptionPlan SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							subscriptionPlanId=@subscriptionPlanId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Subscription Plan InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Subscription Plan Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrTax]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC usp_MstrTax 'insert','','','1','5','1','CGST',0,'','','','1','',''
--- ==================================================
--- Modified BY Abhinaya K
--- Modified Date 09-Jan-2023
--- ==================================================

CREATE PROCEDURE [dbo].[usp_MstrTax]
(
	@queryType NVARCHAR(25),
	@taxId INT=NULL,
	@uniqueId  INT=NULL,
	@gymOwnerId INT=NULL,
	@branchId INT=NULL,
	@serviceName  NVARCHAR(50)= NULL , 
	@taxDescription NVARCHAR(50)= NULL ,
	@taxPercentage DECIMAL(18,2)=NULL ,
	@effectiveFrom DATE= NULL ,
	@effectiveTill DATE = NULL ,
	@createdBy INT=NULL,
	@updatedBy INT=NULL,
	@StatusCode INT=NULL OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	
	BEGIN TRY
		IF(@queryType='add')
			BEGIN
				IF NOT EXISTS(SELECT * FROM Mstr_Tax WHERE serviceName = @serviceName AND taxDescription = @taxDescription AND taxId='0' AND activeStatus='T' AND
				 branchId=@branchId AND gymOwnerId=@gymOwnerId)
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_Tax WHERE serviceName = @serviceName AND taxDescription = @taxDescription 
					AND taxPercentage=@taxPercentage AND activeStatus='T' AND branchId=@branchId AND gymOwnerId=@gymOwnerId)
					BEGIN
						INSERT INTO Mstr_Tax(gymOwnerId,branchId,taxId,serviceName, taxDescription, taxPercentage, effectiveFrom,activeStatus, createdby, createdDate)
						VALUES(@gymOwnerId,@branchId,'0',@serviceName, @taxDescription, @taxPercentage,@effectiveFrom,'T', @createdby, GETDATE())

						IF @@ROWCOUNT > 0
						BEGIN
						   SET @StatusCode=1;
							SET @Response ='Tax Details Added Successfully.'
							COMMIT TRANSACTION
						END	
					END
					ELSE 
					BEGIN
						SET @StatusCode=0;
						SET @Response ='Tax Details Already Added.'
						ROLLBACK TRANSACTION
					END
					
				END
				ELSE
				BEGIN
			
					SET @StatusCode=0;
					SET @Response ='Tax Details Already Added.'
					ROLLBACK TRANSACTION
			
				END
       END

	   ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT * FROM Mstr_Tax WHERE serviceName = @serviceName AND uniqueId = @uniqueId AND branchId=@branchId
			AND gymOwnerId=@gymOwnerId AND activeStatus='T')
				BEGIN
				    UPDATE Mstr_Tax SET taxDescription = @taxDescription,effectiveFrom=@effectiveFrom, taxPercentage=@taxPercentage WHERE serviceName = @serviceName AND uniqueId = @uniqueId
					IF @@ROWCOUNT > 0
					BEGIN
						SET @StatusCode = 1
						SET @Response='Tax Details Updated Successfully !!!'
						COMMIT TRANSACTION
					END	
				END	
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Tax Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='delete')
				BEGIN
					IF EXISTS(SELECT * FROM Mstr_Tax WHERE  uniqueId = @uniqueId AND activeStatus='T')
						BEGIN
							DELETE FROM Mstr_Tax WHERE  uniqueId = @uniqueId AND activeStatus='T'
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Tax Details Deleted Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Tax Details Is Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='insert')
			BEGIN
			  DECLARE @activeStatus CHAR(1);
			 
			     DECLARE tax_Cursor CURSOR LOCAL  FOR
				  SELECT uniqueId,serviceName,taxDescription,effectiveFrom,activeStatus FROM Mstr_Tax WHERE serviceName=@serviceName
				  AND branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='T'
				   OPEN tax_Cursor
				    FETCH NEXT FROM tax_Cursor  INTO @uniqueId,@serviceName,@taxDescription,@effectiveFrom,@activeStatus
				      WHILE @@FETCH_STATUS = 0
                        BEGIN
							IF EXISTS(SELECT * FROM Mstr_Tax WHERE taxId='0' AND activeStatus='T' AND uniqueId=@uniqueId)
								BEGIN
								
									DECLARE @iUid INT
									DECLARE @ieffectiveFrom DATE
									SET @iUid=(SELECT ISNULL(MIN(uniqueId),0)  FROM Mstr_Tax WHERE serviceName=@serviceName AND taxDescription=@taxDescription AND activeStatus='A' AND effectiveTill IS NULL 
									AND effectiveTill IS NULL AND branchId=@branchId AND gymOwnerId=@gymOwnerId)
									SET @ieffectiveFrom=(SELECT effectiveFrom  FROM Mstr_Tax WHERE serviceName=@serviceName AND taxDescription=@taxDescription AND activeStatus='A'
									AND effectiveTill IS NULL AND branchId=@branchId AND gymOwnerId=@gymOwnerId)
									IF(@iUid>0)
										BEGIN
											DECLARE @Service INT
											SET @Service = (SELECT DISTINCT(serviceName) FROM Mstr_Tax WHERE serviceName=@serviceName AND taxDescription=@taxDescription AND activeStatus='A'
											AND effectiveTill IS NULL AND effectiveTill IS NULL AND branchId=@branchId AND gymOwnerId=@gymOwnerId)
												DECLARE @Dcount INT 
												SET @Dcount=0
												SET @Dcount=(SELECT Datediff(day, @ieffectiveFrom, @effectiveFrom) FROM Mstr_Tax WHERE serviceName=@serviceName 
												AND taxDescription=@taxDescription AND activeStatus='A' AND effectiveTill IS NULL AND effectiveTill IS NULL AND branchId=@branchId AND gymOwnerId=@gymOwnerId)
													IF(@Dcount>0)
													BEGIN
											 
														UPDATE Mstr_Tax SET effectiveTill=DATEADD(D,-1,@effectiveFrom),updatedBy = @updatedBy, updatedDate = GETDATE(), activeStatus = 'D'
														WHERE uniqueId=@iUid

															IF @@ROWCOUNT > 0
															BEGIN
												 
																UPDATE Mstr_Tax SET effectiveFrom = @effectiveFrom, activeStatus = 'A', updatedBy = @updatedBy, updatedDate = GETDATE() 
																WHERE uniqueId=@uniqueId
																		IF @@ROWCOUNT > 0
																		BEGIN
													  
																			SET @StatusCode = 1
																			SET @Response = 'Tax Details Inserted Successfully.'
														
																		END
																		ELSE
																		BEGIN
																			SET @StatusCode =0
																			SET @Response ='Insert Error'
													
																		END
															END
															ELSE
															BEGIN
																SET @StatusCode =0
																SET @Response ='Effective Till Updation Error'
													
															END
													END
													ELSE
													BEGIN
														SET @StatusCode = 0
														SET @Response ='Effective From Date Should be greater then ' + CAST(convert(varchar(100), @ieffectiveFrom, 105) AS VARCHAR)
											                                  
													END
										
										END
										ELSE
											BEGIN
													UPDATE Mstr_Tax SET effectiveFrom = @effectiveFrom, activeStatus = 'A', updatedBy = @updatedBy, updatedDate = GETDATE() 
													WHERE uniqueId=@uniqueId
													IF @@ROWCOUNT > 0
													BEGIN
										
														SET @StatusCode = 1
														SET @Response ='Tax Details Inserted Successfully'
													 END
											END
										
								END
								ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response ='Add Tax Details for further Process.'
								
								END
							
							FETCH NEXT FROM tax_Cursor
							INTO @uniqueId,@serviceName,@taxDescription,@effectiveFrom,@activeStatus

			            END
				 CLOSE tax_Cursor;
			    DEALLOCATE tax_Cursor;

				COMMIT TRANSACTION
		   END
		ELSE
		BEGIN
			SET @StatusCode=0;
			SET @Response='QueryType '+@queryType+ ' Is Invalid !!!'
			--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
		END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrTrainingType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrTrainingType]
(
@queryType VARCHAR(100),
@trainingTypeId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@trainingTypeNameId NVARCHAR(50)=NULL,
@description NVARCHAR(150)=NULL,
@imageUrl VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
        SET NOCOUNT ON

        BEGIN TRANSACTION
        BEGIN TRY
                IF(@queryType='Insert')
                        BEGIN
                                IF NOT EXISTS(SELECT trainingTypeId,gymOwnerId,branchId,trainingTypeNameId 
								FROM Mstr_TrainingType WHERE trainingTypeNameId=@trainingTypeNameId AND gymOwnerId=@gymOwnerId AND branchId = @branchId)
                                        BEGIN
                                                INSERT INTO Mstr_TrainingType (gymOwnerId,branchId,trainingTypeNameId,description,imageUrl,createdBy,createdDate) 
												VALUES(@gymOwnerId,@branchId,@trainingTypeNameId,@description,@imageUrl,@createdBy,GETDATE())
                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response='TrainingType  Is Inserted Successfully !!!' 
                                                                        COMMIT TRANSACTION
                                                                END
                                        END
                                ELSE
                                        BEGIN
                                                SET @StatusCode=0;
                                                SET @Response='TrainingType Is Already Exists !!!'
                                                ROLLBACK TRANSACTION
                                        END
                        END

            ELSE IF(@queryType='Update')
                        BEGIN
                                IF EXISTS(SELECT trainingTypeId,gymOwnerId,branchId FROM Mstr_TrainingType WHERE trainingTypeId=@trainingTypeId AND gymOwnerId = @gymOwnerId 
								AND branchId = @branchId AND activeStatus='A')
                                        BEGIN
                                                IF NOT EXISTS(SELECT trainingTypeId,branchId,gymOwnerId,trainingTypeNameId 
												FROM Mstr_TrainingType WHERE  trainingTypeNameId=@trainingTypeNameId 
												AND gymOwnerId= @gymOwnerId AND trainingTypeNameId=@trainingTypeNameId AND branchId= @branchId AND trainingTypeId !=@trainingTypeId)
                                                        BEGIN
                                                                UPDATE Mstr_TrainingType SET trainingTypeNameId=@trainingTypeNameId,
															    description=@description,imageUrl=@imageUrl, updatedBy=@updatedBy,updatedDate=GETDATE()
                                                                WHERE trainingTypeId=@trainingTypeId AND gymOwnerId = @gymOwnerId AND branchId= @branchId AND activeStatus='A' 

                                                                IF(@@ROWCOUNT>0)
                                                                        BEGIN
                                                                                SET @StatusCode=1;
                                                                                SET @Response='TrainingType Is Updated Successfully !!!'
                                                                                COMMIT TRANSACTION
                                                                        END
                                                        END
                                                ELSE
                                                        BEGIN
                                                                SET @StatusCode=0;
                                                                SET @Response='TrainingType  Is Already Exists !!!'
                                                                ROLLBACK TRANSACTION
                                                        END
                                        END
                                ELSE
                                        BEGIN
                                                SET @StatusCode=0;
                                                SET @Response='TrainingType Is Does Not Exists !!!'
                                                ROLLBACK TRANSACTION
                                        END
                        END

                ELSE        IF(@queryType ='Active')
                                BEGIN
                                        IF EXISTS(SELECT trainingTypeId FROM Mstr_TrainingType WHERE trainingTypeId=@trainingTypeId AND activeStatus='D')
                                                BEGIN
                                                        UPDATE Mstr_TrainingType SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
                                                        trainingTypeId=@trainingTypeId AND activeStatus='D'

                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response='TrainingType Activated Successfully !!!'
                                                                        COMMIT TRANSACTION
                                                                END
                                                END
                                        ELSE
                                                BEGIN
                                                        SET @StatusCode=0;
                                                        SET @Response='TrainingType Does Not Exists !!!'
                                                        ROLLBACK TRANSACTION
                                                END
                                END

                ELSE        IF(@queryType ='InActive')
                                BEGIN
                                        IF EXISTS(SELECT trainingTypeId FROM Mstr_TrainingType WHERE trainingTypeId=@trainingTypeId AND activeStatus='A')
                                                BEGIN
                                                        UPDATE Mstr_TrainingType SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
                                                        trainingTypeId=@trainingTypeId AND activeStatus='A'

                                                        IF(@@ROWCOUNT>0)
                                                                BEGIN
                                                                        SET @StatusCode=1;
                                                                        SET @Response='TrainingType InActivated Successfully !!!'
                                                                        COMMIT TRANSACTION
                                                                END
                                                END
                                        ELSE
                                                BEGIN
                                                        SET @StatusCode=0;
                                                        SET @Response='TrainingType Does Not Exists !!!'
                                                        ROLLBACK TRANSACTION
                                                END
                                END

                                        ELSE
                        BEGIN
                                SET @StatusCode=0;
                                SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
                                ROLLBACK TRANSACTION
                        END
        END TRY
        BEGIN CATCH 
                        SET @StatusCode=0;
                        SET @Response=(SELECT ERROR_MESSAGE())
                        ROLLBACK TRANSACTION
        END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUser]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrUser]
(
@queryType NVARCHAR(100),
@userId  INT=0,
@firstName NVARCHAR(50)=NULL,
@lastName NVARCHAR(50)=NULL,
@dob Date=NULL,
@gender CHAR(1)= NULL,
@maritalStatus CHAR(1)= NULL,
@addressLine1 NVARCHAR(100)=NULL,
@addressLine2 NVARCHAR(100)=NULL,
@zipcode INT=0,
@district NVARCHAR(50)=NULL,
@state NVARCHAR(50)=NULL,
@city NVARCHAR(50)=NULL,
@score INT = 0,
@rewardPoints INT = 0,
@rewardUtilized INT = 0,
@promoNotification NVARCHAR(1)=NULL,
@gymOwnerId INT = 0,
@branchId INT = 0,
@enquiryReason NVARCHAR(250)=NULL,
@enquiryDate Date=NULL,
@followUpMode INT = 0,
@followUpStatus INT = 0,
@mobileNo NVARCHAR(10)=NULL,
@mailId NVARCHAR(50)=NULL,
@passWord NVARCHAR(20)=NULL,
@photoLink VARCHAR(MAX)=NULL,
@registrationToken NVARCHAR(MAX)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
		DECLARE @userIds INT
		DECLARE @roleIds INT
		DECLARE @OTP INT
		DECLARE @AdminuserIds INT
	BEGIN TRANSACTION
	BEGIN TRY
	IF(@queryType='updateProfile')
		BEGIN
			IF EXISTS(SELECT * FROM Mstr_User AS Emp INNER JOIN Mstr_UserLogin AS UserLogin  ON Emp.userId=UserLogin.userId  
				WHERE  (UserLogin.mobileNo=@mobileNo OR UserLogin.mailId=@mailId) AND Emp.activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_User AS Emp INNER JOIN Mstr_UserLogin AS UserLogin  ON Emp.userId=UserLogin.userId  
				     WHERE Emp.firstName=@firstName AND UserLogin.mobileNo=@mobileNo  AND Emp.userId !=@userId)
						BEGIN 
							UPDATE Mstr_User SET firstName=@firstName, lastName=@lastName,gender=@gender,addressLine1=@addressLine1,addressLine2=@addressLine2,
							district=@district,state=@state,city=@city,zipcode=@zipcode,maritalStatus=@maritalStatus,dob=@dob,photoLink=@photoLink,
							updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@userId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET mobileNo=@mobileNo,mailId=@mailId,passWord=@passWord,
									updatedBy=@updatedBy,updatedDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
										IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='User Details  Updated Successfully !!!'
											COMMIT TRANSACTION
										END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='User Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='User Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END
		ELSE IF(@queryType='InsertAdminUser')
		BEGIN
			IF NOT EXISTS(SELECT firstName FROM Mstr_User  WHERE firstName=@firstName )
			BEGIN
			IF NOT EXISTS(SELECT userId FROM Mstr_UserLogin WHERE (mobileNo=@mobileNo OR mailId=@mailId) )
						BEGIN 
							SET @roleIds=(SELECT configId FROm Mstr_Configuration WHERE configName='User')
						      INSERT INTO Mstr_UserLogin(mobileNo,mailId,password,roleId,activeStatus) 
						      VALUES(@mobileNo,@mailId,@passWord,@roleIds,'A')					     
							
							IF(@@ROWCOUNT>0)
								BEGIN
									 SET @AdminuserIds = (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mobileNo=@mobileNo AND mailId=@mailId)
									 INSERT INTO Mstr_User(userId,firstName,lastName,gender,addressLine1,addressLine2,district,state,city,zipcode,maritalStatus,
									 gymOwnerId,branchId,enquiryReason,score,rewardPoints,rewardUtilized,enquiryDate,followUpMode,followUpStatus,
									 dob,photoLink,activeStatus,createdBy,createdDate) 
						             VALUES(@AdminuserIds,@firstName,@lastName,@gender,@addressLine1,@addressLine2,@district,@state,@city,@zipcode,@maritalStatus,
									 @gymOwnerId,@branchId,@enquiryReason,@score,@rewardPoints,@rewardUtilized,@enquiryDate,@followUpMode,@followUpStatus,
									 @dob,@photoLink,'A',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='User Details  Inserted Successfully !!!'
											COMMIT TRANSACTION
										END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='User Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END	
				ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='User Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
	  END
	  ELSE IF(@queryType='updateAdminUserProfile')
		BEGIN
			IF EXISTS(SELECT * FROM Mstr_User AS Emp INNER JOIN Mstr_UserLogin AS UserLogin  ON Emp.userId=UserLogin.userId  
				WHERE  (UserLogin.mobileNo=@mobileNo OR UserLogin.mailId=@mailId) AND Emp.activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_User AS Emp INNER JOIN Mstr_UserLogin AS UserLogin  ON Emp.userId=UserLogin.userId  
				     WHERE Emp.firstName=@firstName AND UserLogin.mobileNo=@mobileNo  AND Emp.userId !=@userId)
						BEGIN 
							UPDATE Mstr_User SET firstName=@firstName, lastName=@lastName,gender=@gender,addressLine1=@addressLine1,addressLine2=@addressLine2,
							district=@district,state=@state,city=@city,zipcode=@zipcode,maritalStatus=@maritalStatus,dob=@dob,photoLink=@photoLink,
							gymOwnerId=@gymOwnerId,branchId=@branchId,enquiryReason=@enquiryReason,score=@score,rewardPoints=@rewardPoints,rewardUtilized=@rewardUtilized,
							enquiryDate=@enquiryDate,followUpMode=@followUpMode,followUpStatus=@followUpStatus,
							updatedBy=@updatedBy,updatedDate=GETDATE() WHERE  userId=@userId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									UPDATE Mstr_UserLogin SET mobileNo=@mobileNo,mailId=@mailId,passWord=@passWord,
									updatedBy=@updatedBy,updatedDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
										IF(@@ROWCOUNT>0)
										BEGIN
											SET @StatusCode=1;
											SET @Response='User Details  Updated Successfully !!!'
											COMMIT TRANSACTION
										END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='User Details Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='User Details Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
	  END
	ELSE IF(@queryType='updatePassword')
		BEGIN
		IF EXISTS(SELECT * FROM  Mstr_UserLogin    
		WHERE userId=@userId AND activeStatus='A')
				BEGIN
			     UPDATE Mstr_UserLogin SET passWord=@passWord,
			     updatedBy=@userId,updatedDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
			  	IF(@@ROWCOUNT>0)
				BEGIN
					SET @StatusCode=1;
					SET @Response='User Password  Updated Successfully !!!'
					COMMIT TRANSACTION
				END
				END
				ELSE
				BEGIN
				SET @StatusCode=0;
					SET @Response='User Password Not Updated !!!'
					COMMIT TRANSACTION
				END
		END
		ELSE IF(@queryType='updateregistrationToken')
		BEGIN
		IF EXISTS(SELECT * FROM  Mstr_User    
		WHERE userId=@userId AND activeStatus='A')
				BEGIN
			     UPDATE Mstr_User SET registrationToken=@registrationToken,
			     updatedBy=@userId,updatedDate=GETDATE() WHERE userId=@userId AND activeStatus='A'
			  	IF(@@ROWCOUNT>0)
				BEGIN
					SET @StatusCode=1;
					SET @Response='User Registration Token  Updated Successfully !!!'
					COMMIT TRANSACTION
				END
				END
				ELSE
				BEGIN
				SET @StatusCode=0;
					SET @Response='User Registration Token Not Updated !!!'
					COMMIT TRANSACTION
				END
		END
		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUserFoodMenu]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--*******************************
--Modified By Abhinaya K
--Modified Date 07-Jan-2023
--*******************************
CREATE PROCEDURE [dbo].[usp_MstrUserFoodMenu]
(
@queryType VARCHAR(100),
@uniqueId INT= 0,
@bookingId INT= 0,
@userId INT=0,
@dietTimeId INT= 0,
@dietTypeId INT= 0,
@fromTime Time= NULL,
@ToTime Time= NULL,
@foodItemId INT= 0,
@foodItemName VARCHAR(100)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@UserfoodDietTimeId INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	     DECLARE @servingIn INT
		 SET @servingIn=(SELECT servingIn FROM Mstr_FoodItem WHERE foodItemId=@foodItemId)
		 DECLARE @calories INT
		 SET @calories=(SELECT calories FROM Mstr_FoodItem WHERE foodItemId=@foodItemId)
		 DECLARE @TDEE INT 
		 SET @TDEE=(SELECT TOP 1 TDEE FROM Mstr_UserInBodyTest WHERE USERID=@userId ORDER BY createdDate DESC)
		 DECLARE @TotalCalories INT 
	BEGIN TRANSACTION
	BEGIN TRY
	    
		IF(@queryType='insert')
				BEGIN
				   
					 IF NOT EXISTS(SELECT up.userId FROM Mstr_UserDietTime as up INNER JOIN Mstr_UserFoodMenu as ut ON up.dietTimeId=ut.dietTimeId WHERE up.userId=@userId AND
					 ut.foodItemId=@foodItemId AND up.dietTimeId= @dietTimeId)
						BEGIN
							INSERT INTO Mstr_UserDietTime(userId,BookingId,dietTypeId,dietTimeId,fromTime,toTime,createdBy,createdDate)
							VALUES(@userId,@bookingId,@dietTypeId,@dietTimeId,@fromTime,@toTime,@createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
									BEGIN
									    INSERT INTO Mstr_UserFoodMenu(userId,BookingId,dietTimeId,foodItemId,foodItemName,servingIn,calories,alternative,createdBy,createdDate)
										VALUES(@userId,@bookingId,@dietTimeId,@foodItemId,@foodItemName,@servingIn,@calories,'N',@createdBy,GETDATE())
										IF(@@ROWCOUNT>0)
											BEGIN
											    SET @TotalCalories=(SELECT SUM(calories) FROM Mstr_UserFoodMenu
												WHERE USERID=@userId AND BookingId=@bookingId )
												IF(CAST(@TDEE AS INT) <= CAST(@TotalCalories AS INT )   )
												BEGIN 
												    SET @StatusCode=0;
												    SET @Response='Total Calories Should Be less than '+CAST(@TDEE  AS varchar(50))
												END
												ELSE
												BEGIN
												   SET @StatusCode=1;
												   SET @Response='Food Item ' +@foodItemName+ ' Is  Inserted Successfully !!!'
												END
												
												
											END
							        END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Food Item Is Already Exists !!!'
							
						END
				END

		ELSE IF(@queryType='update')
			BEGIN
			DECLARE @dietTimeIds INT

					SET @userId=(SELECT userId FROM Mstr_UserFoodMenu WHERE   uniqueId =@uniqueId)
					SET @bookingId=(SELECT bookingId FROM Mstr_UserFoodMenu WHERE   uniqueId =@uniqueId)
				
					IF NOT EXISTS(SELECT uniqueId,dietTimeId,foodItemId FROM Mstr_UserFoodMenu WHERE  foodItemId =@foodItemId AND userId=@userId AND BookingId=@bookingId AND dietTimeId= @dietTimeId
					 AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_UserFoodMenu SET dietTimeId= @dietTimeId ,foodItemId=@foodItemId,foodItemName=@foodItemName,servingIn=@servingIn,calories=@calories,				
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE uniqueId=@uniqueId 

								IF(@@ROWCOUNT>0)
									BEGIN
									     UPDATE Mstr_UserDietTime SET dietTimeId= @dietTimeId ,fromTime=@fromTime,toTime=@toTime,			
											updatedBy=@updatedBy,updatedDate=GETDATE()
											WHERE uniqueId=@UserfoodDietTimeId
											IF(@@ROWCOUNT>0)
									                 BEGIN
														SET @TotalCalories=(SELECT SUM(calories) FROM Mstr_UserFoodMenu
															  WHERE USERID=@userId AND BookingId=@bookingId )
																IF(CAST(@TDEE AS INT) <= CAST(@TotalCalories AS INT )   )
															BEGIN 
																SET @StatusCode=0;
																SET @Response='Total Calories Should Be less than '+CAST(@TDEE  AS varchar(50))
															END
															ELSE
															BEGIN
															   SET @StatusCode=1;
															   SET @Response='Food Item ' +@foodItemName+ ' Is  Updated Successfully !!!'
															END
										              END
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Food Item ' +@foodItemName+ ' Is Already Exists !!!'
								
							END
					
				
			END

		 ELSE	IF(@queryType ='delete')
		
				BEGIN
				    SET @foodItemName=(SELECT foodItemName FROM Mstr_UserFoodMenu WHERE uniqueId=@uniqueId)
					IF EXISTS(SELECT uniqueId FROM Mstr_UserFoodMenu WHERE uniqueId=@uniqueId )
						BEGIN
						    DELETE FROM Mstr_UserFoodMenu WHERE uniqueId=@uniqueId
							IF(@@ROWCOUNT>0)
								BEGIN
								    DELETE FROM Mstr_UserDietTime WHERE uniqueId=@UserfoodDietTimeId
									IF(@@ROWCOUNT>0)
								     BEGIN
										SET @StatusCode=1;
										SET @Response='Food Item ' +@foodItemName+ ' Is Deleted Successfully !!!'
									END
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Food Item ' +@foodItemName+ ' Does Not Exists !!!'
							
						END
				END

	
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				
			END
      IF(@StatusCode = 1)
		BEGIN
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			  COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			  SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			  ROLLBACK TRANSACTION
		END

	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUserInBodyTest]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrUserInBodyTest]
(
@queryType VARCHAR(100),
@userId INT=NULL,
@firstName NVARCHAR(50)=NULL,
@lastName NVARCHAR(50)=NULL,
@dob Date=NULL,
@gender CHAR(1)= NULL,
@weight DECIMAL=NULL,
@height DECIMAL=NULL,
@fatPercentage INT=NULL,
@WorkOutStatus NVARCHAR(50)=NULL,
@WorkOutValue DECIMAL=NULL,
@age INT=NULL,
@BMR DECIMAL=NULL,
@BMI DECIMAL=NULL,
@TDEE INT=NULL,
@date Date=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@mobileNo NVARCHAR(15)=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')		
					BEGIN
						INSERT INTO Mstr_UserInBodyTest (userId,weight,height,age,fatPercentage,WorkOutStatus,WorkOutValue,BMR,BMI,TDEE,date,createdBy,createdDate) 
						VALUES(@userId,@weight,@height,@age,@fatPercentage,@WorkOutStatus,@WorkOutValue,@BMR,@BMI,@TDEE,@date,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
								IF(@firstName IS NOT NULL)
									BEGIN
									     UPDATE Mstr_User SET firstName=@firstName,dob=@dob,gender=@gender WHERE userId=@userId
									END
									ELSE 
									BEGIN
									     UPDATE Mstr_User SET dob=@dob,gender=@gender WHERE userId=@userId
									END
									SET @StatusCode=1;
									SET @Response='User In Body Test Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
		ELSE IF(@queryType='InsertForEnrollment')		
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mstr_UserLogin AS UserLogin WHERE  UserLogin.mobileNo=@mobileNo)
					BEGIN
				        INSERT INTO Mstr_UserLogin(mobileNo,roleId,activeStatus) 
						VALUES(@mobileNo,'33','A')					     
							  IF(@@ROWCOUNT>0)
								BEGIN
									  SET @userId = (SELECT TOP 1 userId FROM Mstr_UserLogin WHERE activeStatus='A' AND mobileNo=@mobileNo )
										INSERT INTO Mstr_User(userId,activeStatus,createdBy,createdDate) 
										VALUES(@userId,'A',@createdBy,GETDATE())
								  		IF(@@ROWCOUNT>0)
											BEGIN
													INSERT INTO Mstr_UserInBodyTest (userId,weight,height,age,fatPercentage,WorkOutStatus,WorkOutValue,BMR,BMI,TDEE,date,createdBy,createdDate) 
													VALUES(@userId,@weight,@height,@age,@fatPercentage,@WorkOutStatus,@WorkOutValue,@BMR,@BMI,@TDEE,@date,@createdBy,GETDATE())
														IF(@@ROWCOUNT>0)
															BEGIN 
															IF(@firstName IS NOT NULL)
																BEGIN
																		UPDATE Mstr_User SET firstName=@firstName,dob=@dob,gender=@gender WHERE userId=@userId
																END
																ELSE 
																BEGIN
																		UPDATE Mstr_User SET dob=@dob,gender=@gender WHERE userId=@userId
																END
																SET @StatusCode=1;
																SET @Response=CAST(@userId AS VARCHAR(200))+' ~ User In Body Test Is Inserted Successfully !!!' 
																COMMIT TRANSACTION
															END
											END
								END
						END
						ELSE
					        BEGIN
								SET @StatusCode=0;
								SET @Response='MobileNo "'+ @mobileNo +'" Is Already Exist !!!'
								ROLLBACK TRANSACTION
							END
							
				END
	    ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUserMenuAccess]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_MstrUserMenuAccess]
(
@QueryType VARCHAR(150),
@MenuOptionAcessId INT=0,
@gymOwnerId INT,
@branchId INT,
@empId INT,
@roleId INT,
@optionId INT,
@viewRights CHAR(1)=NULL,
@addRights CHAR(1)=NULL,
@editRights CHAR(1)=NULL,
@deleteRights CHAR(1)=NULL,
@activeStatus CHAR(1)=NULL,
@CreatedBy INT=0,
@UpdatedBy INT=NULL,
@StatusCode INT=0 OUT,
@Response VARCHAR(500)=NULL OUT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY

	DECLARE @OptionName VARCHAR(300);
	DECLARE @EmployeeName VARCHAR(200);

		IF(@QueryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT MenuOptionAcessId FROM Mstr_UserMenuAccess WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND empId=@empId AND optionId=@optionId)
					BEGIN
						INSERT INTO Mstr_UserMenuAccess(gymOwnerId,branchId,empId,roleId,optionId,viewRights,addRights,editRights,deleteRights,activeStatus,createdBy)
						VALUES(@gymOwnerId,@branchId,@empId,@roleId,@optionId,@viewRights,@addRights,@editRights,@deleteRights,@activeStatus,@createdBy)

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='Menu Access Rights Inserted Successfully !!!.';
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Something Went Wrong !!!.';								
							END
					END
				ELSE
					BEGIN
						SET @OptionName =(SELECT optionName FROM Mstr_MenuOption WHERE optionId=@optionId );
						SET @EmployeeName =(SELECT firstName+' '+lastName FROM Mstr_Employee WHERE empId=@empId)
						SET @StatusCode=0;
						SET @Response='Option Name '''+@OptionName+''' Is Already Exists For User '''+@EmployeeName+''' !!!.';
					END
			END

		IF(@QueryType='Update')
			BEGIN
				IF EXISTS(SELECT MenuOptionAcessId FROM Mstr_UserMenuAccess WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND empId=@empId AND optionId=@optionId )
					BEGIN
						UPDATE 
							Mstr_UserMenuAccess 
						SET 
							addRights=@addRights,editRights=@editRights,viewRights=@viewRights,deleteRights=@deleteRights,
							activeStatus=@activeStatus, updatedBy=@UpdatedBy,updatedDate=GETDATE()
						WHERE 
							gymOwnerId=@gymOwnerId AND branchId=@branchId AND empId=@empId AND optionId=@optionId AND roleId=@roleId AND MenuOptionAcessId=@MenuOptionAcessId

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='Menu Access Rights Updated Successfully !!!.';
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Something Went Wrong !!!.';								
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Option ID '''+CAST(@optionId AS VARCHAR)+''' Does Not Exist !!!.';
					END
			END
	END TRY
	BEGIN CATCH
		SET @StatusCode=0;
		SET @Response=(SELECT ERROR_MESSAGE());

		 SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_STATE() AS ErrorState,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	END CATCH

	IF(@StatusCode =1)
		BEGIN
			COMMIT TRAN
		END
	ELSE
		BEGIN
			ROLLBACK TRAN
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUserNotification]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrUserNotification]
(
@queryType VARCHAR(100),
@notificationId  INT=NULL,
@userId INT=NULL,
@notification NVARCHAR(MAX)=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				INSERT INTO Mstr_UserNotification (userid,notification,createdDate) 
				VALUES(@userId,@Notification,GETDATE())
					IF(@@ROWCOUNT>0)
						BEGIN 
							SET @StatusCode=1;
							SET @Response='UserNotification Is Inserted Successfully !!!' 
							COMMIT TRANSACTION
						END						
				
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT userid,notification FROM Mstr_UserNotification WHERE notificationId=@notificationId)
					BEGIN
						UPDATE Mstr_UserNotification SET readstatus='Y',updatedDate=GETDATE()
						WHERE notificationId=@notificationId 

						IF(@@ROWCOUNT>0)
							BEGIN
								SET @StatusCode=1;
								SET @Response='UserNotification Is Updated Successfully !!!'
								COMMIT TRANSACTION
							END
					END	
			ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='UserNotification Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrUserTestimonials]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrUserTestimonials]
(
@queryType VARCHAR(100),
@feedbackId INT=NULL,
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@bookingId INT=NULL,
@imageUrl VARCHAR(Max)=NULL,
@feedbackRating INT=NULL,
@feedbackComment VARCHAR(Max)=NULL,
@dispayStatus CHAR(1)=NULL,
@createdBy INT=NULL,
@updateBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
						INSERT INTO Mstr_UserTestimonials (gymOwnerId,branchId,bookingId,imageUrl,feedbackRating,feedbackComment,dispayStatus,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchId,@bookingId,@imageUrl,@feedbackRating,@feedbackRating,@dispayStatus,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='User Testimonials Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END	
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='User Testimonials Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
		 
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT feedbackId,gymOwnerId,branchId,bookingId FROM Mstr_UserTestimonials WHERE feedbackId=@feedbackId 
				AND gymOwnerId= @gymOwnerId AND branchId = @branchId AND bookingId = @bookingId )
					BEGIN
								UPDATE Mstr_UserTestimonials SET imageUrl=@imageUrl, feedbackRating=@feedbackRating,feedbackComment=@feedbackComment,
								dispayStatus=@dispayStatus,updateBy=@updateBy,updatedDate=GETDATE()
								WHERE gymOwnerId= @gymOwnerId AND branchId = @branchId AND bookingId =@bookingId AND feedbackId =@feedbackId 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='UserTestimonials Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='User Testimonials Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='User Testimonials Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrWorkoutMealPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrWorkoutMealPlan]
(
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@typeOfRoutine INT=NULL,
@description VARCHAR(Max)=NULL,
@specificInstruction VARCHAR(Max)=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT uniqueId,typeOfRoutine FROM Mstr_WorkoutMealPlan WHERE  typeOfRoutine=@typeOfRoutine)
					BEGIN
						INSERT INTO Mstr_WorkoutMealPlan (typeOfRoutine,description,specificInstruction,createdBy,createdDate) 
						VALUES(@typeOfRoutine,@description,@specificInstruction,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='Workout Routine Meal Plan Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Workout Routine Meal Plan Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
			
	   ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT uniqueId,typeOfRoutine FROM Mstr_WorkoutMealPlan WHERE typeOfRoutine=@typeOfRoutine AND uniqueId= @uniqueId AND activeStatus='A')
					BEGIN
						IF NOT EXISTS(SELECT uniqueId,typeOfRoutine FROM Mstr_WorkoutMealPlan WHERE  typeOfRoutine= @typeOfRoutine 
						AND uniqueId !=@uniqueId)
							BEGIN
								UPDATE Mstr_WorkoutMealPlan SET typeOfRoutine=@typeOfRoutine, description=@description,					
								updatedBy=@updatedBy,updatedDate=GETDATE()
								WHERE typeOfRoutine=@typeOfRoutine AND uniqueId= @uniqueId AND activeStatus='A' 

								IF(@@ROWCOUNT>0)
									BEGIN
										SET @StatusCode=1;
										SET @Response='Workout Routine Meal Plan Is Updated Successfully !!!'
										COMMIT TRANSACTION
									END
							END
						ELSE
							BEGIN
								SET @StatusCode=0;
								SET @Response='Workout Routine Meal Plan Is Already Exists !!!'
								ROLLBACK TRANSACTION
							END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Workout Routine Meal Plan Is Does Not Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

		ELSE	IF(@queryType ='Active')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_WorkoutMealPlan WHERE uniqueId=@uniqueId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_WorkoutMealPlan SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Workout Routine Meal Plan Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Workout Routine Meal Plan Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE	IF(@queryType ='InActive')
				BEGIN
					IF EXISTS(SELECT uniqueId FROM Mstr_WorkoutMealPlan WHERE uniqueId=@uniqueId AND activeStatus='A')
						BEGIN
							UPDATE Mstr_WorkoutMealPlan SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							uniqueId=@uniqueId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='Workout Routine Meal Plan InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Workout Routine Meal Plan Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_MstrWorkOutType]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_MstrWorkOutType]
(
@queryType NVARCHAR(100),
@workoutTypeId INT=0,
@gymOwnerId INT= 0,
@branchId INT= 0,
@workoutCatTypeId int=NULL,
@workoutType NVARCHAR(50)=NULL,
@description NVARCHAR(150)=NULL,
@imageUrl VARCHAR(MAX)=NULL,
@video NVARCHAR(200)=NULL,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='insert')
			BEGIN
				IF NOT EXISTS(SELECT workoutCatTypeId FROM Mstr_WorkoutType WHERE workoutCatTypeId=@workoutCatTypeId AND workoutType=@workoutType AND gymOwnerId=@gymOwnerId AND branchId=@branchId)
					BEGIN
						INSERT INTO Mstr_WorkoutType(gymOwnerId,branchId,workoutCatTypeId,workoutType,description,imageUrl,video,activeStatus,createdBy,createdDate) 
						VALUES(@gymOwnerId,@branchId,@workoutCatTypeId,@workoutType,@description,@imageUrl,@video,'A',@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='WorkOut Type Is Inserted Successfully !!!'
									COMMIT TRANSACTION
								END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='WorkOut Type Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END

	    ELSE  IF(@queryType='update')
		BEGIN
			IF EXISTS(SELECT workoutCatTypeId FROM Mstr_WorkoutType WHERE workoutCatTypeId=@workoutCatTypeId  AND gymOwnerId=@gymOwnerId AND branchId=@branchId AND activeStatus='A')
				BEGIN
					IF NOT EXISTS(SELECT workoutCatTypeId FROM Mstr_WorkoutType WHERE  workoutCatTypeId=@workoutCatTypeId   AND workoutType=@workoutType
					AND gymOwnerId=@gymOwnerId AND branchId=@branchId AND workoutTypeId!=@workoutTypeId)
						BEGIN
							UPDATE Mstr_WorkoutType SET workoutCatTypeId=@workoutCatTypeId,workoutType=@workoutType,description=@description,
							imageUrl=@imageUrl, video=@video,updatedBy=@updatedBy,updatedDate=GETDATE()
							WHERE workoutTypeId=@workoutTypeId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='WorkOut Type  Updated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='WorkOut Type  Is Already Exists !!!'
							ROLLBACK TRANSACTION
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='WorkOut Type  Is Does Not Exists !!!'
					ROLLBACK TRANSACTION
				END
		END

	    ELSE IF(@queryType ='active')
				BEGIN
					IF EXISTS(SELECT workoutCatTypeId FROM Mstr_WorkoutType WHERE workoutTypeId=@workoutTypeId AND activeStatus='D')
						BEGIN
							UPDATE Mstr_WorkoutType SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE()
							WHERE workoutTypeId=@workoutTypeId AND activeStatus='D'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='WorkOut Type Activated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='WorkOut Type Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

	    ELSE IF(@queryType ='inActive')
				BEGIN
					IF EXISTS(SELECT workoutCatTypeId FROM Mstr_WorkoutType WHERE workoutTypeId=@workoutTypeId  AND activeStatus='A')
						BEGIN
							UPDATE Mstr_WorkoutType SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							 workoutTypeId=@workoutTypeId AND activeStatus='A'

							IF(@@ROWCOUNT>0)
								BEGIN
									SET @StatusCode=1;
									SET @Response='WorkOut Type InActivated Successfully !!!'
									COMMIT TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='WorkOut Type Does Not Exists !!!'
							ROLLBACK TRANSACTION
						END
				END

		ELSE
	BEGIN
		SET @StatusCode=0;
		SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
		--SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
		ROLLBACK TRANSACTION
	END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


SELECT * FROM Mstr_WorkoutType
GO
/****** Object:  StoredProcedure [dbo].[usp_paymentUPIDetails]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_paymentUPIDetails]
(
@queryType VARCHAR(100),
@paymentUPIId Int =0,
@gymOwnerId int =NULL,
@name NVARCHAR(50) =NULL,
@phoneNumber NVARCHAR(15) =NULL,
@UPIId NVARCHAR(30) =NULL,
@branchId INT =NULL,
@merchantId NVARCHAR(50) =NULL,
@merchantCode NVARCHAR(50)=NULL,
@mode NVARCHAR(15)=NULL,
@orgId NVARCHAR(15)=NULL,
@sign NVARCHAR(100)=NULL,
@url NVARCHAR(100)=NULL,
@createdBy INT =NULL,
@updatedBy INT = Null,
@paymentUPIDetailsId INT =Null,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
			SET @paymentUPIId = (SELECT paymentUPIDetailsId FROM paymentUPIDetails WHERE branchId=@branchId AND gymOwnerId=@gymOwnerId AND activeStatus='A')
						BEGIN
							UPDATE paymentUPIDetails SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
							paymentUPIDetailsId=@paymentUPIId AND activeStatus='A'
						END 
				IF NOT EXISTS(SELECT gymOwnerId,UPIId FROM paymentUPIDetails WHERE  gymOwnerId=@gymOwnerId AND UPIId=@UPIId AND activeStatus = 'A')
					BEGIN
						INSERT INTO paymentUPIDetails(gymOwnerId,name,phoneNumber,UPIId,branchId,merchantId,merchantCode,mode, orgId, sign, url,activeStatus,createdBy,createdDate)
	                     VALUES(@gymOwnerId, @name,@phoneNumber,@UPIId,@branchId,@merchantId,@merchantCode,@mode, @orgId, @sign,@url,'A',@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN  
									SET @StatusCode=1;
									SET @Response='UPI Details Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='UPI Details Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
					END
			
	
	/***Backup Code For Future Update ***/

	 --  ELSE IF(@queryType='Update')
		--	BEGIN
		--		IF EXISTS(SELECT gymOwnerId,paymentUPIDetailsId FROM paymentUPIDetails WHERE gymOwnerId=@gymOwnerId AND branchId =@branchId
		--		AND paymentUPIDetailsId= @paymentUPIDetailsId AND activeStatus='A')
		--			BEGIN
		--				IF NOT EXISTS(SELECT gymOwnerId,paymentUPIDetailsId FROM paymentUPIDetails WHERE  gymOwnerId=@gymOwnerId AND branchId=@branchId AND UPIId=@UPIId 
		--				AND paymentUPIDetailsId !=@paymentUPIDetailsId)
		--					BEGIN
		--						UPDATE paymentUPIDetails SET name=@name,phoneNumber=@phoneNumber,UPIId=@UPIId,branchId=@branchId,
		--						merchantId=@merchantId,merchantCode=@merchantCode,mode=@mode, orgId=@orgId, 
		--						sign=@sign,url=@url,activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE paymentUPIDetailsId=@paymentUPIDetailsId 

		--						IF(@@ROWCOUNT>0)
		--							BEGIN
		--								SET @StatusCode=1;
		--								SET @Response='UPI Details Is Updated Successfully !!!'
		--								COMMIT TRANSACTION
		--							END
		--					END
		--				ELSE
		--					BEGIN
		--						SET @StatusCode=0;
		--						SET @Response='UPI Details Is Already Exists !!!'
		--						ROLLBACK TRANSACTION
		--					END
		--			END
		--		ELSE
		--			BEGIN
		--				SET @StatusCode=0;
		--				SET @Response='UPI Details Is Does Not Exists !!!'
		--				ROLLBACK TRANSACTION
		--			END
		--	END

		--ELSE	IF(@queryType ='Active')
		--		BEGIN
		--			IF EXISTS(SELECT paymentUPIDetailsId FROM paymentUPIDetails WHERE paymentUPIDetailsId=@paymentUPIDetailsId AND activeStatus='D')
		--				BEGIN
		--					UPDATE paymentUPIDetails SET activeStatus='A',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
		--					paymentUPIDetailsId=@paymentUPIDetailsId AND activeStatus='D'

		--					IF(@@ROWCOUNT>0)
		--						BEGIN
		--							SET @StatusCode=1;
		--							SET @Response='UPI Details Activated Successfully !!!'
		--							COMMIT TRANSACTION
		--						END
		--				END
		--			ELSE
		--				BEGIN
		--					SET @StatusCode=0;
		--					SET @Response='UPI Details Does Not Exists !!!'
		--					ROLLBACK TRANSACTION
		--				END
		--		END

		--ELSE	IF(@queryType ='InActive')
		--		BEGIN
		--			IF EXISTS(SELECT paymentUPIDetailsId FROM paymentUPIDetails WHERE paymentUPIDetailsId=@paymentUPIDetailsId AND activeStatus='A')
		--				BEGIN
		--					UPDATE paymentUPIDetails SET activeStatus='D',updatedBy=@updatedBy,updatedDate=GETDATE() WHERE 
		--					paymentUPIDetailsId=@paymentUPIDetailsId AND activeStatus='A'

		--					IF(@@ROWCOUNT>0)
		--						BEGIN
		--							SET @StatusCode=1;
		--							SET @Response='UPI Details InActivated Successfully !!!'
		--							COMMIT TRANSACTION
		--						END
		--				END
		--			ELSE
		--				BEGIN
		--					SET @StatusCode=0;
		--					SET @Response='UPI Details Does Not Exists !!!'
		--					ROLLBACK TRANSACTION
		--				END
		--		END

					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_SingleLogin]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_SingleLogin]
(
@QueryType VARCHAR(150),
@UserId INT,
@SessionId VARCHAR(200),
@StatusCode INT=0 OUT,
@Response VARCHAR(200)=NULL OUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRAN 

	BEGIN TRY
	IF(@QueryType='Login')
		BEGIN
			IF EXISTS(SELECT userId FROM Mstr_UserLogin WHERE userId=@UserId AND SessionId IS NULL)
				BEGIN
					UPDATE Mstr_UserLogin SET SessionId=@SessionId,updatedBy=@UserId,updatedDate=GETDATE() WHERE userId=@UserId AND activeStatus='A'

					IF(@@ROWCOUNT>0)
						BEGIN
							SET @StatusCode=1;
							SET @Response=@SessionId;
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Something Went Wrong !!!.';
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=1;
					SET @Response=(SELECT SessionId FROM Mstr_UserLogin WHERE userId=@UserId)
				END
		END

	IF(@QueryType='ReLogin')
		BEGIN
			IF EXISTS(SELECT userId FROM Mstr_UserLogin WHERE userId=@UserId)
				BEGIN
					UPDATE Mstr_UserLogin SET SessionId=@SessionId,updatedBy=@UserId,updatedDate=GETDATE() WHERE userId=@UserId AND activeStatus='A'

					IF(@@ROWCOUNT>0)
						BEGIN
							SET @StatusCode=1;
							SET @Response=@SessionId;
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Something Went Wrong !!!.';
						END
				END
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='User Does Not Exists !!!.';
				END
		END
	END TRY
	BEGIN CATCH
		SET @StatusCode=0;
		SET @Response=(SELECT ERROR_MESSAGE());
	END CATCH

	IF(@StatusCode=1)
		BEGIN
			COMMIT TRAN
		END
	ELSE
		BEGIN
			ROLLBACK TRAN
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranPaymentCycles]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranPaymentCycles]
(
@queryType VARCHAR(100),
@bookingId INT=0,
@userId INT=0,
@paidAmount DECIMAL(7,2)=NULL,
@paymentCyclesStatus CHAR(1)=NULL,
@transactionId VARCHAR(50)=NULL,
@bankName VARCHAR(50)=NULL,
@bankReferenceNumber VARCHAR(50)=NULL,
@createdBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
	    DECLARE @totalAmount  DECIMAL(7,2)
		 DECLARE @paymentStatus Char(1)
	   SET @totalAmount =(SELECT totalAmount FROM Tran_Booking WHERE bookingId=@bookingId)
	   If(@totalAmount = @paidAmount)
		   BEGIN
			 SET  @paymentStatus ='P'
		   END
	   ELSE
		   BEGIN
			  SET  @paymentStatus =(SELECT paymentStatus FROM Tran_Booking WHERE bookingId=@bookingId)
		   END

		IF(@queryType='insert')		
					BEGIN
						  INSERT INTO Tran_PaymentCycle(bookingId ,userId ,paidAmount ,paidDate  ,transactionId ,bankName
											,bankReferenceNumber  ,paymentStatus,createdBy ,createdDate) 
											VALUES(@bookingId ,@userId ,@paidAmount ,GETDATE()  ,@transactionId ,@bankName
										   ,@bankReferenceNumber ,@paymentCyclesStatus,  @createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
										BEGIN 
											Update Tran_Booking SET paidAmount=@paidAmount,paymentStatus=@paymentStatus,updatedBy=@createdBy ,updatedDate=GETDATE()
											WHERE bookingId=@bookingId
												IF(@@ROWCOUNT>0)
												  BEGIN 
													SET @StatusCode=1;
													SET @Response='Paid Successfully !!!' 
													COMMIT TRANSACTION
												  END
												ELSE
												  BEGIN
													SET @StatusCode=0;
													SET @Response='Not Paid !!!'
													ROLLBACK TRANSACTION
												  END
										END
								ELSE
									  BEGIN
										SET @StatusCode=0;
										SET @Response='Not Paid !!!'
										ROLLBACK TRANSACTION
									  END
							
					END
		
	      ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
					ROLLBACK TRANSACTION
				END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranSubspBooking]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranSubspBooking]
	(
	@queryType VARCHAR(100),
	@subBookingId INT=0,
	@gymOwnerId INT=0,
	@branchId INT=0,
	@branchName NVARCHAR(100)=NULL,
	@subscriptionPlanId INT=0,
	@userId INT=0,
	@booking CHAR(2)=NULL,
	@loginType CHAR(1)=NULL,
	@price DECIMAL(18,2)=NULL,
	@taxId INT=0,
	@taxName VARCHAR(50)=NULL,
	@taxAmount DECIMAL(7,2)=NULL,
	@offerId INT=0,
	@offerAmount DECIMAL(7,2)=NULL,
	@totalAmount DECIMAL(7,2)=NULL,
	@paidAmount DECIMAL(7,2)=NULL,
	@paymentStatus CHAR(1)=NULL,
	@paymentType INT=NULL,
	@cancellationStatus CHAR(1)=NULL,
	@refundStatus CHAR(1)=NULL,
	@cancellationCharges  DECIMAL(7,2)=NULL,
	@refundAmt  DECIMAL(7,2)=NULL,
	@cancellationReason VARCHAR(MAX)=NULL,
	@transactionId VARCHAR(50)=NULL,
	@bankName VARCHAR(50)=NULL,
	@bankReferenceNumber VARCHAR(50)=NULL,
	@createdBy INT=NULL,
	@StatusCode INT=NULL OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
	   DECLARE @PlanDurationMonth NVARCHAR(50)
	   DECLARE @fromDate DATE
	   DECLARE @toDate DATE
	   DECLARE @Month INT
	    SET @PlanDurationMonth =(SELECT noOfDays FROM Mstr_SubscriptionPlan WHERE subscriptionPlanId=@subscriptionPlanId)
		SET @Month=(SELECT TOP 1 value FROM STRING_SPLIT(@PlanDurationMonth, ' '))
		SET @fromDate =CAST(GETDATE() AS DATE)
		SET @toDate=DATEADD(DAY, @Month, @fromDate) 
		
		IF(@queryType='insert')		
					BEGIN
					IF NOT EXISTS(SELECT subBookingId FROM  Tran_SubspBooking WHERE toDate > @fromDate 
					AND userId=@userId )
					BEGIN
						INSERT INTO Tran_SubspBooking(gymOwnerId ,branchId ,branchName ,userId,subscriptionPlanId
							,booking,loginType,fromDate  ,toDate   ,price ,taxId
							,taxName ,taxAmount ,offerId  ,offerAmount 
							,totalAmount,paidAmount,paymentStatus,paymentType ,cancellationStatus   ,refundStatus
							,cancellationCharges ,refundAmt  ,cancellationReason,transactionId,bankName
							,bankReferenceNumber,createdBy ,bookingDate) 
						VALUES(@gymOwnerId ,@branchId ,@branchName ,@userId,@subscriptionPlanId
							,@booking,@loginType,@fromDate  ,@toDate   ,@price ,@taxId
							,@taxName ,@taxAmount ,@offerId  ,@offerAmount  
							,@totalAmount,@paidAmount,@paymentStatus ,@paymentType ,@cancellationStatus,@refundStatus
							,@cancellationCharges ,@refundAmt  ,@cancellationReason,@transactionId,@bankName
							,@bankReferenceNumber,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
								    SET @subBookingId= (SELECT TOP 1 subBookingId FROm Tran_SubspBooking ORDER BY bookingDate DESC)
									SET @StatusCode=1;
									SET @Response=CAST(@subBookingId  AS VARCHAR(50))+' ~ Booked Inserted Successfully !!!' 
									COMMIT TRANSACTION
							    END
							ELSE
                              BEGIN
								SET @StatusCode=0;
								SET @Response='Not Booked !!!'
								ROLLBACK TRANSACTION
			                  END
						END
						ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Already Booked'
									ROLLBACK TRANSACTION
								END	
					END
		    ELSE IF(@queryType='update')		
				BEGIN	
				IF  EXISTS(SELECT subBookingId FROM  Tran_SubspBooking WHERE fromDate = @fromDate AND @toDate = toDate 
					AND userId=@userId)
					BEGIN
					    Update Tran_SubspBooking SET price=@price ,taxId=@taxId,taxName=@taxName,taxAmount=@taxAmount 
				           ,totalAmount=@totalAmount,paidAmount=@paidAmount,paymentStatus =@paymentStatus,paymentType=@paymentType,transactionId=@transactionId,
						   bankName=@bankName,bankReferenceNumber=@bankReferenceNumber,updatedBy=@createdBy ,updatedDate=GETDATE()
						   WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND subBookingId=@subBookingId
						IF(@@ROWCOUNT>0)
							BEGIN 
								SET @subBookingId= (SELECT TOP 1 subBookingId FROm Tran_SubspBooking ORDER BY bookingDate DESC)
								SET @StatusCode=1;
								SET @Response=CAST(@subBookingId  AS VARCHAR(50))+' ~ Booked Updated Successfully !!!' 
								COMMIT TRANSACTION
							END
						ELSE
                            BEGIN
							SET @StatusCode=0;
							SET @Response='Not Booked !!!'
							ROLLBACK TRANSACTION
			                END
					END
				ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Booking Details Not Found '
							ROLLBACK TRANSACTION
						END	
				END
	    ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranUpdateBookingPaymentStatus]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- ================================================
--- Create by: Jaya suriya
--- Created Date: 15-02-2023
--- ================================================
CREATE PROCEDURE [dbo].[usp_TranUpdateBookingPaymentStatus]
(
	@QueryType VARCHAR(50),
	@BookingId INT,
	@PaidAmount DECIMAL(18,2),
	@PaymentStatus VARCHAR(50),
	@BankReferenceNumber VARCHAR(50),
	@StatusCode INT=NULL OUTPUT,
	@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRAN
	BEGIN TRY
		IF(@QueryType='UpdateBookingPaymentStatus')
		BEGIN
			--Checking If Details Exits
			IF NOT EXISTS(SELECT * FROM Tran_Booking WHERE paidAmount=@PaidAmount AND bookingId=@BookingId)
			BEGIN
				SET @StatusCode=0;
				SET @Response='No Booking Details Found !!!.';
				ROLLBACK TRAN;
				SELECT @Response
				RETURN;
			END

			DECLARE @PaidStatus CHAR(1);
			SET @PaidStatus=(SELECT TOP 1 paymentStatus FROM Tran_Booking WHERE paidAmount=@PaidAmount AND bookingId=@BookingId);
			--Checking if the paymentstaus is P i.e, Already Paid Or Not		
			IF(@PaidStatus='P')
				BEGIN
					SET @StatusCode=0;
					SET @Response='Payment is already paid for this booking !!!.';
					ROLLBACK TRAN;
					SELECT @Response
					RETURN;
				END
			
			IF(@PaymentStatus='Success')
				BEGIN
					UPDATE Tran_Booking SET paymentStatus='P',bankReferenceNumber=@BankReferenceNumber WHERE BookingId=@BookingId AND paidAmount=@PaidAmount

					IF(@@ROWCOUNT>0)
						BEGIN
							SET @StatusCode=1;
							SET @Response='Payment status is updated successfully !!!.'
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Failed to update payment status !!!.'
						END
				END
			ELSE
				BEGIN
					UPDATE Tran_Booking SET bankReferenceNumber=@BankReferenceNumber WHERE BookingId=@BookingId AND paidAmount=@PaidAmount

					IF(@@ROWCOUNT>0)
						BEGIN
							SET @StatusCode=1;
							SET @Response='Payment status is updated successfully !!!.'
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Failed to update payment status !!!.'
						END
				END
		END
	END TRY
	BEGIN CATCH
		SET @StatusCode=0;
		SET @Response=(SELECT ERROR_MESSAGE());
	END CATCH

	IF(@StatusCode=1)
		BEGIN
			COMMIT TRAN;
		END
	ELSE
		BEGIN
			ROLLBACK TRAN;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranUserBooking]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranUserBooking]
(
@queryType VARCHAR(100),
@bookingId INT=0,
@gymOwnerId INT=0,
@branchId INT=0,
@branchName NVARCHAR(100)=NULL,
@categoryId INT=0,
@trainingTypeId INT=0,
@traningMode CHAR(1)=NULL,
@planDurationId INT=0,
@slotId INT=0,
@slotFromTime DATETIME=NULL,
@slotToTime DATETIME=NULL,
@priceId INT=0,
@phoneNumber NVARCHAR(15)=NULL,
@userId INT=0,
@booking CHAR(2)=NULL,
@loginType CHAR(1)=NULL,
@price DECIMAL(18,2)=NULL,
@taxId INT=0,
@taxName VARCHAR(50)=NULL,
@taxAmount DECIMAL(18,2)=NULL,
@offerId INT=0,
@offerAmount DECIMAL(18,2)=NULL,
@utilizedRewardPoints INT=NULL,
@rewardPointsAmount DECIMAL(7,2)=NULL,
@totalAmount DECIMAL(18,2)=NULL,
@paidAmount DECIMAL(18,2)=NULL,
@paymentStatus CHAR(1)=NULL,
@paymentCycles INT=NULL,
@paymentCyclesStatus CHAR(1)=NULL,
@paymentType INT=NULL,
@cancellationStatus CHAR(1)=NULL,
@refundStatus CHAR(1)=NULL,
@cancellationCharges  DECIMAL(7,2)=NULL,
@refundAmt  DECIMAL(18,2)=NULL,
@cancellationReason VARCHAR(MAX)=NULL,
@transactionId VARCHAR(50)=NULL,
@bankName VARCHAR(50)=NULL,
@bankReferenceNumber VARCHAR(50)=NULL,
@createdBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
	   DECLARE @PlanDurationMonth NVARCHAR(50)
	   DECLARE @fromDate DATE
	   DECLARE @toDate DATE
	   DECLARE @Month INT
	   DECLARE @Categoryname nvarchar(50)
	   SET @PlanDurationMonth =(SELECT configName FROM Mstr_Configuration WHERE configId=@planDurationId)
		SET @Month=(SELECT TOP 1 value FROM STRING_SPLIT(@PlanDurationMonth, ' '))
		SET @fromDate =CAST(GETDATE() AS DATE)
		SET @toDate=DATEADD(MONTH, @Month, @fromDate)
		
		
		IF(@queryType='insert')		
					BEGIN
					IF NOT EXISTS(SELECT BookingId FROM  Tran_Booking WHERE toDate > @fromDate 
					AND userId=@userId )--And phoneNumber=@phoneNumber AND categoryId=@categoryId AND trainingTypeId=@trainingTypeId AND traningMode=@traningMode
					BEGIN
							INSERT INTO Tran_Booking(gymOwnerId ,branchId ,branchName ,categoryId  ,trainingTypeId ,traningMode
								,slotId ,slotFromTime ,slotToTime, priceId  ,phoneNumber,userId
								,booking,loginType,fromDate  ,toDate   ,price ,taxId
								,taxName ,taxAmount ,offerId  ,offerAmount  ,utilizedRewardPoints  ,rewardPointsAmount
								,totalAmount,paidAmount,paymentStatus ,paymentCycles,paymentType ,cancellationStatus   ,refundStatus
								,cancellationCharges ,refundAmt  ,cancellationReason,transactionId,bankName
								,bankReferenceNumber,createdBy ,bookingDate) 
							VALUES(@gymOwnerId ,@branchId ,@branchName ,@categoryId  ,@trainingTypeId ,@traningMode
								,@slotId ,@slotFromTime  ,@slotToTime  ,@priceId  ,@phoneNumber,@userId
								,@booking,@loginType,@fromDate  ,@toDate   ,@price ,@taxId
								,@taxName ,@taxAmount ,@offerId  ,@offerAmount  ,@utilizedRewardPoints  ,@rewardPointsAmount
								,@totalAmount,@paidAmount,'P' ,@paymentCycles,@paymentType ,@cancellationStatus,@refundStatus
								,@cancellationCharges ,@refundAmt  ,@cancellationReason,@transactionId,@bankName
								,@bankReferenceNumber,@createdBy,GETDATE())
								IF(@@ROWCOUNT>0)
									BEGIN 
										SET @bookingId= (SELECT TOP 1 bookingId FROm Tran_Booking ORDER BY bookingDate DESC)
										SET @StatusCode=1;
										SET @Response=CAST(@bookingId AS VARCHAR(50))+' ~ Booked Successfully !!!' 
										COMMIT TRANSACTION
									END
								ELSE
								  BEGIN
									SET @StatusCode=0;
									SET @Response='Not Booked !!!'
									ROLLBACK TRANSACTION
								  END
						END
						ELSE
								BEGIN
								    SET @Categoryname =(select categoryName from Mstr_FitnessCategory 
									WHERE categoryId=(SELECT categoryId FROM  Tran_Booking WHERE userId=@userId ))
									SET @StatusCode=0;
									SET @Response='You have already purchased ' + @Categoryname
									ROLLBACK TRANSACTION
								END
					END
		    ELSE IF(@queryType='Update')		
				BEGIN
					IF  EXISTS(SELECT BookingId FROM  Tran_Booking WHERE fromDate = @fromDate AND @toDate = toDate 
					AND userId=@userId And phoneNumber=@phoneNumber AND categoryId=@categoryId AND trainingTypeId=@trainingTypeId AND traningMode=@traningMode)
					BEGIN
					    Update Tran_Booking SET priceId=@priceId ,price=@price ,taxId=@taxId,taxName=@taxName,taxAmount=@taxAmount 
				           ,totalAmount=@totalAmount,paidAmount=@paidAmount,paymentStatus ='P',paymentType=@paymentType,transactionId=@transactionId,
						   bankName=@bankName,bankReferenceNumber=@bankReferenceNumber,updatedBy=@createdBy ,updatedDate=GETDATE()
						   WHERE gymOwnerId=@gymOwnerId AND branchId=@branchId AND bookingId=@bookingId
						IF(@@ROWCOUNT>0)
							BEGIN 
							IF(@paymentStatus !='P')
								 BEGIN
										INSERT INTO Tran_PaymentCycle(bookingId ,userId ,paidAmount ,paidDate  ,transactionId ,bankName
										,bankReferenceNumber  ,paymentStatus,createdBy ,createdDate) 
										VALUES(@bookingId ,@userId ,@paidAmount ,GETDATE()  ,@transactionId ,@bankName
									   ,@bankReferenceNumber ,@paymentCyclesStatus,  @createdBy,GETDATE())
										   IF(@@ROWCOUNT>0)
										   BEGIN
										        SET @bookingId= (SELECT TOP 1 bookingId FROm Tran_Booking ORDER BY bookingDate DESC)
												SET @StatusCode=1;
												SET @Response=CAST(@bookingId AS VARCHAR(50))+' ~ Booked Successfully !!!' 
												COMMIT TRANSACTION
										   END
								END
							ELSE
								 BEGIN
									SET @bookingId= (SELECT TOP 1 bookingId FROm Tran_Booking ORDER BY bookingDate DESC)
									SET @StatusCode=1;
								    SET @Response=CAST(@bookingId AS VARCHAR(50))+' ~ Booked Successfully !!!' 
									COMMIT TRANSACTION
										
								END
							END
						ELSE
                            BEGIN
							SET @StatusCode=0;
							SET @Response='Not Booked !!!'
							ROLLBACK TRANSACTION
			                END
					END
						ELSE
								BEGIN
									SET @StatusCode=0;
									SET @Response='Booking Details Not Found '
									ROLLBACK TRANSACTION
								END
				END
	    ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())

			SELECT ERROR_MESSAGE(),ERROR_LINE()
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranUserFoodTracking]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranUserFoodTracking]
(
@queryType VARCHAR(100),
@userId INT=NULL,
@foodMenuId INT=NULL,
@mealtypeId INT=NULL,
@consumingStatus Char(1)=NULL,
@date Date=NULL,
@bookingId INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
				IF NOT EXISTS(SELECT userId,foodMenuId,date FROM Tran_UserFoodTracking WHERE  userId=@userId AND foodMenuId=@foodMenuId  AND mealTypeId=@mealtypeId
				AND date =@date AND bookingId=@bookingId )
					BEGIN
						INSERT INTO Tran_UserFoodTracking (userId,bookingId,foodMenuId,mealtypeid,consumingStatus,date,createdBy,createdDate) 
						VALUES(@userId,@bookingId,@foodMenuId,@mealtypeid,'Y',@date,@createdBy,GETDATE())
							IF(@@ROWCOUNT>0)
								BEGIN 
									SET @StatusCode=1;
									SET @Response='food Menu Item Is Inserted Successfully !!!' 
									COMMIT TRANSACTION
								END
							
					END
				ELSE
					BEGIN
					    Declare @FoodName NVARCHAR(100);
					    SET @FoodName =	(SELECT Distinct f.foodItemName FROM Tran_UserFoodTracking  AS uf
                        INNER JOIN Mstr_FoodItem AS f on f.foodItemId =uf.foodMenuId  
						WHERE  userId=@userId AND foodMenuId=@foodMenuId AND date =@date AND bookingId=@bookingId)
						SET @StatusCode=0;
						SET @Response=''+@FoodName +' Is Already Exists !!!'
						ROLLBACK TRANSACTION
					END
		   END
					ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranUserWorkOutPlan]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranUserWorkOutPlan]
(	
@queryType VARCHAR(100),
@gymOwnerId INT=NULL,
@branchId INT=NULL,
@bookingId INT=NULL,
@workoutPlanId INT=NULL,
@workoutCatTypeId INT=NULL,
@workoutTypeId INT=NULL,
@day CHAR(2)=NULL,
@fromDate DATE=NULL,
@toDate DATE=NULL,
@csetType INT=0,
@cnoOfReps INT=0,
@cweight INT=0,
@userId INT=NULL,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
			IF NOT EXISTS(SELECT * FROM Tran_UserWorkOutPlan WHERE workoutCatTypeId=@workoutCatTypeId
			 AND workoutTypeId=@workoutTypeId AND day=@day AND fromDate=@fromDate AND toDate=@toDate AND csetType=@csetType AND userId=@userId)
				BEGIN				
					INSERT INTO Tran_UserWorkOutPlan(workoutCatTypeId,workoutTypeId,gymOwnerId,branchId,bookingId,day,
					fromDate,toDate,csetType,cnoOfReps,cweight,userId,createdBy,createdDate)
					VALUES(@workoutCatTypeId,@workoutTypeId,@gymOwnerId,@branchId,@bookingId,@day,
					@fromDate,@toDate,@csetType,@cnoOfReps,@cweight,@userId,@createdBy,GETDATE())

					IF(@@ROWCOUNT>0)
						BEGIN 
						    UPDATE Tran_Booking SET fromDate=@fromDate,toDate=@toDate WHERE branchId=@branchId AND bookingId=@bookingId
							IF(@@ROWCOUNT>0)
						     BEGIN 
								SET @StatusCode=1;
								SET @Response='Workout Plan Is Inserted Successfully !!!' 
								COMMIT TRANSACTION
							END
						END
					ELSE
						BEGIN 
							SET @StatusCode=0;
							SET @Response='Workout Plan Is Not Inserted  !!!' 
							ROLLBACK TRANSACTION
						END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Workout Plan Already Exists !!!'
						ROLLBACK TRANSACTION
					END
			END
		ELSE IF(@queryType='Update')
			BEGIN
				IF EXISTS(SELECT * FROM Tran_UserWorkOutPlan WHERE workoutPlanId=@workoutPlanId)
				BEGIN
					IF NOT EXISTS(SELECT workoutPlanId,userId,gymOwnerId,branchId,bookingId,workoutCatTypeId,workoutTypeId,
							day,fromDate,toDate,csetType,cnoOfReps,cweight FROM Tran_UserWorkOutPlan WHERE userId= @userId 
							AND  bookingId = @bookingId AND branchId=@branchId AND workoutPlanId != @workoutPlanId)
						BEGIN
							UPDATE Tran_UserWorkOutPlan SET gymOwnerId=@gymOwnerId,branchId=@branchId,
							bookingId=@bookingId,workoutCatTypeId=@workoutCatTypeId,workoutTypeId=@workoutTypeId,
							day=@day,fromDate=@fromDate,toDate=@toDate,csetType=@csetType,
							cnoOfReps=@cnoOfReps,cweight=@cweight,userId=@userId,updatedBy=@updatedBy,updatedDate=GETDATE() 
							WHERE workoutPlanId=@workoutPlanId

							IF(@@ROWCOUNT>0)
								BEGIN
									 UPDATE Tran_Booking  SET fromDate=@fromDate,toDate=@toDate WHERE branchId=@branchId AND bookingId=@bookingId
									IF(@@ROWCOUNT>0)
									 BEGIN 
										SET @StatusCode=1;
										SET @Response='Workout Plan Is Updated Successfully !!!' 
										COMMIT TRANSACTION
									END
								END
							ELSE
								BEGIN 
									SET @StatusCode=0;
									SET @Response='Workout Plan Is Not Updated  !!!' 
									ROLLBACK TRANSACTION
								END
						END
					ELSE
						BEGIN
							SET @StatusCode=0;
							SET @Response='Workout Plan Already Exists !!!'
							ROLLBACK TRANSACTION
						END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Workout Plan Does Not Exist !!!'
						ROLLBACK TRANSACTION
					END
			END
				ELSE IF(@queryType='UpdateApproveStatus')
			BEGIN
			IF EXISTS(SELECT * FROM Tran_UserDietPlan WHERE bookingId=@bookingId and userId= @userId )
				BEGIN
						 UPDATE Tran_UserDietPlan  SET approvedBy=@updatedBy WHERE bookingId=@bookingId and userId= @userId
									IF(@@ROWCOUNT>0)
									 BEGIN
										   UPDATE Tran_UserWorkOutPlan  SET approvedBy=@updatedBy WHERE bookingId=@bookingId and userId= @userId
										   IF(@@ROWCOUNT>0)
										   BEGIN
												SET @StatusCode=1;
												SET @Response='User Diet Plan Is Approved Successfully !!!' 
												COMMIT TRANSACTION
											END
									END
									ELSE
									 BEGIN 
										SET @StatusCode=0;
										SET @Response='User Diet Plan Did Not Updated Successfully !!!' 
										COMMIT TRANSACTION
									END
					END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='User Diet Plan Does Not Exist !!!'
						ROLLBACK TRANSACTION
					END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
	
END
GO
/****** Object:  StoredProcedure [dbo].[usp_TranUserWorkoutTracking]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_TranUserWorkoutTracking]
(  
@queryType VARCHAR(100),
@uniqueId INT=NULL,
@bookingId INT,
@userId INT,
@date Date,
@day char(3),
@workoutCatTypeId INT,
@workoutTypeId INT,
@setType INT,
@noOfReps INT,
@weight INT,
@createdBy INT=NULL,
@updatedBy INT=NULL,
@StatusCode INT=NULL OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@queryType='Insert')
			BEGIN
			IF NOT EXISTS(SELECT * FROM Tran_UserWorkoutTracking WHERE workoutCatTypeId=@workoutCatTypeId AND workoutTypeId=@workoutTypeId 
			AND setType=@setType AND noOfReps=@noOfReps AND weight=@weight AND userId=@userId AND date = CAST(@date AS DATE))
				BEGIN	
					INSERT INTO Tran_UserWorkoutTracking(bookingId,userId,date,day,workoutCatTypeId,workoutTypeId,setType,noOfReps,weight,createdBy,createdDate)
					VALUES(@bookingId,@userId,CAST(@date AS DATE),@day,@workoutCatTypeId,@workoutTypeId,@setType,@noOfReps,@weight,@createdBy,GETDATE())
					
					IF(@@ROWCOUNT>0)
						BEGIN 
							SET @StatusCode=1;
							SET @Response='Workout Tracking Is Inserted Successfully !!!' 
							COMMIT TRANSACTION
						END
					ELSE
						BEGIN 
							SET @StatusCode=0;
							SET @Response='Workout Tracking Is Not Inserted  !!!' 
							ROLLBACK TRANSACTION
						END
				END				
			ELSE
				BEGIN
					SET @StatusCode=0;
					SET @Response='Workout Tracking Already Exists !!!'
					ROLLBACK TRANSACTION
				END
			END
		ELSE IF(@queryType='Update')
			BEGIN
			IF EXISTS(SELECT * FROM Tran_UserWorkoutTracking WHERE uniqueId=@uniqueId)
			BEGIN
				IF NOT EXISTS(SELECT uniqueId, userId, bookingId, workoutCatTypeId, workoutTypeId, date, setType, noOfReps, 
							weight FROM Tran_UserWorkoutTracking WHERE userId= @userId AND bookingId = @bookingId AND uniqueId != @uniqueId)
				BEGIN
					UPDATE Tran_UserWorkoutTracking SET date=@date,day=@day, workoutCatTypeId=@workoutCatTypeId, workoutTypeId=@workoutTypeId,
					setType=@setType, noOfReps=@noOfReps, weight=@weight, updatedBy=@updatedBy, updatedDate=GETDATE()
					WHERE userId= @userId AND uniqueId=@uniqueId 
					
					IF(@@ROWCOUNT>0)
					BEGIN
						SET @StatusCode=1;
						SET @Response='Workout Tracking Is Updated Successfully !!!'
						COMMIT TRANSACTION
					END
					ELSE
					BEGIN 
						SET @StatusCode=0;
						SET @Response='Workout Tracking Is Not Updated  !!!' 
						ROLLBACK TRANSACTION
					END
				END
				ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Workout Tracking Already Exists !!!'
						ROLLBACK TRANSACTION
					END					
			END
			ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='Workout Tracking Does Not Exist !!!'
				ROLLBACK TRANSACTION
			END
			END
		ELSE
			BEGIN
				SET @StatusCode=0;
				SET @Response='QueryType '+@QueryType+ ' Is Invalid !!!'
				ROLLBACK TRANSACTION
			END
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			ROLLBACK TRANSACTION
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateTaxId]    Script Date: 27-Jul-23 11:50:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC usp_MstrTax 'insert','','','1','5','1','CGST',0,'','','','1','',''
CREATE PROCEDURE [dbo].[usp_UpdateTaxId]
(
@queryType NVARCHAR(25),
@taxId INT=0,
@uniqueId  INT=0,
@gymOwnerId INT=0,
@branchId INT=0,
@serviceName  NVARCHAR(50)= NULL , 
@taxDescription NVARCHAR(50)= NULL ,
@taxPercentage DECIMAL(18,2)= 0 ,
@effectiveFrom DATE= NULL ,
@effectiveTill DATE = NULL ,
@createdBy INT=0,
@updatedBy INT=0,
@StatusCode INT=0 OUTPUT,
@Response VARCHAR(150)=NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRANSACTION
	
	BEGIN TRY
	    IF(@queryType ='UpdateTaxId')
		    BEGIN
			DECLARE @MAXId INT;
			SET @MAXId = (SELECT ISNULL(MAX(taxId),0)+1 AS 'TaxID' FROM Mstr_Tax WHERE activeStatus='A')
			UPDATE Mstr_Tax SET TaxId =@MAXId  WHERE TaxId='0' AND activeStatus='A'
				IF(@@ROWCOUNT>0)
					BEGIN
						SET @StatusCode=1;
						SET @Response='Tax Details Inserted Successfully !!!'
						COMMIT TRANSACTION
					END
					ELSE
					BEGIN
						SET @StatusCode=0;
						SET @Response='Insert Error !!!'
						ROLLBACK TRANSACTION
					END

					END
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
	END TRY
	BEGIN CATCH 
			SET @StatusCode=0;
			SET @Response=(SELECT ERROR_MESSAGE())
			SELECT @StatusCode AS 'Statuscode',@Response AS 'Response'
			ROLLBACK TRANSACTION
	END CATCH
END


SELECT * FROM Mstr_Tax



GO
