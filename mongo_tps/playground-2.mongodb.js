

db.restaurants.find(
    {
        grades: {
            $elemMatch: {
                score: {
                    $gte: 70,
                    $lte: 90
                }
            }
        }
    },
    {
        _id:1,
        grades:1
    },
)



db.restaurants.updateOne(
    {
        restaurant_id: '50018608'
    },
    {
        $addToSet: {
            grades: {
                $each:[
                    {
                        "date" : ISODate("2019-10-10T00:00:00Z"),
                        "grade" : "A",
                        "score" : 18
                    },
                    {
                        "date" : ISODate("2020-02-25T00:00:00Z"),
                        "grade" : "A",
                        "score" : 21
                    }
                ]
            }
        }
    }
)