// Create Constraints
CREATE CONSTRAINT IF NOT EXISTS FOR (c:Car) REQUIRE (c.VIN) IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (ch:Characteristics) REQUIRE (ch.Trim, ch.Body, ch.Odometer, ch.Condition, ch.Color, ch.Interior, ch.Transmission) IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Person) REQUIRE (p.id) IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (mh:ManufacturingHouse) REQUIRE (mh.Name) IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (s:Store) REQUIRE (s.id) IS UNIQUE;

// Create Indexes
CREATE INDEX IF NOT EXISTS FOR (c:Car) ON (c.Model);
CREATE INDEX IF NOT EXISTS FOR (ch:Characteristics) ON (ch.Body);
CREATE INDEX IF NOT EXISTS FOR (ch:Characteristics) ON (ch.Condition);
CREATE INDEX IF NOT EXISTS FOR (c:Car) ON (c.ProductionYear);
CREATE INDEX IF NOT EXISTS FOR (s:Store) ON (s.id);
CREATE INDEX IF NOT EXISTS FOR (mh:ManufacturingHouse) ON (mh.Name);

CALL db.awaitIndexes();

// Delete all Nodes and Relationship
CALL apoc.periodic.iterate(
	"MATCH ()-[r]->() RETURN r",
	"DELETE r",
{batchSize:10000, parallel:true});
CALL apoc.periodic.iterate(
	"MATCH (n) RETURN n",
	"DELETE n",
{batchSize:10000, parallel:true});

// Load Data from new_car_prices.csv
// Note: splitted in order to reduce the possibility of deadlocks
//LOAD CSV WITH HEADERS FROM 'file:///new_car_prices.csv' AS row
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///Cars.csv') YIELD map AS row
	WITH row, split(row.saledate, ' ') AS parts
	RETURN row, (parts[3] + '-' + 
		CASE parts[1]
			WHEN 'Jan' THEN '01'
			WHEN 'Feb' THEN '02'
			WHEN 'Mar' THEN '03'
			WHEN 'Apr' THEN '04'
			WHEN 'May' THEN '05'
			WHEN 'Jun' THEN '06'
			WHEN 'Jul' THEN '07'
			WHEN 'Aug' THEN '08'
			WHEN 'Sep' THEN '09'
			WHEN 'Oct' THEN '10'
			WHEN 'Nov' THEN '11'
			WHEN 'Dec' THEN '12'
		END + '-' + parts[2]) AS formattedDate",
    "CREATE (:Car {
		ProductionYear: toInteger(row.year),
		SellingPrice: toFloat(row.sellingprice),
		SellingDate: formattedDate,
		VIN: row.vin,
		Model: row.model,
		MMR: toFloat(row.mmr)
	})",
{batchSize:10000, parallel:true});
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///Characteristics.csv') YIELD map AS row",
    "MERGE (ch:Characteristics {
		Trim: row.trim,
		Body: row.body,
		Odometer: toInteger(row.odometer),
		Condition: toInteger(row.condition),
		Color: row.color,
		Interior: row.interior,
		Transmission: row.transmission
	})
	WITH row, ch, apoc.convert.fromJsonList(row.vin) AS VINList
	MATCH (c:Car)
	WHERE c.VIN IN VINList
	CREATE (c)-[:Has]->(ch)",
{batchSize:10000, parallel:true});
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///ManufacturingHouses.csv') YIELD map AS row",
    "MERGE (mh:ManufacturingHouse {
		Name: row.make,
		Address: ''
	})
	WITH row, mh, apoc.convert.fromJsonList(row.vin) AS VINList
	MATCH (c:Car)
	WHERE c.VIN IN VINList
	CREATE (c)-[:ProducedBy]->(mh)",
{batchSize:10000, parallel:true});
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///Stores.csv') YIELD map AS row",
    "MERGE (s:Store {
		id: row.id,
		Name: row.seller,
		Address: ''
	})
	WITH row, s, apoc.convert.fromJsonList(row.vin) AS VINList
	MATCH (c:Car)
	WHERE c.VIN IN VINList
	CREATE (c)<-[:Sell]-(s)",
{batchSize:10000, parallel:true});
MATCH (mh:ManufacturingHouse), (s:Store)
WHERE EXISTS ((mh)-[]-()-[]-(s))
CREATE (mh)-[:Branch]->(s);

// Load Data from new_clients.csv
//LOAD CSV WITH HEADERS FROM 'file:///new_clients.csv' AS row
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///new_clients2.csv') YIELD map AS row",
    "CREATE (p:Person { id: row.id, FullName: row.FullName, Birthdate: row.Birthdate })
	WITH row, p, apoc.convert.fromJsonList(row.cars) AS CarsList
	MATCH (c:Car)
	WHERE c.VIN IN CarsList
	CREATE (p)-[:Buy]->(c)",
{batchSize:10000, parallel:true});

// Create Employee Relationship
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('file:///Stores.csv') YIELD map AS row
	MATCH (s:Store {id: row.id})
	RETURN s, apoc.convert.fromJsonList(row.workers) AS Workers, datetime({year: 2016}) AS endDate",
    "MATCH (p:Person)
	WHERE toString(p.id) IN Workers
	WITH s, p, endDate, (datetime(p.Birthdate) + duration({years: 18})) AS startDate
	WITH s, p, datetime(startDate + rand()*duration.between(startDate, endDate)) AS start_date
	CREATE (s)<-[:Employee { StartDate: start_date, EndDate: '' }]-(p)",
{batchSize:10000, parallel:true});