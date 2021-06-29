import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:graphql_demo_1/models/ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/src/types/models/model_association.dart';
class ModelMutation {

  static String getModelType(ModelFieldTypeEnum val) {
    switch (val) {
      case ModelFieldTypeEnum.string:
        return "String";
      case ModelFieldTypeEnum.int:
        return "int";
      case ModelFieldTypeEnum.model:
        return "ID";
      default:
        return "Error: UnknownType!";
    }
  } 

  static ModelSchema getSchema(ModelType modelType) {
    var modelProvider = ModelProvider.instance;
    return modelProvider.modelSchemas.firstWhere((elem) => 
      modelProvider.getModelTypeByModelName(elem.name) == modelType
    );
  }

  static getFuncParam(String key, ModelFieldTypeEnum fieldType) {
    return "\$$key: ${getModelType(fieldType)}!";
  }
  static getStmtParam(String key) {
    return "$key: \$$key";
  }

  static GraphQLRequest<String> create(Model model) {
    ModelType modelType = model.getInstanceType();
    
    ModelSchema schema = getSchema(modelType);
    print("SCHEME: " + schema.toJson());
    var modelName = schema.name;
    var fieldsMap = schema.fields;
    
    List<String> fieldsList = [];
    List<String> funcParamList = [];
    List<String> statementParamList = [];
    Map<String, dynamic> variables = {};

    if (fieldsMap == null) {
      return null;
    }

    fieldsMap.forEach((field, val) { 
      // DECISION: exclude nested properties?
      if(val.association == null)
        fieldsList.add(field);

      // need to know how to accurately exclude ids since fieldType are strings
      if(val.isRequired && val.name != 'id') {
        funcParamList.add(getFuncParam(field, val.type.fieldType));
        statementParamList.add(getStmtParam(field));
      }

      // Model has a BelongsTo relationship
      if (val.association != null && val.association.associationType == ModelAssociationEnum.BelongsTo){
        funcParamList.add(getFuncParam(val.association.targetName, val.type.fieldType));
        statementParamList.add(getStmtParam(val.association.targetName));
        // TODO: Get child model name
        variables[val.association.targetName] = model.toJson()[field]["id"];
      } else if(model.toJson()[field] != null && val.name != 'id'){
        variables[field] = model.toJson()[field];
      }
    });


    String doc = '''mutation Create$modelName(${funcParamList.join(", ")}) {
        create$modelName(input: {${statementParamList.join(", ")}}) {
          ${fieldsList.join('\n')}
        }
      }
    ''';



    print("create$modelName Doc: " + doc);
    print("create$modelName Var: " + variables.toString()); // id is included but gets overriden by appsync

    return GraphQLRequest<String>(document: doc, variables: variables);
  }

  static GraphQLRequest<String> delete(Model model) {
    ModelSchema schema = getSchema(model.getInstanceType());

    var modelName = schema.name;
    var fieldsMap = schema.fields;

    List<String> fieldsList = [];
    if (fieldsMap != null) {
      fieldsMap.forEach((key, value) { 
        if(value.association == null)
          fieldsList.add(key);
      });
    }
    

    String doc = '''mutation Delete$modelName(\$id: ID!) {
      delete$modelName(input: {id: \$id}) {
        ${fieldsList.join('\n')}
      }
    }
    ''';

    var variables = { "id": model.getId() };

    return GraphQLRequest<String>(document: doc, variables: variables);
  }
}