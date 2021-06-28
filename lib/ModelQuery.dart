import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:graphql_demo_1/models/ModelProvider.dart';

class ModelQuery {

  static ModelSchema getSchema(ModelType modelType) {
      var modelProvider = ModelProvider.instance;
      return modelProvider.modelSchemas.firstWhere((elem) => 
        modelProvider.getModelTypeByModelName(elem.name) == modelType
      );
    }

  static GraphQLRequest<String> get<T extends Model>(ModelType<T> modelType, String id) {
    ModelSchema schema = getSchema(modelType);

    var modelName = schema.name;
    var fieldsMap = schema.fields;

    List<String> fieldsList = [];
    if (fieldsMap != null) {
      fieldsMap.forEach((key, value) { 
        if(value.association == null)
          fieldsList.add(key);
      });
    }
    

    String doc = '''query Get$modelName(\$id: ID!) {
      get$modelName(id: \$id) {
        ${fieldsList.join('\n')}
      }
    }
    ''';

    var variables = { "id": id };

    // print(doc);
    // print(variables);
    return GraphQLRequest<String>(document: doc, variables: variables);
  }

  static GraphQLRequest<String> list<T extends Model>(ModelType<T> modelType) {
    ModelSchema schema = getSchema(modelType);

    var modelName = schema.pluralName;
    var fieldsMap = schema.fields;

    List<String> fieldsList = [];
    if (fieldsMap != null) {
      fieldsMap.forEach((key, value) { 
        if(value.association == null)
          fieldsList.add(key);
      });
    }

    String doc = '''query Query$modelName {
      list$modelName {
        items {
          ${fieldsList.join('\n')}
        }
      }
    }
    ''';

    // print(doc);
    return GraphQLRequest<String>(document: doc);
  }
}