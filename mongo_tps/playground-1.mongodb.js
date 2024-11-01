/* global use, db */
// MongoDB Playground
// To disable this template go to Settings | MongoDB | Use Default Template For Playground.
// Make sure you are connected to enable completions and to be able to run a playground.
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.
// The result of the last command run in a playground is shown on the results panel.
// By default the first 20 documents will be returned with a cursor.
// Use 'console.log()' to print to the debug output.
// For more documentation on playgrounds please refer to
// https://www.mongodb.com/docs/mongodb-vscode/playgrounds/

// Select the database to use.
use('mflix');



// Listar el nombre, email, texto y fecha de los
//  comentarios que la película con id (movie_id) 
//  ObjectId("573a1399f29313caabcee886") recibió 
//  entre los años 2014 y 2016 inclusive. Listar
//   ordenados por fecha. Escribir una nueva consulta
//    (modificando la anterior) para responder ¿Cuántos 
//    comentarios recibió?

db.comments.find(
    {
        date: { 
            $gte: ISODate('2014-01-01T00:00:01Z'),
            $lte: ISODate('2016-01-01T00:00:01Z')
        }
    },
    {
        email: 1, text: 1, date: 25 
    })

// Actualizar los valores de los campos texto (text)
// y fecha (date) del comentario cuyo id
//es ObjectId("5b72236520a3277c015b3b73") 
// a "mi mejor comentario" y fecha actual respectivamente.

db.comments.find(
    {
        _id: ObjectId("5b72236520a3277c015b3b73")
    },
)

db.comments.updateOne(
    {
        _id: ObjectId("5b72236520a3277c015b3b73")
    },
    {
        $set : {text: 'mi mejor comentario'}
    }
)

//Actualizar el valor de la contraseña del usuario cuyo email es joel.macdonel@fakegmail.com a "some password". La misma consulta debe poder insertar un nuevo usuario en caso que el usuario no exista. Ejecute la consulta dos veces. ¿Qué operación se realiza en cada caso?  (Hint: usar upserts). 
db.users.updateOne(
    {
        email: 'joel.macdonel@fakegmail.com'
    },
    {
        $set: { password: 'some_password'}
    },
    {
        upsert : true
    }
)

//Remover todos los comentarios realizados por el usuario cuyo email es victor_patel@fakegmail.com durante el año 1980.
db.comments.deleteMany(
    {
        email: 'victor_patel@fakegmail.com',
        date: {
            $gte: ISODate('1990-01-01T00:00:01Z'),
            $lte: ISODate('1990-12-31T00:00:01Z')
        }
    }
)

