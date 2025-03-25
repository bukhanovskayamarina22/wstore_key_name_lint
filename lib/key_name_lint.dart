import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _ExampleLinter();

class _ExampleLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [KeyNameLinter()];
}

/// This linter is intended to be used in applications that use
/// the `wstore` package for state management.
///
/// It ensures that for all computed and
/// `computedFromStore` getters, the `keyName` matches the name
/// of the getter. For example:
///   GlobalErrors get globalError => computedFromStore(
///     store: ErrorsStore(),
///     getValue: (store) => store.globalError,
///     keyName: 'globalError',
///   );
///
class KeyNameLinter extends DartLintRule {
  KeyNameLinter() : super(code: _code);

  static const _code = LintCode(
    // the name of the lint rule (can be used to turn it off)
    name: 'key_name_matches',
    // the problem message that will be displayed
    problemMessage:
        'The keyName of this computed method does not match its name',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // adding the rule to method declarations only
    // (the linter will not work if the function is not a method of a class)
    context.registry.addMethodDeclaration((node) {
      // check if the declaration is a getter
      if (node.isGetter) {
        // getting the String name of the method
        final getterName = node.name.lexeme;
        final body = node.body;
        // checking that the body is an arrow function (=>, and not {})
        if (body is ExpressionFunctionBody) {
          final expression = body.expression;
          // checking that immediately after => a function call occurs
          if (expression is MethodInvocation) {
            // getting the name of the called function
            final methodName = expression.methodName.name;
            if (methodName == 'computed' || methodName == 'computedFromStore') {
              // getting the list of arguments of the invoked method
              // and looking for the argument called 'keyName'
              final keyNameArgument = expression.argumentList.arguments
                  .whereType<NamedExpression>()
                  .firstWhereOrNull((arg) => arg.name.label.name == 'keyName');
              // if such an argument was found
              if (keyNameArgument != null) {
                // getting the value passed
                final keyNameValue = keyNameArgument.expression;
                // if the value of the expression is a String literal
                if (keyNameValue is StringLiteral) {
                  // comparing the keyName's value with the getters' name
                  // if they are different - reporting an error on the getter (on the node)
                  if (keyNameValue.stringValue != getterName) {
                    reporter.atNode(node, code);
                  }
                }
              }
            }
          }
        }
      }
    });
  }
}
