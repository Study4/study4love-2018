truncate table MeterMeasurement
insert MeterMeasurement default values
go
insert MeterMeasurement(MeasurementInkWh) select rand() from MeterMeasurement;
waitfor delay '00:00:01'
go 20

