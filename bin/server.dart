import 'dart:convert' show json, jsonDecode, jsonEncode, utf8;
import 'dart:io'; // for server creation

import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  var port = 8085;
  var server = await HttpServer.bind('localhost', port);

  var db = Db(
      'mongodb+srv://salman:1234@uetroute.4hfzd.mongodb.net/routeapp?retryWrites=true&w=majority');
  // var db = Db('mongodb://localhost:27017/routeapp');
  // var db = Db('mongodb+srv://salman:1234@uetroute.4hfzd.mongodb.net/routeapp');

  try {
    await db.open();
  } catch (e) {
    print('failed ${e.toString()}');
  }
  print('connected to database');

  server.listen((HttpRequest request) async {
    //print on server side which route is called
    print(request.uri.path);

    // defining routes
    switch (request.uri.path) {
      case '/':
        request.response
          ..write('Hello, World')
          ..close();
        break;
      case '/buses':
        DbCollection busesColl = db.collection('buses');
        // handle get request
        if (request.method == 'GET') {
          //TODO : handle null issue
          var col = await busesColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          print('post bus');
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await busesColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
          // var content = await request.transform(Utf8Decoder()).join();
          // var data = json.decode(content);
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          print('put bus');
          print(request.toString());
          var id = (request.uri.queryParameters['id']);
          // Future<String> content = utf8.decodeStream(request);
          // // var content = await request.transform(Utf8Decoder()).join();
          // var document = json.decode(content);
          var itemToReplace = await busesColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          print(itemToReplace);
          await (utf8.decodeStream(request)).then((value) async {
            print(value);
            var document = json.decode(value);
            print('putting');
            print(document);
            if (itemToReplace == null) {
              print('insert');
              await busesColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              print('update');
              await busesColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
          // var itemToReplace = await coll.findOne(where.eq('id', id));
          // if (itemToReplace == null) {
          //   await coll.insertOne(document);
          // } else {
          //   await coll.update(itemToReplace, document);
          // }
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await busesColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await busesColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await busesColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await busesColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await busesColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      case '/drivers':
        var driversColl = db.collection('drivers');
        // handle get request
        if (request.method == 'GET') {
          var col = await driversColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await driversColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          // Future<String> content = utf8.decodeStream(request);
          // // var content = await request.transform(Utf8Decoder()).join();
          // var document = json.decode(content);
          var itemToReplace = await driversColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await driversColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await driversColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await driversColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await driversColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await driversColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await driversColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await driversColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      case '/admins':
        DbCollection adminsColl = db.collection('admins');
        // handle get request
        if (request.method == 'GET') {
          var col = await adminsColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await adminsColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          // Future<String> content = utf8.decodeStream(request);
          // // var content = await request.transform(Utf8Decoder()).join();
          // var document = json.decode(content);
          var itemToReplace = await adminsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await adminsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await adminsColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await adminsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await adminsColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await adminsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await adminsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await adminsColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      case '/members':
        DbCollection membersColl = db.collection('members');
        // handle get request
        if (request.method == 'GET') {
          var col = await membersColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await membersColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          // Future<String> content = utf8.decodeStream(request);
          // // var content = await request.transform(Utf8Decoder()).join();
          // var document = json.decode(content);
          var itemToReplace = await membersColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await membersColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await membersColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await membersColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await membersColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await membersColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await membersColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await membersColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      case '/stops':
        DbCollection stopsColl = db.collection('stops');
        // handle get request
        if (request.method == 'GET') {
          var col = await stopsColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await stopsColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          var itemToReplace = await stopsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await stopsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await stopsColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await stopsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await stopsColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await stopsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await stopsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await stopsColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;

      case '/tracking':
        DbCollection trackingsColl = db.collection('tracking');
        // handle get request
        if (request.method == 'GET') {
          var col = await trackingsColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await trackingsColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          // Future<String> content = utf8.decodeStream(request);
          // // var content = await request.transform(Utf8Decoder()).join();
          // var document = json.decode(content);
          var itemToReplace = await trackingsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await trackingsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await trackingsColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await trackingsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await trackingsColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await trackingsColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await trackingsColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await trackingsColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      case '/tracks':
        DbCollection tracksColl = db.collection('tracks');
        // handle get request
        if (request.method == 'GET') {
          var col = await tracksColl.find().toList();
          if (col == null) {
            request.response.statusCode = 404; // not found
          } else {
            request.response.write(jsonEncode(col));
          }
        }
        //handle post request
        else if (request.method == 'POST') {
          // to convert data from req
          await (utf8.decodeStream(request)).then((value) async {
            var data = json.decode(value);
            await tracksColl.insertOne(data).then((value) {
              if (value.isSuccess) {
                request.response.statusCode = 201;
              } else {
                request.response.statusCode = 400;
              }
            });
          });
        }
        // handle put request(replace)
        else if (request.method == 'PUT') {
          var id = (request.uri.queryParameters['id']);
          var itemToReplace = await tracksColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToReplace == null) {
              await tracksColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            } else {
              await tracksColl
                  .update(itemToReplace, document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 400);
            }
          });
        }
        //handle delete request
        else if (request.method == 'DELETE') {
          var id = (request.uri.queryParameters['id']);
          var itemToDelete = await tracksColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          if (itemToDelete != null) {
            // to prevent from deleting all records
            await tracksColl
                .remove(itemToDelete)
                .then((value) => request.response.statusCode = 200)
                .onError(
                    (error, stackTrace) => request.response.statusCode = 404);
          } else {
            //item not found
            request.response.statusCode = 404;
          }
        }
        //handle patch request
        else if (request.method == 'PATCH') {
          var id = (request.uri.queryParameters['id']);
          var itemToPatch = await tracksColl
              .findOne(where.eq('_id', ObjectId.fromHexString(id)));
          await (utf8.decodeStream(request)).then((value) async {
            var document = json.decode(value);
            if (itemToPatch == null) {
              await tracksColl
                  .insertOne(document)
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            } else {
              await tracksColl
                  .update(itemToPatch, {r'$set': document})
                  .then((value) => request.response.statusCode = 200)
                  .onError(
                      (error, stackTrace) => request.response.statusCode = 404);
            }
          });
        }
        await request.response.close();
        break;
      default:
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('not found');
      // await request.response.close();
    }
  });

  print('server listening at http:localhost:$port');
}
