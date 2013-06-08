package Test::CT::Handler::RESTfulAPI;
# VERSION 0.01


1;


__END__


Swagger Type     Description
----------------------------
byte
boolean
int
long
float
double
string
Date             a ISO-8601 Date, which is represented in a String (1970-01-01T00:00:00.000+0000)

my $obj = Test::CT::Handler::RESTfulAPI->new (

    tester => $tester,

    on_post => sub {},
    on_get => sub {},
    on_delete => sub {},
    on_put => sub {},

    models => {

        "Tag": {
            "properties":{
            "id":{
                "type": "long",
                "description": "unique identifier for the tag"
            },
            "name":{
                "type": "string"
            }
            },
            "id":"Tag"
        },
        "Pet":{
            "properties":{
                "tag":{
                    "type":"Tag",
                },
                "id":{
                    "type":"Long"
                },
                "categories":{
                    "type":"List",
                    "description":"categories that the Pet belongs to",
                    "items":{
                        '$ref':"Category"
                    },
                "status":{
                    "type":"String",
                    "description":"pet status in the store",
                    "allowableValues":{
                    "valueType":"LIST",
                    "values":[
                        "available",
                        "pending",
                        "sold"
                    ]
                    }
                },
                "happiness": {
                    "type": "Int",
                    "description": "how happy the Pet appears to be, where 10 is 'extremely happy'",
                    "allowableValues": {
                        "valueType": "RANGE",
                        "min": 1,
                        "max": 10
                    }
                },
            }

        }
    }

);


$obj->setup(
    version => '4.0',
    name => 'Foo application',

    base_path => 'http://petstore.swagger.wordnik.com/api',
);


my $api = $obj->push_api(
    path => "/pet.{format}/{petId}",
    description:"Operations about pets",

    base_path => 'http://petstore.swagger.wordnik.com/api',
);


my $op = $api->push_op(
    method => 'GET',

    notes => 'A longer text field to explain the behavior of the operation.',
    summary => 'summary,  this field should be less than 60 characters',

    parameters => [

        {
            "paramType": "path",
            "name": "petId",
            "description": "ID of pet that needs to be fetched",
            "dataType": "String",
            "required": 1,
            "allowableValues": {
              "max": 10,
              "min": 0,
              "valueType": "RANGE"
            },
            "allowMultiple": 0
          }

    ],

    base_path => 'http://petstore.swagger.wordnik.com/api',
);

$op->execute(
    [ 'param1', 'param2' ]
);

OR

$op->execute(
    { field => 'value', field2 => 'value2' }
);

OR

$op->execute(
    params => {field => 'value', field2 => 'value2'}
);



------
future ?

$op->post_and_check(
    params => {
        field => 'value',
        field2 => 'value2',
        some_datefield => \'ymd'
    },
    check => sub {

    }
);





=pod

    "apiVersion": "4.0",
    "swaggerVersion": "1.0",
    "basePath": "http://api.wordnik.com/v4"

=cut