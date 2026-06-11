class AiAssistantModel {
  final String? reply;
  final bool policyViolation;
  final String? message;

  AiAssistantModel({this.reply, this.policyViolation = false, this.message});

  factory AiAssistantModel.fromJson(Map<String, dynamic> json) {
    return AiAssistantModel(
      reply: json['reply'],
      policyViolation: json['policyViolation'] == true,
      message: json['message'],
    );
  }
}
