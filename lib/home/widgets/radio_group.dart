import 'package:flutter/material.dart';

class RadioGroup<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?> onChanged;
  final List<Widget> children;

  const RadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return _RadioGroupScope<T>(
      value: value,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _RadioGroupScope<T> extends InheritedWidget {
  const _RadioGroupScope({
    required this.value,
    required this.onChanged,
    required super.child,
  });

  final T? value;
  final ValueChanged<T?> onChanged;

  static _RadioGroupScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(_RadioGroupScope<T> old) {
    return value != old.value || onChanged != old.onChanged;
  }
}

class RadioItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const RadioItem({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scope = _RadioGroupScope.of<T>(context);
    final isSelected = scope?.value == value;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => scope?.onChanged(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              // Custom Radio Button
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey.shade600,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? theme.primaryColor : Colors.transparent,
                    ),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}