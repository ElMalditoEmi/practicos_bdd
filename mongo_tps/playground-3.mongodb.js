db.theaters.aggregate([
    {
        $group: {
          _id: "$location.address.state",
          count: {
            $sum: 1
          }
        }
    }
])

//2. Cantidad de estados con al menos dos cines (theaters) registrados.

db.theaters.aggregate([
    {
        $group: {
            _id: "$location.address.state",
            count: {
                $sum: 1
            }
        },
    },
    {
        $match: {
            count: {
                $gte: 2
            }
        }
    },
])

//3. Cantidad de películas dirigidas por "Louis Lumière". Se puede responder sin pipeline de agregación, realizar ambas queries.
//sin pipeline

db.movies.find(
    {
        directors: {
            $elemMatch: {
                $eq: "Louis Lumière"
            }
        }
    }
).count()


// cc pipeline forma 1
db.movies.aggregate([
    {
        $match: {
          directors: {
            $in : ["Louis Lumière"]
            }
        }
    },
    {
        $count: 'cuenta'
    }
])

// cc pipleine forma 2

db.movies.aggregate([
    {
        $unwind: {
          path: "$directors",
        }
    },
    {
        $match: {
            directors: {
                $eq: "Louis Lumière"
            }
        }
    },
    {
        $count: 'cuenta'
    }
])


//4.
// Cantidad de películas estrenadas en los años 50 (desde 1950 hasta 1959). Se puede responder sin pipeline de agregación, realizar ambas queries.

db.movies.find(
    {
        year: {
            $gte: 1950,
            $lte: 1959
        }
    }
).count()

// cc pipeline
db.movies.aggregate([
    {
        $match: {
            year: {
                $gte: 1950,
                $lte: 1959
            }
        }
    },
    {
        $count: 'Peliclas de los 50'
    }
])

//5.
// Listar los 10 géneros con mayor cantidad de
// películas (tener en cuenta que las películas pueden tener más de un género).
// Devolver el género y la cantidad de películas. Hint: unwind puede ser de utilidad

db.movies.aggregate([
    {
        $unwind: {
          path: "$genres",
        }
    },
    {
        $group: {
          _id: "$genres",
          count: {
            $sum: 1
          }
        }
    },
    {
        $sort: {
          count: -1
        }
    },
    {
        $limit: 10
    }

]
)


//6.
//Top 10 de usuarios con mayor cantidad de comentarios, mostrando Nombre, Email y Cantidad de Comentarios.}
db.comments.aggregate([
    {
        $group: {
          _id: "$email",
          count: {
            $sum: 1
          }
        }
    },
    {
        $sort: {
          count: -1
        }
    },
    {
        $limit: 10
    },
    {
        $project: {
          "name" : 1,
          "count" : 1,
          "email": 1
        }
    }
])


db.users.aggregate([
    {
        $lookup: {
          from: "comments",
          localField: "email",
          foreignField: "email",
          as: "commented_on"
        }
    },
    {
        $addFields: {
          comments: {$size: "$commented_on"}
        }
    },
    {
        $project: {
          "name": 1,
          "comments" : 1
        }
    },
    {
        $sort: {
          comments: -1
        }
    },
    {
        $limit: 10
    }
])

// Ej 7
db.movies.findOne()

db.movies.aggregate([
    {
        $match : {
            year: {
                $gte: 1980,
                $lte: 1989
            }
        }
    },
    {
        $group: {
            _id: "$year",
            "prom" : {
                $avg : "$imdb.rating"
            },
            "max" : {
                $max : "$imdb.rating"
            },
            "min" : {
                $min : "$imdb.rating"
            }
        }
    },
    {
        $sort: {
            prom : -1
        }
    }
])

// 8. Título, año y cantidad de comentarios de las 10 películas con más comentarios.


