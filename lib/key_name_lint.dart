import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/listener.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _ExampleLinter();

class _ExampleLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [KeyNameLinter()];
}

class KeyNameLinter extends DartLintRule {
  KeyNameLinter() : super(code: _code);

  static const _code = LintCode(
    name: 'key_name_matches',
    problemMessage:
        'The keyName of this computed method does not match its name',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      if (node.isGetter) {
        final getterName = node.name.lexeme;
        final body = node.body;
        if (body is ExpressionFunctionBody) {
          final expression = body.expression;
          if (expression is MethodInvocation) {
            final methodName = expression.methodName.name;
            if (methodName == 'computed' || methodName == 'computedFromStore') {
              final keyNameArgument = expression.argumentList.arguments
                  .whereType<NamedExpression>()
                  .firstWhereOrNull((arg) => arg.name.label.name == 'keyName');
              if (keyNameArgument != null) {
                final keyNameValue = keyNameArgument.expression;
                if (keyNameValue is StringLiteral) {
                  if (keyNameValue.stringValue != getterName) {
                    print(keyNameArgument);
                    print(getterName);
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
