# DMS_Project-2

Geographic Information System (GIS) Analysis Project
This project involves working with spatial data, utilizing access methods and query executions, and performing optimizations on a PostgreSQL database with the PostGIS extension. The project requires writing SQL queries to retrieve information, such as locations of specific features, distances between points, and areas of interest.
Goal
Creating a Geographic Information System (GIS) Analysis: A project that involves analyzing geographic data such as maps and spatial data. 
Requirements
PostgreSQL with PostGIS extension installed
Data containing spatial information (e.g., points.shp)
Project Setup
Load the spatial data into the PostgreSQL database. Use the shp2pgsql tool to convert the shapefile data into SQL commands, and then execute those commands on the database.
Write and execute SQL queries to perform the following tasks:
Retrieve Locations of specific features
Calculate Distance between points
Calculate Areas of Interest
Optimize the queries to improve execution performance, using indexing.
Example Queries
Retrieve Locations of specific features
sql
SELECT osm_id, name, type, geom
FROM public.points_table
WHERE type = 'traffic_signals'
ORDER BY osm_id DESC
LIMIT 10;

Calculate Distance between points
sql
WITH reference_point AS (
  SELECT geom AS ref_geom
  FROM public.points_table
  WHERE osm_id = 'reference_osm_id'
)
SELECT
  p.osm_id,
  ST_Distance(rp.ref_geom::geography, p.geom::geography) AS distance_meters
FROM public.points_table p, reference_point rp
WHERE p.osm_id <> 'reference_osm_id'
ORDER BY distance_meters ASC;

Calculate Areas of Interest 
sql
SELECT
  p1.osm_id AS reference_point_id,
  p2.osm_id AS nearby_point_id,
  p2.type,
  p2.geom,
  ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters
FROM public.points_table p1, public.points_table p2
WHERE p1.osm_id = '419363225'
  AND ST_DWithin(p1.geom::geography, p2.geom::geography, 500) -- 500 meters
  AND p1.osm_id <> p2.osm_id
  LIMIT 10;



OPTIMIZATION:


These two indexes are designed to optimize query performance on the public.points_table. Indexes help the database to quickly locate specific rows of data without having to scan the entire table.
CREATE INDEX IF NOT EXISTS points_table_type_idx ON public.points_table(type);
This command creates a new index called points_table_type_idx on the public.points_table for the type column. The IF NOT EXISTS clause ensures that the index is created only if it doesn't already exist. This index is useful when you have queries that filter or sort the data based on the type column. The database can use the index to find the relevant rows more efficiently, reducing the time it takes to execute the query.
CREATE INDEX points_table_geom_idx ON public.points_table USING gist(geom);
This command creates a new index called points_table_geom_idx on the public.points_table for the geom column using the GiST (Generalized Search Tree) index method. GiST is a flexible and extensible indexing technique that is particularly well-suited for complex data types like geometries in PostGIS. This index helps speed up spatial queries that involve the geom column, such as finding the nearest points to a given location, checking if points are within a specific area, or calculating the distance between points. Using a GiST index can significantly improve the performance of these types of spatial queries.
By creating these indexes, you help the PostgreSQL database to optimize the query execution involving the type and geom columns, resulting in faster planning time

When the PostgreSQL query planner receives a query, it estimates the cost of different strategies for executing the query and chooses the one with the lowest estimated cost. Creating indexes on columns that are frequently used in query predicates (e.g., filters, joins, or sorts) can help the query planner to reduce the cost of these operations and generate a more efficient query execution plan. This, in turn, reduces the planning time