db.movies.aggregate([
    {
        $lookup: {
            from: "comments",
            localField: "_id",
            foreignField: "movie_id",
            as: "cmts"
        }   
    },
    {
        $addFields: {
            count_cmts: {$size : "$cmts"}, 
        }
    },
    {
        $sort: {
            count_cmts: -1
        }
    },
    {
        $limit: 10
    },
    {
        $project: {
            "title": 1,
            "year": 1,
            "count_cmts": 1,
        }
    }
    
])



//9. Crear una vista con los 5 géneros con mayor cantidad de comentarios, junto con la cantidad de comentarios.
db.createView(
    "sex",
    "movies",
    [ 
        {
            $lookup: {
                from: "comments",
                localField: "_id",
                foreignField: "movie_id",
                as: "cmts"
            }   
        },
        {
            $addFields: {
                count_cmts: {$size : "$cmts"}, 
            }
        },
        {
            $unwind: {
                path: "$genres",
            }
        },
        { $group: {
            _id: "$genres" ,
            "cmts_on_genre": {
                $sum: "$count_cmts"
            }
        }
        },
        {
            $sort: {
                cmts_on_genre: -1
            }
        },
        {
            $limit: 5
        }
    ]
)

db.movies.findOne()

// 10. Listar los actores (cast) que trabajaron en 2 o más películas dirigidas por "Jules Bass". Devolver el nombre de estos actores junto con la lista de películas (solo título y año) dirigidas por “Jules Bass” en las que trabajaron. 
db.movies.aggregate([
    {
      $match: {
        directors: { $elemMatch: { $eq: "Jules Bass" } },
      },
    },
    {
      $unwind: "$cast",
    },
    {
      $group: {
        _id: "$cast",
        movies: {
          $addToSet: {
            // NOTE: notar que si no agregamos el id y hay 2 peliculas con el
            // mismo nombre, pero distintos directores no lo vamos a detectar porque
            // addToSet es un conjunto => si matchea el titulo y el año no lo agrega.
            _id: "$_id",
  
            title: "$title",
            year: "$year",
          },
        },
      },
    },
    {
      $match: {
        // NOTE: Para que exista el elemento 1 debe
        // exitstir el elemento 0 => movies.length >= 2
        "movies.1": { $exists: true },
      },
    },
    {
      $project: {
        actor_name: "$_id",
        movies: 1,
        _id: 0,
      },
    },
    
  ]);

// 11.Listar los usuarios que realizaron comentarios 
// durante el mismo mes de lanzamiento de la película comentada,
// mostrando Nombre, Email, fecha del comentario, título de
// la película, fecha de lanzamiento. HINT: usar $lookup con 
// multiple condiciones

db.movies.findOne()
db.comments.findOne()

db.comments.aggregate([
    {
        $lookup: {
            from: "movies",
            localField: "movie_id",
            foreignField: "_id",
            let: { commentDate: "$date" },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $and: [
                                { $eq: [{ $month: "$$commentDate" }, { $month: "$released" }] },
                                { $eq: [{ $year: "$$commentDate" }, { $year: "$released" }] }
                            ]
                        }
                    }
                }
            ],
            as: "deaf"
        }
    },
    {
        $unwind: {
          path: "$deaf", 
        }
    },
    {
        $lookup:{
            from:"users",
            localField: "email",
            foreignField: "email",
            as: "kmi"
        }
    },
    {
        $project: {
            email : 1,
            name : 1,
            date : 1,
            "deaf.title": 1,
        }
    }
]);



// 12.Listar el id y nombre de los restaurantes junto con su puntuación máxima, mínima y la suma total. Se puede asumir que el restaurant_id es único.
// a. Resolver con $group y accumulators.

db.restaurants.findOne()

db.restaurants.aggregate([
    {
        $unwind: {
          path: "$grades",
        }
    },
    {
        $group: {
          _id: "$_id",
          suma: {
            $sum: "$grades.score"
          },
          max: {
            $max: "$grades.score"
          },          
          min: {
            $min: "$grades.score"
          },
          name: {
            $first: "$name"
          },
          restaurant_id: {
            $first: "$restaurant_id"
          }
        }
    },
    {
    $project: {
        "restaurant_id": 1,
        "name": 1,
        "max": 1,
        "min": 1,
        "suma": 1,
      }
    }
])

