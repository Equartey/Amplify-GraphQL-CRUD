import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';

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
    * Get Queries
    *
  */

  void _queryBlogs() async {
    try {
      String graphQLDocument = '''query GetBlogs {
          listBlogs {
            items {
              id
              name
            }
          }
        }''';
      var request = GraphQLRequest<String>(document: graphQLDocument);
      var operation = Amplify.API.query(request: request);
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
      
      print('Query Blogs: ' + data);
    } on ApiException catch (e) {
        print('Query Blogs failed: $e');
    }
  }

  void _queryPosts() async {
    try {
      String graphQLDocument = '''query GetPosts {
          listPosts {
            items {
              id
              title
            }
          }
        }''';
      var request = GraphQLRequest<String>(document: graphQLDocument);
      var operation = Amplify.API.query(request: request);
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
      String graphQLDocument = '''query GetComments {
          listComments {
            items {
              id
              content
            }
          }
        }''';
      var request = GraphQLRequest<String>(document: graphQLDocument);
      var operation = Amplify.API.query(request: request);
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
      String graphQLDocument = '''mutation CreateBlog(\$name: String!) {
            createBlog(input: {name: \$name}) {
              id
              name
              createdAt
            }
          }''';
      var variables = {
        "name": _updateContentTextController.text,
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

  void _createPost() async{
    try {
      String graphQLDocument =
        '''mutation CreatePost(\$title: String!, \$blogId:ID!) {
            createPost(input: {title: \$title, blogID: \$blogId}) {
              createdAt
              id
              title
            }
          }''';
      print("VARIABLES:" + _updateContentTextController.text + ":" + _updateContentTextController.text);
      var variables = {
        "title": _updateContentTextController.text,
        "blogId": _blogTarget,
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

  void _createComment() async{
    try {
      String graphQLDocument =
        '''mutation CreateComment(\$content: String!, \$postId: ID!) {
            createComment(input: {content: \$content, postID: \$postId}) {
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
        "content": _updateContentTextController.text,
        "postId": _postTarget,
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
    * Update Mutations
    *
  */
  void _updateBlog() async{
    try {
      String graphQLDocument = '''mutation UpdateBlog(\$id: ID!, \$name: String!) {
            updateBlog(input: {id: \$id, name: \$name}) {
              id
              name
              createdAt
            }
          }''';
      var variables = {
        "name": _updateContentTextController.text,
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
                  Padding(padding: EdgeInsets.all(15.0)),
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
                    Padding(padding: EdgeInsets.all(15.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Query',
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
                                child: Text('Blog'),
                              ),
                              ElevatedButton(
                                onPressed: _queryPosts,
                                child: Text('Post'),
                              ),
                              ElevatedButton(
                                onPressed: _queryComments,
                                child: Text('Comment'),
                              )
                          ],)
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(15.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('CREATE',
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
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                onPressed: _createBlog,
                                child: Text('Blog'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                onPressed: _createPost,
                                child: Text('Post'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green
                                ),
                                onPressed: _createComment,
                                child: Text('Comment'),
                              )
                          ],)
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(15.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('UPDATE',
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
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                onPressed: _updateBlog,
                                child: Text('Blog'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                onPressed: _updatePost,
                                child: Text('Post'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber
                                ),
                                onPressed: _updateComment,
                                child: Text('Comment'),
                              )
                          ],)
                      ],),
                    ),
                    Padding(padding: EdgeInsets.all(15.0)),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black54)), 
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('DELETE',
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
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deleteBlog,
                                child: Text('Blog'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deletePost,
                                child: Text('Post'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                ),
                                onPressed: _deleteComment,
                                child: Text('Comment'),
                              )
                          ],)
                      ],),
                    ),
                  ],),
                  Padding(padding: EdgeInsets.all(15.0)),
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
