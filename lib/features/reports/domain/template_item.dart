/// Template item model for predefined reports
class TemplateItem {
  final String label;
  final String prompt;

  TemplateItem({required this.label, required this.prompt});

  factory TemplateItem.fromJson(Map<String, dynamic> json) {
    return TemplateItem(
      label: json['label'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'prompt': prompt};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          prompt == other.prompt;

  @override
  int get hashCode => label.hashCode ^ prompt.hashCode;

  @override
  String toString() => 'TemplateItem(label: $label, prompt: $prompt)';
}
