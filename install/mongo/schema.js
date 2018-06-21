db.createCollection("logs", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["request_method", "request_endpoint", "request_payload", "request_response", "request_time"],
         properties: {
            user_id: {
               bsonType: "int"
            },  
            token_id: {
               bsonType: "int"
            },
            request_method: {
               bsonType: "string"               
            },
            request_endpoint: {
               bsonType: "string"              
            },
            request_payload: {
              bsonType: "object"       
            },
            request_response: {
              bsonType: "object"       
            },
            request_time: {
              bsonType: "date"
            },
            sinatra_route: {
              bsonType: "string"
            }
         }
      }
   }
});
db.createCollection("user_sessions", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         properties: {
            user_id: {
               bsonType: "int"
            },
            start_time: {
               bsonType: "date"
            },
            end_time: {
               bsonType: "date"
            },
            request_ids: {
               bsonType: "array"              
            }
         }
      }
   }
});
db.logs.createIndex({user_id:1})
db.logs.createIndex({request_time:1})
db.logs.createIndex({sinatra_route:1})
db.user_sessions.createIndex({user_id:1})
use kuadro_log
db.createUser({ user: "kuadro_admin", pwd: "qwkljrhadslkfjadslkfjdsaklfj", roles: [{ role: "readWrite", db: "kuadro_log" }] })
