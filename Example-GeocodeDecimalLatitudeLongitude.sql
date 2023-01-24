/* This example geocodes a point stored in decimal format. */

UPDATE dbo.AddressExample
SET [Geocode] = geography::Point([Lat], [Lng], 4326)