// b.
// Resolver con expresiones sobre arreglos (por ejemplo, $sum) pero sin $group.
db.restaurants.aggregate([
    {
        $addFields: {
          max: {
            $max: "$grades.score"
          },
          min: {
            $min: "$grades.score"
          },
          suma: {
            $sum: "$grades.score"
          }
        }
    },
    {
        $project: {
          "restaurant_id": 1,
          "name": 1,
          "max": 1,
          "min": 1,
          "suma": 1,
        }
    }
])

//c. Resolver como en el punto b) pero usar $reduce para calcular la puntuación total.
db.restaurants.aggregate([
    {
        $addFields: {
          max: {
            $max: "$grades.score"
          },
          min: {
            $min: "$grades.score"
          },
          suma: {
            $reduce:{
                input: "$grades.score",
                initialValue: { suma: 0},
                in: {
                    suma: {
                        $add: ["$$value.suma","$$this"]
                    }
                }
                
            }
          }
        }
    },
    {
        $project: {
          "restaurant_id": 1,
          "name": 1,
          "max": 1,
          "min": 1,
          "suma": 1,
        }
    },
])

//c. pero todo por reduce
db.restaurants.aggregate([
    {
        $addFields: {
            max: {
                $reduce: {
                    input: "$grades.score",
                    initialValue: { max: { $arrayElemAt: ["$grades.score", 0] } },
                    in: {
                        max: { $max: ["$$value.max", "$$this"] }
                    }
                }
            },
            min: {
                $reduce: {
                    input: "$grades.score",
                    initialValue: { min: { $arrayElemAt: ["$grades.score", 0] } },
                    in: {
                        min: { $min: ["$$value.min", "$$this"] }
                    }
                }
            },
            suma: {
                $reduce: {
                    input: "$grades.score",
                    initialValue: { suma: 0 },
                    in: {
                        suma: { $add: ["$$value.suma", "$$this"] }
                    }
                }
            }
        }
    },
    {
        $project: {
            "restaurant_id": 1,
            "name": 1,
            "max": 1,
            "min": 1,
            "suma": 1,
        }
    },
])

// d. con find
db.restaurants.findOne()
db.restaurants.find({},{
        restaurant_id: 1,
        name: 1,
        grade_stats: {
            $reduce: {
                input: "$grades",
                initialValue: {
                    max: -Infinity,
                    min: Infinity,
                    sum: 0
                },
                in: {
                    max: { $max: ["$$value.max", "$$this.score"] },
                    min: { $min: ["$$value.min", "$$this.score"] },
                    sum: { $add: ["$$value.sum", "$$this.score"] }
                }
            }
        }
    }
);

db.restaurants.findOne({},{
        restaurant_id: 1,
        name: 1,
        grade_stats: {
            $reduce: {
                input: "$grades",
                initialValue: {
                    max: { $arrayElemAt: ["$grades.score", 0] },
                    min: { $arrayElemAt: ["$grades.score", 0] },
                    sum: 0
                },
                in: {
                    max: { $max: ["$$value.max", "$$this.score"] },
                    min: { $min: ["$$value.min", "$$this.score"] },
                    sum: { $add: ["$$value.sum", "$$this.score"] }
                }
            }
        }
    }
);


// 13.

db.restaurants.findOne()

db.restaurants.updateMany({}, [

    {
        $set: {
            average_score: {
                $avg: "$grades.score"
            }
        }
    },
    {
        $set: {
            grade: {
                $switch: {
                    branches: [
                        { case: { $gte: ["$average_score", 28] }, then: "C" }, // Para average_score >= 28
                        { case: { $gte: ["$average_score", 14] }, then: "B" }, // Para 14 <= average_score < 28
                        { case: { $gte: ["$average_score", 0] }, then: "A" }, // Para 0 <= average_score < 14
                      ],
                    default: null, // Valor por defecto si no se cumple ninguna condición
                }
            }
        }
    }
])