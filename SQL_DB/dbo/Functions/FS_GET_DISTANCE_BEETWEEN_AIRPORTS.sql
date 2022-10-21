
/*
see: https://spr.com/how-far-geography-data-types-in-sql-server/
GEOGRAPHY::Point(Latitude, Longitude, SRID)
Latitude = Y-axis degree. Values must be in [-90, 90]
Longitude= X-axis degree. Values must be in [-180, 180]
SRID stands for Spatial Reference Identifier. The most common SRID = 4326

*/
----                     
CREATE FUNCTION [dbo].[FS_GET_DISTANCE_BEETWEEN_AIRPORTS] 
(@orig varchar(max), @dest varchar(max), @unit varchar(max))
--=============================================================
--Created: 25-Jul-2022                    Altered: 26-Jul-2022
--=============================================================
--Gets distance between 2 airports as shown in the example below
/*
 select [dbo].[FS_GET_DISTANCE_BEETWEEN_AIRPORTS] ('KBP','AMS','km') -- = 1826.00 km
*/
--=============================================================
RETURNS  decimal(16,2) -- int
AS
BEGIN   
   DECLARE @orig_latitude  float = 0
          ,@dest_latitude  float = 0  
		  ,@orig_longitude float = 0 
		  ,@dest_longitude float = 0 
		  ,@distance       decimal(10,2)   = 0.0; -- int
   --==========================================================================================================
   --Convert ORIGINAL geo-point (both Latitude and Longtitude in string format like 'N240600' or 'E0494700' to float
   SELECT TOP 1
          @orig_latitude = CASE LEFT(LATITUDE,1)   
                             WHEN 'N' THEN CAST( ('+' + SUBSTRING(LATITUDE,2,2)  + '.' + SUBSTRING(LATITUDE,4,3))  as float)
                             WHEN 'S' THEN CAST( ('+' + SUBSTRING(LATITUDE,2,2)  + '.' + SUBSTRING(LATITUDE,4,3))  as float)
                             ELSE 0.0
                           END 
         ,@orig_longitude = CASE LEFT(LONGITUDE,1) 
                             WHEN 'E' THEN CAST( ('+' + SUBSTRING(LONGITUDE,2,3) + '.' + SUBSTRING(LONGITUDE,5,4)) as float)
                             WHEN 'W' THEN CAST( ('-' + SUBSTRING(LONGITUDE,2,3) + '.' + SUBSTRING(LONGITUDE,5,4)) as float) 
                             ELSE 0.0
                           END 
   FROM  [dbo].[DIM_AIRPORT] WHERE AIRPORT_CODE = @orig 
   --==========================================================================================================
   --Convert DESTINATION geo-point (both Latitude and Longtitude in string format like 'N240600' or 'E0494700' to float
   SELECT TOP 1
          @dest_latitude = CASE LEFT(LATITUDE,1)   
                             WHEN 'N' THEN CAST( ('+' + SUBSTRING(LATITUDE,2,2)  + '.' + SUBSTRING(LATITUDE,4,3)) as float)
                             WHEN 'S' THEN CAST( ('+' + SUBSTRING(LATITUDE,2,2)  + '.' + SUBSTRING(LATITUDE,4,3)) as float)
                             ELSE 0.0
                           END 
         ,@dest_longitude = CASE LEFT(LONGITUDE,1) 
                             WHEN 'E' THEN CAST( ('+' + SUBSTRING(LONGITUDE,2,3) + '.' + SUBSTRING(LONGITUDE,5,4)) as float)
                             WHEN 'W' THEN CAST( ('-' + SUBSTRING(LONGITUDE,2,3) + '.' + SUBSTRING(LONGITUDE,5,4)) as float)
                             ELSE 0.0
                           END 
   FROM  [dbo].[DIM_AIRPORT] WHERE AIRPORT_CODE = @dest 
   --==========================================================================================================
   --Latitude = Y-axis degree. Values must be in [-90, 90] for South abd North accorfingly
   --Longitude= X-axis degree. Values must be in [-180, 180] for West and East accordingly
   --Method STDistance() — calculates distance between 2 point-objects  
   --This distance can be obtained only in case when both point-oblects have the same SRID.
   IF((@orig_latitude >= -90 and @orig_latitude <= 90) and (@dest_latitude >= -180 and @dest_latitude <= 180))
     BEGIN -- most popular Reference = 4326
       DECLARE @orig_geo geography = geography::STGeomFromText('POINT(' + cast(@orig_longitude as varchar(max)) + ' ' + cast(@orig_latitude as varchar(max)) + ')', 4326)
              ,@dest_geo geography = geography::STGeomFromText('POINT(' + cast(@dest_longitude as varchar(max)) + ' ' + cast(@dest_latitude as varchar(max)) + ')', 4326);
       SET @distance = case 
                         when @unit = 'm'    then cast(@orig_geo.STDistance(@dest_geo)          as int)
                         when @unit = 'km'   then cast(@orig_geo.STDistance(@dest_geo)/1000     as int)
                         when @unit = 'mile' then cast(@orig_geo.STDistance(@dest_geo)/1609.344 as int)
                         else NULL
                        end;
     END

   --Return result to the caller
   RETURN @distance 

END



