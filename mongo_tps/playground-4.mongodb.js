db.runCommand({
    collMod: "users",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name","email","password"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "debe ser un string y es requerido",
                    maxLength: 30
                },
                email: {
                    bsonType: "string",
                    pattern: "^(.*)@(.*)\\.(.{2,4})$"
                },
                password: {
                    bsonType: "string",
                    minLength: 50,
                }

            }
        }
    },
    validationAction: "error" // Puede ser "error" o "warn"
});

// 2. xd 
db.getCollectionInfos({"name":"users"})
// 3.
db.runCommand({
    collMod: "theaters",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["theaterId","location"],
            properties: {
                theaterId: {
                    bsonType: "int",
                    description: "entero anana",
                },
                location: {
                    bsonType: "object",
                    required: ["address"],
                    properties:
                    {
                        address: {
                            bsonType: "object",
                            required: ["street1", "city", "state","zipcode"],
                            properties: {
                                "street1": { bsonType: "string"},
                                "city": { bsonType: "string"},
                                "state": { bsonType: "string"},
                                "zipcode": { bsonType: "string"},
                            }
                        },
                        geo: {
                            bsonType: "object",
                            properties: {
                                type: {
                                    "enum": ["Point",null]
                                },
                                coordinates:{
                                    bsonType: "array",
                                    items:{
                                        bsonType: "double"
                                    },
                                    maxItems: 2,
                                    minItems: 2
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    validationAction: "error" // Puede ser "error" o "warn"
});

db.getCollectionInfos({"name":"theaters"})

db.theaters.insertOne(
    {
        "theaterId":2,
        "location": {
          "address": {
            "street1": "340 W Market",
            "city": "Bloomington",
            "state": "MN",
            "zipcode": "55425"
          },
          "geo": {
            "type": "Point",
            "coordinates": [
              -93.24565,0.123
            ]
          }
        }
      }
)

db.getCollectionInfos({"name":"theaters"})

// 4.
db.runCommand({
    collMod: "movies",
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["title","year"],
            properties: {
                "title":{
                    bsonType: "string",
                },
                "year":{
                    "minimum": 1900,
                    "maximum": 3000
                },
                "cast": {
                    bsonType: "array",
                    items:{
                        "type": "string"
                    },
                    "uniqueItems": true
                },
                "directors": {
                    bsonType: "array",
                    items:{
                        "type": "string"
                    },
                    "uniqueItems": true
                },
                "countries": {
                    bsonType: "array",
                    items:{
                        "type": "string"
                    },
                    "uniqueItems": true
                },
                "genres": {
                    bsonType: "array",
                    items:{
                        "type": "string"
                    },
                    "uniqueItems": true
                }

            }
        }
    },
    validationAction: "error" // Puede ser "error" o "warn"
});

// PARA IR CHEQUEANDO
db.movies.insertOne(
    {
        "title":  "paquito",
        "year": NumberInt(1999),
        "cast": ["yo","yoCC"]
    }
)


//6. 
//
db.movies.findOne()
db.comments.findOne()