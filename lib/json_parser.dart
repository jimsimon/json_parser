part of json_tokenizer;

class JsonValidator {
  Queue<Token> _tokens;
  String state = "init";

  JsonValidator._fromTokens(Queue<Token> this._tokens);

  JsonValidator(String json) {
    _tokens = new JsonTokenizer(json)._tokens;
  }

  Token _getNextToken() {
    if (_tokens.isEmpty) {
      return new Token()..type="eof";
    }
    return _tokens.removeFirst();
  }

  isValid() {
    while (true) {
      Token token = _getNextToken();
      switch(state) {
        case "init":
          switch(token.type) {
            case "begin-object":
              state = "entered-object";
              break;
            case "begin-array":
              state = "entered-array";
              break;
            case "value":
              state = "top-level-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "top-level-value":
          switch(token.type) {
            case "eof":
              return true;
            default:
              throwError(token);
          }
          break;
        case "entered-object":
          switch(token.type) {
            case "end-object":
              state = "exited-object";
              break;
//            case "begin-array":
//              state = "in-array";
//              break;
            case "value":
              //TODO only allow strings
              state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-key":
          switch(token.type) {
            case "name-separator":
              state = "object-name-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-name-separator":
          switch(token.type) {
            case "value":
              state = "object-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value":
          switch(token.type) {
            case "end-object":
              state = "exited-object";
              break;
            case "value-separator":
              state = "object-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "object-value-separator":
          switch(token.type) {
            case "value":
              state = "object-key";
              break;
            default:
              throwError(token);
          }
          break;
        case "entered-array":
          switch(token.type) {
            case "end-array":
              return true;
            case "value":
              state = "array-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value":
          switch(token.type) {
            case "end-array":
              return true;
            case "value-separator":
              state = "array-value-separator";
              break;
            default:
              throwError(token);
          }
          break;
        case "array-value-separator":
          switch(token.type) {
            case "value":
              state = "array-value";
              break;
            default:
              throwError(token);
          }
          break;
        case "exited-object":
          switch(token.type) {
            case "eof":
              return true;
            default:
              throwError(token);
          }
          break;
        default:
          throwError(token);
          break;
      }
    }
  }
}

void throwError(Token token) {
  throw new ArgumentError("Unexpected token: ${token.value}");
}