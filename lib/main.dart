import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:graphql_demo_1/ModelMutation.dart';
import 'package:graphql_demo_1/ModelQuery.dart';
import 'package:graphql_demo_1/models/ModelProvider.dart';

import 'amplifyconfiguration.dart';
import 'models/Blog.dart';
import 'dart:convert';

import 'models/Comment.dart';
import 'models/Post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GraphQL Basic Use Case'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    TextEditingController _updateContentTextController;

    List<Blog> _blogs;
    List<Post> _posts;
    List<Comment> _comments;

    String _blogTarget = 'Loading...';
    String _postTarget = 'Loading...';
    String _commentTarget = 'Loading...';

    String _result = '';
    
   @override
    void initState() {
        super.initState();
        _updateContentTextController = TextEditingController();

        _configureAmplify();

    }

    @override
    void dispose() {
      _updateContentTextController.dispose();
      super.dispose();
    }

    void _configureAmplify() async {
        // Add the following line to add API plugin to your app
        Amplify.addPlugin(AmplifyAPI());

        try {
          await Amplify.configure(amplifyconfig);

          _queryBlogs();
          _queryPosts();
          _queryComments();
        } on AmplifyAlreadyConfiguredException {
          print("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
        }
    }

  /*
    *
    * Get/List Queries
    *
  */
  

  Future<Blog> _getBlog(String id) async{
    try {
      var operation = Amplify.API.mutate(request: ModelQuery.get(Blog.classType, id));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';
      Map<String, dynamic> dataJson = json.decode(data);
      Blog blog = Blog.fromJson(dataJson["getBlog"]);
      print("JSON: " + dataJson.toString());
      print("BLOG: " + blog.toString());
      return blog;
    } on ApiException catch(e) {
      print(e.message);
      return null;
    }
  }

  Future<Post> _getPost(String id) async{
    try {
      var operation = Amplify.API.mutate(request: ModelQuery.get(Post.classType, id));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';
      Map<String, dynamic> dataJson = json.decode(data);
      // print("JSON: " + dataJson.toString());
      Post post = Post.fromJson(dataJson["getPost"]);
      // print("POST: " + post.toString());
      return post;
    } on ApiException catch(e) {
      print(e.message);
      return null;
    }
  }

  Future<Comment> _getComment(String id) async{
    try {
      var operation = Amplify.API.mutate(request: ModelQuery.get(Comment.classType, id));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';
      Map<String, dynamic> dataJson = json.decode(data);
      // print("JSON: " + dataJson.toString());
      Comment comment = Comment.fromJson(dataJson["getComment"]);
      // print("Comment: " + Comment.toString());
      return comment;
    } on ApiException catch(e) {
      print(e.message);
      return null;
    }
  }

  void _queryBlogs() async {
    try {
      var operation = Amplify.API.query(request: ModelQuery.list(Blog.classType));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
          data = 'null';

      var dataObj = json.decode(data);
      List<Blog> blogList = List<Blog>.from(dataObj["listBlogs"]["items"].map((i) => Blog.fromJson(i)));


      setState(() {
        _result = data;
        _blogs = blogList;
        _blogTarget = blogList.first.id;
      });
      
      // print('Query Blogs: ' + data);
    } on ApiException catch (e) {
        print('Query Blogs failed: $e');
    }
  }

  void _queryPosts() async {
    try {
      var operation = Amplify.API.query(request: ModelQuery.list(Post.classType));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
          data = 'null';

      var dataObj = json.decode(data);
      List<Post> postList = List<Post>.from(dataObj["listPosts"]["items"].map((i) => Post.fromJson(i)));

      setState(() {
        _result = data;
        _posts = postList;
        _postTarget = postList.first.id;
      });
      
      print('Query Posts: ' + data);
    } on ApiException catch (e) {
        print('Query Posts failed: $e');
    }
  }

  void _queryComments() async {
    try {
      var operation = Amplify.API.query(request: ModelQuery.list(Comment.classType));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
          data = 'null';

      var dataObj = json.decode(data);
      List<Comment> commentList = List<Comment>.from(dataObj["listComments"]["items"].map((i) => Comment.fromJson(i)));

      setState(() {
        _result = data;
        _comments = commentList;
        _commentTarget = commentList.first.id;
      });
      
      print('Query Comments: ' + data);
    } on ApiException catch (e) {
        print('Query Comments failed: $e');
    }
  }

  /*
    *
    * Create Mutations
    *
  */

  void _createBlog() async{
    try {

      Blog blog = Blog(name: _updateContentTextController.text);

      var operation = Amplify.API.mutate(request: ModelMutation.create(blog));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryBlogs();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _createPost() async{
    try {
      Blog blog = await _getBlog(_blogTarget);

      Post post = Post(title: _updateContentTextController.text, blog: blog);      

      var operation = Amplify.API.mutate(request: ModelMutation.create(post));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryPosts();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _createComment() async{
    try {
      Post post = await _getPost(_postTarget);
      
      Comment comment = Comment(content: _updateContentTextController.text, post: post);

      var operation = Amplify.API.mutate(request: ModelMutation.create(comment));
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryComments();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  /*
    *
    * Update Mutations
    *
  */
  Future<GraphQLRequest<String>> pocBlogUpdate(Blog updatedBlog) async {
    Blog oldBlog = await _getBlog(_blogTarget);
    Blog updatedBlog = oldBlog.copyWith(id: oldBlog.getId(), name:  _updateContentTextController.text);

    var modelName = Blog.schema.name;
    var fieldsMap = Blog.schema.fields;
    
    List<String> fieldsList = [];
    List<String> funcParamList = [];
    List<String> statementParamList = [];
    Map<String, dynamic> variables = {};
    
    print(Blog.schema.toJson());

    if (fieldsMap != null) {
      fieldsMap.forEach((key, value) { 
        // DECISION: exclude nested properties?
        if(value.association == null)
          fieldsList.add(key);

        // need to know how to accruately exclude ids since types do not match
        if(value.isRequired) {
          funcParamList.add("\$$key: ${value.name == 'id' ? 'ID' : ModelMutation.getModelType(value.type.fieldType)}!");
          statementParamList.add("$key: \$$key");
        }
      });
    }

    String doc = '''mutation Create$modelName(${funcParamList.join(", ")}) {
        create$modelName(input: {${statementParamList.join(", ")}}) {
          ${fieldsList.join('\n\t')}
        }
      }
    ''';


    fieldsMap.forEach((key, value) {
      if(updatedBlog.toJson()[key] != null)
        variables[key] = updatedBlog.toJson()[key];
    });

    // print("createBlog Doc: " + doc);
    // print("createBlog Var: " + variables.toString()); // id is included but gets overriden by appsync

    return GraphQLRequest<String>(document: doc, variables: variables);
  }

  void _updateBlog() async{
    try {
      Blog updatedBlog = Blog(id: _blogTarget, name: _updateContentTextController.text);
      var req = await pocBlogUpdate(updatedBlog);
      var operation = Amplify.API.mutate(request: req);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryBlogs();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _updatePost() async{
    try {
      String graphQLDocument =
        '''mutation UpdatePost(\$title: String!, \$id:ID!) {
            updatePost(input: {title: \$title, id: \$id}) {
              createdAt
              id
              title
            }
          }''';
      var variables = {
        "title": _updateContentTextController.text,
        "id": _postTarget,
      };

      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryPosts();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _updateComment() async{
    try {
      String graphQLDocument =
        '''mutation UpdateComment(\$content: String!, \$id: ID!) {
            updateComment(input: {content: \$content, id: \$id}) {
              id
              content
              post {
                id
                title
                blog {
                  id
                  name
                }
              }
            }
          }''';
      print("VARIABLES:" + _updateContentTextController.text + ":" + _updateContentTextController.text);
      var variables = {
        "content": _updateContentTextController.text,
        "id": _commentTarget,
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryComments();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  /*
    *
    *  Delete Mutations
    *
  */
  void _deleteBlog() async{
    try {
      String graphQLDocument = '''mutation DeleteBlog(\$id: ID!) {
            deleteBlog(input: {id: \$id}) {
              id
              name
              createdAt
            }
          }''';
      var variables = {
        "id": _blogTarget
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryBlogs();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _deletePost() async{
    try {
      String graphQLDocument =
        '''mutation DeletePost(\$id:ID!) {
            deletePost(input: {id: \$id}) {
              createdAt
              id
              title
            }
          }''';
      var variables = {
        "id": _postTarget,
      };

      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryPosts();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  void _deleteComment() async{
    try {
      String graphQLDocument =
        '''mutation deleteComment(\$id: ID!) {
            deleteComment(input: {id: \$id}) {
              id
              content
              post {
                id
                title
                blog {
                  id
                  name
                }
              }
            }
          }''';
      var variables = {
        "id": _commentTarget,
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data != null ? response.data : response.errors[0].message;

      if(data == null)
        data = 'null';

      setState(() {
        _result = data;
      });

      _queryComments();

      print('Mutation result: ' + data);
    } on ApiException catch (e) {
        print('Mutation failed: $e');
    }
  }

  /*
    *
    *  Template
    *
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView ( child:
        Container (
          margin: const EdgeInsets.all(20),
          child:
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(children: [
                      Text('Target',
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.5,
                        style: TextStyle(
                          color: Colors.black
                        ),
                      ),
                      if(_blogs != null)
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Blog'),
                          value: _blogTarget,
                          items: _blogs.map((Blog value) {
                            return DropdownMenuItem<String>(
                              value: value.id,
                              child: new Text(value.name),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                             String blogName = _blogs.firstWhere((b) => b.id == newValue).name;
                             setState(() {
                              _blogTarget = newValue;
                              _updateContentTextController.text = blogName;
                            });
                          },
                        ),  
                      if(_posts != null)
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Post'),
                          value: _postTarget,
                          items: _posts.map((Post value) {
                            return DropdownMenuItem<String>(
                              value: value.id,
                              child: new Text(value.title),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            String postTarget = _posts.firstWhere((p) => p.id == newValue).title;
                            setState(() {
                              _postTarget = newValue;
                              _updateContentTextController.text = postTarget;
                            });
                          },
                        ),
                      if(_comments != null)
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Comment'),
                          value: _commentTarget,
                          items: _comments.map((Comment value) {
                            return DropdownMenuItem<String>(
                              value: value.id,
                              child: new Text(value.content),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            String commentContent = _comments.firstWhere((c) => c.id == newValue).content;
                             setState(() {
                              _commentTarget = newValue;
                              _updateContentTextController.text = commentContent;
                            });
                          },
                        )   
                    ],),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Column( 
                    children: [
                    Container (
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
                      child: Column(children: [
                        Text('Input',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.5,
                          style: TextStyle(
                            color: Colors.black
                          ),
                        ),
                        TextField(
                            decoration: InputDecoration(labelText: 'Content'),
                            controller: _updateContentTextController,
                          )
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('BLOGS',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10.0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _queryBlogs,
                                child: Text('Get'),
                              ),
                              ElevatedButton(
                                onPressed: _createBlog,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                child: Text('Create'),
                              ),
                              ElevatedButton(
                                onPressed: _updateBlog,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                child: Text('Update'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deleteBlog,
                                child: Text('Delete'),
                              )
                          ],)
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('POSTS',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10.0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _queryPosts,
                                child: Text('Get'),
                              ),
                              ElevatedButton(
                                onPressed: _createPost,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                child: Text('Create'),
                              ),
                              ElevatedButton(
                                onPressed: _updatePost,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                child: Text('Update'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deletePost,
                                child: Text('Delete'),
                              )
                          ],)
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('COMMENTS',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.5,
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10.0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _queryComments,
                                child: Text('Get'),
                              ),
                              ElevatedButton(
                                onPressed: _createComment,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                child: Text('Create'),
                              ),
                              ElevatedButton(
                                onPressed: _updateComment,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                child: Text('Update'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deleteComment,
                                child: Text('Delete'),
                              )
                          ],)
                      ],),
                    ),
                  ],),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(children: [
                          Text(
                            'GraphQL Response:',
                            textAlign: TextAlign.left,
                            style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(5.0)),
                          if (_result != '')
                            Text(JsonEncoder.withIndent('  ').convert(JsonDecoder().convert(_result)),
                              style: new TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.black,
                                ),
                            ),
                      ],)
                   ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
